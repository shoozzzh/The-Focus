dofile_once( "__THIS_FOLDER__current_carrier_utils.lua" )
local this_id = GetUpdatedEntityID()
local last_id = get_current_camera_carrier()
if EntityGetIsAlive( last_id ) then
	local last_next_comp = EntityGetFirstComponentIncludingDisabled( last_id, "VariableStorageComponent", "camera_carrier_next_id" )
	local this_last_comp = EntityGetFirstComponentIncludingDisabled( this_id, "VariableStorageComponent", "camera_carrier_last_id" )
	ComponentSetValue2( last_next_comp, "value_int", this_id )
	ComponentSetValue2( this_last_comp, "value_int", last_id )
	EntitySetComponentsWithTagEnabled( last_id, "camera_carrying", false )
end
EntitySetComponentsWithTagEnabled( this_id, "camera_carrying", true )
set_current_camera_carrier( this_id )