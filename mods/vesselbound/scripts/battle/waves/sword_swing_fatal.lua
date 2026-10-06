local SwordSwingFatal, super = Class(Wave)

local ScreenOverlay, screen_super = Class(Object)

function ScreenOverlay:init(color, layer)
    screen_super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.alpha = 0
    self.color = color or {1, 1, 1}
    self.layer = layer or (BATTLE_LAYERS["above_ui"] + 90)
end

function ScreenOverlay:draw()
    Draw.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    Draw.setColor(1, 1, 1, 1)
end

function SwordSwingFatal:onStart()
    self.time = 100

    self.base_y = {}
    for _, attacker in ipairs(self:getAttackers()) do
        self.base_y[attacker] = attacker.y
    end
    self.soul_base_y = Game.battle.soul.y

    self.tracking_enabled = true
    self.big_attack_done = false
    self.big_bullet = nil
    self.arena_shattered = false
    self.freeze_soul = false
    self.soul_freeze_x = 0
    self.soul_freeze_y = 0
    self.arena_center_x = 0
    self.arena_center_y = 0
    self.shards = {}

    self.second_phase_started = false
    self.fatal_ending_triggered = false

    local ramp_time = 5
    local big_attack_at = 5

    self.timer:script(function(wait)
        local elapsed = 0

        while true do
            if self.fatal_ending_triggered then return end
            if not Game.battle.soul then return end

            local t = math.min(elapsed / ramp_time, 1)

            local divisor = 2 + (4 - 2) * t
            local interval = 1 / divisor
            local bullet_speed = 8 + (16 - 8) * t

            wait(interval)

            if self.fatal_ending_triggered then return end
            if not Game.battle.soul then return end

            local attackers = self:getAttackers()

            if not self.big_attack_done then
                for _, attacker in ipairs(attackers) do
                    attacker:setAnimation("battle/attack", function()
                        attacker:setAnimation("battle/idle")
                    end)

                    local spawn_x, spawn_y = attacker:getRelativePos(
                        attacker.width / 2, attacker.height / 2, Game.battle
                    )
                    local dir = Game.battle.soul.x < spawn_x and math.pi or 0

                    Assets.playSound("laz_c")
                    self:spawnBullet("sword_swing", spawn_x, spawn_y, dir, bullet_speed)
                end
            end

            elapsed = elapsed + interval

            if not self.big_attack_done and elapsed >= big_attack_at then
                self.big_attack_done = true
                self.tracking_enabled = false

                for _, attacker in ipairs(attackers) do
                    local base_y = self.base_y[attacker]

                    Game.battle.timer:tween(0.3, attacker, {y = base_y}, "out-quad", function()
                        attacker:setAnimation("battle/attack", function()
                            attacker:setAnimation("battle/idle")
                        end)

                        Assets.playSound("laz_c")

                        local spawn_x, spawn_y = attacker:getRelativePos(
                            attacker.width / 2, attacker.height / 2, Game.battle
                        )
                        local dir = Game.battle.soul.x < spawn_x and math.pi or 0

                        local big = self:spawnBullet("sword_swing", spawn_x, spawn_y, dir, bullet_speed)
                        if big then
                            big.scale_x = 6
                            big.scale_y = 6
                            big:setHitbox(-4, -80, 8, 160)
                            self.big_bullet = big

                            local original_onCollide = big.onCollide
                            big.onCollide = function(bullet_self, soul)
                                if original_onCollide then
                                    original_onCollide(bullet_self, soul)
                                end
                                if not self.arena_shattered then
                                    self.arena_shattered = true
                                    self:shatterArena()
                                end
                            end
                        end
                    end)
                end
            end
        end
    end)
end

