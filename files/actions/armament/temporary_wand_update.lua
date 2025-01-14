local entity_id = GetUpdatedEntityID()
if not EntityGetIsAlive( EntityGetParent( entity_id ) ) then
	EntityRemoveFromParent( entity_id )
	EntityKill( entity_id )
end