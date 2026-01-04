return function( mod_name )
	local pathes = {}
	pathes.MOD_NAME    = mod_name
	pathes.MOD_PREFIX  = pathes.MOD_NAME .. "_"
	pathes.MOD_FILES   = "mods/" .. pathes.MOD_NAME .. "/files/"
	pathes.MOD_LIBS    = "mods/" .. pathes.MOD_NAME .. "/libs/"
	pathes.MOD_ACTIONS = pathes.MOD_FILES .. "actions/"
	pathes.MOD_UTILS   = pathes.MOD_FILES .. "utils/"
	return pathes
end