return use_templates{
	mana = 120,
	price = 350,
	_before_that = function()
		c.fire_rate_wait = c.fire_rate_wait + 13
	end,
}:template_extra_entity_modifier()