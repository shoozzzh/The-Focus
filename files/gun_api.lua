local injectable_func_names = {
	"_set_gun",
	"order_deck",
	"_draw_actions_for_shot",
	"_clear_deck",
	"_add_card_to_deck",
	"set_current_action",
	"move_hand_to_discarded",
	"ActionUsesRemainingChanged",
}
local injectable_funcs = {}
for _, name in ipairs( injectable_func_names ) do
	injectable_funcs[ name ] = _G[ name ]
end
-- a hack to solve that the game doesn't push ActionUsesRemainingChanged() to gun.lua while collecting metadata
injectable_funcs[ "ActionUsesRemainingChanged" ] =
	injectable_funcs[ "ActionUsesRemainingChanged" ] or function() end

local injections = {}

local injection_mt = {
	__index = function( injection, func_name )
		if injectable_funcs[ func_name ] then
			local v = {}
			injection[ func_name ] = v
			return v
		end
	end
}
function new_injection()
	local injection = {}
	setmetatable( injection, injection_mt )
	return injection
end

local action_folder_names = dofile_once( "__MOD_ACTIONS__action_folder_names.lua" )
for _, action_folder_name in ipairs( action_folder_names ) do
	local path = action_folder_name_to_path( action_folder_name ) .. "gun_injection.lua"
	if ModDoesFileExist( path ) then
		table.insert( injections, dofile_once( path ) )
	end
end

for func_name, func in pairs( injectable_funcs ) do
	local valid_injections = {}
	for _, injection in ipairs( injections ) do
		local injection_to_this = rawget( injection, func_name )
		for tipe, args in pairs( injection_to_this or {} ) do
			local func_with_priority
			if type( args ) == "function" then
				func_with_priority = { 0, args }
			elseif type( args ) == "table" then
				func_with_priority = args
			end

			local typed_funcs_to_inject = valid_injections[ tipe ]
			if typed_funcs_to_inject then
				table.insert( typed_funcs_to_inject, func_with_priority )
			else
				valid_injections[ tipe ] = { func_with_priority }
			end
		end
	end
	for _, funcs in pairs( valid_injections ) do
		table.sort( funcs, function( a, b ) return a[1] <= b[1] end )
		for idx, func_with_priority in ipairs( funcs ) do
			funcs[ idx ] = func_with_priority[2]
		end
	end

	for _, f in ipairs( valid_injections.proxy or {} ) do
		local func_ = func
		func = function( ... )
			return f( func_, ... )
		end
	end
	injectable_funcs[ func_name ] = function( ... )
		for _, f in ipairs( valid_injections.pre or {} ) do
			f( ... )
		end

		local result = func( ... )

		for _, f in ipairs( valid_injections.spy or {} ) do
			f( result, ... )
		end

		for _, f in ipairs( valid_injections.post or {} ) do
			f( ... )
		end

		return result
	end
end

for func_name, func in pairs( injectable_funcs ) do
	_G[ func_name ] = func
end

for _, injection in ipairs( injections ) do
	if injection.initializer then
		injection.initializer()
	end
end
