local serpent = dofile_once("__MOD_LIBS__serpent.lua")
return use_templates {
    type = ACTION_TYPE_PROJECTILE,
    mana = 0,
    price = 60,
    action = function()
        if reflecting then
            Reflection_RegisterProjectile("__THIS_FOLDER__projectile.xml")
            return
        end
        if #deck == 0 then return end
        local target = deck[#deck]
        local damage = target.mana / 10 / 25
        table.remove(deck, #deck)
        table.insert(discarded, target)
        BeginProjectile("__THIS_FOLDER__projectile.xml")
        do
            BeginTriggerTimer(1)
            local old_c = c
            c = {}
            reset_modifiers(c)
            c.action_description = serpent.dump {
                target_id = target.id,
                damage = damage,
            }:gsub('"', "^")
            add_projectile("__THIS_FOLDER__data.xml")

            register_action(c)
            SetProjectileConfigs()
            c = old_c
            EndTrigger()
        end
        EndProjectile()
    end
}
