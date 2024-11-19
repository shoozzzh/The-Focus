return use_templates{
	blend_with  = { GRENADE_LARGE = 0.25, DISC_BULLET_BIG = 0.25, LIGHTNING = 0.25, SPORE_POD = 0.25, PURPLE_EXPLOSION_FIELD = 0.25 },
	price            = 90,
	mana             = 50,
	_and_then        = function()
		c.fire_rate_wait = c.fire_rate_wait + 6
	end,
}:template_projectile()