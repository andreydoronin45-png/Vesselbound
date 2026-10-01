local spell, super = Class(Spell, "soul_haste")

function spell:init()
    super.init(self)
    self.name = "Haste"
    self.cast_name = nil
    self.effect = "Boost SOUL\nspeed"
    self.description = "Temporarily increases the SOUL's movement speed for 2 waves."
    self.cost = 20
    self.target = "none"
    self.tags = {"SOUL", "buff"}
end

function spell:getCastMessage(user, target)
    return "* "..user.chara:getName().." use "..self:getCastName().."!"
end

function spell:onCast(user, target)
    Game.battle.soul_buff = 2
    Assets.playSound("snd_boost")
    print("[soul_haste] Установлен Game.battle.soul_buff = 2")
    Game.battle:finishAction()
	Assets.playSound("snd_boost")
    return true
end

return spell