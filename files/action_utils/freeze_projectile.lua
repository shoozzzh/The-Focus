local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if proj_comp then
	ComponentSetValue2( proj_comp, "die_on_low_velocity", false )
end
local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
if vel_comp then
	ComponentSetValue2( vel_comp, "air_friction", 0 )
	ComponentSetValue2( vel_comp, "gravity_y", 0 )
	ComponentSetValueVector2( vel_comp, "mVelocity", 0, 0 )
end