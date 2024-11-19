local i18n_tool = {}
i18n_tool.i18n_data = {}
local lang_map_to_column = {
	en    = 2,
	ru    = 3,
	pt_br = 4,
	es_es = 5,
	de    = 6,
	fr_fr = 7,
	it    = 8,
	pl    = 9,
	zh_cn = 10,
	jp    = 11,
	ko    = 12,
}
local function get_or_set_to_default( map, key, default )
	local result = map[ key ]
	if result == nil then
		map[ key ] = default
		result = map[ key ]
	end
	return result
end
local function escape_csv_string( str )
	local contains_special_symbols = str:find( "[\n\",]" )
	local result = str:gsub( '"', '""' )
	if contains_special_symbols then result = '"' .. result .. '"' end
	return result
end
function i18n_tool:add_entry( key, lang_map_to_values )
	local i18n_entry = get_or_set_to_default( self.i18n_data, key, {} )
	for lang, value in pairs( lang_map_to_values ) do
		local column = lang_map_to_column[ lang ]
		i18n_entry[ column ] = escape_csv_string( value )
	end
end
function i18n_tool:add_value( key, lang, value )
	local i18n_entry = get_or_set_to_default( self.i18n_data, key, {} )
	i18n_entry[ lang_map_to_column[ lang ] ] = escape_csv_string( value )
end

function i18n_tool:apply_i18n_data_to_game()
	local lines = {}
	for key, values in pairs( self.i18n_data ) do
		values[ 1 ] = key
		for column = 2, 12 do
			if values[ column ] == nil then values[ column ] = "" end
		end
		table.insert( lines, table.concat( values, "," ) .. ",,," ) -- complete the line with 3 blank fields
	end
	local game_i18n_content = ModTextFileGetContent( "data/translations/common.csv" )
	if string.sub( game_i18n_content, -1 ) ~= "\n" then
		game_i18n_content = game_i18n_content .. "\r\n"
	end
	ModTextFileSetContent( "data/translations/common.csv", game_i18n_content .. table.concat( lines, "\r\n" ) .. "\r\n" )
	self.i18n_data = {}
end

return i18n_tool