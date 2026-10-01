local Textbox, super = HookSystem.hookScript(Textbox)

function Textbox:init(x, y, width, height, default_font, default_font_size, battle_box)
    super.init(self, x, y, width, height, default_font, default_font_size, battle_box)

    local leader = Game.party and Game.party[1]
    local isSoulLeader = leader and leader.id == "SOUL"

    if isSoulLeader then
        if self.box then
            if self.box.setColor then
                self.box:setColor(1, 0, 0)
            else
                self.box.color = {1, 0, 0}
            end
        end
    end
end

return Textbox