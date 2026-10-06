local kris, super = Class(Encounter)

function kris:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* When did you stop being yourself?"

    -- Battle music ("battle" is rude buster)
    self.music = "battle"
    -- Enables the purple grid battle background
    self.background = false

    -- Add the kris enemy to the encounter
    self:addEnemy("kris")

    --- Uncomment this line to add another!
    --self:addEnemy("kris")
end

return kris
