return use_templates{
	mana = 0,
	price = 60,
	_before_that = function()
		shot_effects.recoil_knockback = shot_effects.recoil_knockback - 80
		limited_speed_multiplier( 7.5 )
		c.spread_degrees = c.spread_degrees - 720
		c.lifetime_add = c.lifetime_add + 25
	end,
}:template_extra_entity_modifier()