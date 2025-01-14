local capture_to_this = nil

local function capture_call( name, args )
	capture_to_this[ #capture_to_this + 1 ] = { name, args }
end

local function set_capture_hook( func_name, func )
	return function( ... )
		if capture_to_this ~= nil then
			capture_call( func_name, { ... } )
			return
		end
		func( ... )
	end
end

local shot_func_names = {
	"BeginProjectile",
	"EndProjectile",
	"BeginTriggerTimer",
	"BeginTriggerHitWorld",
	"BeginTriggerDeath",
	"EndTrigger",
	"RegisterGunAction",
	"RegisterGunShotEffects",
	"SetProjectileConfigs",
}

for i, name in ipairs( shot_func_names ) do
	_G[ name ] = set_capture_hook( name, _G[ name ] )
end

function ___capture_shot( shot_caller )
	local old_capture_to_this = capture_to_this
	capture_to_this = {}
	shot_caller()
	local result = capture_to_this
	capture_to_this = old_capture_to_this
	return result
end

function ___release_shot( captured_shot )
	if not captured_shot then return end
	local env = getfenv()
	for i, p in ipairs( captured_shot ) do
		env[ p[1] ]( unpack( p[2] ) )
	end
end