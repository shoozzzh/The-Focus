dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end

local mv_child_id = ( EntityGetAllChildren( shooter_id, "___movement_shooter_child" ) or {} )[1]
if not EntityGetIsAlive( mv_child_id ) then
	mv_child_id = EntityLoad( "__THIS_FOLDER__shooter_child.xml" )
	EntityAddChild( shooter_id, mv_child_id )
end

local last_movement = read_and_update_var( mv_child_id, "___current_movement", "value_int", function() return entity_id end )
if EntityGetIsAlive( last_movement ) then
	EntityKill( last_movement )
else
	local transform_comp = EntityGetFirstComponentIncludingDisabled( mv_child_id, "AttachToEntityComponent" )
	local _, _, rotation, scale_x, scale_y = EntityGetTransform( shooter_id )
	ComponentSetValue2( transform_comp, "Transform", 0, 0, scale_x, scale_y, rotation )
end

local hit_tag = dofile( "__THIS_FOLDER__get_nearby_tag.lua" )
ComponentSetValue2( proj_comp, "collide_with_tag", hit_tag )

EntitySetComponentsWithTagEnabled( entity_id, "___movement_impl", true )