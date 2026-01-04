dofile_once( "data/scripts/lib/utilities.lua" )
local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "ProjectileComponent" )
if not proj_comp then return end
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
local x, y = EntityGetTransform( entity_id )

local function do_shot( vict_x, vict_y )
	local offset_x, offset_y = vec_normalize( x - vict_x, y - vict_y )
	offset_x, offset_y = vec_mult( offset_x, offset_y, 4 )
	vict_x, vict_y = vec_add( vict_x , vict_y, offset_x, offset_y )
	EntityApplyTransform( entity_id, vict_x, vict_y )
	GamePlaySound( "data/audio/Desktop/projectiles.bank", "projectiles/bullet_sniper_enemy/create", x, y )
end

if not IsPlayer( shooter_id ) then
	local aai_comp = EntityGetFirstComponent( shooter_id, "AnimalAIComponent" )
	if not aai_comp then return end
	local vict_id = ComponentGetValue2( aai_comp, "mGreatestThreat" )
	if not EntityGetIsAlive( vict_id ) then
		vict_id = ComponentGetValue2( aai_comp, "mGreatestPrey" )
	end
	local vict_x, vict_y = EntityGetFirstHitboxCenter( vict_id )
	local found_obs, obs_x, obs_y = RaytraceSurfaces( x, y, vict_x, vict_y )
	if not found_obs or get_distance2( obs_x, obs_y, vict_x, vict_y ) <= 100 then
		do_shot( vict_x, vict_y )
	end
	return
end

local function check_shot( vict_id, mx, my )
	local hitbox_comps = EntityGetComponent( vict_id, "HitboxComponent" )
	if hitbox_comps then
		local vict_x, vict_y = EntityGetFirstHitboxCenter( vict_id )
		local err_x, err_y = mx - vict_x, my - vict_y
		for _, hitbox_comp in ipairs( hitbox_comps ) do
			local min_x = ComponentGetValue2( hitbox_comp, "aabb_min_x" )
			local min_y = ComponentGetValue2( hitbox_comp, "aabb_min_y" )
			local max_x = ComponentGetValue2( hitbox_comp, "aabb_max_x" )
			local max_y = ComponentGetValue2( hitbox_comp, "aabb_max_y" )
			if min_x < err_x and err_x < max_x and min_y < err_y and err_y < max_y then
				return true, vict_x, vict_y
			end
		end
	end

	local pbody_comp = EntityGetFirstComponent( vict_id, "PhysicsBody2Component" ) or EntityGetFirstComponent( vict_id, "PhysicsBodyComponent")
	if pbody_comp then
		local box2d_x, box2d_y = PhysicsComponentGetTransform( pbody_comp )
		local vict_x, vict_y = PhysicsPosToGamePos( box2d_x, box2d_y )
		if get_distance2( mx, my, vict_x, vict_y ) <= 400 then
			return true, vict_x, vict_y
		end
	end

	return false
end

local function try_shoot( vict_id, shooter_herd_id, mx, my )
	if not EntityGetComponent( vict_id, "DamageModelComponent" ) then
		return false
	end
	if shooter_herd_id then
		local vict_genome_comp = EntityGetFirstComponent( vict_id, "GenomeDataComponent" )
		if vict_genome_comp and ComponentGetValue2( vict_genome_comp, "herd_id" ) == shooter_herd_id then
			return false
		end
	end
	local can_shoot, vict_x, vict_y = check_shot( vict_id, mx, my )
	if can_shoot then
		do_shot( vict_x, vict_y )
		return true
	end
	return false
end

local ctrl_comp = EntityGetFirstComponent( shooter_id, "ControlsComponent" )
if not ctrl_comp then return end
local mx, my = ComponentGetValue2( ctrl_comp, "mMousePosition" )
local found_obs, obs_x, obs_y = RaytraceSurfaces( x, y, mx, my )
if found_obs and obs_x and obs_y and get_distance2( obs_x, obs_y, mx, my ) > 100 then
	return
end
local shooter_genome_comp = EntityGetFirstComponent( shooter_id, "GenomeDataComponent" )
local shooter_herd_id
if shooter_genome_comp then
	shooter_herd_id = ComponentGetValue2( shooter_genome_comp, "herd_id" )
end
local closest = EntityGetClosestWithTag( mx, my, "hittable" )
if closest ~= 0 and try_shoot( closest, shooter_herd_id, mx, my ) then
	return
end
for _, vict_id in ipairs( EntityGetInRadiusWithTag( mx, my, 100, "hittable" ) ) do
	if try_shoot( vict_id, shooter_herd_id, mx, my ) then
		return
	end
end