dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )
dofile_once( "__MOD_LIBS__stream.lua" )

local entity_id = GetUpdatedEntityID()
local pbody_id = read_var( entity_id, "__ACTION_ID___pbody_id", "value_int" )
if not pbody_id then return end

local pbody_x, pbody_y, pbody_rot, pbody_vx, pbody_vy = PhysicsBodyIDGetTransform( pbody_id )
if not pbody_x then
	if EntityHasTag( entity_id, "pbody2_sync" ) then
		local pbody_entity = ( EntityGetAllChildren( entity_id, "pbody_sync" ) or {} )[1]
		if not is_valid_entity( pbody_entity ) then
			EntityKill( entity_id )
			return
		end
		pbody_id = stream( EntityGetComponent( pbody_entity, "PhysicsBody2Component" ) )
		.filter( function( c )
			return ComponentGetValue2( c, "update_entity_transform" )
				and ComponentGetValue2( c, "mInitialized" )
				and not ComponentGetValue2( c, "is_static" )
		end )
		.flatmap( function( c )
			local ps = {}
			for _, p in ipairs( PhysicsBodyIDGetFromEntity( pbody_entity, c ) ) do
				table.insert( ps, { e, get_distance2( x, y, PhysicsBodyIDGetTransform( p ) ) } )
			end
			return ps
		end )
		.min( function( pair1, pair2 ) return pair1[2] < pair2[2] end )
		pbody_x, pbody_y, pbody_rot, pbody_vx, pbody_vy = PhysicsBodyIDGetTransform( pbody_id )
	else
		local x, y = EntityGetTransform( entity_id )
		pbody_id = stream( PhysicsBodyIDQueryBodies( x + 1.5, y + 1.5, x - 1.5, y - 1.5 ) )
			.map( function( pb ) return { pb, get_distance2( x, y, PhysicsBodyIDGetTransform( pb ) ) } end )
			.min( function( pair1, pair2 ) return pair1[2] < pair2[2] end )
		pbody_x, pbody_y, pbody_rot, pbody_vx, pbody_vy = PhysicsBodyIDGetTransform( pbody_id )
	end

	if not pbody_x then
		EntityKill( entity_id )
		return
	end
	ComponentSetValue2( get_variable_storage_component( entity_id, "__ACTION_ID___pbody_id" ), "value_int", pbody_id )
end


local pbody_last_vx_comp = get_variable_storage_component( entity_id, "pbody_last_vx" )
local pbody_last_vy_comp = get_variable_storage_component( entity_id, "pbody_last_vy" )
local pbody_last_vx = ComponentGetValue2( pbody_last_vx_comp, "value_float" )
local pbody_last_vy = ComponentGetValue2( pbody_last_vy_comp, "value_float" )
local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )

local vx, vy = GameVecToPhysicsVec( ComponentGetValue2( vel_comp, "mVelocity" ) )
local new_vx, new_vy = vec_add( vx, vy, vec_sub( pbody_vx, pbody_vy, pbody_last_vx, pbody_last_vy ) )

ComponentSetValue2( vel_comp, "mVelocity", PhysicsVecToGameVec( new_vx, new_vy ) )
PhysicsBodyIDSetTransform( pbody_id, pbody_x, pbody_y, pbody_rot, new_vx, new_vy )

ComponentSetValue2( pbody_last_vx_comp, "value_float", new_vx )
ComponentSetValue2( pbody_last_vy_comp, "value_float", new_vy )

local proj_x, proj_y = EntityGetTransform( entity_id )

local proj_last_x_comp = get_variable_storage_component( entity_id, "proj_last_x" )
local proj_last_y_comp = get_variable_storage_component( entity_id, "proj_last_y" )
local proj_last_x = ComponentGetValue2( proj_last_x_comp, "value_float" ) or proj_x
local proj_last_y = ComponentGetValue2( proj_last_y_comp, "value_float" ) or proj_y

pbody_x, pbody_y = PhysicsPosToGamePos( pbody_x, pbody_y )
local new_x, new_y = vec_add( pbody_x, pbody_y, vec_sub( proj_x, proj_y, proj_last_x, proj_last_y ) )

PhysicsBodyIDSetTransform( pbody_id, GamePosToPhysicsPos( new_x, new_y ) )
local parent_id = EntityGetParent( entity_id )
local proj_new_x, proj_new_y
if is_valid_entity( parent_id ) then
	proj_new_x, proj_new_y = EntityGetTransform( parent_id )
else
	proj_new_x, proj_new_y = PhysicsPosToGamePos( PhysicsBodyIDGetWorldCenter( pbody_id ) )
end
EntitySetTransform( entity_id, proj_new_x, proj_new_y )
-- EntityApplyTransform( entity_id, proj_new_x, proj_new_y )

ComponentSetValue2( proj_last_x_comp, "value_float", proj_new_x )
ComponentSetValue2( proj_last_y_comp, "value_float", proj_new_y )

-- This will snap physics pos to entity pos
-- which is not what we want because the physics pos of a pbody is on its corner
-- EntityApplyTransform( entity_id, x, y )