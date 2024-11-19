dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )
local entity_id = GetUpdatedEntityID()
local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
if not vel_comp then return end
local gravity = ComponentGetValue2( vel_comp, "gravity_y" )
local gravity_sign
if gravity >= 0 then
	gravity_sign = 1
else
	gravity_sign = -1
end
ComponentSetValue2( vel_comp, "gravity_y", 0 )
EntityAddComponent2( entity_id, "VariableStorageComponent", {
	name = "gravity_sign",
	value_int = gravity_sign,
} )
return gravity_sign
