local actor, super = Class(Actor, "soul_empty")

function actor:init()
    super.init(self)
    self.name = "EMPTY"
    self.width = 19
    self.height = 27

    self.hitbox = {-1, 15, 19, 14}
    self.soul_offset = {8, 4}
    self.color = {1, 0, 0}
    self.path = "party/soul"
    self.default = "soul_empty"
    self.voice = nil
    self.portrait_path = nil
    self.portrait_offset = nil
    self.can_blush = false
    self.animations = {
        ["idle"] = {"soul_empty"},
    }
    self.offsets = {
        ["idle"] = {-5, 8},
    }
end

return actor