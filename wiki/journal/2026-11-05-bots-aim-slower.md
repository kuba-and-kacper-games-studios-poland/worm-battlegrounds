---
title: "Bots think 2.5 to 4 s, then take aim visibly for 1.5 s before firing"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Settings.lua
---

**What changed.** Bots shoot slower. A bot used to think 1.5 to 3 seconds and fire at once; now it thinks 2.5 to 4
seconds, then holds its weapon and swings its aim from level to its shot over 1.5 seconds, with its aim line shown to
everyone, and fires. In a Studio playtest an Easy bot fired about 4.2 seconds into its 15-second turn.

**Where.** Bots' `TakeTurn` and `_showAim`. Settings: `THINK_TIME` { 2.5, 4 } (was { 1.5, 3 }), `AIM_TIME` 1.5,
`AIM_STEP` 0.1 (how often the aim is sent), `AIM_START_POWER` 0.3. How often bots hit (`HIT_RATE`) is unchanged.

**How to check.** Play solo: the bot waits a few seconds, raises its weapon toward you with its dots showing, then
fires.

**For the wiki.** Wherever bots are described (solo matches): they take a few seconds and aim where you can see it.
