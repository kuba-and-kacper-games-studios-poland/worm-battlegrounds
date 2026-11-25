---
title: "Tutorial: a MOVE HERE step first, and a real fight with the bot"
date: 2026-11-25
status: open
kind: changed
pages: ["Tutorial"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/MatchHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/Spotlight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TutorialHint/init.lua
---

**What changed.** The owner: "first do MOVE HERE - and a arrow and like a tip showing that we can move around using
wasd or the arrows on mobile", and "lets not make so our rocket kills the worm in one hit... so there is the battle".

- On the player's first turn, before "Drag to aim", the red arrow points up at a ring on flat ground 8 studs toward
  the bot ("Move here"), with a smaller tip under it for the device: "Walk with A and D, or the arrow keys" (PC),
  "Walk with the arrow buttons" (phones), "Walk with {Move}" (pad). It's done once the snail is 2 studs from the
  ring, has walked 6 studs, or the player starts aiming; with no flat ground there it's skipped.
- The bot has a snail's full health (250), not 10, so the player fires turn after turn until it's out. It still
  never hits back.
- The onboarding funnel has a Move step after Drop: Drop, Move, Aim, Fire, Won, Pick, Equipped, so its numbers before
  and after this day don't compare.

**Where.** Tutorial's `HINTS.Move`, `MOVE_DISTANCE` (8), `MOVE_SHORT_DISTANCE` (5), `MOVE_STEP` (3), `MOVE_REACH`
(2), `MOVE_DONE_DISTANCE` (6), `MOVE_TIPS`, `FUNNEL_STEPS`; MatchHints' `_needsMove`, `_getMoveSpot`, `_getMoveTip`;
Spotlight's `Show(text, target, step, place, tip?)`; the TutorialHint gui's new `U_Hint › S_Tip` label; Bots'
`HEALTH` (empty).

**How to check.** In Studio, set Workspace's `StudioTutorial` true and clear the profile's Tutorial flags: on the
first turn "MOVE HERE" points at a ring with the walk tip under it; walking there moves on to "Drag to aim"; the bot
takes several rockets.

**For the wiki.** Tutorial: the steps list (land, move, aim and fire until the bot is out, win card, pick a weapon),
the walk tips, and a History line.
