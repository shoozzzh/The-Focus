dofile_once( "__THIS_FOLDER__current_carrier_utils.lua" )
local this_id = GetUpdatedEntityID()
local this_last_comp = EntityGetFirstComponentIncludingDisabled( this_id, "VariableStorageComponent", "camera_carrier_last_id" )
local this_next_comp = EntityGetFirstComponentIncludingDisabled( this_id, "VariableStorageComponent", "camera_carrier_next_id" )
local last_id = ComponentGetValue2( this_last_comp, "value_int" )
local next_id = ComponentGetValue2( this_next_comp, "value_int" )

local last_next_comp = EntityGetFirstComponentIncludingDisabled( last_id, "VariableStorageComponent", "camera_carrier_next_id" )
if last_next_comp then
	ComponentSetValue2( last_next_comp, "value_int", next_id )
end
local next_last_comp = EntityGetFirstComponentIncludingDisabled( next_id, "VariableStorageComponent", "camera_carrier_last_id" )
if next_last_comp then
	ComponentSetValue2( next_last_comp, "value_int", last_id )
end

if get_current_camera_carrier() == this_id then
	if EntityGetIsAlive( last_id ) then
		EntitySetComponentsWithTagEnabled( last_id, "camera_carrying", true )
	else
		GameSetCameraFree( false )
	end
	set_current_camera_carrier( last_id )
end
EntitySetComponentsWithTagEnabled( this_id, "camera_carrying", false )