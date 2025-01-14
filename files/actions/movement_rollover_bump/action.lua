return use_templates{
	_spawn_prob_map  = { [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1 },
	price = 90,
	mana = 50,
	_and_then = function()
		c.fire_rate_wait = c.fire_rate_wait + 30
	end,
}:template_projectile()