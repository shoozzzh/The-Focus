dofile_once( "__MOD_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if not proj_comp then return end
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end
local diff_x = read_var( entity_id,  "__ACTION_ID___diff_x", "value_float" )
local diff_y = read_var( entity_id,  "__ACTION_ID___diff_y", "value_float" )
local shooter_x, shooter_y = EntityGetTransform( shooter_id )
EntitySetTransform( entity_id, shooter_x + diff_x, shooter_y + diff_y )

