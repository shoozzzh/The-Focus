return use_templates{
	mana  = 180,
	price = 300,
	_flag_unlocked = "__ACTION_ID__",
	_and_then = function()
		c.fire_rate_wait = c.fire_rate_wait + 60
		current_reload_time = current_reload_time + 60
		shot_effects.recoil_knockback = shot_effects.recoil_knockback + 300.0
	end
}:template_projectile()