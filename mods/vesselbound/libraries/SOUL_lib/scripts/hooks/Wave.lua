local Wave, super = HookSystem.hookScript(Wave)

function Wave:onEnd(...)
    super.onEnd(self, ...)

    local user = Game.party[1]
    if not user then return end

    for _, enemy in ipairs(Game.battle.enemies) do
        if enemy._decay_ticks and enemy._decay_ticks > 0 and not enemy.is_down then
            local user_attack = user:getStat("attack")
            local user_magic = user:getStat("magic")
            local dot_damage = math.ceil((user_attack * user_magic) / 2)
            if dot_damage < 1 then dot_damage = 1 end

            enemy:hurt(dot_damage, nil, nil, {1, 0, 0})

            Assets.playSound("ominous")
            local flash = enemy:flash()
            flash.color_mask:setColor(1, 0, 0)
            flash.alpha = 0.5
            flash:setScale(1.2)
            Game.battle.timer:tween(0.3, flash, {alpha = 0}, "out-cubic", function()
                flash:remove()
            end)

            enemy._decay_ticks = enemy._decay_ticks - 1
            if enemy._decay_ticks <= 0 then
                enemy._decay_ticks = nil
            end
        end
    end
end

return Wave