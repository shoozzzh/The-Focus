function add_virtual_tag( entity_id, tag, spam_check )
	if spam_check and has_virtual_tag( entity_id, tag ) then
		return
	end
	EntityAddComponent2( entity_id, "VariableStorageComponent", { name = "virtual_tag", value_string = tag })
end

function has_virtual_tag( entity_id, tag )
	local tag_comps = EntityGetComponentIncludingDisabled( entity_id, "VariableStorageComponent" )
	for _, tag_comp in ipairs( tag_comps ) do
		if ComponentGetValue2( tag_comp, "name" ) == "virtual_tag"
			and ComponentGetValue2( tag_comp, "value_string" ) == tag then
			return true
		end
	end
	return false
end