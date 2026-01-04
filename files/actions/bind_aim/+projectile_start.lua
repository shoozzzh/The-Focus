dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if not proj_comp then return end
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end
local ctrls_comp = EntityGetFirstComponent( shooter_id, "ControlsComponent" )
if not ctrls_comp then return end

dofile( "__MOD_UTILS__freeze_projectile.lua" )
local proj_x, proj_y, proj_rot = EntityGetTransform( entity_id )
local shooter_x, shooter_y = EntityGetTransform( shooter_id )
local aim_x, aim_y = ComponentGetValue2( ctrls_comp, "mAimingVector" )
local aim_angle = math.atan2( aim_y, aim_x )
local dist = get_distance( proj_x, proj_y, shooter_x, shooter_y )
local theta = math.atan2( proj_y - shooter_y, proj_x - shooter_x ) - aim_angle
local rot = proj_rot - aim_angle
write_var( entity_id, "__ACTION_ID___dist" , "value_float", dist  )
write_var( entity_id, "__ACTION_ID___theta", "value_float", theta )
write_var( entity_id, "__ACTION_ID___rot"  , "value_float", rot   )

EntityAddComponent2( entity_id, "LuaComponent", {
	script_source_file = "__THIS_FOLDER__bind_aim.lua",
	execute_on_added = true,
	execute_every_n_frame = 1,
} )