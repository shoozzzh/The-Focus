local action_id_to_idx = {}
for idx, action in ipairs( actions ) do
	action_id_to_idx[ action.id ] = idx
end

local function split( str )
	if str:sub( -1, -1 ) ~= "," then
		str = str .. ","
	end
	local result = {}
	for s in str:gmatch( "(..-)," ) do
		table.insert( result, tonumber( s ) )
	end
	return result
end

function to_prob_map( spawn_level, spawn_probability )
	local level_set       = split( spawn_level )
	local probability_set = split( spawn_probability )
	local prob_map = {}
	for idx, level in ipairs( level_set ) do
		prob_map[ level ] = probability_set[ idx ]
	end
	return prob_map
end

function to_string_pair( spawn_prob_map )
	local level_set = {}
	local probability_set = {}
	for level, probability in pairs( spawn_prob_map ) do
		table.insert( level_set, level )
		table.insert( probability_set, probability )
	end
	return table.concat( level_set, "," ), table.concat( probability_set, "," )
end

function get_spawn_prob_map( action_id )
	local action = actions[ action_id_to_idx[ action_id ] ]
	return to_prob_map( action.spawn_level, action.spawn_probability )
end

function prob_map_add( prob_map_a, prob_map_b )
	local result = { unpack( prob_map_a ) }
	for level, probability in pairs( prob_map_b ) do
		result[ level ] = ( result[ level ] or 0 ) + probability
	end
	return result
end

local blending_groups = {}

for idx, action in ipairs( actions ) do
	if action.blend_with ~= nil then
		for source_id, weight in pairs( action.blend_with ) do
			local group = blending_groups[ source_id ]
			if not group then
				group = { [ action_id_to_idx[ source_id ] ] = 1 }
				blending_groups[ source_id ] = group
			end
			table.insert( group, idx, weight )
		end
	end
end

for source_id, group in pairs( blending_groups ) do
	local total_weight = 0
	for idx, weight in pairs( group ) do
		total_weight = total_weight + weight
	end

	local source_prob_map = get_spawn_prob_map( source_id )
	for idx, weight in pairs( group ) do
		local action = actions[ idx ]
		local prob_map = {}
		for level, probability in pairs( source_prob_map ) do
			prob_map[ level ] = probability * weight / total_weight
		end
		if action.blend_result then
			action.blend_result = prob_map_add( action.blend_result, prob_map )
		else
			action.blend_result = prob_map
		end
	end
end

for _, action in ipairs( actions ) do
	local blend_result = action.blend_result
	if blend_result then
		-- print( action.id )
		-- for i,v in pairs( blend_result ) do
		-- 	print(i,v)
		-- end
		if action.post_blend then
			blend_result = action.post_blend( blend_result )
		end
		action.spawn_level, action.spawn_probability = to_string_pair( blend_result )
	end
end