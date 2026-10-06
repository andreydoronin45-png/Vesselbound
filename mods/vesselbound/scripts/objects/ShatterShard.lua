---A shard from a captured source canvas and a pixel mask.
---
---`mask.runs` contains `{x, y, width, height}` rectangles in source coordinates
---@class ShatterShard : Object
---@field canvas love.Canvas
---@field mask ShatterMask
---@field source love.Canvas
local ShatterShard, super = Class(Object)

---@class ShatterMask
---@field runs table[]
---@field bounds {x: integer, y: integer, width: integer, height: integer}
---@field vertex_count integer
---@field tip_x number
---@field tip_y number
---@field pixel_size integer

---@param x number
---@param y number
---@param width number
---@param height number
---@param source love.Canvas
---@param mask ShatterMask
function ShatterShard:init(x, y, width, height, source, mask)
    local bounds = mask.bounds
    super.init(self, x, y, bounds.width, bounds.height)

    self.source = source
    self.mask = mask
    self:setOrigin(0.5, 0.5)
    self:setScaleOrigin(0.5, 0.5)
    self:setRotationOrigin(0.5, 0.5)

    self.canvas = love.graphics.newCanvas(bounds.width, bounds.height)
    self.canvas:setFilter("nearest", "nearest")

    -- we bake the mask once cause otherwise we'd be redrawing it every frame for no reason (this is mildly cursed but its OK)
    love.graphics.push("all")
    Draw.pushCanvas(self.canvas, {clear = true, stencil = true})
    love.graphics.stencil(function()
        for _, run in ipairs(mask.runs) do
            love.graphics.rectangle(
                "fill",
                run[1] - bounds.x,
                run[2] - bounds.y,
                run[3],
                run[4]
            )
        end
    end, "replace", 1)
    love.graphics.setStencilTest("equal", 1)
    Draw.setColor(1, 1, 1, 1)
    Draw.draw(source, -bounds.x, -bounds.y)
    love.graphics.setStencilTest()
    Draw.popCanvas()
    love.graphics.pop()
end

function ShatterShard:draw()
    Draw.draw(self.canvas)
    super.draw(self)
end

return ShatterShard
