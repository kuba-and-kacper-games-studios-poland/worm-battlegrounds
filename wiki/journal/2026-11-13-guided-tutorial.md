---
title: "Guided tutorial: spotlight guide, a bot that can't shoot (10 health), fixed drop, lobby crate and loadout steps"
date: 2026-11-13
status: open
kind: changed
pages: ["Lobby & meta modules", "Match modules", "Lobby", "Bots", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/Spotlight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/MatchHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/LobbyHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Bodies.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Results.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TutorialHint/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Lobby/init.lua
---

**What changed.** The tutorial, reworked from the testers' brief:

- **The guide is a spotlight.** The `TutorialHint` gui blacks out the screen (8, 8, 14 at 0.3) around a lighter
  rounded square over what to press next, with a pulsing gold ring, blocks presses outside it, and shows the hint in
  the confirmation dialog's dark panel (a gold TUTORIAL title, white text) beside it. It replaces the old GUI-kit
  bubble and the lobby's arrow (`Lobby` › `U_Pointer`, removed). Hints are worded per device: `HINTS` (mouse and
  keyboard), `TOUCH_HINTS`, `PAD_HINTS` (pad button names).
- **The match.** Walk and jump hints are gone. The steps: "Click the lit spot to land there" (the hole on the
  player's drop spot), then "Point at the bot, hold the left mouse button to charge, let go to fire" (on touch "Tap
  the bot to aim at it", then the hole on FIRE: "Hold FIRE to charge, let go to shoot"), "The bot doesn't know how to
  shoot yet!" on its turn, "So close! Point at the bot and fire again" after a miss, and "You won! Head back to the
  lobby" with the hole on Return.
- **The bot** starts with 10 health (Bots' `HEALTH.Tutorial`; it used to take 3× damage, `DAMAGE_TAKEN`, two
  Bazooka hits out of 200), so any hit knocks it out. On its turn it raises the Bazooka at the sky, charges to 0.3
  (`TUTORIAL_FUMBLE_POWER`), gives up and passes (it used to fire beside the player). The snail attribute
  `DamageTaken` is gone; a participant's `MaxHealth` sets its health.
- **The drop and the turn order.** The player and the bot start on land about 30 studs apart near the map's middle
  (Match's `TUTORIAL_GAP` 30, from `TUTORIAL_SPOT_COUNT` 16 land spots), the drop lasts `TUTORIAL_DROP_SECONDS` 40
  (10 in other matches), and only a pick within `TUTORIAL_PICK_RADIUS` 6 studs of the shown spot counts. The player
  always plays first (Turns keeps the roster's order in the tutorial).
- **The results.** Rematch shows grey and does nothing (MatchHud's `LOCKED_REMATCH_COLORS`; it used to be hidden),
  so the player presses Return. The server still sends them back when the results' timer ends.
- **The lobby.** The guide lights the Weapons button ("You've got a free crate! Open your crates"), the crate's x1
  ("Open your free crate"), the crate and its TAP TO OPEN line ("Tap the crate to open it!"), shows "Let's see what
  you got!" alone while the reels roll, lights Continue ("Your new weapons!
  Press Continue") and the crates' close, then a loadout slot ("Put the Grenade and the Shotgun in your loadout: press
  a slot") and, in the picker, each weapon ("Pick the Grenade"). The starter weapons are still the Grenade and the
  Shotgun (the testers wrote "rifle"; the game has none).

**Where.** Tutorial's `Spotlight.lua` (`Show`, `Hide`, `_getHole`), `MatchHints._tick`, `LobbyHints._tick`, its
Settings; Bots' `_playTutorial`, `HEALTH`; Match's `Phases._getTutorialSpots`, `PickDrop`, `Turns.Reset`; MatchHud's
`Results`.

**How to check.** Set Workspace's `StudioTutorial` true and play: the drop lights a spot near the bot; clicks
elsewhere do nothing; one Bazooka hit knocks the bot out; the results' Rematch is grey; in the lobby the guide walks
through the crate and the loadout. Exported (TutorialHint, Lobby, MatchBoard, MatchHud) with
`UmeGui.Export` on 2026-11-13, the old copies kept in `ServerStorage.!dump` as `<Name>_before_2026-11-13`. Played in
Studio: the owner beat the bot with one 35-damage hit. Fixed after that run: the hole sat 58 px (the top bar) too low
over world spots and too high over buttons (every gui's `AbsolutePosition` counts from under the top bar, so world
spots go through `WorldToScreenPoint`), and Rematch's gold `Mask` picture kept it looking yellow (now hidden in the
tutorial). Measured after the fix: the drop's hole sits within 1 px of the spot. Then the lobby half, clicked
through in Studio: each hole sat on its button with its 10 px padding (Weapons, x1, Continue, the close, Slot1, the
Grenade card, Slot2, the Shotgun card), each press moved the guide on, and it closed once both weapons were in. Fixed
in that run: on the Studio map the match guide hid the lobby guide's spotlight every frame (it now takes down only
its own), and the crate's tap had no hole (it now lights the crate's area, projected from the Crates viewport's
camera, whose own `WorldToViewportPoint` reports a 1 × 1 view). That hole was measured on the waiting crate
(x 570 to 1337, y 158 to 877 on a 1918 × 1080 screen) but not yet seen lit in play.

**For the wiki.** Lobby & meta modules (Tutorial): the new steps and the spotlight. Bots: the tutorial bot. Match
modules: the tutorial's drop and turn order. Match screen: the grey Rematch. Training Meadow, the tutorial's own map,
has its own entry (`2026-11-13-training-meadow-map`).
