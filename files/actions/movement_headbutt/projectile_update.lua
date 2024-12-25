-- tags = "___movement"

dofile( "__MOD_ACTION_UTILS__movement/projectile_update.lua" )

local entity_id = GetUpdatedEntityID()

local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end

local function sign_of_vx( rot )
	if - math.pi / 2 < rot and rot < math.pi / 2 then
		return 1
	end
	return -1
end

local x_proj, y_proj, rotation, _, _ = EntityGetTransform( entity_id )

local _, _, _, scale_x, _ = EntityGetTransform( shooter_id )
local x_direction = sign_of_vx( rotation )
EntitySetTransform( shooter_id,
	x_proj, y_proj, rotation + x_direction * math.pi / 2, x_direction * math.abs( scale_x ) )
EntityApplyTransform( shooter_id,
	x_proj, y_proj, rotation + x_direction * math.pi / 2, x_direction * math.abs( scale_x ) )