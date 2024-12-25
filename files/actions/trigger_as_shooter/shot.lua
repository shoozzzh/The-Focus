function shot( entity_id )
	if not EntityHasTag( entity_id, "__ACTION_ID__" ) then return end

	local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
	local ets_id = ComponentGetValue2( proj_comp, "mEntityThatShot" )
	if ets_id == 0 then--[[ GamePrint("skipped") ]]return end

	ComponentSetValue2( proj_comp, "mWhoShot", ets_id )
	for _, tpp_comp in ipairs( EntityGetComponent( entity_id, "TeleportProjectileComponent" ) or {} ) do
		ComponentSetValue2( tpp_comp, "mWhoShot", ets_id )
	end
end