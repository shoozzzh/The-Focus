ModTextFileSetContent( "mods/check_id.txt", "check id" )
local mod_name = ModTextFileWhoSetContent( "mods/check_id.txt" )
local pathes = dofile( "mods/" .. mod_name .. "/filepathes.lua" )( mod_name )

-- < functions >

function replace_placeholders_in_file( filepath, filename )
	if filename then
		pathes.THIS_FILE   = filepath .. filename
		pathes.THIS_FOLDER = filepath
	else
		pathes.THIS_FILE   = filepath
	end
	local file_content = ModTextFileGetContent( pathes.THIS_FILE )
	if not file_content then
		return false
	end
	for key, value in pairs( pathes ) do
		file_content = string.gsub( file_content, "__" .. key .. "__", value )
	end
	file_content = string.gsub( file_content, "___", pathes.MOD_PREFIX )
	ModTextFileSetContent( pathes.THIS_FILE, file_content )
	pathes.THIS_FILE   = nil
	pathes.THIS_FOLDER = nil
	return true
end

function dofile_or_default( filepath, default )
	local exists = ModDoesFileExist( filepath )
	if exists then
		local result = dofile( filepath )
		return result or default
	end
	return default
end

function find_value( s, pattern, error_msg )
	_, _, result = string.find( s, pattern )
	if not result and error_msg then print_error( error_msg ) end
	return result
end

-- < / functions >

-- < replace_placeholders_in_general_files >

for _, filename in ipairs( dofile_or_default( pathes.MOD_UTILS .. "files_used_placeholders.lua", {} ) ) do
	replace_placeholders_in_file( pathes.MOD_UTILS, filename )
end
for _, subfolder in ipairs( dofile_or_default( pathes.MOD_UTILS .. "subfolders.lua", {} ) ) do
	local path = pathes.MOD_UTILS .. subfolder .. "/"
	for _, filename in ipairs( dofile_or_default( path .. "files_used_placeholders.lua", {} ) ) do
		replace_placeholders_in_file( path, filename )
	end
end
replace_placeholders_in_file( pathes.MOD_ACTIONS, "action_folder_names.lua" )
replace_placeholders_in_file( pathes.MOD_FILES, "gun_api.lua" )
replace_placeholders_in_file( pathes.MOD_UTILS, "shot_capture.lua" )
replace_placeholders_in_file( pathes.MOD_FILES, "register_actions.lua" )

-- < / replace_placeholders_in_general_files >

-- < append_appendences >

ModLuaFileAppend( "data/scripts/gun/gun_actions.lua", pathes.MOD_FILES .. "register_actions.lua" )
ModLuaFileAppend( "data/scripts/gun/gun.lua", pathes.MOD_FILES .. "gun_api.lua" )
ModLuaFileAppend( "data/scripts/gun/gun.lua", pathes.MOD_UTILS .. "shot_capture.lua" )

do
	local gun_collect_metadata_lua = "data/scripts/gun/gun_collect_metadata.lua"
	local old = ModTextFileGetContent( gun_collect_metadata_lua )
	local start_idx = old:find( "reflecting = true" )
	if not start_idx then
		print_error( "Couldn't find reflecting = true in " .. gun_collect_metadata_lua )
		goto brik
	end
	local new = old:sub( 1, start_idx - 1 )
		.. 'dofile( "' .. pathes.MOD_UTILS .. 'non_rival_weights.lua" )\n'
		.. old:sub( start_idx, -1 )
	new = new:gsub("\r\n\r\n","\r\n")
	ModTextFileSetContent( gun_collect_metadata_lua, new )
end
::brik::

-- < / append_appendences >

-- < auto_add_lua_file_refs_to_xml_files >

local action_folder_names = dofile_once( pathes.MOD_ACTIONS .. "action_folder_names.lua" )

local nxml = dofile_once( pathes.MOD_LIBS .. "nxml.lua" )

