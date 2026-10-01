local UIBox, super = HookSystem.hookScript(UIBox)

function UIBox:init(x, y, width, height, style, properties)
    super.init(self, x, y, width, height, style, properties)

    local leader = Game.party and Game.party[1]
    if leader and leader.id == "SOUL" then
        self:setColor(1, 0, 0)  
    end
end

return UIBox