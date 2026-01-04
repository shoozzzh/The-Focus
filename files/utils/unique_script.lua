local entity_id = GetUpdatedEntityID()
local comp_id = GetUpdatedComponentID()
local current_script = ComponentGetValue2( comp_id, "script_source_file" )
local lua_comps = EntityGetComponentIncludingDisabled( entity_id, "LuaComponent" )
for _, lua_comp in ipairs( lua_comps ) do
	if ComponentGetValue2( lua_comp, "script_source_file" ) == current_script then
		local is_first = lua_comp == comp_id
		if not is_first then
			EntityRemoveComponent( entity_id, comp_id )
		end
		return is_first
	end
end