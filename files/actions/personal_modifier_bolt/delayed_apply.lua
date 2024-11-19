dofile_once( "__MOD_ACTION_UTILS__proj_cfg_utils.lua" )

local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if not proj_comp then return end
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end

local proj_cfg_holders = EntityGetAllChildren( shooter_id, "__ACTION_ID___holder" )
if not proj_cfg_holders or #proj_cfg_holders == 0 then return end
if not apply_proj_cfg_safe_check( entity_id ) then return end

for _, proj_cfg_holder in ipairs( proj_cfg_holders ) do
	local holder_proj_comp = EntityGetFirstComponentIncludingDisabled( proj_cfg_holder, "ProjectileComponent" )
	apply_proj_cfg( read_proj_cfg( holder_proj_comp ), entity_id )
end
local x, y = EntityGetTransform( entity_id )
GamePlaySound( "data/audio/Desktop/misc.snd", "game_effect/invisibility/activate", x, y )
GamePlaySound( "data/audio/Desktop/projectiles.bank", "projectiles/orb_cursed/destroy", x, y )