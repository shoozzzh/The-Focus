local injection = new_injection()

injection.initializer = function()
	___repetitive_casting = false
end

injection._clear_deck.post = function()
	___repetitive_casting = false
end

injection._add_card_to_deck.post = function( action_id )
	if action_id == "__ACTION_ID__" then
		___repetitive_casting = true
	end
end

injection.move_hand_to_discarded.proxy = function( target )
	if not ___repetitive_casting or #hand == 0 then
		target()
		return
	end
	___consumed_uses = false
	local intercepted = {}

	local env = getfenv( target )
	local old_table_insert = env.table.insert
	env.table.insert = function( t, ... )
		if t == discarded then
			t = intercepted
		end
		old_table_insert( t, ... )
	end

	target()

	env.table.insert = old_table_insert

	if ___consumed_uses then
		for _, v in ipairs( intercepted ) do
			table.insert( deck, 1, v )
		end
	else
		for _, v in ipairs( intercepted ) do
			table.insert( discarded, v )
		end
	end
end

injection.ActionUsesRemainingChanged.spy = function( result )
	if result then
		___consumed_uses = true
	end
end

return injection