return use_templates{
	mana = 0,
	price = 10,
	_before_that = function()
		limited_speed_multiplier( 2 )
	end,
}:template_extra_entity_modifier()