local injection = new_injection()

injection.initializer = function()
	dofile_once( "__MOD_LIBS__stream.lua" )
	dofile_once( "__MOD_UTILS__comp_utils.lua" )
	-- will move these into action_utils/(some filename).lua if necessary
	function get_held_wand()
		if not ___held_wand_id then
			local entity_id = GetUpdatedEntityID()
			local inv2_comp = EntityGetFirstComponent( entity_id, "Inventory2Component" )
			if not inv2_comp then return end
			local held_wand_id = ComponentGetValue2( inv2_comp, "mActiveItem" )
			___held_wand_id = held_wand_id
		end
		return ___held_wand_id
	end
	function find_wand( offset )
		local all_wands = get_all_wands_in_inventory()
		if not ___held_wand_index then
			local held_wand_id = get_held_wand()
			for index, wand_id in ipairs( all_wands ) do
				if wand_id == held_wand_id then
					___held_wand_index = index
					break
				end
			end
		end
		local all_wands_num = #all_wands
		local result_index = ( ___held_wand_index + offset ) % all_wands_num
		if result_index == 0 then
			result_index = all_wands_num
		end
		return all_wands[ result_index ]
	end
	function get_all_wands_in_inventory()
		if ___all_wands_in_inventory then return ___all_wands_in_inventory end
		local inventory_quick = stream( EntityGetAllChildren( GetUpdatedEntityID() ) )
			.filter( function( e ) return EntityGetName( e ) == "inventory_quick" end ).next()
		if not inventory_quick then return {} end
		local result = {}
		for _, wand_id in ipairs( EntityGetAllChildren( inventory_quick, "wand" ) or {} ) do
			table.insert( result, wand_id )
		end
		return result
	end
end

injection._clear_deck.post = function()
	___all_wands_in_inventory = nil
	___held_wand_index = -1
	___held_wand_id = nil
end

injection._add_card_to_deck.post = { 16, function( action_id )
	if action_id ~= "__ACTION_ID_UPPER__" then return end
	__ACTION_ID___connected = true
	__ACTION_ID___offset = ( __ACTION_ID___offset or 0 ) + 1
	local next_wand = find_wand( __ACTION_ID___offset )
	if next_wand == get_held_wand() then
		__ACTION_ID___offset = __ACTION_ID___offset - 1
		return
	end
	local next_wand_cards = EntityGetAllChildren( next_wand, "card_action" )
	for _, card_id in ipairs( next_wand_cards or {} ) do
		local item_comp = EntityGetFirstComponentIncludingDisabled( card_id, "ItemComponent" )
		if not item_comp then goto continue end
		local item_id = ComponentGetValue2( item_comp, "mItemUid" )
		local uses_remaining = ComponentGetValue2( item_comp, "uses_remaining" )
		local ia_comp = EntityGetFirstComponentIncludingDisabled( card_id, "ItemActionComponent" )
		if not ia_comp then goto continue end
		local action_id = ComponentGetValue2( ia_comp, "action_id" )
		_add_card_to_deck( action_id, item_id, uses_remaining, true ) -- recursive
		::continue::
	end
	__ACTION_ID___offset = __ACTION_ID___offset - 1
end }

injection.order_deck.post = function()
	if not __ACTION_ID___connected then return end
	for idx = #deck, 1, -1 do
		if deck[ idx ] and deck[ idx ].action_id == "__ACTION_ID_UPPER__" then
			table.remove( deck, idx )
		end
	end
end

return injection