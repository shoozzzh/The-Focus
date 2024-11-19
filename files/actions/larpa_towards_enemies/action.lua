return use_templates{
	mana = 150,
	price = 300,
	_do_in_advance = function()
		c.speed_multiplier = c.speed_multiplier * 0.5
		c.fire_rate_wait = c.fire_rate_wait + 30
	end
}:template_extra_entity_modifier()