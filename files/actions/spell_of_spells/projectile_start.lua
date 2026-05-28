local entity_id = GetUpdatedEntityID()

local data = EntityGetAllChildren(entity_id, "__ACTION_ID___data")[1]
data = EntityGetFirstComponent(data, "ProjectileComponent")
data = ComponentObjectGetValue2(data, "config", "action_description")
ModTextFileSetContent("__THIS_FOLDER__data.lua", data:gsub("%^", '"'))
data = loadfile("__THIS_FOLDER__data.lua")()

local proj_comp = EntityGetFirstComponent(entity_id, "ProjectileComponent")
ComponentSetValue2(proj_comp, "damage", data.damage)

local x, y, r, scale_x, scale_y = EntityGetTransform(entity_id)
x = x - math.sin(r) * 9
y = y + math.cos(r) * 9
local action_entity = CreateItemActionEntity(data.target_id, x, y)
EntitySetTransform(action_entity, x, y, r, scale_x, scale_y)
EntityApplyTransform(action_entity, x, y, r, scale_x, scale_y)

local allowed_comp_type = {
    SpriteComponent = true,
    SpriteOffsetAnimatorComponent = true,
    ParticleEmitterComponent = true,
    SpriteParticleEmitterComponent = true,
}

local function comp_check(c)
    if not allowed_comp_type[ComponentGetTypeName(c)] then
        return false
    end
    if ComponentHasTag(c, "enabled_in_hand") or ComponentHasTag(c, "enabled_in_inventory") then
        return false
    end
    if ComponentHasTag(c, "item_unidentified") then
        return false
    end
    return true
end
for _, c in ipairs(EntityGetAllComponents(action_entity)) do
    if not comp_check(c) then
        EntityRemoveComponent(action_entity, c)
    end
end

for _, c in ipairs(EntityGetAllComponents(action_entity)) do
    if ComponentGetTypeName(c) == "SpriteOffsetAnimatorComponent" and ComponentGetValue2(c, "sprite_id") < 3 then
        ComponentSetValue2(c, "x_amount", 0)
        ComponentSetValue2(c, "y_amount", 0)
    elseif ComponentGetTypeName(c) == "SpriteComponent" then
        ComponentSetValue2(c, "offset_animator_offset", 0, 0)
        -- local spe_comp = EntityAddComponent2(entity_id, "SpriteParticleEmitterComponent", {
        --     sprite_file = ComponentGetValue2(c, "image_file"),
        --     sprite_centered = true,
        --     z_index = -0.5,
        --     lifetime = 0.01,
        --     emission_interval_min_frames = 1,
        --     emission_interval_max_frames = 1,
        --     count_min = 1,
        --     count_max = 1,
        -- })
        -- ComponentSetValue2(spe_comp, "velocity", 0, 0)
        -- local offset_x = ComponentGetValue2(c, "offset_x")
        -- local offset_y = ComponentGetValue2(c, "offset_y") - 9
        -- ComponentSetValue2(spe_comp, "randomize_position", offset_x, offset_y, offset_x, offset_y)
        -- ComponentSetValue2(spe_comp, "velocity", 0, 0)
        -- if ComponentGetValue2(c, "has_special_scale") then
        --     local special_scale_x = ComponentGetValue2(c, "special_scale_x")
        --     local special_scale_y = ComponentGetValue2(c, "special_scale_y")
        --     ComponentSetValue2(spe_comp, "scale", special_scale_x, special_scale_y)
        -- end
        -- ComponentSetValue2(spe_comp, "z_index", ComponentGetValue2(c, "z_index"))
    end
end

local it_comp = EntityAddComponent2(action_entity, "InheritTransformComponent", {})
ComponentSetValue2(it_comp, "Transform", 0, 9, 1, 1, 0)

EntityAddChild(entity_id, action_entity)

local vel_comp = EntityGetFirstComponent(entity_id, "VelocityComponent")
local vx, vy = ComponentGetValue2(vel_comp, "mVelocity")
ComponentSetValue2(vel_comp, "mVelocity", vx * 80, vy * 80)
