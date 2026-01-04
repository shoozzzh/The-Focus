dofile_once( "__MOD_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then
	EntitySetComponentsWithTagEnabled( entity_id, "___movement", false )
	EntityKill( entity_id )
	return
end

local mv_child_id = ( EntityGetAllChildren( shooter_id, "___movement_shooter_child" ) or {} )[1]
if not EntityGetIsAlive( mv_child_id ) then
	mv_child_id = EntityLoad( "__THIS_FOLDER__shooter_child.xml" )
	EntityAddChild( shooter_id, mv_child_id )
	local transform_comp = EntityGetFirstComponentIncludingDisabled( mv_child_id, "AttachToEntityComponent" )
	local _, _, rotation, scale_x, scale_y = EntityGetTransform( shooter_id )
	ComponentSetValue2( transform_comp, "Transform", 0, 0, scale_x, scale_y, rotation )
end

local current_movement_comp = get_var_comp( mv_child_id, "current_movement" )
local current_movement = ComponentGetValue2( current_movement_comp, "value_int" )
if current_movement ~= entity_id then
	if EntityGetIsAlive( current_movement ) then
		EntitySetComponentsWithTagEnabled( current_movement, "___movement", false )
		EntityKill( current_movement )
	end
	ComponentSetValue2( current_movement_comp, "value_int", entity_id )
end

write_var( mv_child_id, "movement_heartbeat", "value_bool", true )

ComponentSetValue2( proj_comp, "collide_with_shooter_frames", 256 )

if not EntityHasTag( entity_id, "___movement_initialized" ) then
	EntitySetComponentIsEnabled( entity_id,
		EntityGetFirstComponentIncludingDisabled( entity_id, "GameAreaEffectComponent" ), true )
	EntityAddTag( entity_id, "___movement_initialized" )
end