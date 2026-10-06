---@class ShatterOptions
---@field parent Object? Parent for the new shards. Defaults to the source parent.
---@field shard_count integer? Number of pieces. Defaults to 12; minimum 4.
---@field pixel_size integer? Size of each hard-edged mask pixel. Defaults to 2.
---@field x number? Left edge of the capture region. Defaults to 0.
---@field y number? Top edge of the capture region. Defaults to 0.
---@field width number? Width of the capture region. Defaults to source.width.
---@field height number? Height of the capture region. Defaults to source.height.
---@field center_x number? Local shatter origin. Defaults near the capture center.
---@field center_y number? Local shatter origin. Defaults near the capture center.
---@field center_jitter number? Random center displacement as a region/size ratio. Defaults to 0.12.
---@field ringed boolean? Prophecylike. Defualt true. basically means you have trapezoids on outer and more triangles inner. makes it look... glassy fuck idk
---@field inner_ring number|{number, number}? Inner ring distance ratio or min/max range. Defaults to {0.28, 0.46}.
---@field speed number|{number, number}? Outward speed or min/max range. Defaults to {2, 6}.
---@field angle_jitter number? Random launch angle range in radians. Defaults to 0.25.
---@field gravity number? Shard gravity. Defaults to 0.2. Set to 0 to disable.
---@field gravity_direction number? Gravity angle. Defaults to math.pi / 2.
---@field spin number|{number, number}? Spin or min/max range. Defaults to {-0.08, 0.08}.
---@field friction number? Shard movement friction. Defaults to 0.
---@field layer number? Shard layer. Defaults to source.layer.
---@field hide_source boolean? Hide the source after capture. Defaults to true.
---@field remove_source boolean? Remove the source after capture. Defaults to false.
---@field capture_children boolean? Include the source's children. Defaults to true.

---@class ShatterUtils
local ShatterUtils = {}

---cursed thing that basically just makes random if more than one value
local function randomRange(value, default_min, default_max)
    if type(value) == "table" then
        return MathUtils.random(value[1] or default_min, value[2] or value[1] or default_max)
    elseif type(value) == "number" then
        return value
    end
    return MathUtils.random(default_min, default_max)
end

local function pointOnPerimeter(distance, width, height)
    local perimeter = (width + height) * 2
    distance = distance % perimeter

    if distance <= width then
        return distance, 0
    elseif distance <= width + height then
        return width, distance - width
    elseif distance <= width * 2 + height then
        return width - (distance - width - height), height
    else
        return 0, height - (distance - width * 2 - height)
    end
end

