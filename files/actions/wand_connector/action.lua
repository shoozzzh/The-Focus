return use_templates{
	_spawn_prob_map = { [4] = 0.7, [5] = 0.7, [6] = 0.7, [10] = 1 },
	mana = 50,
	price = 100,
	_dp_in_advance = function()
		c.fire_rate_wait = c.fire_rate_wait + 30
		current_reload_time = current_reload_time + 30
	end,
}:template_passive()