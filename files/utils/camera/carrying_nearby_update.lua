local x, y = EntityGetTransform( GetUpdatedEntityID() )
GameSetCameraFree( true )
local cam_x, cam_y = GameGetCameraPos()
GameSetCameraPos( cam_x + ( x - cam_x ) / 10, cam_y + ( y - cam_y ) / 10 )