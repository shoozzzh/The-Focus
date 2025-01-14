return use_templates{
	mana = 150,
	price = 300,
	_before_that = function()
		c.speed_multiplier = c.speed_multiplier * 0.5
		c.fire_rate_wait = c.fire_rate_wait + 60
	end
}:template_extra_entity_modifier()