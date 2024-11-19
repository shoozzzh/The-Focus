return use_templates{
	mana = 160,
	price = 300,
	_and_then = function()
		c.fire_rate_wait = c.fire_rate_wait + 180
		current_reload_time = current_reload_time + 180
	end
}:template_projectile()