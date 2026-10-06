-- scripts/hooks/Game.lua
local Game, super = HookSystem.hookScript(Game)

function Game:update(...)
    super.update(self, ...)

    if self.gaster_ending_pending and self.state == "OVERWORLD" and self.world then
        self.gaster_ending_pending = false
        self.world:startCutscene("gaster_ending", "gaster_ending")
    end
end

return Game