local spell, super = Class(Spell, "soul_buster")

function spell:init()
    super.init(self)
    self.name = "SOUL Buster"
    self.cast_name = nil
    self.effect = "SOUL\nPower"
    self.description = "Deals devastating SOUL damage\nto one foe. Depends on Magic."
    self.cost = 60
    self.target = "enemy"
    self.tags = {"SOUL", "damage"}
end

function spell:getCastMessage(user, target)
    return "* "..user.chara:getName().." use "..self:getCastName().."!"
end

function spell:onCast(user, target)
    local buster_finished = false
    local anim_finished = false
    Assets.playSound("snd_boost")

    local function finishAnim()
        anim_finished = true
        if buster_finished then
            Game.battle:finishAction()
        end
    end

    if not user:setAnimation("battle/soulbuster", finishAnim) then
        user:setAnimation("battle/attack", finishAnim)
    end

    Game.battle.timer:after(15/30, function()
        Assets.playSound("snd_TRUE")
        local x, y = user:getRelativePos(user.width, user.height/2 - 10, Game.battle)
        local tx, ty = target:getRelativePos(target.width/2, target.height/2, Game.battle)

        local blast = SoulBusterBeam(x, y, tx, ty, function(damage_bonus, play_sound)
            local damage = self:getDamage(user, target, damage_bonus)
            local flash = target:flash()
            flash.color_mask:setColor(1, 0, 0)
            target:hurt(damage, user)

            if not target.is_down then
                target:recruitMessage("decay")
                target._decay_ticks = 5
            end

            buster_finished = true
            if anim_finished then
                Game.battle:finishAction()
            end
        end)
        blast.layer = BATTLE_LAYERS["above_ui"]
        Game.battle:addChild(blast)
    end)

    return false
end

function spell:getDamage(user, target, damage_bonus)
    local damage = math.ceil((user.chara:getStat("magic") * 6) + (user.chara:getStat("attack") * 13) - (target.defense * 6)) + 90 + (damage_bonus or 0)
    return damage
end

return spell