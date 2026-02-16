dofile_once "__MOD_UTILS__comp_utils.lua"
local entity_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local shooter_id = ComponentGetValue2( proj_comp, "mWhoShot" )
if not EntityGetIsAlive( shooter_id ) then return end

local ig_comp = EntityGetFirstComponent( shooter_id, "IngestionComponent" )
if not ig_comp then return end

local size_remaining = ComponentGetValue2( ig_comp, "ingestion_capacity" ) -
    ComponentGetValue2( ig_comp, "ingestion_size" )

if size_remaining <= 0 then
    return
end

local mat_inv_comp = EntityGetFirstComponent( entity_id, "MaterialInventoryComponent" )
local mat_sucked = ComponentGetValue2( mat_inv_comp, "count_per_material_type" )
for mat, count in ipairs( mat_sucked ) do
    if count > 0 then
        count = math.min( count, size_remaining )
        EntityIngestMaterial( shooter_id, mat, count )
        size_remaining = size_remaining - count
    end
end
RemoveMaterialInventoryMaterial( entity_id )
