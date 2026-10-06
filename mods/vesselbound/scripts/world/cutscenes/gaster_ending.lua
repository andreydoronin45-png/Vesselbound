return {
    gaster_ending = function(cutscene)
        if Game.world.music and Game.world.music:isPlaying() then
            Game.world.music:stop()
        end

        local fake_go = FakeGameOver(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
        fake_go.layer = 9999
        Game.world:addChild(fake_go)

        if Game.gaster_black_screen then
            Game.gaster_black_screen:remove()
            Game.gaster_black_screen = nil
        end

        cutscene:wait(3)

        Game.world.music:play("AUDIO_DRONE")

        local dialogue_layer = 10000
        local text_x = SCREEN_WIDTH / 2 - 180
        local text_y = SCREEN_HEIGHT / 2 - 120

        local dialogue = DialogueText(
            "[speed:0.5][spacing:8][voice:none]YOU HAVE[wait:30]\nBEEN DEPRIVED",
            text_x, text_y,
            {
                style = "GONER",
                voice = "none",
                line_offset = 12,
            }
        )
        dialogue.layer = dialogue_layer
        Game.world:addChild(dialogue)

        cutscene:wait(function()
            return Input.pressed("confirm") and not dialogue:isTyping()
        end)

        dialogue:setText("[speed:0.5][spacing:8][voice:none]OF YOUR[wait:30]\nCURRENT HOST")

        cutscene:wait(function()
            return Input.pressed("confirm") and not dialogue:isTyping()
        end)

        dialogue:setText("[speed:0.5][spacing:8][voice:none]A NEW HOST[wait:30]\nIS REQUIRED")

        cutscene:wait(function()
            return Input.pressed("confirm") and not dialogue:isTyping()
        end)

        dialogue:setText("[speed:0.5][spacing:8][voice:none]TO CONTINUE[wait:30]\nTHE EXPERIMENT")

        cutscene:wait(function()
            return Input.pressed("confirm") and not dialogue:isTyping()
        end)

        dialogue:remove()
        cutscene:wait(0.3)

        fake_go:hideSoul()
        cutscene:wait(1.5)

        fake_go:remove()
    end
}