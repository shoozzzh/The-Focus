return use_templates{
	_condition = function()
		if reflecting then return false end
		local entity_id = GetUpdatedEntityID()
		local who_shot = EntityGetRootEntity( entity_id )
		local x, y = EntityGetTransform( entity_id )
		local tag = "___unique_proj_" .. tostring( who_shot )
		local unique_projectiles = EntityGetInRadiusWithTag( x, y, 800, tag )
		local result = #unique_projectiles == 0
		if result then __concat_extra_entity() end
		return result
	end,
}:template_condition()