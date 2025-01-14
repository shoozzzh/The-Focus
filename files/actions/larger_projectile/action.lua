return use_templates{
	mana = 20,
	_before_that = function ()
		c.damage_projectile_add = c.damage_projectile_add + 0.6
		c.fire_rate_wait = c.fire_rate_wait + 5
		shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0
		c.speed_multiplier = c.speed_multiplier * 0.8
	end,
}:template_extra_entity_modifier()