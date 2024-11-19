return use_templates{
	type = ACTION_TYPE_STATIC_PROJECTILE,
	mana = 120,
	price = 200,
	_and_then = function()
		c.fire_rate_wait = c.fire_rate_wait + 45
		current_reload_time = current_reload_time + 60
	end
}:template_projectile()