-- n = 6
local entity_id = GetUpdatedEntityID()
local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
if not vel_comp then return end
local vx, vy = ComponentGetValueVector2( vel_comp, "mVelocity" )
ComponentSetValueVector2( vel_comp, "mVelocity", -vx, -vy )