local lifetime_to_attrs = {
	[ "init"   ] = {
		execute_on_added      = "1",
		remove_after_executed = "1",
	},
	[ "start"  ] = {
		execute_every_n_frame = "1",
		remove_after_executed = "1",
	},
	[ "done"   ] = {
		execute_every_n_frame = "2",
		remove_after_executed = "1",
	},
	[ "update" ] = {
		execute_every_n_frame = "1",
	},
	[ "end"    ] = {
		execute_on_removed    = "1",
		execute_every_n_frame = "-1",
	},
	[ "every_n_frame" ] = {}, -- specially handled these two below
	[ "nth_frame"     ] = {
		remove_after_executed = "1",
	},
}

local msg_types = {
	"enabled_changed",
	"damage_received",
	"damage_about_to_be_received",
	"item_picked_up",
	"shot",
	"collision_trigger_hit",
	"collision_trigger_timer_finished",
	"physics_body_modified",
	"pressure_plate_change",
	"inhaled_material",
	"death",
	"throw_item",
	"material_area_checker_failed",
	"material_area_checker_success",
	"electricity_receiver_switched",
	"electricity_receiver_electrified",
	"kick",
	"interacting",
	"audio_event_dead",
	"wand_fired",
	"teleported",
	"portal_teleport_used",
	"polymorphing_to",
	"biome_entered",
}

local xml_filenames_to_prefixes = {
	[ "projectile.xml"     ] = "projectile_" ,
	[ "extra_entity.xml" ] = "+projectile_",
	[ "custom_card.xml"    ] = "custom_card_",
}
for _, action_folder_name in ipairs( action_folder_names ) do
	local path = action_folder_name_to_path( action_folder_name )
	for xml_filename, prefix in pairs( xml_filenames_to_prefixes ) do
		local xml_file_content = nxml.parse( ModTextFileGetContent( path .. xml_filename ) or "<Entity/>" )

		for script_lifetime, attrs_prototype in pairs( lifetime_to_attrs ) do
			local script_file = table.concat( { path, prefix, script_lifetime, ".lua" } )
			if not ModDoesFileExist( script_file ) then goto continue end
			local script_content = ModTextFileGetContent( script_file )

			local attrs = {
				_tags = find_value( script_content, '-- tags = "(.-)"' ),
				script_source_file = script_file,
			}
			for k, v in pairs( attrs_prototype ) do
				attrs[ k ] = v
			end
			if script_lifetime == "every_n_frame" or script_lifetime == "nth_frame" then
				attrs.execute_every_n_frame = find_value( script_content, '-- n = (%d+)',
					"Missing line: '-- n = \"[number]\"' in file: " .. script_file )
			end

			xml_file_content:add_child( nxml.new_element( "LuaComponent", attrs ) )
			::continue::
		end

		for _, msg_type in ipairs( msg_types ) do
			local script_file = table.concat( { path, prefix, msg_type, ".lua" } )
			if not ModDoesFileExist( script_file ) then goto continue end
			local script_content = ModTextFileGetContent( script_file )

			local attrs = {
				_tags = find_value( script_content, '-- tags = "(.-)"' ),
				[ "script_" .. msg_type ] = script_file,
			}

			xml_file_content:add_child( nxml.new_element( "LuaComponent", attrs ) )
			::continue::
		end

		ModTextFileSetContent( path .. xml_filename, tostring( xml_file_content ) )
	end
end

-- < / auto_add_lua_files_refs_to_xml_files >

-- < replace_placeholders_in_action_files >

for _, action_folder_name in ipairs( action_folder_names ) do
	local path = action_folder_name_to_path( action_folder_name )
	pathes.ACTION_ID = action_folder_name_to_id( action_folder_name )
	pathes.ACTION_ID_UPPER = pathes.ACTION_ID:upper()
	for _, filename in ipairs( dofile_or_default( path .. "files_used_placeholders.lua", {} ) ) do
		if not replace_placeholders_in_file( path, filename ) then
			print_error( "File doesn't exist at " .. path .. filename )
		end
	end
	for xml_filename, prefix in pairs( xml_filenames_to_prefixes ) do
		replace_placeholders_in_file( path, xml_filename )
		for lifetime, _ in pairs( lifetime_to_attrs ) do
			replace_placeholders_in_file( path, prefix .. lifetime .. ".lua"  )
		end
		for _, msg_type in ipairs( msg_types ) do
			replace_placeholders_in_file( path, prefix .. msg_type .. ".lua" )
		end
	end
	replace_placeholders_in_file( path, "action.lua" )
	replace_placeholders_in_file( path, "gun_injection.lua" )
	replace_placeholders_in_file( path, "game_changes.lua" )
