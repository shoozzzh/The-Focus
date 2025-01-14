return use_templates{
	type = ACTION_TYPE_OTHER,
	mana = 80,
	price = 100,
	action = function()
		local captured = ___capture_shot( function() draw_actions( 1, true ) end )
		for i = 1,2 do
			___release_shot( captured )
		end
	end,
}