local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent( entity_id )
if parent_id ~= 0 then
	entity_id = parent_id
end
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if not proj_comp then return end
ComponentSetValue2( proj_comp, "lifetime", -1 )