local function polygonContains(px, py, polygon)
    for i, point in ipairs(polygon) do
        local next_point = polygon[(i % #polygon) + 1]
        local x1, y1 = point[1], point[2]
        local x2, y2 = next_point[1], next_point[2]
        local cross = (px - x1) * (y2 - y1) - (py - y1) * (x2 - x1)

        -- CollisionUtil's ray cast does not explicitly include boundaries so i get to do this abysmal dogshit
        if math.abs(cross) < 0.0001
            and px >= math.min(x1, x2) - 0.0001
            and px <= math.max(x1, x2) + 0.0001
            and py >= math.min(y1, y2) - 0.0001
            and py <= math.max(y1, y2) + 0.0001
        then
            return true
        end
    end

    return CollisionUtil.pointPolygon(px, py, polygon)
end

local function generatePerimeterPoints(width, height, count)
    local perimeter = (width + height) * 2
    local distances = {0, width, width + height, width * 2 + height}

    for _ = 1, count - 4 do
        table.insert(distances, MathUtils.random(0, perimeter))
    end
    table.sort(distances)

    local points = {}
    for _, distance in ipairs(distances) do
        local x, y = pointOnPerimeter(distance, width, height)
        table.insert(points, {x, y})
    end
    return points
end

local function generateFanPolygons(width, height, count, center_x, center_y)
    local points = generatePerimeterPoints(width, height, count)

    local polygons = {}
    for i, point in ipairs(points) do
        local next_point = points[(i % #points) + 1]
        polygons[i] = {
            {center_x, center_y},
            point,
            next_point,
        }
    end
    return polygons
end

local function generateRingedPolygons(width, height, count, center_x, center_y, inner_ring)
    if count < 8 then
        return generateFanPolygons(width, height, count, center_x, center_y)
    end

    local sector_count = math.floor(count / 2)
    local outer = generatePerimeterPoints(width, height, sector_count)
    local inner = {}

    for i, point in ipairs(outer) do
        local ratio = randomRange(inner_ring, 0.28, 0.46)
        inner[i] = {
            center_x + (point[1] - center_x) * ratio,
            center_y + (point[2] - center_y) * ratio,
        }
    end

    local polygons = {}

    --  inner ring
    for i, point in ipairs(inner) do
        local next_point = inner[(i % #inner) + 1]
        table.insert(polygons, {
            {center_x, center_y},
            point,
            next_point,
        })
    end

    -- outer ring
    for i, point in ipairs(inner) do
        local next_i = (i % #inner) + 1
        local next_point = inner[next_i]

        if count % 2 == 1 and i == 1 then
            table.insert(polygons, {
                point,
                outer[i],
                outer[next_i],
            })
            table.insert(polygons, {
                point,
                outer[next_i],
                next_point,
            })
        else
            table.insert(polygons, {
                point,
                outer[i],
                outer[next_i],
                next_point,
            })
        end
    end

    return polygons
end

-- kinda cursed and only useful for the arena shatter but whaateverrrr
local function findSharpestVertex(polygon)
    local point_count = #polygon
    local sharpest_x, sharpest_y = polygon[1][1], polygon[1][2]
    local sharpest_angle = math.huge

    for i, point in ipairs(polygon) do
        local previous = ((i - 2) % point_count) + 1
        local following = (i % point_count) + 1
        local x, y = point[1], point[2]
        local previous_x, previous_y =
            polygon[previous][1] - x,
            polygon[previous][2] - y
        local following_x, following_y =
            polygon[following][1] - x,
            polygon[following][2] - y
        local length_product =
            math.sqrt(previous_x * previous_x + previous_y * previous_y)
            * math.sqrt(following_x * following_x + following_y * following_y)

        if length_product > 0 then
            local cosine = (
                previous_x * following_x + previous_y * following_y
            ) / length_product
            local angle = math.acos(math.max(-1, math.min(1, cosine)))

            if angle < sharpest_angle then
                sharpest_angle = angle
                sharpest_x, sharpest_y = x, y
            end
        end
    end

    return sharpest_x, sharpest_y
end

---cause otherwise you could theoretically have like. tiny evil fuck you polygons
local function rasterizeMasks(width, height, pixel_size, polygons)
    local masks = {}
    for i = 1, #polygons do
        local tip_x, tip_y = findSharpestVertex(polygons[i])
        masks[i] = {
            runs = {},
            vertex_count = #polygons[i],
            tip_x = tip_x,
            tip_y = tip_y,
            pixel_size = pixel_size,
            min_x = math.huge,
            min_y = math.huge,
            max_x = -math.huge,
            max_y = -math.huge,
        }
    end

    for y = 0, height - 1, pixel_size do
        local run_owner, run_x, run_width

        local function finishRun()
            if not run_owner then
                return
            end
            local mask = masks[run_owner]
            local run_height = math.min(pixel_size, height - y)
            table.insert(mask.runs, {run_x, y, run_width, run_height})
            mask.min_x = math.min(mask.min_x, run_x)
            mask.min_y = math.min(mask.min_y, y)
            mask.max_x = math.max(mask.max_x, run_x + run_width)
            mask.max_y = math.max(mask.max_y, y + run_height)
        end

        for x = 0, width - 1, pixel_size do
            local sample_x = math.min(x + pixel_size / 2, width - 0.001)
            local sample_y = math.min(y + pixel_size / 2, height - 0.001)
            local owner

            for i, polygon in ipairs(polygons) do
                if polygonContains(sample_x, sample_y, polygon) then
                    owner = i
                    break
                end
            end
            owner = owner or #polygons
            local cell_width = math.min(pixel_size, width - x)
            if owner == run_owner then
                run_width = run_width + cell_width
            else
                finishRun()
                run_owner = owner
                run_x = x
                run_width = cell_width
            end
        end
        finishRun()
    end

    for _, mask in ipairs(masks) do
        if #mask.runs > 0 then
            mask.bounds = {
                x = mask.min_x,
                y = mask.min_y,
                width = mask.max_x - mask.min_x,
                height = mask.max_y - mask.min_y,
            }
        end
        mask.min_x, mask.min_y, mask.max_x, mask.max_y = nil, nil, nil, nil
    end
    return masks
end

---Captures an Object's draw output and spawns a bunch of shards out of it.
---
---Because this captures `Object:drawSelf()` rather than reading a Sprite
---texture, it also works with procedural Objects such as Arena. Probably. Hopefully.
---
---example:    local shards = ShatterUtils.shatterObject(Game.battle.arena)
---@param source Object
---@param options? ShatterOptions
---@return ShatterShard[] shards
function ShatterUtils.shatterObject(source, options)
    options = options or {}
    local parent = options.parent or source.parent

    local capture_x = math.floor(options.x or 0)
    local capture_y = math.floor(options.y or 0)
    local width = math.max(1, math.ceil(options.width or source.width))
    local height = math.max(1, math.ceil(options.height or source.height))
    local pixel_size = math.max(1, math.floor(options.pixel_size or 2))
    local shard_count = math.max(4, math.floor(options.shard_count or 12))
    local center_jitter = options.center_jitter
    if center_jitter == nil then center_jitter = 0.12 end

    local center_x = options.center_x and (options.center_x - capture_x)
        or width / 2 + MathUtils.random(-width * center_jitter, width * center_jitter)
    local center_y = options.center_y and (options.center_y - capture_y)
        or height / 2 + MathUtils.random(-height * center_jitter, height * center_jitter)
    center_x = MathUtils.clamp(center_x, math.min(pixel_size, width / 2), math.max(width - pixel_size, width / 2))
    center_y = MathUtils.clamp(center_y, math.min(pixel_size, height / 2), math.max(height - pixel_size, height / 2))

    local snapshot = love.graphics.newCanvas(width, height)
    snapshot:setFilter("nearest", "nearest")
    love.graphics.push("all")
    Draw.pushCanvas(snapshot, {clear = true, stencil = true})
    love.graphics.translate(-capture_x, -capture_y)
    source:drawSelf(options.capture_children == false, true)
    Draw.popCanvas()
    love.graphics.pop()

    local polygons
    if options.ringed == false then
        polygons = generateFanPolygons(width, height, shard_count, center_x, center_y)
    else
        polygons = generateRingedPolygons(
            width,
            height,
            shard_count,
            center_x,
            center_y,
            options.inner_ring
        )
    end
    local masks = rasterizeMasks(width, height, pixel_size, polygons)
    local shards = {}
    local center_parent_x, center_parent_y =
        source:getRelativePos(capture_x + center_x, capture_y + center_y)

    for _, mask in ipairs(masks) do
        if mask.bounds then
            local pivot_local_x = capture_x + mask.bounds.x + mask.bounds.width / 2
            local pivot_local_y = capture_y + mask.bounds.y + mask.bounds.height / 2
            local pivot_x, pivot_y = source:getRelativePos(pivot_local_x, pivot_local_y)
            local shard = ShatterShard(pivot_x, pivot_y, width, height, snapshot, mask)

            shard.rotation = source.rotation
            shard.scale_x = source.scale_x
            shard.scale_y = source.scale_y
            shard.flip_x = source.flip_x
            shard.flip_y = source.flip_y
            shard.layer = options.layer or source.layer

            local angle_jitter = options.angle_jitter or 0.25
            local direction = math.atan2(pivot_y - center_parent_y, pivot_x - center_parent_x)
                + MathUtils.random(-angle_jitter, angle_jitter)
            shard.physics.direction = direction
            shard.physics.speed = randomRange(options.speed, 2, 6)
            shard.physics.friction = options.friction or 0
            shard.physics.gravity = options.gravity == nil and 0.2 or options.gravity
            shard.physics.gravity_direction = options.gravity_direction or math.pi / 2
            shard.graphics.spin = randomRange(options.spin, -0.08, 0.08)

            parent:addChild(shard)
            table.insert(shards, shard)
        end
    end

    if options.remove_source then
        source:remove()
    elseif options.hide_source ~= false then
        source.visible = false
    end

    return shards
end

return ShatterUtils
