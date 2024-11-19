dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
SetRandomSeed( GameGetFrameNum(), entity_id )
first_comp( entity_id, "VelocityComponent", function( vel_comp )
	edit_vec2_field( vel_comp, "mVelocity", function( vx, vy )
		local multiplier = Randomf( 0.5, 2 )
		return vx * multiplier, vy * multiplier
	end )
end )