dofile_once( "__MOD_ACTION_UTILS__shot_capture.lua" )

local injection = new_injection()

injection._draw_actions_for_shot.post = function()
	if state_from_game.action_name == "__ACTION_ID__" then
		ModTextFileSetContent( "__THIS_FOLDER__shot.lua", state_from_game.action_description:gsub( "%^", '"' ) )
		___release_shot( loadfile( "__THIS_FOLDER__shot.lua" )() )
		if state_from_game.state_destroyed_action then
			local caster_id = GetUpdatedEntityID()
			local inv2_comp = EntityGetFirstComponentIncludingDisabled( caster_id, "Inventory2Component" )
			if inv2_comp then
				local wand_id = ComponentGetValue2( inv2_comp, "mActiveItem" )
				EntityRemoveFromParent( wand_id )
				EntityKill( wand_id )
			end
		end
	end
end

injection.play_action.post = function( action )
	if action.uses_remaining ~= nil and action.uses_remaining > 0 then
		ActionUsesRemainingChanged( action.inventoryitem_id, action.uses_remaining )
	end
end

injection.ActionUsesRemainingChanged.spy = function( result, ... )
	if result then
		___reduced_uses = true
	end
end

injection._draw_actions_for_shot.pre = function()
	___reduced_uses = false
end

return injection