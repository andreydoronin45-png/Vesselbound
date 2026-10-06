local SwordSwing, super = Class(Wave)

function SwordSwing:init()
    super.init(self)

    self:setArenaOffset(0, -20)
end

function SwordSwing:onStart()
    self.time = 10

    self.base_y = {}
    for _, attacker in ipairs(self:getAttackers()) do
        self.base_y[attacker] = attacker.y
    end
    self.soul_base_y = Game.battle.soul.y

    local ramp_time = 10

    self.timer:script(function(wait)
        local elapsed = 0

        while true do
            local t = math.min(elapsed / ramp_time, 1)

            local divisor = 2 + (4 - 2) * t
            local interval = 1 / divisor

            local bullet_speed = 8 + (13 - 8) * t

            wait(interval)

            local attackers = self:getAttackers()
            for _, attacker in ipairs(attackers) do
                attacker:setAnimation("battle/attack", function()
                    attacker:setAnimation("battle/idle")
                end)

                local spawn_x, spawn_y = attacker:getRelativePos(
                    attacker.width / 2,
                    attacker.height / 2,
                    Game.battle
                )

                local dir = 0 
                if Game.battle.soul.x < spawn_x then
                    dir = math.pi 
                end

                Assets.playSound("laz_c")
                self:spawnBullet("sword_swing", spawn_x, spawn_y, dir, bullet_speed)
            end

            elapsed = elapsed + interval
        end
    end)
end

function SwordSwing:update()
    super.update(self)

    local soul_offset = Game.battle.soul.y - self.soul_base_y

    for attacker, base_y in pairs(self.base_y) do
        local target_y = base_y + soul_offset
        local factor = math.min(DT * 3, 1)
        attacker.y = attacker.y + (target_y - attacker.y) * factor
    end
end

function SwordSwing:onEnd(death)
    super.onEnd(self, death)

    for attacker, base_y in pairs(self.base_y) do
        Game.battle.timer:tween(0.5, attacker, {y = base_y}, "out-quad")
    end
end

return SwordSwing