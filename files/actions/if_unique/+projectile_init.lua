local entity_id = GetUpdatedEntityID()
local who_shot = EntityGetRootEntity( entity_id )
local tag = "___unique_proj_" .. tostring( who_shot )
EntityAddTag( entity_id, tag )