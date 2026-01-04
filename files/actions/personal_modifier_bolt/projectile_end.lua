dofile_once( "__MOD_UTILS__proj_cfg_utils.lua" )
dofile_once( "__MOD_UTILS__closest_aabb.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
local shooter_to_be = closest_mortal_to_hit( x, y )
if not shooter_to_be then return end

local proj_cfg = read_proj_cfg( EntityGetFirstComponent( entity_id, "ProjectileComponent" ) )

if not EntityGetComponentIncludingDisabled( shooter_to_be, "LuaComponent", "__ACTION_ID__" ) then
	EntityAddComponent2( shooter_to_be, "LuaComponent", {
		_tags = "__ACTION_ID__",
		script_shot = "__THIS_FOLDER__shot.lua",
	} )
end

local proj_cfg_holder = EntityLoad( "__THIS_FOLDER__proj_cfg_holder.xml" )
EntityAddChild( shooter_to_be, proj_cfg_holder )
local proj_comp = EntityGetFirstComponentIncludingDisabled( proj_cfg_holder, "ProjectileComponent" )
store_proj_cfg( proj_comp, proj_cfg )