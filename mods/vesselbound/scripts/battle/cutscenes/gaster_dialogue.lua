
return {

    gaster_ending = function(cutscene)
        local fake_go = FakeGameOver(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
        fake_go.layer = BATTLE_LAYERS["above_ui"] + 100
        Game.battle:addChild(fake_go)

        cutscene:wait(5.5)

        if fake_go.music and fake_go.music:isPlaying() then
            fake_go.music:stop()
        end
        Game.battle.music:play("AUDIO_DRONE")

        local dialogue_layer = BATTLE_LAYERS["above_ui"] + 200
        local text_x = SCREEN_WIDTH / 2 - 180
        local text_y = SCREEN_HEIGHT / 2 - 120

        local dialogue1 = DialogueText(
            "[speed:0.5]YOU HAVE BEEN DEPRIVED\nOF YOUR CURRENT HOST",
            text_x, text_y,
            { style = "GONER", voice = "none", line_offset = 12 }
        )
        dialogue1.layer = dialogue_layer
        Game.battle:addChild(dialogue1)

        cutscene:wait(function()
            return Input.pressed("confirm") and not dialogue1:isTyping()
        end)

        dialogue1:remove()
        cutscene:wait(0.3)

        local dialogue2 = DialogueText(
            "[speed:0.5]A NEW HOST IS REQUIRED\nTO CONTINUE THE EXPERIMENT",
            text_x, text_y,
            { style = "GONER", voice = "none", line_offset = 12 }
        )
        dialogue2.layer = dialogue_layer
        Game.battle:addChild(dialogue2)

        cutscene:wait(function()
            return Input.pressed("confirm") and not dialogue2:isTyping()
        end)

        dialogue2:remove()
        cutscene:wait(0.3)

        fake_go:hideSoul()
        cutscene:wait(1.5)

        Game.battle:setState("VICTORY")
    end
}