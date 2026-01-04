local function apply_state( state )
	local children = EntityGetAllChildren( GetUpdatedEntityID() )
	local light_id
	if children then
		light_id = children[1]
	else
		light_id = EntityLoad( "data/entities/_debug/_free_camera_light.xml" )
		EntityAddComponent( light_id, "InheritTransformComponent" )
		EntityAddChild( GetUpdatedEntityID(), light_id )
	end
	for _, light_comp in ipairs( EntityGetComponentIncludingDisabled( light_id, "LightComponent" ) ) do
		EntitySetComponentIsEnabled( light_id, light_comp, state )
	end
end
local new_state = #EntityGetWithTag( "current_camera_carrier" ) == 0
apply_state( old_state and new_state )

old_state = new_state

function enabled_changed( entity_id, is_enabled )
	apply_state( is_enabled )
end