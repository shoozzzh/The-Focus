local entity_id = GetUpdatedEntityID()
local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
local gravity = ComponentGetValue2( vel_comp, "gravity_y" )
SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() + 199 )
ComponentSetValue2( vel_comp, "gravity_y", gravity + 600 * Randomf( -1, 1 ) )