function SwordSwingFatal:update()
    super.update(self)

    if self.tracking_enabled and Game.battle.soul then
        local soul_y = Game.battle.soul.y
        for attacker, base_y in pairs(self.base_y) do
            local target_y = base_y + (soul_y - self.soul_base_y)
            local factor = math.min(DT * 3, 1)
            attacker.y = attacker.y + (target_y - attacker.y) * factor
        end
    end

    if self.freeze_soul and Game.battle.soul then
        Game.battle.soul.x = self.soul_freeze_x
        Game.battle.soul.y = self.soul_freeze_y
    end

    if self.second_phase_started and not self.fatal_ending_triggered then
        for _, member in ipairs(Game.battle.party) do
            local hp = member.chara and member.chara.health
            if hp and hp <= 500 and hp > 0 and not member.is_down then
                self.fatal_ending_triggered = true
                self:triggerFatalEnding()
                break
            end
        end
    end
end

function SwordSwingFatal:shatterArena()
    local arena = Game.battle.arena
    if not arena then return end

    self.arena_center_x, self.arena_center_y = arena:getCenter()
    local border_padding = arena.line_width or 0

    if Game.battle.soul then
        self.freeze_soul = true
        self.soul_freeze_x = Game.battle.soul.x
        self.soul_freeze_y = Game.battle.soul.y
    end

    Assets.playSound("impact", 1, 0.8)
    Assets.playSound("break2", 0.9, 1.05)
    Game.battle.camera:shake(6, 6, 0.4)

    self.shards = ShatterUtils.shatterObject(arena, {
        parent = Game.battle,
        shard_count = 14,
        pixel_size = 2,
        x = -border_padding,
        y = -border_padding,
        width = arena.width + border_padding * 2,
        height = arena.height + border_padding * 2,
        center_x = arena.width / 2,
        center_y = arena.height / 2,
        center_jitter = 0,
        ringed = true,
        inner_ring = { 0.28, 0.44 },
        speed = { 3, 5 },
        friction = 0.015,
        gravity = 0,
        spin = { -0.05, 0.05 },
        hide_source = true,
    })

    for _, shard in ipairs(self.shards) do
        local side = shard.x < self.arena_center_x and -1 or 1
        local horizontal = side * (
            math.abs(shard.x - self.arena_center_x) + arena.width * 0.35
        )
        local vertical = (shard.y - self.arena_center_y) * 0.55
        shard.physics.direction = math.atan2(vertical, horizontal)
            + MathUtils.random(-0.1, 0.1)
        shard.alpha = 1
    end

    Game.battle.timer:after(2, function()
        for _, shard in ipairs(self.shards) do
            if shard.parent then
                shard.physics.speed = 0
                shard.physics.friction = 0
                shard.graphics.spin = 0

                Game.battle.timer:tween(1.5, shard, {alpha = 0}, "in-quad", function()
                    shard:remove()
                end)
            end
        end

        Game.battle.timer:after(1.5, function()
            self.shards = {}
        end)
    end)

    Game.battle.timer:after(3, function()
        self.freeze_soul = false

        if Game.battle.soul then
            
            Game.battle.soul.can_move = false
            Game.battle.soul.moving_x = 0
            Game.battle.soul.moving_y = 0

            Game.battle.timer:tween(0.9, Game.battle.soul, {
                x = self.arena_center_x,
                y = self.arena_center_y,
            }, "out-quad", function()

                self:startSecondPhase()
            end)
        else
            self:startSecondPhase()
        end
    end)
end

function SwordSwingFatal:startSecondPhase()
    self.second_phase_started = true
    local ramp_time = 8

    self.timer:script(function(wait)
        local elapsed = 0

        while true do
            if self.fatal_ending_triggered then return end
            if not Game.battle.soul then return end

            local t = math.min(elapsed / ramp_time, 1)

            local divisor = 2 + (5 - 2) * t
            local interval = 1 / divisor
            local bullet_speed = 8 + (20 - 8) * t

            wait(interval)

            if self.fatal_ending_triggered then return end
            if not Game.battle.soul then return end

            local attackers = self:getAttackers()
            for _, attacker in ipairs(attackers) do
                attacker:setAnimation("battle/attack", function()
                    attacker:setAnimation("battle/idle")
                end)

                local spawn_x = attacker:getRelativePos(
                    attacker.width / 2, attacker.height / 2, Game.battle
                )
                local spawn_y = Game.battle.soul.y

                local dir = Game.battle.soul.x < spawn_x and math.pi or 0

                Assets.playSound("laz_c")
                self:spawnBullet("sword_swing", spawn_x, spawn_y, dir, bullet_speed, true)
            end

            elapsed = elapsed + interval
        end
    end)
