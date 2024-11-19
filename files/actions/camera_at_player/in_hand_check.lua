function enabled_changed( entity_id, is_enabled )
	local root_id = EntityGetRootEntity( entity_id )
	if not IsPlayer( root_id ) then return end
	if is_enabled then
		local impl = EntityLoad( "__THIS_FOLDER__carrier_impl.xml" )
		EntityAddChild( root_id, impl )
	else
		local impl = EntityGetWithName( "___camera_at_player_impl" )
		EntityKill( impl )
	end
end