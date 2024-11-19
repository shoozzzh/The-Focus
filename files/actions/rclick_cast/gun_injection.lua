local injection = new_injection()

injection.initializer = function()
	___action_table_group_idle = {
		deck      = {},
		hand      = {},
		discarded = {},
	}
	function ___swap_action_table_group()
		local temp = {
			deck      = deck,
			hand      = hand,
			discarded = discarded,
		}
		deck      = ___action_table_group_idle.deck
		hand      = ___action_table_group_idle.hand
		discarded = ___action_table_group_idle.discarded
		___action_table_group_idle = temp
	end
	___splitted_by_mouse_button = false
	___last_shot_cast_by_rc = false
end

injection.order_deck.post = function()
	if not first_shot then return end
	if ___splitted_by_mouse_button then return end
	for index, card in ipairs( deck ) do
		if card.id == "__ACTION_ID_UPPER__" then
			local deck_length = #deck
			for i = index, deck_length do
				table.insert( ___action_table_group_idle.deck, deck[i] )
			end
			for j = 0, deck_length - index do
				table.remove( deck, deck_length - j )
			end
			___splitted_by_mouse_button = true
			return
		end
	end
	___splitted_by_mouse_button = false
end

injection._draw_actions_for_shot.pre = function()
	if ___splitted_by_mouse_button then
		if GlobalsGetValue( "___is_rclick_casting", "0" ) == "1" then
			if not ___last_shot_cast_by_rc then
				___swap_action_table_group()
				GlobalsSetValue( "___is_rclick_casting", "0" )
				___last_shot_cast_by_rc = true
			end
		else
			if ___last_shot_cast_by_rc then
				___swap_action_table_group()
				___last_shot_cast_by_rc = false
			end
		end
	end
end

injection._clear_deck.post = function()
	___action_table_group_idle = {
		deck      = {},
		hand      = {},
		discarded = {},
	}
	___splitted_by_mouse_button = false
	___last_shot_cast_by_rc = false
end

return injection