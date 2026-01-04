dofile_once( "__MOD_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if not proj_comp then return end
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end
local ctrls_comp = EntityGetFirstComponent( shooter_id, "ControlsComponent" )
if not ctrls_comp then return end

local dist  = read_var( entity_id, "__ACTION_ID___dist" , "value_float" )
local theta = read_var( entity_id, "__ACTION_ID___theta", "value_float" )
local rot   = read_var( entity_id, "__ACTION_ID___rot"  , "value_float" )
local aim_x, aim_y = ComponentGetValue2( ctrls_comp, "mAimingVector" )
local aim_angle = math.atan2( aim_y, aim_x )
local angle = aim_angle + theta
local diff_x = dist * math.cos( angle )
local diff_y = dist * math.sin( angle )

local shooter_x, shooter_y = EntityGetHotspot( shooter_id, "shoot_pos", true )
if not shooter_x then
	shooter_x, shooter_y = EntityGetTransform( shooter_id )
end
EntitySetTransform( entity_id, shooter_x + diff_x, shooter_y + diff_y, aim_angle + rot )