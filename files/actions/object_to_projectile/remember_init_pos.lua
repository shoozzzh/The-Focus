local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
EntityAddComponent2( entity_id, "VariableStorageComponent", {
	name = "proj_last_x",
	value_float = x,
} )
EntityAddComponent2( entity_id, "VariableStorageComponent", {
	name = "proj_last_y",
	value_float = y,
} )