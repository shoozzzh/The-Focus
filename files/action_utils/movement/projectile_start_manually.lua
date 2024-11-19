-- call this file in the very beginning of your projectile_update.lua
-- like this:
-- local entity_id = GetUpdatedEntityID()
-- if not EntityHasTag( entity_id, "___initialized_movement" ) then
-- 	dofile( "__MOD_ACTION_UTILS__movement/projectile_start_manually.lua" )
-- 	EntityAddTag( "___initialized_movement" )
-- end
-- if we use a LuaComponent for this instead, the execution order will be unreliable and may lead to memorizing incorrect transform
dofile_once( "data/scripts/lib/utilities.lua" )

local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end

local last_mv_proj
local cmp_comp = get_variable_storage_component( shooter_id, "___current_movement" )
if cmp_comp == 0 or cmp_comp == nil then
	EntityAddComponent2( shooter_id, "VariableStorageComponent", { name = "___current_movement", value_int = entity_id } )
else
	local last_mv_proj_maybe = ComponentGetValue2( cmp_comp, "value_int" )
	if EntityGetIsAlive( last_mv_proj_maybe ) then
		last_mv_proj = last_mv_proj_maybe
	end
	ComponentSetValue2( cmp_comp, "value_int", entity_id )
end

-- memorize shooter's transform before they do movement
local rotation_comp = get_variable_storage_component( entity_id, "___init_rotation" )
local scale_x_comp = get_variable_storage_component( entity_id, "___init_scale_x" )
local scale_y_comp = get_variable_storage_component( entity_id, "___init_scale_y" )
local init_rotation
local init_scale_x
local init_scale_y
if last_mv_proj and EntityGetIsAlive( last_mv_proj ) then
	init_rotation = ComponentGetValue2( get_variable_storage_component( last_mv_proj, "___init_rotation" ), "value_float" )
	init_scale_x = ComponentGetValue2( get_variable_storage_component( last_mv_proj, "___init_scale_x" ), "value_float" )
	init_scale_y = ComponentGetValue2( get_variable_storage_component( last_mv_proj, "___init_scale_y" ), "value_float" )
	EntityKill( last_mv_proj )
else
	_, _, init_rotation, init_scale_x, init_scale_y = EntityGetTransform( shooter_id )
end
ComponentSetValue2( rotation_comp, "value_float", init_rotation )
ComponentSetValue2( scale_x_comp, "value_float", init_scale_x )
ComponentSetValue2( scale_y_comp, "value_float", init_scale_y )

local hit_tag = dofile( "__THIS_FOLDER__get_nearby_tag.lua" )
ComponentSetValue2( proj_comp, "collide_with_tag", hit_tag )