local serpent = dofile_once( "__MOD_LIBS__serpent.lua" )
return use_templates{
	type = ACTION_TYPE_PROJECTILE,
	mana = 20,
	action = function()
		if reflecting then
			Reflection_RegisterProjectile( "__THIS_FOLDER__projectile.xml" )
			return
		end

		BeginProjectile( "__THIS_FOLDER__projectile.xml" )
			BeginTriggerTimer(1)
				local old_c = c
				c = {}
				reset_modifiers( c )

				local old_reduced_uses = ___reduced_uses
				___reduced_uses = false

				local captured = ___capture_shot( function() draw_shot( create_shot(1), true ) end )
				c.action_description = serpent.dump( captured ):gsub( '"', "^" )
				c.state_destroyed_action = ___reduced_uses
				add_projectile( "__THIS_FOLDER__shot_saver.xml" )

				register_action( c )
				SetProjectileConfigs()

				___reduced_uses = old_reduced_uses or ___reduced_uses

				c = old_c
			EndTrigger()
		EndProjectile()
	end,
}:template_projectile()