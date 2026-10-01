local SoulRose, super = Class(Object)

function SoulRose:init(x, y)
    super.init(self, x, y)

    local anim_path = "effects/soulbuster/spr_rose"
    local frame_duration = 1/15

    local offset_x = 0
    local offset_y = 0

    local function startFadeOut()
        Game.battle.timer:tween(0.8, self.fg, {alpha = 0}, "out-cubic")
        Game.battle.timer:after(0.8, function()
            self:remove()
        end)
    end

    self.fg = Sprite(anim_path, offset_x, offset_y)
    self.fg:setOrigin(0.5, 0.5)
    self.fg:setScale(1.8)
    self.fg:play(frame_duration, false, startFadeOut)
    self:addChild(self.fg)

    self.glow = Sprite(anim_path, offset_x, offset_y)
    self.glow:setOrigin(0.5, 0.5)
    self.glow:setColor(1, 1, 1, 0.8)
    self.glow:setScale(1.8)
    self.glow:play(frame_duration, false)
    self:addChild(self.glow)

    Game.battle.timer:tween(0.8, self.glow, {
        scale_x = 4.5,
        scale_y = 4.5,
        alpha = 0
    }, "out-cubic")

    self.hitbox_width = 64
    self.hitbox_height = 64
    self.alpha = 1
end

function SoulRose:update()
    super.update(self)

    if self.fg and self.fg.alpha <= 0 then
        self:remove()
    end
end

function SoulRose:draw()
    super.draw(self)
    if DEBUG_RENDER then
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("line",
            -self.hitbox_width/2,
            -self.hitbox_height/2,
            self.hitbox_width,
            self.hitbox_height
        )
    end
end

return SoulRose