SOUL_lib — SOUL Library for Kristal.
SOUL_lib adds a custom SOUL party member to your Kristal project. This library includes unique spells, a custom soul sprite, and several battle mechanics.

Features:
SOUL Party Member — A new character with custom stats and animations.
SOUL Buster — Powerful attack with the Decay debuff (5 damage ticks, one per wave).
Soul Light — Heal an ally using SOUL power.
Haste — Temporarily increases the SOUL's movement speed for 2 waves.
Custom Soul mode — The soul in battle uses the "soul_blur" sprite and changes to "soul_defend" during defense.
Red UI — All menu frames turn red when SOUL is the party leader.

Installation:

1. Download or clone this repository.
2. Copy the "SOUL_lib" folder into your Kristal project's "libraries/" folder.
3. Open your "mod.json" and add ""SOUL_lib"" to the "libraries" section:

mod.json:
    "libraries": ["SOUL_lib"],