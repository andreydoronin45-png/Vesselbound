---@class SwingBullet : Bullet
local SwingBullet, super = Class(Bullet)

---@param x number
---@param y number
---@param dir number
---@param speed number
---@param fatal boolean? 
function SwingBullet:init(x, y, dir, speed, fatal)
    super.init(self, x, y, "bullets/swing_bullet")

    self.scale_x = 1
    self.scale_y = 1

    self.physics.direction = dir
    self.physics.speed = speed

    self.rotation = dir
    self.physics.match_rotation = true

    local hitbox_size = 32  
    self:setHitbox(-hitbox_size / 2 + 16, -hitbox_size / 2 + 16, hitbox_size - 16, hitbox_size)

    if fatal then
        self.inv_frames = 0.5 
    end

    self.trail_timer = 0
end

function SwingBullet:update()
    super.update(self)

    self.trail_timer = self.trail_timer + 1
    if self.trail_timer >= 2 then
        self.trail_timer = 0

        local ghost = AfterImage(self.sprite, 0.5, 0.1)
        Game.battle:addChild(ghost)
        ghost.layer = self.layer - 1
    end
end

return SwingBullet