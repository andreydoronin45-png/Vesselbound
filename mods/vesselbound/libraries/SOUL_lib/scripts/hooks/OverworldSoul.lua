local OverworldSoul, super = HookSystem.hookScript(OverworldSoul)

function OverworldSoul:init(x, y)
    super.init(self, x, y)

    local leader = Game.party and Game.party[1]
    if leader and leader.id == "SOUL" then
        if self.sprite then
            self:removeChild(self.sprite)
            self.sprite = nil
        end

        self.sprite = Sprite("player/soul_blur")
        self.sprite:setOrigin(0.5, 0.5)
        self.sprite.alpha = 0
        self.sprite.inherit_color = true
        self:addChild(self.sprite)

    end
end

return OverworldSoul