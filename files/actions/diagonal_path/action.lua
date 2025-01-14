return use_templates{
	mana = 0,
	price = 30,
	_before_that = function()
		c.damage_projectile_add = c.damage_projectile_add + 0.25
	end,
}:template_extra_entity_modifier()