-- n = 6
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "__MOD_ACTION_UTILS__comp_utils.lua" )

if not dofile( "__MOD_ACTION_UTILS__unique_script.lua" ) then return end

local entity_id = GetUpdatedEntityID()
local vel_comp = EntityGetFirstComponent( entity_id, "VelocityComponent" )
if not vel_comp then return end
local gravity_sign = read_var( entity_id, "___gravity_sign", "value_int" )
local num = #EntityGetComponent( entity_id, "VariableStorageComponent", "__ACTION_ID__" )
local angle = gravity_sign * 2 * math.pi  / ( num + 2 )
local vx, vy = ComponentGetValueVector2( vel_comp, "mVelocity" )
ComponentSetValueVector2( vel_comp, "mVelocity", vec_rotate( vx, vy, angle ) )