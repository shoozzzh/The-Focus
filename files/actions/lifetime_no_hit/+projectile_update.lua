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
local damage_model = EntityGetFirstComponent( shooter_id, "DamageModelComponent" )
if not damage_model then return end
local last_frame_damaged = ComponentGetValue2( damage_model, "mLastDamageFrame" )
if last_frame_damaged == GameGetFrameNum() then
	EntityKill( entity_id )
end