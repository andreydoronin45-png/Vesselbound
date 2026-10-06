
---@class DepthFountain : Event
local DepthFountain, super = Class(Event, "depthfountain")

function DepthFountain:init(x, y, properties)
    super.init(self, x, y)

    self.properties = properties or {}

    self:setOrigin(0.5, 1)

    self.width = (self.properties["narrow"] and 80 or 120) * 2
    self.height = 280 * 2

    self.texture = Assets.getTexture("IMAGE_DEPTH")

    self.mask_fx = self:addFX(MaskFX(self))

    self.siner = 0
    self.bg_siner = 0
    self.hscroll = 0

    self:setColor(1, 1, 1)
    self.bg_color = { 0, 0, 0 }
end

function DepthFountain:update()
    self.siner = self.siner + DTMULT

    self.hscroll = self.hscroll + DTMULT
    if self.hscroll > 240 then
        self.hscroll = self.hscroll - 240
    end

    self.bg_siner = self.bg_siner + 0.0625 * DTMULT
    if self.bg_siner > 7 then
        self.bg_siner = self.bg_siner - 7
    end

    super.update(self)
end

function DepthFountain:draw()
    local color = { self:getDrawColor() }

    Draw.setColor(self.bg_color)
    love.graphics.rectangle("fill", 1, 1, self.width - 2, self.height - 2)

    Draw.setColor(color, 0.7)
    Draw.drawWrapped(self.texture, true, true, -self.siner, -self.siner, 0, 2, 2)

    Draw.setColor(color, 0.3)
    Draw.drawWrapped(self.texture, true, true, self.hscroll - 240, self.siner, 0, 2, 2)

    Draw.setColor(0, 0, 0)
    love.graphics.rectangle("fill", -100, 0, 120, self.height)
    love.graphics.rectangle("fill", self.width - 20, 0, 120, self.height)

    Draw.setColor(color, 1)
    Draw.drawWrapped(self.texture, false, true, 20, self.height - (self.bg_siner * 280) / 7, 0, 2, 2)
    Draw.setColor(color, 0.5)
    Draw.drawWrapped(self.texture, false, true, 20 + math.sin(self.siner / 16) * 12, self.height - (self.bg_siner * 280) / 7, 0, 2, 2)
    Draw.drawWrapped(self.texture, false, true, 20 - math.sin(self.siner / 16) * 12, self.height - (self.bg_siner * 280) / 7, 0, 2, 2)

    Draw.setColor(color, 0.3)
    local narrow_offset = self.properties["narrow"] and 140 or 0
    Draw.draw(self.texture, 0, self.height - 280 - 8 + (math.sin(self.siner / 16) * 8) + narrow_offset, 0, 2, 2)
    Draw.setColor(color, 0.5)
    Draw.draw(self.texture, 0, self.height - 280 - 4 + (math.sin(self.siner / 16) * 4) + narrow_offset, 0, 2, 2)
    Draw.setColor(color, 1)
    Draw.draw(self.texture, 0, self.height - 280 + narrow_offset, 0, 2, 2)

    super.draw(self)
end

function DepthFountain:drawMask()
    Draw.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
end

return DepthFountain