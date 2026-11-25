# Tutorial

The first-time flow, a short guided first match, then one weapon equipped in the lobby (the owner, 2026-11-24:
"VERY VERY SIMPLE"; 2026-11-25: a move step first, and the bot with a snail's full health, "so there is the battle"). A new player's first join sends them to the tutorial match
(the Lobby module launches it): a 1v1 against the tutorial bot with the Bazooka alone (Match's `TUTORIAL_LOADOUT`), no
wind and no clocks (Match's `TUTORIAL_*`). Nothing is darkened or blocked (the testers, 2026-11-15: "no blackout just
red arrow"): the snail tag's red arrow points at what to do, with a hint of two or three words worded for the player's
device. Its steps:

1. **Land.** "Click to land" ("Tap to land" on touch), the arrow pointing up at a soft white ring from below the lit
   spot (the drop pin hangs over it).
2. **Move.** On the player's first turn "Move here" at a ring on flat ground `MOVE_DISTANCE` studs toward the bot (else
   the other way, else `MOVE_SHORT_DISTANCE`; skipped with none), the arrow pointing up at it from below, and under the
   hint a smaller tip for the device (`MOVE_TIPS`: "Walk with A and D, or the arrow keys", "Walk with the arrow
   buttons", "Walk with {Move}"), until the snail is `MOVE_REACH` studs from it, has walked `MOVE_DONE_DISTANCE`, or the
   player aims.
3. **Aim.** On the player's turn "Drag to aim" alone under their snail, with a touch point sliding as a drag would
   (`SWIPE_*`), until they've aimed this turn (`I.MatchHud.HasAimedThisTurn`).
4. **Fire.** "Press FIRE" ("Tap FIRE", on a pad "Press {Fire}") with the arrow on MatchHud's FIRE button (`U_Fire`).
   Aim and FIRE come round each turn until the bot is out: it has a snail's full health (Snails' `MAX_HEALTH`; Bots'
   `HEALTH` gave it 10 until 2026-11-25). The bot's turns show no hint; it shoots around the player and now and
   then hits them, never knocking them out (Bots' `_tutorialShot`).
5. **Win card.** When the match ends, the `TutorialWin` card in place of the results: "You won!" with the win fanfare,
   or "Nice try!", and one yellow CONTINUE with the arrow pointing up at it from below. CONTINUE leaves the match
   (`Match_Leave`).
6. **Pick a weapon.** Back in the lobby the picker opens by itself once (while no other window is open), and "Pick a
   weapon" points in from the left at the first starter weapon's card (the Grenade), or at a free loadout slot once
   the picker is closed. Equipping any starter weapon finishes the tutorial; a loadout that already holds one finishes
   it on arrival.

Only then are the 50 diamonds paid (`MATCH_DIAMONDS`), and they fly in from the player's stage snail to the diamonds slot
(Progression's replay). The match itself gives the starter weapons, Grenade and Shotgun (no crate since 2026-11-15).
**END TUTORIAL**, on the top bar in Leave game's place through the tutorial match until it ends, asks first, then ends
the whole tutorial at once with the weapons and the diamonds, and goes back to the lobby. **After the tutorial**, each
arrival in the lobby (until the player has played `PUBLIC_HINT_MATCHES` matches) makes every JOIN on the board glow for
a while, with "Hit JOIN to play with other players!" beside the PUBLIC MATCHES title (`PUBLIC_*`). The guide hides while another
window than the win card is open (END TUTORIAL's question, Settings). Studio skips the whole tutorial (`Skip`) unless
Workspace's `StudioTutorial` is true; then the Studio map plays the whole flow on one server, and the Lobby map alone,
which can't start the match, marks it played and goes straight to the lobby's part. Each guide shows only where it
belongs (the `InMatch` Player attribute), and takes down only the hint it put up, so on the Studio map the match guide
never hides the lobby's.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Tutorial` |
| Runs on | Server, Client · every map |
| Exposes | `I.Tutorial` (server) |
| Uses | `I.Currency`, `I.Progression` (server: the diamonds and their replay), `I.Inventory`, `I.Loadout`, `I.Match`, `I.Replicator`, `I.Topic`, `I.Network`; on the client `I.MatchHud`, `I.Snails`, `I.TopBar`, `I.WidgetManager`, `I.Interact`, `I.Sound`, `I.Platform`, `I.Console` (the pad's button names), `I.Utils`, `I.UserInterface` |
| Saves | `Profile.Tutorial` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Saved progress, the match's end, the starter weapons, the equip step, END TUTORIAL, the diamonds and the funnel |
| `Client.lua` | Starts the spotlight, the match guide on the Match map, the lobby guide on the Lobby map, both on the Studio map |
| `Scripts/Client/Spotlight.lua` | The `TutorialHint` gui: `Show(text, target, step, place, tip?)` points the arrow at a gui element (a left-aligned title where its words end), a part or a world spot (a ring round a world spot), with the hint past it and the tip in smaller text under it; `place` nil points it down from above (up from below near the screen's top), `"Below"` up from under the target, `"Left"` right from its left with the hint left of it, `"Right"` left from its right with the line right of it (the tip alone on the line when the hint is `""`), `"Beside"` the same with no arrow, `"Alone"` shows the hint by itself under the target with the touch point and no arrow or ring. The first time a funnel step shows it reports it (`Tutorial_Step`) |
| `Scripts/Client/MatchHints.lua` | The guide during the tutorial match (`TOUCH_HINTS` on touch, `PAD_HINTS` with the pad's button names on a pad), the first turn's move step (`_needsMove`, `_getMoveSpot`, `_getMoveTip`), the win card and CONTINUE, END TUTORIAL and its question |
| `Scripts/Client/LobbyHints.lua` | The guide to the loadout in the lobby: opens the picker once (`I.Loadout.OpenPicker`), points at the first starter weapon or a free slot, reports the equip step; then the public matches hint (`_tickPublic`, `_setJoinGlow`: the board's JOINs' `S_Glow`, from the Statistic folder's `MatchesPlayed`) |
| `Settings.lua` | `Tutorial_Settings` |

## API

### Server: `I.Tutorial`

| Function | Returns | What it does |
| --- | --- | --- |
| `CompleteMatch(player)` | `boolean` | Marks the tutorial match played and gives `STARTER_WEAPONS`, once; no diamonds (they wait for the equip step) |
| `Skip(player)` | | Marks the whole tutorial done without playing it: no diamonds, no weapons (Studio playtests without `StudioTutorial`) |
| `IsMatchDone(player)` | `boolean` | Whether the tutorial match is played |
| `IsDone(player)` | `boolean` | Whether the whole tutorial is finished |

## Network

### Server

**Receive: RemoteEvents**

- `Tutorial_Step @ (player: Player, step: string)`: a step of `FUNNEL_STEPS` whose hint the player saw for the first time
  (the spotlight reports it), which the server logs once in the Roblox onboarding funnel
  (`AnalyticsService:LogOnboardingFunnelStepEvent`, its number its place in the list) while the tutorial isn't done.
  `"Equipped"` (from the lobby guide) finishes the tutorial once the weapons were given and the server sees any starter
  weapon in the loadout (`I.Loadout.GetMatchLoadout`): its last funnel step, then the diamonds (`Currency.Add`, and
  `I.Progression.AddReplayDiamonds` so they fly in). Rate limit 5 per second.
- `Tutorial_End @ (player: Player)`: END TUTORIAL. Only for a player in the tutorial match (`InMatch`, the match's
  `Kind` is `MATCH_KIND`) whose tutorial isn't done: marks the match played, gives the starter weapons, finishes the
  tutorial with its diamonds as the equip step does, and saves the profile. The client then sends `Match_Leave`. Rate
  limit 1 per second.

It listens to `Match_Ended` on the Match map.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Tutorial` | `{ MatchDone = false, CrateOpened = false, Done = false }`; `CrateOpened` is whether the starter weapons were given (named for the crate that gave them until 2026-11-15; one who played the match then and never opened it gets them on their next join) |
| Replicator `Tutorial` | `MatchDone`, `EquipReady`, `Done` | Which step waits (`EquipReady`: weapons given, not done) |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MATCH_DIAMONDS` | `"50"` | Diamonds finishing the tutorial pays (the equip step, or END TUTORIAL) |
| `STARTER_WEAPONS` | `{ "Grenade", "Shotgun" }` | What the tutorial match gives, and what the equip step checks (any one of them); the first is the card the picker's arrow points at |
| `MATCH_MAP`, `LOBBY_MAP`, `MATCH_KIND` | `"Match"`, `"Lobby"`, `"Tutorial"` | The maps that run only the match guide or only the lobby guide, and the match kind |
| `HINTS` | Drop "Click to land", Move "Move here", Aim "Drag to aim", Fire "Press FIRE", Pick "Pick a weapon" | What each step's hint says; capitals come from the gui (`TextCase_Upper`) |
| `TOUCH_HINTS` | Drop "Tap to land", Fire "Tap FIRE" | What those steps say on a touch screen |
| `PAD_HINTS` | Drop "{Move} to the light, {PlaceDrop} to land", Aim "Aim with {Aim}", Fire "Press {Fire}" | What those steps say on a pad: each `{Action}` becomes that action's button in the Console module's scheme, named for the player's pad (`I.Console.GetButtonName`: "RT" or "R2") |
| `FUNNEL_STEPS` | Drop, Move, Aim, Fire, Won, Pick, Equipped | The tutorial's onboarding funnel (Creator Hub → Analytics → Funnels), in order: each logged when its hint first shows, Won with the win card, Equipped when the tutorial is done (changed 2026-11-24, and Move added 2026-11-25, so its numbers before and after don't compare) |
| `MOVE_DISTANCE`, `MOVE_SHORT_DISTANCE`, `MOVE_STEP`, `MOVE_REACH`, `MOVE_DONE_DISTANCE` | `8`, `5`, `3`, `2`, `6` | The move step's ring: studs from the snail (then the shorter try), the most it may be above or below the snail's feet; done this close to it, or after walking this far |
| `MOVE_TIPS` | Desktop, Mobile, Console | The tip under "Move here" by device (`{Move}` named for the pad) |
| `PUBLIC_HINT`, `PUBLIC_GLOW_TRANSPARENCY`, `PUBLIC_GLOW_RATE` | "Hit JOIN to play with other players!", `{ 0, 0.55 }`, `4` | The public matches hint: the line beside the board's title, and the JOIN glows' pulse (transparency range, radians a second) |
| `PUBLIC_HINT_DELAY`, `PUBLIC_HINT_SECONDS`, `PUBLIC_HINT_MATCHES` | `3`, `12`, `2` | Seconds after a lobby arrival before it shows, how long it shows, and the matches played (the tutorial's counts) after which it never shows again |
| `END_TEXT`, `END_ICON`, `END_QUESTION` | "End tutorial", `"rbxassetid://107990939394341"`, "End the tutorial? You still get 50 diamonds." | END TUTORIAL's top bar button (`I.TopBar.AddButton("Left")`, layout order 3, after Settings and the music button) and its question (`I.WidgetManager.ShowConfirmation`) |
| `WIN_TITLE`, `LOST_TITLE` | "You won!", "Nice try!" | The win card's title when the player won, and when their snail went out |
| `HOLE_PADDING`, `WORLD_HOLE_RADIUS`, `HOLE_MIN`, `RING_PULSE_RATE` | `6`, `3`, `56`, `4` | Pixels the arrow keeps past a gui element's edge; the ring round a world spot: studs around it, its smallest size in pixels, its pulse in radians a second |
| `ARROW_GAP`, `ARROW_FLIP_SHARE`, `ARROW_BOB`, `ARROW_BOB_RATE` | `6`, `0.3`, `12`, `6` | The arrow: pixels from the target, the top share of the screen where it turns over to point up, and its bob toward the target in pixels and radians a second |
| `HINT_GAP`, `HINT_EDGE` | `4`, `16` | The hint sits this many pixels past the arrow (or the target, when it shows alone), and this far in from the screen's edges |
| `SWIPE_DISTANCE`, `SWIPE_RISE`, `SWIPE_GAP`, `SWIPE_SECONDS` | `150`, `34`, `56`, `1.6` | Under "Drag to aim" the touch point slides this many design pixels right and up, this far under the hint, fading in and out, every this many seconds |
| `HINT_GUI_NAME`, `WIN_GUI_NAME`, `MATCH_HUD_GUI_NAME`, `LOADOUT_GUI_NAME`, `PICKER_GUI_NAME`, `BOARD_GUI_NAME` | `"TutorialHint"`, `"TutorialWin"`, `"MatchHud"`, `"Loadout"`, `"LoadoutPicker"`, `"MatchBoard"` | The guide's gui, the win card, and the guis whose parts it points at |

## In the place

Drives `TutorialHint` (`U_Spotlight` › `S_Ring`, `U_Arrow`, `U_Hint` › `S_Text`, `U_Swipe` › `S_SwipeGlow`) and opens
`TutorialWin` (`S_Title`, `S_Continue`) through WidgetManager. Adds the END TUTORIAL button to the top bar, shown only
in the tutorial match before it ends. Points at, without changing them: MatchHud's `U_Fire`, the Loadout slots
(`Slot<n>`) and the LoadoutPicker cards (named by item id, in `U_Items`). The tutorial bot's play and health are the
Bots module's (`HEALTH`, `TUTORIAL_*`); the tutorial's drop, loadout, clocks and turn order are the Match
module's (`TUTORIAL_*`); its hidden clocks, its hidden Leave game and its missing results are
MatchHud's.
