---
title: "Worms hold their weapon, on the side facing the camera"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: added
pages: ["Arsenal", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Held.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** During its turn, the active worm holds the weapon picked in its loadout bar (a bot: the weapon it
chose), in front of its body on the camera's side, so players always see it. The weapon points the way the worm
faces and turns with its aim while it aims, never upside down; it goes when the shot is fired or the turn ends.
Weapons without a model yet (Baseball Bat, Minigun, One Punch, Spartan Spear, Variety Grenade) show nothing.

**Where.** Combat's client handler `Scripts/Client/Held.lua` copies the weapon's model (`I.G_Arsenal.GetModel`) into
`Workspace.Ume.Combat` on every client, from the worm's `HeldItem`, `Active`, `AimAngle` and `AimTime` attributes.
Settings: `HELD_FORWARD` 0.8 (studs along the aim), `HELD_HEIGHT` -0.3, `HELD_DEPTH` 1.5 (toward the camera),
`HELD_TURN_SPEED` 14.

**How to check.** In a match, the player's worm holds the Bazooka at its turn; the bot's weapon rises toward its
target as it aims (checked in a Studio playtest).

**For the wiki.** Arsenal: worms hold the weapon they've picked. Match screen: the held weapon shows whose turn it is
and what they hold.
