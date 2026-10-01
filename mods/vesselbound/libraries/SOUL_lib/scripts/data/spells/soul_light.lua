local spell, super = Class(Spell, "soul_light")

function spell:init()
    super.init(self)
    self.name = "SOUL Light"
    self.cast_name = nil
    self.effect = "Heal\nally"
    self.description = "Restores HP to one ally using the power of the SOUL.\nScales with Magic."
    self.cost = 20
    self.target = "ally"
    self.tags = {"SOUL", "heal"}
end

function spell:getCastMessage(user, target)
    return "* "..user.chara:getName().." use "..self:getCastName().."!"
end

function spell:onSelect(user)
    Assets.playSound("snd_boost")
end
function spell:onCast(user, target)
    local buster_finished = false
    local anim_finished = false
    local function finishAnim()
        anim_finished = true
        if buster_finished then
            Game.battle:finishAction()
        end
    end

    if not user:setAnimation("battle/spell", finishAnim) then
        anim_finished = false
        user:setAnimation("battle/attack", finishAnim)
    end

    Game.battle.timer:after(15/30, function()
        Assets.playSound("snd_boost")
        local x, y = user:getRelativePos(user.width, user.height/2 - 10, Game.battle)
        local tx, ty = target:getRelativePos(target.width/2, target.height/2, Game.battle)

        local blast = SoulBusterBeam(x, y, tx, ty, function(damage_bonus, play_sound)
            local heal = self:getHeal(user, target, damage_bonus)
            if play_sound then
                Assets.playSound("heal")
            end
            local flash = target:flash()
            flash.color_mask:setColor(0, 1, 0)
            target:heal(heal, user)
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

function spell:getHeal(user, target, bonus)
    local heal = math.ceil((user.chara:getStat("magic") * 8) + 30 + (bonus or 0))
    return heal
end

return spell