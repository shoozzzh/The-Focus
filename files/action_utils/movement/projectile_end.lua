dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local shooter_id = ComponentGetValue2( EntityGetFirstComponent( entity_id, "ProjectileComponent" ), "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end

local mv_child_id = ( EntityGetAllChildren( shooter_id, "___movement_shooter_child" ) or {} )[1]
if not EntityGetIsAlive( mv_child_id ) then return end
if entity_id ~= read_var( mv_child_id, "___current_movement", "value_int" ) then return end

local transform_comp = EntityGetFirstComponentIncludingDisabled( mv_child_id, "AttachToEntityComponent" )
local _, _, scale_x, scale_y, rotation = ComponentGetValue2( transform_comp, "Transform" )
local x, y = EntityGetTransform( entity_id )
EntitySetTransform( shooter_id, x, y, rotation, scale_x, scale_y )

shoot_projectile( shooter_id, "__MOD_ACTION_UTILS__teleportation_to_free_space.xml", x, y, 0, 0, false )

local hit_tag = dofile( "__THIS_FOLDER__get_nearby_tag.lua" )
local all_that_tagged = EntityGetWithTag( hit_tag )
for _, tagged in ipairs( all_that_tagged ) do
	EntityRemoveTag( tagged, hit_tag )
end