dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if not proj_comp then return end
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end

dofile( "__MOD_ACTION_UTILS__freeze_projectile.lua" )
local proj_x, proj_y = EntityGetTransform( entity_id )
local shooter_x, shooter_y = EntityGetTransform( shooter_id )
local diff_x, diff_y = proj_x - shooter_x, proj_y - shooter_y
write_var( entity_id, "__ACTION_ID___diff_x", "value_float", diff_x )
write_var( entity_id, "__ACTION_ID___diff_y", "value_float", diff_y )

EntityAddComponent2( entity_id, "LuaComponent", {
	script_source_file = "__THIS_FOLDER__bind_static.lua",
	execute_on_added = true,
	execute_every_n_frame = 1,
} )