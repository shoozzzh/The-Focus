function shot( proj_id )
	EntityAddComponent2( proj_id, "LuaComponent", {
		script_source_file = "__THIS_FOLDER__delayed_apply.lua",
		execute_every_n_frame = 1,
		remove_after_executed = true,
	} )
end