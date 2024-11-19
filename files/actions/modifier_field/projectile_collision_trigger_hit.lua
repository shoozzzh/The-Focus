dofile_once( "__MOD_ACTION_UTILS__proj_cfg_utils.lua" )
dofile_once( "__MOD_ACTION_UTILS__virtual_tag.lua" )
dofile_once( "__MOD_ACTION_UTILS__entity_uuid.lua" )

function collision_trigger( collider_id )
	local entity_id = GetUpdatedEntityID()
	local tag = "__ACTION_ID___" .. tostring( get_uuid( entity_id ) )
	if EntityHasTag( entity_id, "activated" ) then
		if has_virtual_tag( collider_id, tag ) or not apply_proj_cfg_safe_check( collider_id ) then return end

		local mem_proj_comp = EntityGetComponentIncludingDisabled( entity_id, "ProjectileComponent" )[2]
		apply_proj_cfg( read_proj_cfg( mem_proj_comp ), collider_id )
		add_virtual_tag( collider_id, tag )

		local x, y = EntityGetTransform( collider_id )
		GamePlaySound( "data/audio/Desktop/misc.snd", "game_effect/invisibility/activate", x, y )
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "projectiles/orb_cursed/destroy", x, y )
		return
	end

	local proj_comp = EntityGetFirstComponent( collider_id, "ProjectileComponent" )
	if not proj_comp then return end
	
	local proj_cfg = read_proj_cfg( proj_comp )
	local mem_proj_comp = EntityAddComponent2( entity_id, "ProjectileComponent", { _enabled = false } )
	store_proj_cfg( mem_proj_comp, proj_cfg )
	
	EntityAddTag( entity_id, "activated" )
	add_virtual_tag( collider_id, tag )
	EntitySetComponentsWithTagEnabled( entity_id, "activated", true )
	EntitySetComponentsWithTagEnabled( entity_id, "not_activated", false)

	local x, y = EntityGetTransform( entity_id )
	-- sadly this so suitable sound doesn't do any panning for some reason
	GamePlaySound( "data/audio/Desktop/items.bank", "magic_wand/mana_fully_recharged", x, y )
end