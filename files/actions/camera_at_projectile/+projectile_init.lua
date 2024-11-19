local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local player = ComponentGetValue2( proj_comp, "mWhoShot" )
if not IsPlayer( player ) then
	EntityKill( entity_id )
end