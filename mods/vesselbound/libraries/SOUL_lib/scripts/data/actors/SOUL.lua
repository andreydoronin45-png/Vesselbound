local actor, super = Class(Actor, "SOUL")

function actor:init()
    super.init(self)
    self.name = "YOU"
    self.width = 19
    self.height = 27

    self.hitbox = {0, 15, 19, 14}
    self.soul_offset = {9, 4}
    self.color = {1, 0, 0}
    self.path = "party/soul"
    self.default = "idle"
    self.voice = nil
    self.portrait_path = nil
    self.portrait_offset = nil
    self.can_blush = false
    self.animations = {
        ["idle"] = {"soul_blur"},
        ["battle/spell_ready"] = {"spell_ready", 1/13, true},
        ["battle/spell"] = {"spell", 1/20, false, next="idle"},
		["battle/soulbuster"] = {"soul_buster", 1/26, false, next="idle"},
		["battle/defend"] = {"soul_defend_7", false},
		["battle/defend_ready"] = {"soul_defend", 1/26, false},
    }

    self.offsets = {
        ["spell_ready"] = {-7, -8},
        ["spell"] = {-7, -8},
		["soul_blur"] = {1, 0}, 
		["soul_buster"] = {-7, -8},
		["soul_defend"] = {-7, -8}, 
    }
end

function actor:onSpriteUpdate(sprite)
    local offset_y = -5
    sprite.y = offset_y + math.sin(Kristal.getTime() * 3 + 1) * 2

    if not Game.battle then return end

    local soul = Game.battle.soul
    local is_haste = (Game.battle.soul_buff and Game.battle.soul_buff > 0) or
                     (soul and (soul._haste_applied or soul.haste_active))

    if is_haste then
        sprite.img_timer = (sprite.img_timer or 0) + DTMULT
        if sprite.img_timer < 7 then return end   
        sprite.img_timer = 0

        if sprite and sprite.visible then
            local img = AfterImage(sprite, 0.8, 0.009)  
            img.alpha = 0.6
            img.physics.direction = math.rad(180)
            img.physics.speed = 1
            sprite.parent:addChild(img)
            img.debug_select = false
        end
    else
        sprite.img_timer = 0
    end
	
end

return actor