local Kris, super = Class(EnemyBattler)

function Kris:init()
    super.init(self)

    -- Enemy name
    self.name = "Kris"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/Kris.lua)
    self:setActor("kris")
    self:setAnimation("battle/idle")
    if self.sprite then
        self.sprite.flip_x = true
    end

    -- Enemy health
    self.max_health = 450
    self.health = 450
    -- Enemy attack (determines bullet damage)
    self.attack = 4
    -- Enemy defense (usually 0)
    self.defense = 0
    -- Enemy reward
    self.money = 100

    -- Mercy given when sparing this enemy before its spareable (20% for basic enemies)
    self.spare_points = 20

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        "sword_swing_fatal"
        
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "AT 4 DF 0\n* A Cage without human soul\nand parts."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* The Kris gives you a soulles\nsmile.",
        "* Smells like flesh.",
    }
    -- Text displayed at the bottom of the screen when the enemy has low health
    --self.low_health_text = "* The Kris looks like it's\nabout to fall over."

    -- Register act called "Smile"
    --self:registerAct("Smile")
    -- Register party act with Ralsei called "Tell Story"
    -- (second argument is description, usually empty)
    --self:registerAct("Tell Story", "", {"ralsei"})
end

function Kris:onAct(battler, name)


    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super.onAct(self, battler, name)
end

return Kris