end
pathes.ACTION_ID = nil
pathes.ACTION_ID_UPPER = nil

-- < / replace_placeholders_in_action_files >

-- < auto_complete_common_parts_to_xml >

local xml_filenames_to_completers = {
	-- auto add projectile_file VSC
	[ "projectile.xml"  ] = function( xml_file_content, pathes )
		if xml_file_content.attr.cloneable == "0" then
			xml_file_content.attr.cloneable = nil
			return
		end
		xml_file_content:add_child( nxml.new_element( "VariableStorageComponent",
			{ name = "projectile_file", value_string = pathes.THIS_FILE }
		) )
	end,
	-- auto add base file
	[ "custom_card.xml" ] = function( xml_file_content, pathes )
		local base_named_element = nxml.new_element( "Base", { file = "data/entities/base_custom_card.xml" } )
		-- if using sprite = "..." in action.lua this won't sync with it, TODO: solve it
		local icon = pathes.THIS_FOLDER .. "icon.png"
		base_named_element:add_child( nxml.new_element( "SpriteComponent",
			{ image_file = ModDoesFileExist( icon ) and icon or pathes.MOD_ACTIONS .. "default_icon.png" }
		) )
		base_named_element:add_child( nxml.new_element( "ItemActionComponent",
			{ _tags = "enabled_in_world", action_id = pathes.ACTION_ID_UPPER }
		) )
		xml_file_content:add_child( base_named_element )
	end,
}

for _, action_folder_name in ipairs( action_folder_names ) do
	local path = action_folder_name_to_path( action_folder_name )
	pathes.THIS_FOLDER = path
	pathes.ACTION_ID = action_folder_name_to_id( action_folder_name )
	pathes.ACTION_ID_UPPER = pathes.ACTION_ID:upper()
	for xml_filename, completer in pairs( xml_filenames_to_completers ) do
		pathes.THIS_FILE = path .. xml_filename
		local file_content = ModTextFileGetContent( pathes.THIS_FILE )
		if file_content then
			local xml_file_content = nxml.parse( file_content )
			completer( xml_file_content, pathes )
			ModTextFileSetContent( pathes.THIS_FILE, tostring( xml_file_content ) )
		end
	end
end
pathes.THIS_FOLDER = nil
pathes.ACTION_ID = nil
pathes.ACTION_ID_UPPER = nil
pathes.THIS_FILE = nil

-- < / auto_complete_common_parts_to_xml >

-- < misc_changes >

ModTextFileSetContent( "data/entities/_debug/_free_camera_light.xml",
	ModTextFileGetContent( "data/entities/_debug/free_camera_light.xml" ) )
ModTextFileSetContent( "data/entities/_debug/free_camera_light.xml",
	ModTextFileGetContent( pathes.MOD_UTILS .. "camera/free_camera_light.xml" ) )

for _, action_folder_name in ipairs( action_folder_names ) do
	local path = action_folder_name_to_path( action_folder_name )
	dofile_or_default( path .. "game_changes.lua" )
end

-- < / misc_changes >

-- < i18n_of_actions >

local i18n_tool = dofile( pathes.MOD_FILES .. "i18n_tool.lua" )
for _, action_folder_name in ipairs( action_folder_names ) do
	local path = action_folder_name_to_path( action_folder_name )
	local action_id = action_folder_name_to_id( action_folder_name )
	local action_i18n_data = dofile( path .. "i18n_data.lua" )
	local action_key_prefix = action_id .. "_"
	for lang, translations in pairs( action_i18n_data ) do
		for key, value in pairs( translations ) do
			i18n_tool:add_value( action_key_prefix .. key, lang, value )
		end
	end
end
i18n_tool:apply_i18n_data_to_game()

-- < / i18n_of_actions >