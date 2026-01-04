function allocate_uuid( entity_id )
	local uuid = tonumber( GlobalsGetValue( "___max_uuid", "0" ) ) + 1
	EntityAddComponent2( entity_id, "VariableStorageComponent", {
		name = "___uuid",
		value_int = uuid,
	} )
	GlobalsSetValue( "___max_uuid", tostring( uuid ) )
	return uuid
end

function raw_get_uuid( entity_id )
	local var_comps = EntityGetComponent( entity_id, "VariableStorageComponent" )
	if not var_comps or #var_comps == 0 then
		return nil
	end
	for _, var_comp in ipairs( var_comps ) do
		if ComponentGetValue2( var_comp, "name" ) == "___uuid" then
			return ComponentGetValue2( var_comp, "value_int" )
		end
	end
end

function get_uuid( entity_id )
	return raw_get_uuid( entity_id ) or allocate_uuid( entity_id )
end