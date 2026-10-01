local World, super = HookSystem.hookScript(World)

function World:setBattle(state, ...)
    super.setBattle(self, state, ...)

    local leader = Game.party and Game.party[1]
    if leader and leader.id == "SOUL" then
        local player = self.player
        if player then
            local target_alpha = state and 0 or 1
            local duration = 0.5

            if player._battle_alpha_tween then
                self.timer:cancel(player._battle_alpha_tween)
                player._battle_alpha_tween = nil
            end

            if state then
                player.visible = true
                player._battle_alpha_tween = self.timer:tween(duration, player, {alpha = target_alpha}, "linear", function()
                    player._battle_alpha_tween = nil
                    player.visible = false
                end)
            else
                player.visible = true
                player._battle_alpha_tween = self.timer:tween(duration, player, {alpha = target_alpha}, "linear", function()
                    player._battle_alpha_tween = nil
                end)
            end
        end
    end
end

return World