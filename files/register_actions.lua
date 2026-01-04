local action_templates = {}

function use_templates( action )
	setmetatable( action, { __index = action_templates } )
	return action
end

function action_templates:template_projectile()
	self.type = self.type or ACTION_TYPE_PROJECTILE
	local related_projectile
	if self.related_projectiles then
		related_projectile = self.related_projectiles[1]
	else
		related_projectile = PATH .. "projectile.xml"
		self.related_projectiles = { related_projectile }
	end
	self.action = self.action or function()
		add_projectile( related_projectile )
	end
	return self:decorate_action_fn()
end

function action_templates:template_projectile_repetitive( times )
	self.type = self.type or ACTION_TYPE_PROJECTILE
	local related_projectile
	if self.related_projectiles then
		related_projectile = self.related_projectiles[1]
	else
		related_projectile = PATH .. "projectile.xml"
		self.related_projectiles = { related_projectile, times }
	end
	self.action = self.action or function()
		for i = 1, times do
			add_projectile( related_projectile )
		end
	end
	return self:decorate_action_fn()
end

function action_templates:decorate_action_fn()
	if self.action == nil then
		self.action = function()
			draw_actions( 1, true )
		end
	end
	if self._and_then ~= nil then
		local action = self.action
		-- the reference inside the table will be removed by remove_unnecessary_args soon, so it's not reliable
		local and_then = self._and_then
		self.action = function()
			action()
			and_then()
		end
	end
	if self._before_that ~= nil then
		local action = self.action
		local before_that = self._before_that
		self.action = function()
			before_that()
			action()
		end
	end
	return self
end

function action_templates:template_blank()
	self.action = function() return end
	return self
end

function action_templates:template_passive()
	self.type = self.type or ACTION_TYPE_PASSIVE
	return self:decorate_action_fn()
end

function action_templates:template_simple_modifier()
	self.type = self.type or ACTION_TYPE_MODIFIER
	return self:decorate_action_fn()
end

function action_templates:template_extra_entity_modifier()
	self.type = self.type or ACTION_TYPE_MODIFIER
	local extra_entities_concat
	if self.related_extra_entities == nil then
		extra_entities_concat = PATH .. "extra_entity.xml,"
		self.related_extra_entities = { PATH .. "extra_entity.xml" }
	else
		extra_entities_concat = table.concat( self.related_extra_entities, "," ) .. ","
	end
	self.action = function()
		c.extra_entities = c.extra_entities .. extra_entities_concat
		draw_actions( 1, true )
	end
	return self:decorate_action_fn()
end

function action_templates:template_condition()
	self.type                = self.type                or ACTION_TYPE_OTHER
	self.spawn_requires_flag = self.spawn_requires_flag or "card_unlocked_maths"
	self._spawn_prob_map     = self._spawn_prob_map     or { [10] = 1 }
	self.mana                = self.mana                or 0
	local condition = self._condition
	self.action = function( recursion_level, iteration )
		local endpoint = -1
		local elsepoint = -1
		local doskip = not condition()

		-- same as vanilla
		if ( #deck > 0 ) then
			for i,v in ipairs( deck ) do
				if ( v ~= nil ) then
					if ( string.sub( v.id, 1, 3 ) == "IF_" ) and ( v.id ~= "IF_END" ) and ( v.id ~= "IF_ELSE" ) then
						endpoint = -1
						break
					end
					if ( v.id == "IF_ELSE" ) then
						endpoint = i
						elsepoint = i
					end	
					if ( v.id == "IF_END" ) then
						endpoint = i
						break
					end
				end
			end

			local envelope_min = 1
			local envelope_max = 1
			if doskip then
				if ( elsepoint > 0 ) then
					envelope_max = elsepoint
				elseif ( endpoint > 0 ) then
					envelope_max = endpoint
				end
				for i = envelope_min, envelope_max do
					local v = deck[ envelope_min ]
					if ( v ~= nil ) then
						table.insert( discarded, v )
						table.remove( deck, envelope_min )
					end
				end
			else
				if ( elsepoint > 0 ) then
					envelope_min = elsepoint
					if ( endpoint > 0 ) then
						envelope_max = endpoint
					else
						envelope_max = #deck
					end
					for i = envelope_min,envelope_max do
						local v = deck[  envelope_min ]
						if ( v ~= nil ) then
							table.insert( discarded, v )
							table.remove( deck, envelope_min )
						end
					end
				end
			end
		end
		draw_actions( 1, true )
	end
	return self:decorate_action_fn()
end

function remove_unnecessary_args( action )
	for k, v in pairs( action ) do
		-- starts with a "_" means unnecessary
		if k:sub( 1, 1 ) == "_" then
			action[ k ] = nil
		end
	end
	setmetatable( action, nil )
end

function parse_spawn_prob_map( action )
	if action._spawn_prob_map == nil then return end
	local spawn_level = {}
	local spawn_probability = {}
	for l, p in pairs( action._spawn_prob_map ) do
		table.insert( spawn_level, l )
		table.insert( spawn_probability, p )
	end
	action.spawn_level = table.concat( spawn_level, "," )
	action.spawn_probability = table.concat( spawn_probability, "," )
end

function parse_flag_unlocked( action )
	if action._flag_unlocked == nil then return end
	action.spawn_requires_flag = "card_unlocked_" .. action._flag_unlocked
end

local function extra_entity_concator( path )
	local extra_entity = path .. "extra_entity.xml,"
	return function()
		c.extra_entities = c.extra_entities .. extra_entity
	end
end

function limited_speed_multiplier( multiplier )
	c.speed_multiplier = c.speed_multiplier * multiplier
	if ( c.speed_multiplier >= 20 ) then
		c.speed_multiplier = math.min( c.speed_multiplier, 20 )
	elseif ( c.speed_multiplier < 0 ) then
		c.speed_multiplier = 0
	end
end

local action_folder_names = dofile_once( "__MOD_ACTIONS__action_folder_names.lua" )
for _, action_folder_name in ipairs( action_folder_names ) do
	PATH = action_folder_name_to_path( action_folder_name )
	__concat_extra_entity = extra_entity_concator( PATH )
	local action = dofile_once( PATH .. "action.lua" )
	local action_id = action_folder_name_to_id( action_folder_name )
	parse_spawn_prob_map( action )
	parse_flag_unlocked( action )
	remove_unnecessary_args( action )
	action.id          = string.upper( action_id )
	action.name        = "$" .. action_id .. "_action_name"
	action.description = "$" .. action_id .. "_action_desc"
	action.mod         = "__MOD_NAME__"
	action.author      = "Shug"
	if not action.sprite then
		local icon = PATH .. "icon.png"
		action.sprite = ModDoesFileExist( icon ) and icon or "__MOD_ACTIONS__default_icon.png"
	end
	local custom_card = PATH .. "custom_card.xml"
	if ModDoesFileExist( custom_card ) then
		action.custom_xml_file = custom_card
	end
	table.insert( actions, action )
end

PATH = nil