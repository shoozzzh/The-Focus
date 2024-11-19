dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local x, y, r = EntityGetTransform( entity_id )
local angle = get_and_update_var( entity_id, 
	"__ACTION_ID___angle", "value_float", function( a ) return a + math.pi / 6 end, -math.pi / 2 )

local radius = get_magnitude( GameGetVelocityCompVelocity( entity_id ) ) / 60 * 6
radius = ( radius + 1 ) ^ ( 2 / 3 ) - 1

local offset_x, offset_y = rad_to_vec( r + angle )
EntitySetTransform( entity_id, x + offset_x * radius, y + offset_y * radius )