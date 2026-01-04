function first_comp( entity_id, comp_name, do_what )
	local comp = EntityGetFirstComponent( entity_id, comp_name )
	if comp then
		do_what( comp )
		return true
	end
	return false
end

function for_comps( entity_id, comp_name, do_what )
	local comps = EntityGetComponentIncludingDisabled( entity_id, comp_name ) or {}
	for _, comp in ipairs( comps ) do
		do_what( comp )
	end
end

function for_all_these_comps( entity_id, comp_names, do_what )
	for _, comp_name in ipairs( comp_names ) do
		for_comps( entity_id, comp_name, do_what )
	end
end

function get_field_or_default( comp_id, field_name, default_value )
	local result = ComponentGetValue2( comp_id, field_name )
	if result == nil then
		result = default_value
	end
	return result
end

function get_object_field_or_default( comp_id, object_name, field_name, default_value )
	local result = ComponentObjectGetValue2( comp_id, object_name, field_name )
	if result == nil then
		result = default_value
	end
	return result
end

function get_vec2_field_or_default( comp_id, field_name, default_left_value, default_right_value )
	local result_left, result_right = ComponentGetValue2( comp_id, field_name )
	if result_left  == nil then result_left  = default_left_value  end
	if result_right == nil then result_right = default_right_value end
	return result_left, result_right
end

function edit_field( comp_id, field_name, value_func, default_old_value )
	ComponentSetValue2( comp_id, field_name, value_func( get_field_or_default( comp_id, field_name, default_old_value ) ) )
end

function edit_object_field( comp_id, object_name, field_name, value_func, default_old_value )
	ComponentObjectSetValue2( comp_id, object_name, field_name,
		value_func( get_object_field_or_default( comp_id, object_name, field_name, default_old_value ) )
	)
end

function edit_vec2_field( comp_id, field_name, value_func, default_old_left_value, default_old_right_value )
	local left, right = ComponentGetValue2( comp_id, field_name )
	if left  == nil then left  = default_old_left_value  end
	if right == nil then right = default_old_right_value end
	left, right = value_func( left, right )
	ComponentSetValue2( comp_id, field_name, left, right )
end

local function find_var_comp( entity_id, var_name )
	local var_comps = EntityGetComponent( entity_id, "VariableStorageComponent" )
	if not var_comps or #var_comps == 0 then
		return
	end
	for _, var_comp in ipairs( var_comps ) do
		if ComponentGetValue2( var_comp, "name" ) == var_name then
			return var_comp
		end
	end
end

function get_var_comp( entity_id, var_name )
	local result = find_var_comp( entity_id, var_name )
	if result then
		return result, true
	end
	return EntityAddComponent2( entity_id, "VariableStorageComponent", { name = var_name } ), false
end

function read_var( entity_id, var_name, var_type )
	local var_comp = find_var_comp( entity_id, var_name )
	if var_comp then
		return ComponentGetValue2( var_comp, var_type )
	end
end

function read_and_update_var( entity_id, var_name, var_type, updator )
	local var_comp = find_var_comp( entity_id, var_name )
	local result = ComponentGetValue2( var_comp, var_type )
	if result then
		if type( updator ) == "function" then
			ComponentSetValue2( var_comp, var_type, updator( result ) )
		else
			ComponentSetValue2( var_comp, var_type, updator )
		end
	end
	return result
end

function get_and_update_var( entity_id, var_name, var_type, update_fn, default_old_value )
	local var_comp, exists = get_var_comp( entity_id, var_name )
	local result = exists and ComponentGetValue2( var_comp, var_type ) or default_old_value
	ComponentSetValue2( var_comp, var_type, update_fn( result ) )
	return result
end

function write_var( entity_id, var_name, var_type, value )
	ComponentSetValue2( get_var_comp( entity_id, var_name ), var_type, value )
end

local vars_access_mt = {
	__index = function( t, k )
		local comp, type = unpack( rawget( t, k ) )
		return ComponentGetValue2( comp, type )
	end,
	__newindex = function( t, k, v )
		local comp, type = unpack( rawget( t, k ) )
		ComponentSetValue2( comp, type, v )
	end,
}
function access_vars( entity_id, var_map )
	local result = {}
	for var_name, var_type in pairs( var_map ) do
		result[ var_name ] = { var_comp, var_type }
	end
	setmetatable( result, vars_access_mt )
	return result
end