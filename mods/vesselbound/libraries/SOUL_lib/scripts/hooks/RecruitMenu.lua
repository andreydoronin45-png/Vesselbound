local RecruitMenu, super = HookSystem.hookScript(RecruitMenu)

function RecruitMenu:draw()
    super.draw(self)

    local leader = Game.party and Game.party[1]
    if leader and leader.id == "SOUL" then
        love.graphics.setLineWidth(4)
        Draw.setColor(1, 0, 0)
        if self.state == "SELECT" then
            love.graphics.rectangle("line", 32, 12, 587, 427)
        elseif self.state == "INFO" then
            love.graphics.rectangle("line", 32, 12, 577, 437)
        end
        love.graphics.rectangle("line", self.recruit_box.x, self.recruit_box.y, self.recruit_box.width + 1, self.recruit_box.height + 1)
        love.graphics.setLineWidth(1)
    end
end

return RecruitMenu