--- Creates a Depth Fountain - simplified copy of DarkFountain.
--- Manual tiling instead of drawWrapped to avoid jitter on non-POT textures.
--- Bottom and edge are stretched horizontally with a pixelate shader.
--- Blue-purple palette, slowed animation, bottom uses same color as edge.
---@class DepthFountain : Event
local DepthFountain, super = Class(Event, "depthfountain")

function DepthFountain:init(x, y, properties)
    super.init(self, x, y)

    self.properties = properties or {}

    self:setOrigin(0.5, 1)

    self.width = (self.properties["narrow"] and 120 or 180) * 2
    self.height = 280 * 2

    self.bg_texture = Assets.getTexture("IMAGE_DEPTH_EXTEND_MONO_SEAMLESS_BRIGHTER")
    self.edge_texture = Assets.getTexture("world/events/darkfountain/edge" .. (self.properties["narrow"] and "_narrow" or ""))
    self.bottom_texture = Assets.getTexture("world/events/darkfountain/bottom" .. (self.properties["narrow"] and "_narrow" or ""))

    self.bg_tex_w = self.bg_texture:getWidth()
    self.bg_tex_h = self.bg_texture:getHeight()

    self.mask_fx = self:addFX(MaskFX(self))

    self.siner = 0
    self.hscroll = 0
    self.bg_siner = 0

    self.eyebody = 1
    self.adjust = 0
    self.slowdown = 0
    self.bg_color = { 0, 0, 0 }

    self.palette = {
        { 0x0E / 255, 0x2B / 255, 0xAD / 255 }, -- #0E2BAD синий
        { 0x1A / 255, 0x3C / 255, 0xC3 / 255 }, -- #1A3CC3 синий
        { 0x4B / 255, 0x2D / 255, 0xD8 / 255 }, -- #4B2DD8 сине-фиолетовый
        { 0x6A / 255, 0x2D / 255, 0xD8 / 255 }, -- #6A2DD8 фиолетовый
        { 0xA4 / 255, 0x6E / 255, 0xFC / 255 }, -- #A46EFC светлый фиолетовый
        { 0x2D / 255, 0x0E / 255, 0xAD / 255 }, -- #2D0EAD тёмно-синий (замыкает цикл)
    }

    self.shift = 0
    self.shift_speed = 0.1 

    if not DepthFountain._pixelate_shader then
        DepthFountain._pixelate_shader = love.graphics.newShader([[
            extern number blocks_x;
            extern number blocks_y;

            vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
                vec2 uv = vec2(
                    floor(texture_coords.x * blocks_x) / blocks_x,
                    floor(texture_coords.y * blocks_y) / blocks_y
                );
                return Texel(tex, uv) * color;
            }
        ]])
    end
end

function DepthFountain:onAdd(parent)
    super.onAdd(self, parent)

    self:setLayer(WORLD_LAYERS["bottom"])
end

function DepthFountain:getPaletteColor(t)
    t = t % 1
    local count = #self.palette
    local scaled = t * count

    local i1 = math.floor(scaled) % count + 1
    local i2 = i1 % count + 1
    local frac = scaled - math.floor(scaled)

    local c1 = self.palette[i1]
    local c2 = self.palette[i2]

    return {
        c1[1] + (c2[1] - c1[1]) * frac,
        c1[2] + (c2[2] - c1[2]) * frac,
        c1[3] + (c2[3] - c1[3]) * frac,
    }
end

function DepthFountain:drawTiled(texture, alpha, off_x, off_y)
    Draw.setColor(1, 1, 1, alpha)

    local scale = 2
    local tw = texture:getWidth() * scale
    local th = texture:getHeight() * scale

    local ox = math.floor(off_x) % tw
    local oy = math.floor(off_y) % th

    local x = -ox
    while x < self.width do
        local y = -oy
        while y < self.height do
            love.graphics.draw(texture, x, y, 0, scale, scale)
            y = y + th
        end
        x = x + tw
    end
end

function DepthFountain:drawBottomLayer(color, alpha, y_offset)
    Draw.setColor(color[1], color[2], color[3], alpha)

    local bottom_h = self.bottom_texture:getHeight() * 2
    local scale_x = self.width / self.bottom_texture:getWidth()

    love.graphics.setShader(DepthFountain._pixelate_shader)
    DepthFountain._pixelate_shader:send("blocks_x", self.width / 4)
    DepthFountain._pixelate_shader:send("blocks_y", bottom_h / 4)

    local narrow_offset = self.properties["narrow"] and 140 or 0
    love.graphics.draw(self.bottom_texture, 0,
        self.height - 280 + y_offset + narrow_offset, 0, scale_x, 2)

    love.graphics.setShader()
end

function DepthFountain:drawEdgeLayer(color, alpha, x_offset, y_offset)
    Draw.setColor(color[1], color[2], color[3], alpha)

    local edge_w = self.edge_texture:getWidth()
    local edge_h = self.edge_texture:getHeight() * 2

    local scale_x = self.width / edge_w

    love.graphics.setShader(DepthFountain._pixelate_shader)
    DepthFountain._pixelate_shader:send("blocks_x", self.width / 4)
    DepthFountain._pixelate_shader:send("blocks_y", edge_h / 4)

    local oy = math.floor(y_offset) % edge_h
    local y = -oy
    while y < self.height do
        love.graphics.draw(self.edge_texture, x_offset, y, 0, scale_x, 2)
        y = y + edge_h
    end

    love.graphics.setShader()
end

function DepthFountain:update()
    self.siner = self.siner + DTMULT
    self.hscroll = self.hscroll + DTMULT

    self:setColor(1, 1, 1)
    self.bg_color = { 0, 0, 0 }

    self.shift = self.shift + (self.shift_speed * DT / 30)

    self.bg_siner = self.bg_siner + 0.02 * DTMULT
    if self.bg_siner > 7 then
        self.bg_siner = self.bg_siner - 7
    end

    super.update(self)
end

function DepthFountain:draw()
    local ec = self:getPaletteColor(self.shift)

    Draw.setColor(self.bg_color)
    love.graphics.rectangle("fill", 1, 1, self.width - 2, self.height - 2)

    self:drawTiled(self.bg_texture, 0.7 * self.eyebody, -self.siner, -self.siner)

    self:drawTiled(self.bg_texture, 0.3 * self.eyebody,
        self.hscroll - self.bg_tex_w, self.siner)

    Draw.setColor(0, 0, 0)
    love.graphics.rectangle("fill", -100, 0, 120, self.height)
    love.graphics.rectangle("fill", self.width - 20, 0, 120, self.height)

    local edge_offset = (self.bg_siner * 280) / 7

    self:drawEdgeLayer(ec, 1.0, 0, edge_offset)
    self:drawEdgeLayer(ec, 0.5,
        math.sin(self.siner / 16) * 12, edge_offset)
    self:drawEdgeLayer(ec, 0.5,
        -math.sin(self.siner / 16) * 12, edge_offset)

    self:drawBottomLayer(ec, 0.3, -8 + math.sin(self.siner / 40) * 8)
    self:drawBottomLayer(ec, 0.5, -4 + math.sin(self.siner / 40) * 4)
    self:drawBottomLayer(ec, 1.0, 0)

    super.draw(self)
end

function DepthFountain:drawMask()
    Draw.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
end

return DepthFountain