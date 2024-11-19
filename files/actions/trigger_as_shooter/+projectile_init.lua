local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local ets_id = ComponentGetValue2( proj_comp, "mEntityThatShot" )
if ets_id == 0 then return end

ComponentSetValue2( proj_comp, "mWhoShot", ets_id )
for _, tpp_comp in ipairs( EntityGetComponent( entity_id, "TeleportProjectileComponent" ) or {} ) do
	ComponentSetValue2( tpp_comp, "mWhoShot", ets_id )
end