---@class Encounter : Encounter
local Encounter, super = HookSystem.hookScript(Encounter)


function Encounter:createSoul(...)
    local leader = Game.party[1]
    if leader and leader.id == "SOUL" then
        return BodylessSoul(320, 240, self:getSoulColor() or {1, 0, 0})
    end
    return super.createSoul(self, ...)
end

function Encounter:onBattleStart(...)
    super.onBattleStart(self, ...)

    local has_soul = false
    if Game.party then
        for _, member in ipairs(Game.party) do
            if member.id == "SOUL" then
                has_soul = true
                break
            end
        end
    end
end


return Encounter