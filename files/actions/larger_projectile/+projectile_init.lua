dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local multiplier = 1.3
local x, y, r, scale_x, scale_y = EntityGetTransform( entity_id )
EntitySetTransform( entity_id, x, y, r, scale_x * multiplier, scale_y * multiplier )
local function multiply_fields( comp, ... )
	local fields = { ... }
	for _, field in ipairs( fields ) do
		local value = ComponentGetValue2( comp, field )
		ComponentSetValue2( comp, field, value * multiplier )
	end
end
local function sign( n )
	return n > 0 and 1 or n == 0 and 0 or -1
end
local function multiply_fields_pixel_max( comp, ... )
	local fields = { ... }
	for _, field in ipairs( fields ) do
		local value = ComponentGetValue2( comp, field ) + 0.5
		ComponentSetValue2( comp, field, value * multiplier - 0.5 )
	end
end
local function multiply_fields_pixel_min( comp, ... )
	local fields = { ... }
	for _, field in ipairs( fields ) do
		local value = ComponentGetValue2( comp, field ) - 0.5
		ComponentSetValue2( comp, field, value * multiplier + 0.5 )
	end
end
local function multiply_object_fields( comp, object_name, ... )
	local fields = { ... }
	for _, field in ipairs( fields ) do
		local value = ComponentObjectGetValue2( comp, object_name, field )
		ComponentObjectSetValue2( comp, object_name, field, value * multiplier )
	end
end
local function multiply_vec2( comp, vec2_name )
	local left, right = ComponentGetValue2( comp, vec2_name )
	ComponentSetValue2( comp, vec2_name, left * multiplier, right * multiplier )
end
local old_for_comps = for_comps
local function for_comps( comp_name, do_what )
	old_for_comps( entity_id, comp_name, do_what )
end 
for_comps( "ProjectileComponent", function( comp )
	multiply_fields( comp, "velocity_sets_scale_coeff" )
end )
for_comps( "SpriteComponent", function( comp )
	if ComponentGetValue2( comp, "has_special_scale" ) then
		multiply_fields( comp, "special_scale_x", "special_scale_y" )
	end
end )
for_comps( "ParticleEmitterComponent", function( comp )
	multiply_fields_pixel_min( comp, "x_pos_offset_min", "y_pos_offset_min" )
	multiply_fields_pixel_max( comp, "x_pos_offset_max", "y_pos_offset_max" )
	multiply_vec2( comp, "offset" )
	multiply_vec2( comp, "area_circle_radius" )
	-- squared multiplier for these two
	multiply_fields( comp, "count_min", "count_max" )
	multiply_fields( comp, "count_min", "count_max" )
end )
for_comps( "SpriteParticleEmitterComponent", function( comp )
	multiply_fields( comp, "count_min", "count_max" )
	multiply_fields( comp, "count_min", "count_max" )
	local min_x, min_y, max_x, max_y = ComponentGetValue2( comp, "randomize_position" )
	ComponentSetValue2( comp, "randomize_position",
		min_x * multiplier, min_y * multiplier, max_x * multiplier, max_y * multiplier )
end )
for_comps( "HitboxComponent", function( comp )
	multiply_fields( comp, "aabb_min_x", "aabb_max_x", "aabb_min_y", "aabb_max_y" )
end )
for_comps( "AreaDamageComponent", function( comp )
	multiply_vec2( comp, "aabb_min" )
	multiply_vec2( comp, "aabb_max" )
end )
for_comps( "GameAreaEffectComponent", function( comp )
	multiply_fields( comp, "radius" )
end )
for_comps( "LaserEmitterComponent", function( comp )
	multiply_object_fields( comp, "laser", "beam_radius", "max_length" )
end )
for_comps( "CellEaterComponent", function( comp )
	multiply_fields( comp, "radius" )
end )
for_comps( "CollisionTriggerComponent", function( comp )
	multiply_fields( comp, "radius", "width", "height" )
end )
for_comps( "BlackHoleComponent", function( comp )
	multiply_fields( comp, "radius" )
end )
for_comps( "LightComponent", function( comp )
	multiply_fields( comp, "radius" )
end )
for_comps( "LevitationComponent", function( comp )
	multiply_fields( comp, "radius" )
end )
for_comps( "CharacterDataComponent", function( comp )
	multiply_fields( comp, "buoyancy_check_offset_y", "check_collision_max_size_x", "check_collision_max_size_y",
	"eff_hg_position_x", "eff_hg_position_y", "eff_hg_size_x", "eff_hg_size_y", "eff_hg_offset_y",
	"collision_aabb_min_x", "collision_aabb_max_x", "collision_aabb_min_y", "collision_aabb_max_y" )
end )

local child_entities = EntityGetAllChildren( entity_id ) or {}
for _, child_id in ipairs( child_entities ) do
	EntityAddComponent2( child_id, "LuaComponent", {
		script_source_file = "__THIS_FILE__",
		execute_on_added = true,
		remove_after_executed = true,
	} )
end