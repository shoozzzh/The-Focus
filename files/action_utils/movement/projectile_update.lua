local entity_id = GetUpdatedEntityID()
local shooter_id = ComponentGetValue2( EntityGetFirstComponent( entity_id, "ProjectileComponent" ), "mWhoShot" )
local x, y = EntityGetTransform( entity_id )
local vx, vy = GameGetVelocityCompVelocity( entity_id )
local hit_tag = dofile( "__THIS_FOLDER__get_nearby_tag.lua" )
local last_frame_tagged = EntityGetWithTag( hit_tag )
for _, tagged in ipairs( last_frame_tagged ) do
	EntityRemoveTag( tagged, hit_tag )
end
local hittables_in_radius = EntityGetInRadiusWithTag( x, y, vx + vy, "hittable" )
for _, hittable in ipairs( hittables_in_radius ) do
	if hittable ~= shooter_id then
		EntityAddTag( hittable, hit_tag )
	end
end