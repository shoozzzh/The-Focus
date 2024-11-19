return use_templates{
	mana = 60,
	price = 125,
	custom_xml_file = "data/entities/misc/custom_cards/lifetime_infinite.xml",
	_do_in_advance = function()
		c.fire_rate_wait = c.fire_rate_wait + 13
	end,
}:template_extra_entity_modifier()