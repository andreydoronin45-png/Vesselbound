local BattleBackground, super = HookSystem.hookScript(BattleBackground)

function BattleBackground:drawBackground()
    local leader = Game.party and Game.party[1]
    local isSoulLeader = leader and leader.id == "SOUL"
    local color_r, color_g, color_b = 1, 1, 1
    if isSoulLeader then
        color_r, color_g, color_b = 1, 0, 0
    end
    Draw.setColor(0, 0, 0, self.alpha)
    love.graphics.rectangle("fill", -10, -10, SCREEN_WIDTH + 20, SCREEN_HEIGHT + 20)
    local background = Assets.getTexture("ui/battle/background")
    Draw.setColor(color_r, color_g, color_b, self.alpha / 2)
    Draw.drawWrapped(background, true, true, MathUtils.round(-100 + self.position), MathUtils.round(-100 + self.position))
    Draw.setColor(color_r, color_g, color_b, self.alpha)
    Draw.drawWrapped(background, true, true, MathUtils.round(-200 - self.position2), MathUtils.round(-210 - self.position2))
end

return BattleBackground