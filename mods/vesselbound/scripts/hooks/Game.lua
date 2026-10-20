-- scripts/hooks/Game.lua
local Game, super = HookSystem.hookScript(Game)

function Game:load(...)
    super.load(self, ...)
    -- Saved spell lists replace the defaults; restore Fireshock on old saves.
    local ralsei = self:getPartyMember("ralsei")
    if ralsei and not ralsei:hasSpell("fire_shock") then
        ralsei:addSpell("fire_shock")
    end
end

function Game:encounter(encounter, transition, enemy, context)
    local encounter_id = type(encounter) == "string" and encounter or encounter and encounter.id
    if encounter_id == "roaring_knight_kris" and not self.battle then
        local previous_party = self.party
        local vessel = self:getPartyMember("vessel")
        assert(vessel, "Roaring Knight Kris requires the playable_flowers library")
        vessel:setHealth(vessel:getStat("health"))
        vessel.savedata = {}
        local previous_appearance = {}
        for _, id in ipairs({"susie", "ralsei"}) do
            local chara = self:getPartyMember(id)
            local buffs = {}
            for stat, value in pairs(chara:getStatBuffs()) do
                buffs[stat] = value
            end
            previous_appearance[id] = {
                color = chara.color,
                soul_priority = chara.soul_priority,
                buffs = buffs,
            }
        end
        local knight_party = {
            vessel,
            self:getPartyMember("susie"),
            self:getPartyMember("ralsei"),
        }
        self.party = knight_party
        self.vesselbound_pending_party = knight_party
        super.encounter(self, encounter, transition, enemy, context)
        self.vesselbound_pending_party = nil
        self.battle.vesselbound_previous_party = previous_party
        self.battle.vesselbound_previous_appearance = previous_appearance
        return
    end
    return super.encounter(self, encounter, transition, enemy, context)
end

function Game:update(...)
    super.update(self, ...)

    if self.gaster_ending_pending and self.state == "OVERWORLD" and self.world then
        self.gaster_ending_pending = false
        self.world:startCutscene("gaster_ending", "gaster_ending")
    end
end

return Game
