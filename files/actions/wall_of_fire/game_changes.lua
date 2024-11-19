local file = "data/scripts/buildings/sun/sun_collision.lua"
local injection = [[
	CreateItemActionEntity( "__ACTION_ID__", x, y )
	AddFlagPersistent( "card_unlocked___ACTION_ID__" )
]]
local inject_at = 'AddFlagPersistent( "secret_supernova" )'
ModTextFileSetContent( file, ModTextFileGetContent( file ):gsub( inject_at, inject_at .. injection ) )