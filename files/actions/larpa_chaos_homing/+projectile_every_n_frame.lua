-- n = 10
dofile_once("data/scripts/lib/utilities.lua")

local entity_id = EntityGetRootEntity( GetUpdatedEntityID() )
local x, y = EntityGetTransform( entity_id )

local proj_file_comp = get_variable_storage_component( entity_id, "projectile_file" )
if not proj_file_comp then return end
local projectile_file = ComponentGetValue2( proj_file_comp, "value_string" )

SetRandomSeed( GameGetFrameNum() + GetUpdatedComponentID(), x + y + entity_id )
local angle = math.rad( Random( 0, 359 ) )
local speed = 800
local vx = math.cos( angle ) * speed
local vy = math.sin( angle ) * speed
local copy_id = shoot_projectile_from_projectile( entity_id, projectile_file, x, y, vx, vy )
EntityAddTag( copy_id, "projectile_cloned" )
-- same as vanilla HOMING spell
EntityAddComponent2( copy_id, "HomingComponent", {
	homing_targeting_coeff = 130.0,
	homing_velocity_multiplier = 0.86,
	max_turn_rate = 0.3, -- except this
} )