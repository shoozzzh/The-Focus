local entity_id = GetUpdatedEntityID()
local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
if not vel_comp then return end
local gravity = ComponentGetValue2( vel_comp, "gravity_y" )
SetRandomSeed( GameGetFrameNum() + 97, entity_id + GetUpdatedComponentID() + 199 )
ComponentSetValue2( vel_comp, "gravity_y", vel_comp * Randomf( -1, 1 ) )