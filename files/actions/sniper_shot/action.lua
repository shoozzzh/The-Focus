return use_templates{
	mana = 40,
	_before_that = function()
		c.fire_rate_wait = c.fire_rate_wait + 30
		c.knockback_force = c.knockback_force + 2
	end,
}:template_extra_entity_modifier()