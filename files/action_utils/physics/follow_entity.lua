dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )
local entity_id = GetUpdatedEntityID()
local x, y, _ = EntityGetTransform( entity_id )
x, y = GamePosToPhysicsPos( x, y )
local vel_x, vel_y = GameVecToPhysicsVec( GameGetVelocityCompVelocity( entity_id ) )
local pbody2_comp = EntityGetFirstComponent( entity_id, "PhysicsBody2Component" )
if not pbody2_comp then return end
local _, _, r = PhysicsComponentGetTransform( pbody2_comp )
local dist  = read_var( entity_id, "pbody_offset_dist" , "value_float" )
local theta = read_var( entity_id, "pbody_offset_theta", "value_float" )
local angle = r + theta
local offset_x = dist * math.cos( angle )
local offset_y = dist * math.sin( angle )

PhysicsComponentSetTransform( pbody2_comp, x + offset_x, y + offset_y, r, vel_x, vel_y )

-- This will snap physics pos to entity pos
-- which is not what we want because the physics pos of a pbody is on its corner
-- EntityApplyTransform( entity_id, x, y )