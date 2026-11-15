---
title: "Tutorial: a real match against a bot that shoots back, a red arrow and a prediction line, no crate"
date: 2026-11-15
status: open
kind: changed
pages: ["Tutorial", "Bots", "Training Meadow"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/MatchHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/LobbyHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/Spotlight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TutorialHint/init.lua
---

**What changed.** A tester's notes (Bax). The tutorial is a whole match now, its guide points instead of blacking out,
and it has no crate.

- **The bot.** It plays and shoots back, with the Bazooka only: Easy's brain (Bots' `TUTORIAL_BRAIN`) and a clumsier
  hand (`SKILLS.Tutorial`: AimNoise 14°, PowerNoise 0.15, WindRead 0.2). It has 100 health (Bots' `HEALTH`, was 10);
  a snail has 200. It no longer fumbles and passes (`TUTORIAL_FUMBLE_POWER` is gone).
- **The player's shots.** Nothing steers them onto the bot any more (Combat's `Fire` and `Aimbot.GetShot` are gone).
- **The player's loadout.** The Bazooka and a Grenade, whatever their own loadout (Match's `TUTORIAL_LOADOUT`).
- **The steps.** The player plays first, so their turn is the round:
  - Land on the lit spot.
  - Round 1: shoot the bot.
  - Round 2: pick the Grenade on the bar, then throw it. Its cooldown makes it ready on turn 2.
  - Round 3: strong wind against the shot. The arrow points at the wind number.
  - After that: finish the bot.
  - The bot's turns show a hint alone, and the results point at Back to lobby.
- **The tutorial's wind.** Match's `TUTORIAL_WINDS` is `{ 0, -16 }`: calm for rounds 1 and 2, then −16 for rounds 3
  and 4. The player starts left of the bot, so it blows against them. After that it rolls as usual.
- **The guide.** Nothing is darkened or blocked any more. A pulsing gold ring sits on the target, a red arrow
  (`TutorialHint` › `U_Arrow`) bobs toward it, and the hint panel sits beside them. The arrow turns over to point up
  near the screen's top. The hint panel with no target sits at 25% of the height (`HINT_TOP`), under the turn banner.
- **The prediction line.** Tutorial only, for arced weapons (MatchHud's `PREDICTION_*`). Gold dots follow the shot's
  path, wind included, to the first thing it hits, with a red dot where it lands. It moves with the power held while
  charging; before a press it shows the power last fired, faded. It ignores water and bounces.
- **No crate.** The match gives 100 coins plus the Grenade and the Shotgun (Tutorial's `_giveStarters`). The lobby
  guide goes straight to putting them in the loadout. The tutorial crate's steps, and its close button step, are
  gone. The `Tutorial` crate row stays hidden and never opens. Someone who played the match before this but never
  opened the crate gets the two weapons on their next join.
- **Data.** The saved `Tutorial.CrateOpened` key now means "starter weapons given". The Replicator's `CrateReady` is
  gone.
- **Funnel.** The steps are Drop, Aim, Grenade, Throw, Wind, Lobby, Equip, Pick, Equipped. Funnel numbers from before
  this change don't compare with after.

**Where.** Tutorial's `HINTS`, `TOUCH_HINTS`, `PAD_HINTS`, `FUNNEL_STEPS` and `ARROW_*`, and `MatchHints._tick`. Bots'
`SKILLS.Tutorial`, `HEALTH` and `LOADOUTS.Tutorial`. Match's `TUTORIAL_WINDS` and `TUTORIAL_LOADOUT`. MatchHud's
`Aim._drawPrediction`.

**How to check.** Set Workspace's `StudioTutorial` to true and play on the Studio map.

- **Checked in Studio on 2026-11-15:**
  - The drop arrow and ring.
  - The aim hint over the bot, with the line.
  - The bot shooting back.
  - The Grenade step pointing at its slot.
  - The −16 wind on round 3, with the arrow up at the wind and the line blown back.
  - The results' arrow.
  - The weapons given (Grenade 1, Shotgun 1) and the lobby's slot step.
  - In a second run: the bot at 100/100, and the gold line landing on the bot at 59% power.
- **Not checked:**
  - The Throw hint after picking the Grenade: the scripted click on the slot fired a shot instead, so it wasn't seen.
  - The touch screen and pad wording.

**For the wiki.** Tutorial: the new flow, the prediction line, no crate. Bots: the tutorial bot now plays. Training
Meadow: still the tutorial's map.

Supersedes 2026-11-15-tutorial-funnel's step list. The drop in 2026-11-15-tutorial-drop-spot still holds.
