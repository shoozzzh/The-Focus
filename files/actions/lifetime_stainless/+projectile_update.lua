local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent( entity_id )
if parent_id ~= 0 and EntityGetIsAlive( parent_id ) then
	entity_id = parent_id
end
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if not proj_comp then return end
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then
	EntityKill( entity_id )
end
local children = EntityGetAllChildren( shooter_id )
for _, child_id in ipairs( children ) do
	local effect = EntityGetFirstComponent( child_id, "GameEffectComponent" )
	if effect then
		if ComponentGetValue2( effect, "caused_by_stains" ) then
			EntityKill( entity_id )
			return
		end
	end
end