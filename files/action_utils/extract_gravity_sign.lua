dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )
local entity_id = GetUpdatedEntityID()
local gravity_sign_comp, extracted = get_var_comp( entity_id, "___gravity_sign" )
if extracted then
	return ComponentGetValue2( gravity_sign_comp, "value_int" )
end

local gravity_sign

do
	local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
	if not vel_comp then
		SetRandomSeed( entity_id + GameGetFrameNum(), entity_id - GameGetFrameNum() )
		gravity_sign = 2 * Random(1,2) - 3
		goto skip
	end
	
	local gravity = ComponentGetValue2( vel_comp, "gravity_y" )
	if gravity >= 0 then
		gravity_sign = 1
	else
		gravity_sign = -1
	end
	ComponentSetValue2( vel_comp, "gravity_y", 0 )
end

::skip::

ComponentSetValue2( gravity_sign_comp, "value_int", gravity_sign )
return gravity_sign
