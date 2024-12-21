local entity_id = GetUpdatedEntityID()
local shooter_id = ComponentGetValue2( EntityGetFirstComponent( entity_id, "ProjectileComponent" ), "mWhoShot" )

if not EntityGetIsAlive( shooter_id ) then
	EntityKill( entity_id )
end

local function sign_of_vx( rot )
	if - math.pi / 2 < rot and rot < math.pi / 2 then
		return 1
	end
	return -1
end

local x_proj, y_proj, rotation, _, _ = EntityGetTransform( entity_id )

local step = 2 * math.pi / 20
local _, _, rot_shooter, scale_x, _ = EntityGetTransform( shooter_id )
local x_direction = sign_of_vx( rotation )
EntitySetTransform( shooter_id, x_proj, y_proj, rot_shooter + x_direction * step, x_direction * math.abs( scale_x ) )