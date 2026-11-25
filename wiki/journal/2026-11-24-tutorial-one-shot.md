---
title: "Tutorial: land, drag, FIRE, one hit wins, equip a weapon, then 100 coins; END TUTORIAL"
date: 2026-11-24
status: open
kind: changed
pages: ["Tutorial", "Controls"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/MatchHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/LobbyHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/Spotlight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Panels.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Results.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/TopBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TutorialHint/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TutorialWin/init.lua
---

**What changed.** The owner (2026-11-24: "VERY VERY SIMPLE", "click to land - then aiming, click Fire", "we kill the
tutorial bot with 1 hit") cut the tutorial down to one shot and one equip. Supersedes the step list of
2026-11-15-tutorial-full-match (a step per round: shoot, Grenade, strong wind) and its grey Rematch; still true from
it: a 1v1 on Training Meadow against the tutorial bot, the player first, the red arrow with nothing blacked out, the
prediction line, no crate, Grenade and Shotgun as the starter weapons. Also supersedes 2026-11-16-tutorial-picker-opens
(the picker opened once for each starter weapon; now once in all), and the line of 2026-11-24-coin-payout saying
`CompleteMatch` pays the tutorial's coins (now the tutorial's end does, below).

- **In the match**, with the Bazooka alone (Match's `TUTORIAL_LOADOUT` `{}`, was `{ "Grenade" }`), no wind (Match's
  `TUTORIAL_WINDS` `{ 0, -16 }` is gone) and no clocks: the drop and the player's turns last 900 s
  (`TUTORIAL_DROP_SECONDS`, was 40; new `TUTORIAL_TURN_SECONDS`), and the HUD hides the turn timer, the "You're next"
  line and the drop's timer and title. The bot's turns keep `TURN_SECONDS` (25).
  1. "Click to land" ("Tap to land"; pad "{Move} to the light, {PlaceDrop} to land"): the arrow points up at a soft
     white ring from below the lit spot, since the drop pin hangs over it.
  2. "Drag to aim" ("Aim with {Aim}" on a pad) alone under the player's snail, with a white touch point sliding
     right and up as a drag would (`SWIPE_*`: 150 design px right, 34 up, every 1.6 s), until they've aimed this turn
     (`I.MatchHud.HasAimedThisTurn`).
  3. "Press FIRE" ("Tap FIRE", pad "Press {Fire}") with the arrow on the FIRE button.
  - Any hit knocks the bot out: Bots' `HEALTH.Tutorial` 10 (was 100, of 200), the Bazooka's blast edge too.
  - The bot never hits the player: on its turn (`_missOnPurpose`) it fires the Bazooka 55° up away from the player
    (`TUTORIAL_MISS_ANGLE`), at the power, tried every 0.05 (`TUTORIAL_MISS_POWER_STEP`), that lands farthest from
    both snails and at least 10 studs from each (`TUTORIAL_MISS_CLEAR`). Its turns show no hint.
- **The win card** (`TutorialWin`, new gui) replaces the Results screen in the tutorial: "You won!" (with the win
  fanfare) or "Nice try!" (`WIN_TITLE`, `LOST_TITLE`), one yellow CONTINUE with the arrow pointing up at it from
  below. CONTINUE fires `Match_Leave`.
- **In the lobby** the picker opens by itself once; "Pick a weapon" points in from the left at the Grenade's card, or
  at a free loadout slot. Equipping either starter weapon finishes the tutorial (was both); a loadout that already
  holds one finishes it on arrival.
- **Coins:** the match no longer pays (`CompleteMatch` gives only `MatchDone` and the starter weapons). The 100 coins
  (`MATCH_COINS`) are paid when the tutorial finishes (`_finish`: `Currency.Add` and
  `I.Progression.AddReplayCoins`), so they fly into the coins slot.
- **END TUTORIAL** on the top bar (left side, after Settings and music: `END_TEXT` "End tutorial", `END_ICON`
  `rbxassetid://107990939394341`), in Leave game's place (hidden in the tutorial) until the match ends. It asks "End
  the tutorial? You still get 100 coins." (`END_QUESTION`, WidgetManager's confirmation), then fires the new remote
  `Tutorial_End` (client → server, rate limit 1/s; the server checks `InMatch`, the tutorial kind and not done, sets
  `MatchDone`, gives the starters, pays the coins, marks it done and saves) and `Match_Leave`.
- **The guide's look:** no panel; the hint is the HUD's white heavy italic outlined text at 48 px (title outline
  0.06), the arrow is the snail tag's turn arrow picture (`rbxassetid://107929925047000`), and the ring shows only
  round world spots (white, was a gold square). It hides while another window (END TUTORIAL's question, Settings) is
  open.
- **Funnel:** `FUNNEL_STEPS` is Drop, Aim, Fire, Won, Pick, Equipped (was Drop, Aim, Grenade, Throw, Wind, Lobby,
  Equip, Pick, Equipped), so its numbers before and after don't compare.

**Where.** Tutorial's `Settings.lua` (`HINTS`, `TOUCH_HINTS`, `PAD_HINTS`, `FUNNEL_STEPS`, `END_*`, `WIN_TITLE`,
`LOST_TITLE`, `HOLE_*`, `ARROW_*`, `HINT_*`, `SWIPE_*`; `GRENADE`, `HINT_TOP`, `HINT_TEXT_SIZE`, `HINT_BOTTOM_PADDING`,
`RESULTS_GUI_NAME` removed), `Server.lua` (`CompleteMatch`, `_onStep`, `_onEnd`, `_finish`), `MatchHints.lua`,
`LobbyHints.lua`, `Spotlight.Show(text, target, step, place)`. Bots' `ServerSettings.lua` and `_missOnPurpose`.
Match's `TUTORIAL_*` and `Turns.RunTurn`. MatchHud's `I.MatchHud.HasAimedThisTurn`, its Turn, Panels, Results and
TopBar handlers (`LOCKED_REMATCH_COLORS` removed).

**How to check.** In Studio with Workspace's `StudioTutorial` true and the profile's `Tutorial` flags false: land
on the lit spot, drag, press FIRE; one hit ends the match on "You won!"; the bot's shots land away from both snails;
CONTINUE goes to the lobby, the picker opens, equipping the Grenade pays 100 coins that fly into the slot. END
TUTORIAL on the top bar asks, then pays the coins and goes back.

**For the wiki.** Tutorial: the new steps (land, drag to aim, FIRE, one hit, win card, pick a weapon), the coins at
the end, END TUTORIAL, the bot that never hits, no wind or timers. Controls: the tutorial's hints per device.

Not checked here: the whole flow in a play test after these changes, on touch and pad.
