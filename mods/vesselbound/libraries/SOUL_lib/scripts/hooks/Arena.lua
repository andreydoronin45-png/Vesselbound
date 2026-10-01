local Arena, super = HookSystem.hookScript(Arena)

function Arena:init(x, y, shape)
    super.init(self, x, y, shape)

    local leader = Game.party[1]
    if leader and leader.id == "SOUL" then
        self.color = {1, 0, 0}
    else
        self.color = {0, 0.75, 0}
    end
end

return Arena