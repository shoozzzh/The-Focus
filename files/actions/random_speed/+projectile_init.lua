local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if not proj_comp then return end

SetRandomSeed( GameGetFrameNum() + 102, entity_id + GetUpdatedComponentID() + 57 )
local speed = RandomDistributionf( 0, 1000, 500, 1, 0 )
ComponentSetValue2( proj_comp, "speed_min", speed )
ComponentSetValue2( proj_comp, "speed_max", speed )