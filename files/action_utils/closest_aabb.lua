dofile_once( "__MOD_LIBS__stream.lua" )

local function offset_factor( center, aabb_min, aabb_max, pos )
	local length = pos > center and aabb_max or aabb_min
	return math.abs( ( pos - center ) / length )
end

-- if a projectile dies in the frame it hit a hitbox, it will teleport to the surface of it
-- so if one of a hitbox's offset factors is 1 which meaning it's on the surface, we just pick it
function closest_mortal_to_hit( x, y )
	local result_pair = stream( EntityGetInRadiusWithTag( x, y, 200, "mortal" ) or {} )
		.flatmap( function( e )
			local ex, ey = EntityGetTransform( e )
			return stream( EntityGetComponent( e, "HitboxComponent" ) or {} )
				.map( function( hitbox )
					local offset_x, offset_y = ComponentGetValue2( hitbox, "offset" )
					local aabb_min_x = ComponentGetValue2( hitbox, "aabb_min_x" )
					local aabb_max_x = ComponentGetValue2( hitbox, "aabb_max_x" )
					local aabb_min_y = ComponentGetValue2( hitbox, "aabb_max_y" )
					local aabb_max_y = ComponentGetValue2( hitbox, "aabb_max_y" )
					return { math.max( offset_factor( ex + offset_x, aabb_min_x, aabb_max_x, x ),
						offset_factor( ey + offset_y, aabb_min_y, aabb_max_y, y ) ), e }
				end )
				.toarray()
		end )
		.min( function( pair1, pair2 )
			if pair1[1] == 1 then return false end
			if pair2[1] == 1 then return true end
			return pair1[1] < pair2[1]
		end )
	if not result or result_pair[1] > 1 then return nil end
	return result_pair[2]
end