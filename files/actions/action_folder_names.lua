local action_folder_names = {
	"movement_rollover_bump",
	"movement_headbutt",
	"camera_at_player",
	"camera_at_projectile",
	"if_unique",
	"sniper_shot",
	"regular_polygon_arc",
	"larger_projectile",
	"reciprocating_path",
	"bind_static",
	"bind_aim",
	"wall_of_fire",
	"random_gravity",
	"larpa_towards_enemies",
	"larpa_chaos_homing",
	"square_arc",
	"diagonal_path",
	"wall_field",
	"unreal_shot",
	"no_hit",
	"repetitive_casting",
	"object_to_projectile",
	"modifier_field",
	"personal_modifier_bolt",
	"wand_connector",
	"spiral",
	"random_speed",
	"trigger_as_shooter",
	"lifetime_stainless",
	"lifetime_no_hit",
	"gold_collector",
	"double_shot",
	"armament",
	"fake_projectile_spell",
	"actual_material_eater",
}

function action_folder_name_to_id( folder_name )
	-- requirement spells' ids must start with "if_"
	if string.sub( folder_name, 1, 2 ) == "if" then
		return "if_" .. "___" .. folder_name
	end
	return "___" .. folder_name
end

function action_folder_name_to_path( folder_name )
	return string.format( "__MOD_ACTIONS__%s/", folder_name )
end

return action_folder_names
