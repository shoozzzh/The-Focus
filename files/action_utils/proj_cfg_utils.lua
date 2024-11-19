dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local fields_available = {
	-- "action_id",
	-- "action_name",
	-- "action_description",
	-- "action_sprite_filename",
	-- "action_unidentified_sprite_filename",
	-- "action_type",
	-- "action_spawn_level",
	-- "action_spawn_probability",
	-- "action_spawn_requires_flag",
	-- "action_spawn_manual_unlock",
	-- "action_max_uses",
	-- "custom_xml_file",
	-- "action_mana_drain",
	-- "action_is_dangerous_blast",
	-- "action_draw_many_count",
	-- "action_ai_never_uses",
	-- "action_never_unlimited",
	-- "cast_state_shuffled",
	-- "cast_state_cards_drawn",
	-- "cast_state_discarded_action",
	-- "cast_state_destroyed_action",
	-- "fire_rate_wait",
	"speed_multiplier",
	"child_speed_multiplier",
	-- "dampening",
	"explosion_radius",
	-- "spread_degrees",
	-- "pattern_degrees",
	-- "screenshake",
	-- "recoil",
	"damage_melee_add",
	"damage_projectile_add",
	"damage_electricity_add",
	"damage_fire_add",
	"damage_explosion_add",
	"damage_ice_add",
	"damage_slice_add",
	"damage_healing_add",
	"damage_curse_add",
	"damage_drill_add",
	"damage_critical_chance",
	-- "damage_critical_multiplier", -- these two are never used in spells
	-- "explosion_damage_to_materials",
	"knockback_force",
	-- "reload_time",
	-- "lightning_count",
	-- "material",
	-- "material_amount",
	"trail_material",
	"trail_material_amount",
	"bounces",
	"gravity",
	-- "light",
	"blood_count_multiplier",
	"gore_particles", -- TODO
	-- "ragdoll_fx",
	"friendly_fire",
	-- "physics_impulse_coeff",
	"lifetime_add",
	-- "sprite",
	"extra_entities",
	"game_effect_entities",
	-- "sound_loop_tag",
	-- "projectile_file",
}

function read_proj_cfg( proj_comp )
	local proj_cfg = {}
	for _, field_name in ipairs( fields_available ) do
		proj_cfg[ field_name ] = ComponentObjectGetValue2( proj_comp, "config", field_name )
	end
	return proj_cfg
end

function store_proj_cfg( proj_comp, proj_cfg )
	for _, field_name in ipairs( fields_available ) do
		ComponentObjectSetValue2( proj_comp, "config", field_name, proj_cfg[ field_name ] )
	end
end

local modifiable_damage_types = {
	"melee",
	"projectile",
	"electricity",
	"fire",
	"explosion",
	"ice",
	"slice",
	"healing",
	"curse",
	"drill",
}

function apply_proj_cfg( proj_cfg, entity_id )
	first_comp( entity_id, "VelocityComponent", function( comp )
		edit_vec2_field( comp, "mVelocity", function( vx, vy )
			return vx * proj_cfg.speed_multiplier, vy * proj_cfg.speed_multiplier
		end, 0, 0 )

		edit_field( comp, "gravity_y", function( gravity ) return gravity + proj_cfg.gravity end, 400 )
	end )

	first_comp( entity_id, "ProjectileComponent", function( comp )
		edit_object_field( comp, "config_explosion", "explosion_radius",
			function( explosion_radius ) return explosion_radius + proj_cfg.explosion_radius end, 20 )

		for _, damage_type in ipairs( modifiable_damage_types ) do
			edit_object_field( comp, "damage_by_type", damage_type,
				function( damage ) return damage + proj_cfg[ "damage_" .. damage_type .. "_add" ] end, 0 )
		end

		edit_object_field( comp, "damage_critical", "chance",
			function( chance ) return chance + proj_cfg.damage_critical_chance end, 0 )

		edit_field( comp, "knockback_force",
			function( knockback_force ) return knockback_force + proj_cfg.knockback_force end, 0 )

		edit_field( comp, "bounces_left", function( bounces ) return bounces + proj_cfg.bounces end, 0 )

		edit_field( comp, "blood_count_multiplier",
			function( multiplier ) return multiplier * proj_cfg.blood_count_multiplier end, 1 )

		edit_field( comp, "friendly_fire",
			function( friendly_fire ) return friendly_fire or proj_cfg.friendly_fire end, false )

		edit_field( comp, "lifetime", function( lifetime )
			if lifetime == -1 then return -1 end
			return lifetime + proj_cfg.lifetime_add
		end, 0 )
	end )

	string.gsub( proj_cfg.extra_entities, "[^,]+", function( extra_entity_file )
		EntityLoadToEntity( extra_entity_file, entity_id )
	end )

	string.gsub( proj_cfg.game_effect_entities, "[^,]+", function( game_effect_entity_file )
		EntityAddComponent2( entity_id, "HitEffectComponent", {
			effect_hit = "LOAD_UNIQUE_GAME_EFFECT",
			value_string = game_effect_entity_file,
		} )
	end )

	local offset = math.sqrt( proj_cfg.trail_material_amount )
	string.gsub( proj_cfg.trail_material, "[^,]+", function( trail_material )
		EntityAddComponent2( entity_id, "ParticleEmitterComponent", {
			emitted_material_name = trail_material,
			emit_real_particles = true,
			x_pos_offset_min = -offset,
			x_pos_offset_max = offset,
			y_pos_offset_min = -offset,
			y_pos_offset_max = offset,
			emission_interval_min_frames = 0,
			emission_interval_max_frames = 0,
			is_trail = true,
		} )
	end )

	for _, child_id in pairs( EntityGetAllChildren( entity_id ) or {} ) do
		first_comp( child_id, "VelocityComponent", function( comp )
			edit_vec2_field( comp, "mVelocity", function( vx, vy )
				return vx * proj_cfg.child_speed_multiplier, vy * proj_cfg.child_speed_multiplier
			end, 0, 0 )
		end )
	end
end

function apply_proj_cfg_safe_check( entity_id )
	return EntityGetParent( entity_id ) == 0 and not EntityHasTag( entity_id, "projectile_cloned" )
end