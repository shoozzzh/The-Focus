dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )
local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end

local multiplier = 2.0

do
	local shooter_wallet_comp = EntityGetFirstComponent( shooter_id, "WalletComponent" )
	local mat_inv_comp     = EntityGetFirstComponent( entity_id , "MaterialInventoryComponent" )
	local mat_sucked = ComponentGetValue2( mat_inv_comp, "count_per_material_type" )
	for mat, count in ipairs( mat_sucked ) do
		if count > 0 then
			edit_field( shooter_wallet_comp, "money", function( m ) return m + count * 1.5 end, 0 )
		end
	end
	RemoveMaterialInventoryMaterial( entity_id )
end

do
	local x, y                 = EntityGetTransform( entity_id  )
	local shooter_x, shooter_y = EntityGetTransform( shooter_id )
	local gold_nuggets = EntityGetInRadiusWithTag( x, y, 16, "gold_nugget" )
	for _, gold_nugget_id in ipairs( gold_nuggets ) do
		read_and_update_var( gold_nugget_id, "gold_value", "value_int", function( v ) return v * 1.5 end )
		EntitySetTransform( entity_id, shooter_x, shooter_y )
		EntityLoad( "data/entities/particles/teleportation_source.xml", x, y )
		EntityLoad( "data/entities/particles/teleportation_target.xml", shooter_x, shooter_y )
	end
end