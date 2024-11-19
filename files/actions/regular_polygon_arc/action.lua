return use_templates{
	spawn_level       = "1,3,5", -- HORIZONTAL_ARC
	spawn_probability = "0.3,0.4,0.5", -- HORIZONTAL_ARC
	price = 30,
	mana = 0,
	_and_then = function ()
		c.damage_projectile_add = c.damage_projectile_add + 0.1
		c.fire_rate_wait = c.fire_rate_wait - 6
		c.lifetime_add = c.lifetime_add + 25
	end,
}:template_extra_entity_modifier()