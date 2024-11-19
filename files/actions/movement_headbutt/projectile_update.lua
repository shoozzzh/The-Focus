local entity_id = GetUpdatedEntityID()
if not EntityHasTag( entity_id, "___initialized_movement" ) then
	dofile( "__MOD_ACTION_UTILS__movement/projectile_start_manually.lua" )
	EntityAddTag( entity_id, "___initialized_movement" )
end
local function sign_of_vx( angle )
	if - math.pi / 2 < angle and angle < math.pi / 2 then
		return 1
	end
	return -1
end

local x_proj, y_proj, rotation, _, _ = EntityGetTransform( entity_id )
local shooter_id = ComponentGetValue2( EntityGetFirstComponent( entity_id, "ProjectileComponent" ), "mWhoShot" )

if EntityGetIsAlive( shooter_id ) then
	EntitySetTransform( shooter_id, x_proj, y_proj, rotation + math.pi / 2, sign_of_vx( rotation ), 1 )
else
	EntityKill( entity_id )
end