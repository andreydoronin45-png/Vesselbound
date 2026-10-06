
---@class FakeGameOver : Object
local FakeGameOver, super = Class(Object, "FakeGameOver")

function FakeGameOver:init(soul_x, soul_y)
    super.init(self, 0, 0)

    self.bg_alpha = 1

    self.timer = Timer()
    self:addChild(self.timer)

    self.music = Music()
    self.music:play("AUDIO_DEFEAT")

    self.continue_btn = Text("CONTINUE", 160, 360)
    self.continue_btn.alpha = 0
    self:addChild(self.continue_btn)

    self.giveup_btn = Text("GIVE UP", 390, 360)
    self.giveup_btn.alpha = 0
    self:addChild(self.giveup_btn)

    self.text = Sprite("ui/gameover", 0, 40)
    self.text:setScale(2)
    self.text.alpha = 0
    self:addChild(self.text)

    local heart_x = SCREEN_WIDTH / 2
    local heart_y = 380
    self.soul = SoulAppearance(heart_x, heart_y, { skip_appear = true, no_float = true })
    self.soul:setColor(Game:getSoulColor())
    self:addChild(self.soul)

    local t = self.timer

    t:tween(0.6, self.text, {alpha = 1}, "out-quad")
    t:tween(0.6, self.continue_btn, {alpha = 1}, "out-quad")
    t:tween(0.6, self.giveup_btn, {alpha = 1}, "out-quad")

    t:after(3, function()
        t:tween(1.0, self.text, {alpha = 0}, "out-quad")
        t:tween(1.0, self.continue_btn, {alpha = 0}, "out-quad")
        t:tween(1.0, self.giveup_btn, {alpha = 0}, "out-quad")

        self.music:fade(0, 1.0)

        t:after(1.0, function()
            t:tween(1.2, self.soul, {
                x = SCREEN_WIDTH / 2,
                y = SCREEN_HEIGHT / 2,
            }, "in-out-quad")
        end)
    end)
end

function FakeGameOver:hideSoul()
    if self.soul and self.soul.hide then
        self.soul:hide()
    end
end

function FakeGameOver:onRemove(parent)
    super.onRemove(self, parent)
    if self.music then
        self.music:remove()
    end
end

function FakeGameOver:draw()
    Draw.setColor(0, 0, 0, self.bg_alpha)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    Draw.setColor(1, 1, 1, 1)

    super.draw(self)
end

return FakeGameOver