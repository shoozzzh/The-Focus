dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
first_comp( entity_id, "ProjectileComponent", function( comp )
	ComponentSetValue2( comp, "collide_with_world", false )
	ComponentSetValue2( comp, "collide_with_entities", false )
end )
first_comp( entity_id, "VelocityComponent", function( comp )
	ComponentSetValue2( comp, "liquid_drag", 0 )
	ComponentSetValue2( comp, "displace_liquid", false )
end )

local function remove( comp )
	EntityRemoveComponent( entity_id, comp )
end

for_all_these_comps( entity_id, {
	"AreaDamageComponent", "BlackHoleComponent", "CellEaterComponent", "CharacterCollisionComponent",
	"DamageNearbyEntitiesComponent", "ElectricChargeComponent", "ElectricityComponent",
	"ElectricitySourceComponent", "GameAreaEffectComponent", "HitboxComponent", "LaserEmitterComponent",
	"LevitationComponent", "LiquidDisplacerComponent", "LooseGroundComponent",
	"MagicConvertMaterialComponent",
}, remove )

local function nullify_explosion( comp )
	ComponentObjectSetValue2( comp, "config_explosion", "damage", 0 )
	ComponentObjectSetValue2( comp, "config_explosion", "camera_shake", 0 )
	ComponentObjectSetValue2( comp, "config_explosion", "knockback_force", 0 )
	ComponentObjectSetValue2( comp, "config_explosion", "create_cell_probability", 0 )
	ComponentObjectSetValue2( comp, "config_explosion", "stains_enabled", false )
	ComponentObjectSetValue2( comp, "config_explosion", "ray_energy", 0 )
	ComponentObjectSetValue2( comp, "config_explosion", "hole_enabled", false )
	ComponentObjectSetValue2( comp, "config_explosion", "sparks_enabled", false )
	ComponentObjectSetValue2( comp, "config_explosion", "destroy_non_platform_solid_enabled", false )
	ComponentObjectSetValue2( comp, "config_explosion", "shake_vegetation", false )
	ComponentObjectSetValue2( comp, "config_explosion", "physics_explosion_power", 0, 0 )
end

for_all_these_comps( entity_id, {
	"ExplodeOnDamageComponent", "ExplosionComponent", "LightningComponent", "ProjectileComponent",
}, nullify_explosion )