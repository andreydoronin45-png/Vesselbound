---@class DepthFountainFloor : Event
local DepthFountainFloor, super = Class(Event, "depthfountainfloor")

function DepthFountainFloor:init(x, y, shape)
    super.init(self, x, y, shape)

    self:setColor(0x0E / 255, 0x2B / 255, 0xAD / 255)

    self.fountain = nil
    self.siner = 0

    self.float_texture = Assets.getTexture("IMAGE_DEPTH_EXTEND_MONO_SEAMLESS_BRIGHTER")

    self.tex_scale = 1
    self.tex_w = self.float_texture:getWidth() * self.tex_scale
    self.tex_h = self.float_texture:getHeight() * self.tex_scale

    self.float_x = 0
    self.float_y = 0

    self.float_alpha = 0.4
    self.scroll_speed = 0.3
    self.pixel_factor = 2

    self.afterimage_alpha = 0.5
    self.afterimage_margin = 40

    if not DepthFountainFloor._pixelate_shader then
        DepthFountainFloor._pixelate_shader = love.graphics.newShader([[
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

    self.floor_canvas = nil
end

function DepthFountainFloor:onAdd(parent)
    super.onAdd(self, parent)

    if parent and parent.getObjects then
        local fountain = parent:getObjects(DepthFountain)[1]
        if fountain then
            self.fountain = fountain
        end
    end

    self:setLayer(-50)
end

function DepthFountainFloor:update()
    super.update(self)

    self.siner = self.siner + DTMULT

    self.float_x = (self.float_x + self.scroll_speed * DTMULT) % self.tex_w
    self.float_y = (self.float_y + self.scroll_speed * DTMULT) % self.tex_h
end

function DepthFountainFloor:drawFloorTile()
    local ox = math.floor(self.float_x) % self.tex_w
    local oy = math.floor(self.float_y) % self.tex_h

    local x = -ox
    while x < self.width do
        local y = -oy
        while y < self.height do
            love.graphics.draw(self.float_texture, x, y, 0, self.tex_scale, self.tex_scale)
            y = y + self.tex_h
        end
        x = x + self.tex_w
    end
end

function DepthFountainFloor:renderToCanvas()
    local width = math.ceil(self.width)
    local height = math.ceil(self.height)

    if not self.floor_canvas or self.floor_canvas:getWidth() ~= width or self.floor_canvas:getHeight() ~= height then
        self.floor_canvas = love.graphics.newCanvas(width, height)
    end

    love.graphics.push("all")
    Draw.pushCanvas(self.floor_canvas, { clear = true })

    local r, g, b

    if self.fountain and self.fountain.getPaletteColor then
        local c = self.fountain:getPaletteColor(self.fountain.shift)
        r, g, b = c[1], c[2], c[3]
    else
        local shift_speed = 0.1
        local t = (self.siner * shift_speed / 30) % 1

        local palette = {
            { 0x0E / 255, 0x2B / 255, 0xAD / 255 },
            { 0x1A / 255, 0x3C / 255, 0xC3 / 255 },
            { 0x4B / 255, 0x2D / 255, 0xD8 / 255 },
            { 0x6A / 255, 0x2D / 255, 0xD8 / 255 },
            { 0xA4 / 255, 0x6E / 255, 0xFC / 255 },
            { 0x2D / 255, 0x0E / 255, 0xAD / 255 },
        }

        local count = #palette
        local scaled = t * count
        local i1 = math.floor(scaled) % count + 1
        local i2 = i1 % count + 1
        local frac = scaled - math.floor(scaled)

        local c1 = palette[i1]
        local c2 = palette[i2]

        r = c1[1] + (c2[1] - c1[1]) * frac
        g = c1[2] + (c2[2] - c1[2]) * frac
        b = c1[3] + (c2[3] - c1[3]) * frac
    end

    Draw.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", 0, 0, width, height)

    love.graphics.setShader(DepthFountainFloor._pixelate_shader)
    DepthFountainFloor._pixelate_shader:send("blocks_x", self.tex_w / self.pixel_factor)
    DepthFountainFloor._pixelate_shader:send("blocks_y", self.tex_h / self.pixel_factor)

    Draw.setColor(1, 1, 1, self.float_alpha)
    self:drawFloorTile()

    love.graphics.setShader()

    Draw.popCanvas()
    love.graphics.pop()
end

function DepthFountainFloor:draw()
    self:renderToCanvas()

    local prev_sx, prev_sy, prev_sw, prev_sh = love.graphics.getScissor()

    local transform = love.graphics.getTransform()
    local tx, ty = transform:transformPoint(0, 0)
    local bx, by = transform:transformPoint(self.width, self.height)

    local margin = self.afterimage_margin

    local scissor_x = math.floor(tx) - margin
    local scissor_y = math.floor(ty) - margin
    local scissor_w = math.floor(bx - tx) + margin * 2
    local scissor_h = math.floor(by - ty) + margin * 2

    if prev_sw and prev_sw > 0 then
        local nx = math.max(scissor_x, prev_sx)
        local ny = math.max(scissor_y, prev_sy)
        local nw = math.min(scissor_x + scissor_w, prev_sx + prev_sw) - nx
        local nh = math.min(scissor_y + scissor_h, prev_sy + prev_sh) - ny
        scissor_x, scissor_y, scissor_w, scissor_h = nx, ny, nw, nh
    end

    love.graphics.setScissor(scissor_x, scissor_y, scissor_w, scissor_h)

    local ysin = math.cos(self.siner / 12) * 3

    for i = 2, 1, -1 do
        Draw.setColor(1, 1, 1, self.afterimage_alpha)
        Draw.draw(self.floor_canvas, ysin * 2 * i, ysin * 2 * i)
    end

    Draw.setColor(1, 1, 1, 1)
    Draw.draw(self.floor_canvas, 0, 0)

    if prev_sw and prev_sw > 0 then
        love.graphics.setScissor(prev_sx, prev_sy, prev_sw, prev_sh)
    else
        love.graphics.setScissor()
    end

    Draw.setColor(1, 1, 1, 1)
end

return DepthFountainFloor