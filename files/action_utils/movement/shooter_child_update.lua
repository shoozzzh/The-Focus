dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local transform_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "AttachToEntityComponent" )
if not transform_comp then return end
local heartbeat = read_and_update_var( entity_id, "movement_heartbeat", "value_bool", false )
if heartbeat then return end

local parent_id = EntityGetParent( entity_id )
local _, _, scale_x, scale_y, rotation = ComponentGetValue2( transform_comp, "Transform" )
local x, y = EntityGetTransform( parent_id )
EntitySetTransform( parent_id, x, y, rotation, scale_x, scale_y )
shoot_projectile( parent_id, "__MOD_ACTION_UTILS__teleportation_to_free_space.xml", x, y, 0, 0, false )

EntityKill( entity_id )