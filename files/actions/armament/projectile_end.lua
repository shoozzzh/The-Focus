dofile_once( "__MOD_LIBS__stream.lua" )
dofile_once( "__MOD_UTILS__closest_aabb.lua" )

local entity_id = GetUpdatedEntityID()

local x, y = EntityGetTransform( entity_id )
local give_wand_to = closest_mortal_to_hit( x, y )
if not give_wand_to or not EntityGetFirstComponent( give_wand_to, "ControlsComponent" ) then return end

local is_player = EntityHasTag( give_wand_to, "player_unit" )
local ipu_comp = EntityGetFirstComponent( give_wand_to, "ItemPickUpperComponent" )

if ipu_comp then
	if not ComponentHasTag( ipu_comp, "__ACTION_ID__" ) then
		if not is_player and ComponentGetValue2( ipu_comp, "is_in_npc" ) then
			GameDropAllItems( give_wand_to )
		else
			local inventory_quick = stream( EntityGetAllChildren( give_wand_to ) or {} )
				.filter( function( e ) return EntityGetName( e ) == "inventory_quick" end )
				.next()
			if inventory_quick then
				local taken = {}
				for _, e in ipairs( EntityGetAllChildren( inventory_quick ) or {} ) do
					local item_comp = EntityGetFirstComponentIncludingDisabled( e, "ItemComponent" )
					local item_x, item_y = ComponentGetValue2( item_comp, "inventory_slot" )
					if item_y == 0 then
						taken[item_x] = true
					end
				end
				if taken[0] and taken[1] and taken[2] and taken[3] then
					return
				end
			end
		end
	else
		ipu_comp = nil
	end
else
	local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
	if not is_player and ComponentGetValue2( proj_comp, "mShooterHerdId" ) == 0 then
		local gd_comp = EntityGetFirstComponent( entity_id, "GenomeDataComponent" )
		local is_ally = gd_comp and ComponentGetValue2( gd_comp, "herd_id" ) == 0
		local is_charmed = GameGetGameEffect( give_wand_to, "CHARM" ) ~= 0

		if is_ally or is_charmed then
			EntityAddComponent2( give_wand_to, "ItemPickUpperComponent", {
				_tags = "__ACTION_ID__",
				is_in_npc = true,
			} )
		else
			return
		end
	else
		return
	end
end

local shot_saver_comp = EntityGetFirstComponent( EntityGetAllChildren( entity_id, "___shot_saver" )[1],
	"ProjectileComponent" ) 
local saved_shot = ComponentObjectGetValue2( shot_saver_comp, "config", "action_description"     )
local one_off    = ComponentObjectGetValue2( shot_saver_comp, "config", "state_destroyed_action" )

-- grabbed from gun_procedural.lua
function SetWandSprite( entity_id, ability_comp, item_file, offset_x, offset_y, tip_x, tip_y )

	if( ability_comp ~= nil ) then
		ComponentSetValue( ability_comp, "sprite_file", item_file)
	end

	local sprite_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "SpriteComponent", "item" )
	if( sprite_comp ~= nil ) then
		ComponentSetValue( sprite_comp, "image_file", item_file)
		ComponentSetValue( sprite_comp, "offset_x", offset_x )
		ComponentSetValue( sprite_comp, "offset_y", offset_y )
	end

	local hotspot_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "HotspotComponent", "shoot_pos" )
	if( hotspot_comp ~= nil ) then
		ComponentSetValueVector2( hotspot_comp, "offset", tip_x, tip_y )
	end	
end

local wand_sprites = {
	{ image_file = "data/items_gfx/wands/wand_0076.png", grip_x = 1, grip_y = 3, tip_x = 10, tip_y = 3 },
	{ image_file = "data/items_gfx/wands/wand_0201.png", grip_x = 1, grip_y = 2, tip_x = 8, tip_y = 2 },
	{ image_file = "data/items_gfx/wands/wand_0231.png", grip_x = 1, grip_y = 3, tip_x = 10, tip_y = 3 },
	{ image_file = "data/items_gfx/wands/wand_0447.png", grip_x = 1, grip_y = 2, tip_x = 8, tip_y = 2 },
	{ image_file = "data/items_gfx/wands/wand_0735.png", grip_x = 1, grip_y = 2, tip_x = 12, tip_y = 2 },
	{ image_file = "data/items_gfx/wands/wand_0855.png", grip_x = 2, grip_y = 3, tip_x = 10, tip_y = 3 },
}

local sprite = wand_sprites[ ( #saved_shot % #wand_sprites ) + 1 ]

local wand_id = EntityLoad( "__THIS_FOLDER__temporary_wand.xml" )
local ab_comp = EntityGetFirstComponentIncludingDisabled( wand_id, "AbilityComponent" )

SetWandSprite( wand_id, ab_comp, sprite.image_file, sprite.grip_x, sprite.grip_y, sprite.tip_x, sprite.tip_y )
EntityRefreshSprite( wand_id, EntityGetFirstComponent( wand_id, "SpriteComponent" ) )

ComponentObjectSetValue2( ab_comp, "gunaction_config", "action_description"     , saved_shot )
ComponentObjectSetValue2( ab_comp, "gunaction_config", "state_destroyed_action" , one_off    )

ComponentSetValue2( ab_comp, "ui_name",
	one_off and "$__ACTION_ID___temporary_wand_one_off" or "$__ACTION_ID___temporary_wand" )

if not ipu_comp then
	ComponentSetValue2(
		EntityGetFirstComponentIncludingDisabled( give_wand_to, "ItemPickUpperComponent" ),
		"only_pick_this_entity", wand_id )
end
GamePickUpInventoryItem( give_wand_to, wand_id, false )