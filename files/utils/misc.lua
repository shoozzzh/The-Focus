function get_herd_id2( entity_id )
	local gd_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "GenomeDataComponent" )
	local herd_id = ComponentGetValue2( gd_comp, "herd_id" )
	return herd_id
end