return use_templates{
	mana = 0,
	price = 20,
	_do_in_advance = function()
		c.lifetime_add = c.lifetime_add + 25
	end,
}:template_extra_entity_modifier()