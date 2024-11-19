dofile_once( "data/scripts/lib/utilities.lua" )

local x, y = EntityGetTransform( GetUpdatedEntityID() )
GameSetCameraFree( false )
local cam_x, cam_y = GameGetCameraPos()
-- local next_cam_x, next_cam_y = cam_x + ( x - cam_x ) / 4, cam_y + ( y - cam_y ) / 4

-- if math.abs( next_cam_x - x ) > 100 or math.abs( next_cam_y - y ) > 100 then
-- 	local offset_x, offset_y = vec_normalize( cam_x - x, cam_y - y )
-- 	next_cam_x, next_cam_y = vec_multiply( offset_x, offset_y, 100 )
-- 	next_cam_x, next_cam_y = x + next_cam_x, y + next_cam_y
-- end
-- GameSetCameraPos( next_cam_x, next_cam_y )
GameSetCameraPos( x, y )
GameSetCameraFree( true )