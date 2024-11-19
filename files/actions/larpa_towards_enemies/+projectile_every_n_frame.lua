-- n = 10
dofile_once("data/scripts/lib/utilities.lua")

local entity_id = EntityGetRootEntity( GetUpdatedEntityID() )
local x, y = EntityGetTransform( entity_id )

local proj_file_comp = get_variable_storage_component( entity_id, "projectile_file" )
if not proj_file_comp then return end
local projectile_file = ComponentGetValue2( proj_file_comp, "value_string" )

local target = EntityGetClosestWithTag( x, y, "homing_target" )
if target == 0 then return end
local tx, ty = EntityGetTransform( target )
local angle = math.atan2( ty - y, tx - x )
local speed = 1000
local vx = math.cos( angle ) * speed
local vy = math.sin( angle ) * speed
local copy_id = shoot_projectile_from_projectile( entity_id, projectile_file, x, y, vx, vy )
EntityAddTag( copy_id, "projectile_cloned" )