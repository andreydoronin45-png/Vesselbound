local DarkStorageMenu, super = HookSystem.hookScript(DarkStorageMenu)

function DarkStorageMenu:draw()
    super.draw(self)

    local leader = Game.party and Game.party[1]
    if leader and leader.id == "SOUL" then
        love.graphics.setLineWidth(4)
        Draw.setColor(1, 0, 0)
        love.graphics.rectangle("line", 42, 122, 557, 155)
        love.graphics.rectangle("line", 42, 277, 557, 152)
        love.graphics.setLineWidth(1)
    end
end

return DarkStorageMenu