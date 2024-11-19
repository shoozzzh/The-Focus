dofile_once( "data/scripts/lib/utilities.lua" )
local entity_id = GetUpdatedEntityID()
local shooter_id = ComponentGetValue2( EntityGetFirstComponent( entity_id, "ProjectileComponent" ), "mWhoShot" )
if shooter_id == 0 then return end
local cmp_comp = get_variable_storage_component( shooter_id, "___current_movement" )
if cmp_comp == 0 then return end
if entity_id ~= ComponentGetValue2( cmp_comp, "value_int" ) then return end
local x, y = EntityGetTransform( entity_id )
local init_rotation = ComponentGetValue2( get_variable_storage_component( entity_id, "___init_rotation" ), "value_float" )
local init_scale_x = ComponentGetValue2( get_variable_storage_component( entity_id, "___init_scale_x" ), "value_float" )
local init_scale_y = ComponentGetValue2( get_variable_storage_component( entity_id, "___init_scale_y" ), "value_float" )
EntitySetTransform( shooter_id, x, y, init_rotation, init_scale_x, init_scale_y )
shoot_projectile( shooter_id, "__MOD_ACTION_UTILS__teleportation_to_free_space.xml", x, y, 0, 0, false )

local hit_tag = dofile( "__THIS_FOLDER__get_nearby_tag.lua" )
local all_that_tagged = EntityGetWithTag( hit_tag )
for _, tagged in ipairs( all_that_tagged ) do
	EntityRemoveTag( tagged, hit_tag )
end