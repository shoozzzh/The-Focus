dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_LIBS__stream.lua" )
dofile_once( "__MOD_ACTION_UTILS__proj_cfg_utils.lua" )
dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
local x_phy, y_phy = GamePosToPhysicsPos( x, y )
local radius = 20
local entities_in_range = EntityGetInRadius( x, y, radius )

local function not_projectile( e )
	return not EntityHasTag( e, "projectile" ) or EntityHasTag( e, "projectile_not" )
end

-- Plan A
local function try_pbody_projectilize()
	local object_id = stream( entities_in_range )
		.filter( function( e ) return EntityGetFirstComponent( e, "PhysicsBodyComponent" ) end )
		.filter( not_projectile )
		.map( function( e ) local ex, ey = EntityGetTransform( e ) return { e, get_distance2( x, y, ex, ey ) } end )
		.min( function( pair1, pair2 ) return pair1[2] < pair2[2] end )
	if not object_id then
		return nil
	end
	return object_id[1]
end

local function create_sync_proj_for( pbody_id, init_x, init_y )
	local proj_id = EntityLoad( "__THIS_FOLDER__pbody_sync_projectile.xml", init_x, init_y )
	EntityAddComponent2( proj_id, "VariableStorageComponent", {
		_tags = "enabled_in_world",
		name = "__ACTION_ID___pbody_id",
		value_int = pbody_id,
	} )
	return proj_id
end

-- Plan B
local function try_pbody2_sync()
	local pbody_id = stream( entities_in_range )
		.filter( function( e ) return EntityGetFirstComponent( e, "PhysicsBody2Component" ) end )
		.filter( not_projectile )
		.flatmap( function( e )
			local result = {}
			for _, c in ipairs( EntityGetComponent( e, "PhysicsBody2Component" ) or {} ) do
				table.insert( result, { e, c } )
			end
			return result
		end )
		.filter( function( pair )
			local c = pair[2]
			return ComponentGetValue2( c, "update_entity_transform" )
				and ComponentGetValue2( c, "mInitialized" )
				and not ComponentGetValue2( c, "is_static" )
		end )
		.flatmap( function( pair )
			local e, c = pair[1], pair[2]
			local result = {}
			for _, p in ipairs( PhysicsBodyIDGetFromEntity( e, c ) ) do
				table.insert( result, { e, p, get_distance2( x, y, PhysicsBodyIDGetTransform( p ) ) } )
			end
			return result
		end )
		.min( function( pair1, pair2 ) return pair1[3] < pair2[3] end )
	if not pbody_id then
		return nil
	end
	local sync_proj = create_sync_proj_for( pbody_id[2], EntityGetTransform( pbody_id[1] ) )
	EntityAddTag( pbody_id[1], "pbody_sync" )
	EntityAddTag( sync_proj, "sync_pbody2" )
	EntityAddChild( sync_proj, pbody_id[1] )
	return sync_proj
end
-- Plan C
local function try_no_entity_pbody_sync()
	local radius_ = radius * 0.707 -- sqrt( 2 ) / 2
	local pbodies_of_entities = stream( entities_in_range )
		.flatmap( PhysicsBodyIDGetFromEntity )
		.toarray()
	local pbody_id = stream( PhysicsBodyIDQueryBodies( x - radius_, y - radius_, x + radius_, y + radius_ ) )
		.filter( function( p )
			return stream( pbodies_of_entities ).nonematch( function( ep ) return ep == p end )
		end )
		.map( function( pb ) return { pb, get_distance2( x_phy, y_phy, PhysicsBodyIDGetTransform( pb ) ) } end )
		.min( function( pair1, pair2 ) return pair1[2] < pair2[2] end )
	if not pbody_id then
		return nil
	end
	return create_sync_proj_for( pbody_id[1], PhysicsPosToGamePos( PhysicsBodyIDGetWorldCenter( pbody_id[1] ) ) )
end

local proj_to_be_id = try_pbody_projectilize() or try_pbody2_sync() or try_no_entity_pbody_sync()
if not proj_to_be_id then return end

local old_comp_tag = "__ACTION_ID___old_comp"
for _, comp in ipairs( EntityGetAllComponents( proj_to_be_id ) ) do
	ComponentAddTag( comp, old_comp_tag )
end

local ptb_vel_comp = EntityGetFirstComponent( proj_to_be_id, "VelocityComponent" )
if ptb_vel_comp then
	ComponentSetValue2( ptb_vel_comp, "affect_physics_bodies", true )
else
	EntityAddComponent2( proj_to_be_id, "VelocityComponent", {
		gravity_y = 0,
		mass = 0.05,
		affect_physics_bodies = true,
	} )
end

local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local who_shot = ComponentGetValue2( proj_comp, "mWhoShot" )
local herd_id = get_herd_id( who_shot )
local ptb_proj_comp = EntityGetFirstComponent( proj_to_be_id, "ProjectileComponent" )
if ptb_proj_comp then
	ComponentSetValue2( ptb_proj_comp, "mWhoShot", who_shot )
	ComponentSetValue2( ptb_proj_comp, "mShooterHerdId", herd_id)
else
	EntityAddComponent2( proj_to_be_id, "ProjectileComponent", {
		collide_with_world = false,
		penetrate_entities = true,
		damage = 0,
		mWhoShot = who_shot,
		mShooterHerdId = herd_id,
	} )
end
local ptb_x , ptb_y  = EntityGetTransform( proj_to_be_id )
local ptb_vx, ptb_vy = GameGetVelocityCompVelocity( entity_id )
GameShootProjectile( who_shot, ptb_x, ptb_y, ptb_x + ptb_vx, ptb_y + ptb_vy, proj_to_be_id, false )

local proj_cfg = read_proj_cfg( proj_comp )
apply_proj_cfg( proj_cfg, proj_to_be_id )

if EntityGetFirstComponent( proj_to_be_id, "PhysicsBodyComponent" )
	or EntityGetFirstComponent( proj_to_be_id, "ItemComponent" ) then
	for _, comp in ipairs( EntityGetAllComponents( proj_to_be_id ) ) do
		if not ComponentHasTag( comp, old_comp_tag ) and ComponentGetIsEnabled( comp ) then
			ComponentAddTag( comp, "enabled_in_world" )
		end
	end
end

EntityAddTag( proj_to_be_id, "projectile" )
EntityRemoveTag( proj_to_be_id, "projectile_not" )