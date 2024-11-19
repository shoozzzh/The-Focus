dofile_once( "data/scripts/lib/utilities.lua" )
local entity_id = GetUpdatedEntityID()
local x, y, r = EntityGetTransform( entity_id )
local width_half = 24
local height_half = 200

local xa, ya = vec_add( x, y, vec_rotate(  width_half,  height_half, r ) )
local xb, yb = vec_add( x, y, vec_rotate( -width_half,  height_half, r ) )
local xc, yc = vec_add( x, y, vec_rotate( -width_half, -height_half, r ) )
local xd, yd = vec_add( x, y, vec_rotate(  width_half, -height_half, r ) )

local function sign( x1, y1, x2, y2, x0, y0 )
	return ( x2 - x1 ) * ( y0 - y1 ) - ( x0 - x1 ) * ( y2 - y1 )
end

local max_dist = math.sqrt( width_half ^ 2 + height_half ^ 2 )
local hittables = EntityGetInRadiusWithTag( x, y, max_dist, "hittable" ) or {}
local function inflict_damage( victim_id, damage, damage_type, death_cause )
	EntityInflictDamage( victim_id, damage, damage_type, death_cause, "NONE", 0, 0, 0 ) -- accidental death
end
for _, hittable in ipairs( hittables ) do
	local hx, hy = EntityGetTransform( hittable )
	if sign( xa, ya, xb, yb, hx, hy ) * sign( xc, yc, xd, yd, hx, hy ) >= 0
		and sign( xa, ya, xd, yd, hx, hy ) * sign( xc, yc, xb, yb, hx, hy ) >= 0 then
		inflict_damage( hittable, 2.4, "DAMAGE_FIRE"      , "$damage_fire" )
		inflict_damage( hittable, 0.3, "DAMAGE_PROJECTILE", "$damage_projectile" )
	end
end