local injection = new_injection()

injection._set_gun.pre = function()
	local entity_id = GetUpdatedEntityID()
	local children = EntityGetAllChildren( entity_id, "__ACTION_ID___shot_script_holder" )
	if children and #children > 0 then return end
	local child_id = EntityLoad( "__THIS_FOLDER__shot_script_holder.xml" )
	EntityAddChild( entity_id, child_id )
end

return injection