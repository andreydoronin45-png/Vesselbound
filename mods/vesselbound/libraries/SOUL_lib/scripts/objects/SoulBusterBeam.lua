---@class SoulBusterBeam : Sprite
local SoulBusterBeam, super = Class(Sprite)

function SoulBusterBeam:init(x, y, tx, ty, after)
    super.init(self, "effects/soulbuster/soul_buster", x, y)

    self:setOrigin(0.5, 0.5)
    self:setScale(3)

    self.start_x = x
    self.start_y = y
    self.target_x = tx
    self.target_y = ty

    self.total_dist = Utils.dist(x, y, tx, ty)
    self.dist_traveled = 0

    self:setColor(0.5, 0.5, 0.5, 0.8)

    self.rotation = Utils.angle(x, y, tx, ty) + math.rad(20)
    self.physics.speed = 24
    self.physics.friction = -1.5
    self.physics.match_rotation = true

    self.alpha = 0
    self.after_func = after

    self.afterimg_timer = 0

    self.pressed = false
    self.bolt_timer = 0
    self.final_bolt = 0
    self.final_bolt_set = false
    self.chosen_bolt = 0
    self.bonus_anim = false
end

function SoulBusterBeam:update()
    self.alpha = MathUtils.approach(self.alpha, 1, 0.25 * DTMULT)

    local dir = Utils.angle(self.x, self.y, self.target_x, self.target_y)
    self.rotation = self.rotation + (MathUtils.angleDiff(dir, self.rotation) / 4) * DTMULT

    self.bolt_timer = self.bolt_timer + DTMULT
    if Input.pressed("confirm") and not self.pressed then
        self.pressed = true
        self.chosen_bolt = self.bolt_timer
    end

    local current_dist = Utils.dist(self.x, self.y, self.target_x, self.target_y)
    self.dist_traveled = self.total_dist - current_dist

    local progress = math.min(1, self.dist_traveled / self.total_dist)

    local red = 0.5 + 0.5 * progress
    local green = 0.5 * (1 - progress)
    local blue = 0.5 * (1 - progress)
    self:setColor(red, green, blue, 1)

    if current_dist <= 40 then
        if not self.final_bolt_set then
            self.final_bolt_set = true
            self.final_bolt = self.bolt_timer
        end
        if self.after_func then
            local damage_bonus, play_sound = 0, false
            self.chosen_bolt = MathUtils.round(self.chosen_bolt)
            self.final_bolt = MathUtils.round(self.final_bolt)
            if self.chosen_bolt > 0 then
                if self.chosen_bolt == self.final_bolt then
                    damage_bonus = 30
                elseif self.chosen_bolt == self.final_bolt - 1 then
                    damage_bonus = 28
                elseif self.chosen_bolt == self.final_bolt - 2 then
                    damage_bonus = 22
                elseif self.chosen_bolt == self.final_bolt - 3 then
                    damage_bonus = 20
                elseif self.chosen_bolt == self.final_bolt - 4 then
                    damage_bonus = 13
                elseif self.chosen_bolt == self.final_bolt - 5 then
                    damage_bonus = 11
                elseif self.chosen_bolt == self.final_bolt - 6 then
                    damage_bonus = 10
                end
                if math.abs(self.chosen_bolt - self.final_bolt) <= 2 then
                    self.bonus_anim = true
                    play_sound = true
                end
            end
            self.after_func(damage_bonus, play_sound)
        end
        Assets.playSound("ominous_stab_harsh")

        local rose = SoulRose(self.target_x, self.target_y)
        rose.layer = self.layer + 0.02
        Game.battle:addChild(rose)

        self:remove()
        return
    end

    self.afterimg_timer = self.afterimg_timer + DTMULT
    if self.afterimg_timer >= 0.3 then
        self.afterimg_timer = 0
        local after = Sprite("effects/soulbuster/bigshot", self.x, self.y)
        after:setOrigin(0.5, 0.5)
        after:setScale(1)
        local r, g, b = self:getColor()
        after:setColor(r, g, b, 0.4)
        after.rotation = self.rotation
        after:fadeOutAndRemove(0.6)
        after.layer = self.layer - 0.01
        after.graphics.grow_y = -0.1
        after.graphics.remove_shrunk = true
        self.parent:addChild(after)
    end

    super.update(self)
end

return SoulBusterBeam