end

function SwordSwingFatal:triggerFatalEnding()

    if Game.battle.arena then
        Game.battle.arena.onRemove = function() end
        Game.battle.arena.visible = false
    end

    local soul = Game.battle.soul
    if not soul then return end

    local soul_x = soul.x
    local soul_y = soul.y

    if Game.battle.music and Game.battle.music:isPlaying() then
        Game.battle.music:stop()
    end
    if Game.battle.wave then
        Game.battle.wave:setFinished()
    end
    Game.battle.wave_timer = Game.battle.wave_length or 0
    self.tracking_enabled = false
    self.freeze_soul = false

    Kristal.hideBorder(0)

    soul:remove()
    Game.battle.soul = nil

    self.white_screen = ScreenOverlay({1, 1, 1}, BATTLE_LAYERS["above_ui"] + 90)
    Game.battle:addChild(self.white_screen)

    Game.battle.timer:tween(1.0, self.white_screen, {alpha = 1}, "out-quad", function()
        
        self.black_screen = ScreenOverlay({0, 0, 0}, BATTLE_LAYERS["above_ui"] + 91)
        self.black_screen.alpha = 1
        Game.battle:addChild(self.black_screen)

        self.white_screen:remove()
        self.white_screen = nil

        local fake_soul = Sprite("player/heart", soul_x, soul_y)
        fake_soul:setOrigin(0.5, 0.5)
        fake_soul:setColor(Game:getSoulColor())
        fake_soul.layer = BATTLE_LAYERS["above_ui"] + 95
        Game.battle:addChild(fake_soul)

        Assets.playSound("break1")
        fake_soul:setSprite("player/heart_break")

        Game.battle.timer:after(40 / 30, function()
            Assets.playSound("break2")

            local shard_count = 6
            local shard_x_table = { -2, 0, 2, 8, 10, 12 }
            local shard_y_table = { 0, 3, 6 }

            for i = 1, shard_count do
                local x_pos = shard_x_table[((i - 1) % #shard_x_table) + 1]
                local y_pos = shard_y_table[((i - 1) % #shard_y_table) + 1]
                local shard = Sprite("player/heart_shard", fake_soul.x + x_pos, fake_soul.y + y_pos)
                shard:setColor(Game:getSoulColor())
                shard.physics.direction = math.rad(MathUtils.random(360))
                shard.physics.speed = 7
                shard.physics.gravity = 0.2
                shard.layer = BATTLE_LAYERS["above_ui"] + 95
                shard:play(5 / 30)
                Game.battle:addChild(shard)
            end

            fake_soul:remove()

            Game.gaster_ending_pending = true

            Game.battle.timer:after(1.2, function()
                local stage_black = Sprite("other/flash", SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
                stage_black:setOrigin(0.5, 0.5)
                stage_black:setScale(2)
                stage_black:setColor(0, 0, 0, 1)
                stage_black.layer = 9999
                Game.stage:addChild(stage_black)

                Game.gaster_black_screen = stage_black

                Game.battle:setState("TRANSITIONOUT")
            end)
        end)
    end)
end

function SwordSwingFatal:onEnd(death)
    super.onEnd(self, death)

    for attacker, base_y in pairs(self.base_y) do
        Game.battle.timer:tween(0.5, attacker, {y = base_y}, "out-quad")
    end
end

return SwordSwingFatal