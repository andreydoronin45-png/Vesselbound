local BodylessSoul, super = Class(Soul, "BodylessSoul")

function BodylessSoul:init(x, y, color)
    if not color then color = {1, 0, 0} end

    local leader = Game.party[1]
    local battler = nil
    if leader and leader.id == "SOUL" then
        battler = Game.battle:getPartyBattler(leader.id)
    end

    local start_x, start_y = x, y
    if battler then
        local actor_id = battler.actor
        if actor_id then
            local actor_data = Registry.getActor(actor_id)
            local offset_x, offset_y = 0, 0
            if actor_data and actor_data.soul_offset then
                offset_x = actor_data.soul_offset[1] or 0
                offset_y = actor_data.soul_offset[2] or 0
            end
            start_x = battler.x + offset_x
            start_y = battler.y + offset_y
        else
            start_x = battler.x + 8
            start_y = battler.y + 8
        end
    end

    super.init(self, start_x, start_y, color)
    self.color = color

    if self.sprite then
        self:removeChild(self.sprite)
        self.sprite = nil
    end

    self.sprite = Sprite("player/soul_blur")
    self.sprite:setOrigin(0.5, 0.5)
    self:addChild(self.sprite)

    self._battler = battler

    if battler then
        battler:setActor("soul_empty")
    end

    Assets.playSound("break2")
    self:transitionTo(x, y)
    self.target_alpha = 1

    self._haste_applied = false
    if Game.battle.soul_buff and Game.battle.soul_buff > 0 then
        self.speed = self.speed + 2
        self._haste_applied = true
        if self.sprite then
            self.sprite:setColor(1, 0, 0)
        end
    end

    self.haste_afterimage_timer = 0
    self._defending = false
    self._defend_waves = 0
    self._was_defending = false

end

function BodylessSoul:update()
    if type(self.color) ~= "table" then
        self:setColor({1, 0, 0})
    end

    if self._battler then
        local is_defending = self._battler.defending == true
        if is_defending ~= self._was_defending then
            self._was_defending = is_defending
            if is_defending then
                self.sprite:setSprite("player/soul_defend")
                self.sprite:setOrigin(0.5, 0.5)
                self.sprite:play(1/26, false)
                Assets.playSound("snd_petrify")
            else
                self.sprite:setSprite("player/soul_blur")
                self.sprite:setOrigin(0.5, 0.5)
            end
        end
    end

    if self._haste_applied and self.sprite and self.sprite.visible then
        self.haste_afterimage_timer = self.haste_afterimage_timer + DTMULT
        if self.haste_afterimage_timer >= 3 then
            self.haste_afterimage_timer = 0
            local img = AfterImage(self.sprite, 0.7, 0.035)
            img.alpha = 0.5
            img.physics.speed = 0
            img:setColor(1, 1, 0.5)
            self:addChild(img)
        end
    end

    super.update(self)
end

function BodylessSoul:onRemove(parent)
    if self._haste_applied and Game.battle.soul_buff and Game.battle.soul_buff > 0 then
        Game.battle.soul_buff = Game.battle.soul_buff - 1
        if Game.battle.soul_buff <= 0 then
            Game.battle.soul_buff = nil
        end
    end

    local leader = Game.party[1]
    if leader and leader.id == "SOUL" then
        local battler = Game.battle:getPartyBattler(leader.id)
        if battler then
            battler:setActor("SOUL")
        end
    end

    Assets.playSound("hurt")
    super.onRemove(self, parent)
end

function BodylessSoul:draw()
    if type(self.color) ~= "table" then
        self:setColor({1, 0, 0})
    end
    super.draw(self)
end

return BodylessSoul