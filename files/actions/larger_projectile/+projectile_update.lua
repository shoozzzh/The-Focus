if not dofile( "__MOD_ACTION_UTILS__unique_script.lua" ) then return end

dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )
dofile_once( "__MOD_LIBS__stream.lua" )

local entity_id = GetUpdatedEntityID()
local multiplier =
	stream( EntityGetComponentIncludingDisabled( entity_id, "VariableStorageComponent" ) )
	.filter( function( c ) return ComponentGetValue2( c, "name" ) == "___projectile_sizer" end )
	.map( function( c ) return ComponentGetValue2( c, "value_float" ) end )
	.reduce( 1, function( a, b ) return a * b end )
local x, y, r, scale_x, scale_y = EntityGetTransform( entity_id )
local function sign( n )
	return n > 0 and 1 or n == 0 and 0 or -1
end

EntitySetTransform( entity_id, x, y, r, sign( scale_x ) * multiplier, sign( scale_y ) * multiplier )

local function keep_fields_multiplied( comp, ... )
	local fields = { ... }
	for _, field in ipairs( fields ) do
		local value = ComponentGetValue2( comp, field )
		ComponentSetValue2( comp, field, sign( value ) * multiplier )
	end
end
for_comps( entity_id, "SpriteComponent", function( comp )
	if ComponentGetValue2( comp, "has_special_scale" ) then
		keep_fields_multiplied( comp, "special_scale_x", "special_scale_y" )
	end
end )