dofile_once( "data/scripts/lib/utilities.lua" )
local entity_id = GetUpdatedEntityID()
local pbody2_comp = EntityGetFirstComponent( entity_id, "PhysicsBody2Component" )
-- GamePrint( "pbody2_comp is " .. tostring( pbody2_comp ) )
if not pbody2_comp then return end

PhysicsBody2InitFromComponents( entity_id )
-- ComponentSetValue2( pbody2_comp, "update_entity_transform", false )
local px, py, p_rot = PhysicsComponentGetTransform( pbody2_comp )
print( "p_rot is", tostring(p_rot) )
local x, y, r = EntityGetTransform( entity_id )
x, y = GamePosToPhysicsPos( x, y )
local dist = get_distance( x, y, px, py )
local theta = math.atan2( py - y, px - x ) - r
-- local rot = p_rot - r
EntityAddComponent2( entity_id, "VariableStorageComponent", { name = "pbody_offset_dist" , value_float = dist  } )
EntityAddComponent2( entity_id, "VariableStorageComponent", { name = "pbody_offset_theta", value_float = theta } )
-- EntityAddComponent2( entity_id, "VariableStorageComponent", { name = "pbody_offset_rot"  , value_float = rot   } )