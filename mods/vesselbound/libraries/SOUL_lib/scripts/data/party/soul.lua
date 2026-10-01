local character, super = Class(PartyMember, "SOUL")

function character:init()
    super.init(self)
    self.name = "YOU"

    self:setActor("SOUL")
    self:setLightActor("SOUL")

    self.level = Game.chapter
    self.title = "It's YOU."

    self.soul_priority = 1
    self.soul_color = {1, 0, 0}

    self.has_act = true
    self.has_spells = true
    self.has_xact = false
    self.xact_name = "S-Action"

    self:addSpell("soul_light")
    self:addSpell("soul_buster")
	self:addSpell("soul_haste")
	
    self.health = 999
    self.stats = {
        health = 999,
        attack = 4,
        defense = 10,
        magic = 14
    }
    self.max_stats = {
        health = 1300
    }

    self.color = {1, 0, 0}
    self.dmg_color = {1, 0, 0}
    self.attack_bar_color = {1, 0, 0}
    self.attack_box_color = {1, 0, 0}
    self.xact_color = {1, 0, 0}

    self.menu_icon = "party/soul/soul_blur"
    self.head_icons = "party/soul/heads"
    self.name_sprite = "party/soul/name"

    self.attack_sound = "break1"
    self.attack_pitch = 1

    self.battle_offset = {0, 8}
    self.head_icon_offset = {-1, -2}
    self.menu_icon_offset = {5, 5}

    self.gameover_message = nil

    self.weapon_icon = nil
    self.lw_weapon_default = nil
    self.lw_armor_default = nil
end


function character:canEquip(item, slot_type, slot_index)
    return false
end

function character:onSoulSpawn(battler)
    if battler then
        battler:setActor("soul_empty")
    end
end

function character:onSoulDespawn(battler)
    if battler then
        battler:setActor("SOUL")
    end
end

return character