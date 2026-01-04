function set_current_camera_carrier( carrier_id )
	EntityRemoveTag( get_current_camera_carrier(), "current_camera_carrier" )
	EntityAddTag( carrier_id, "current_camera_carrier" )
end

function get_current_camera_carrier()
	return EntityGetWithTag( "current_camera_carrier" )[1]
end