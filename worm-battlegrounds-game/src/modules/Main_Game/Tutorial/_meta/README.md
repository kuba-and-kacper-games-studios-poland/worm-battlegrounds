# Tutorial

The first-time flow, a guided first match then the loadout. A new player's first join sends them to the tutorial match
(the Lobby module launches it): a whole 1v1 against the tutorial bot, which plays and shoots back (Bots' `TUTORIAL_BRAIN`,
a clumsy hand, half health), with the Bazooka and a Grenade (Match's `TUTORIAL_LOADOUT`). Nothing is darkened or
blocked (the testers, 2026-11-15: "no blackout just red arrow"): a gold ring and a bobbing red arrow point at what to
do, with a hint beside them worded for the player's device, and MatchHud draws a prediction line of the shot in the
tutorial. Its steps: the lit spot to land on (the drop starts the player and the bot close together, Match's
`TUTORIAL_*`), then one per round, since the player plays first: shoot the bot (round 1), pick the Grenade and throw it
(round 2), a strong wind against the shot (round 3, Match's `TUTORIAL_WINDS`; the arrow points at the wind), then finish
the bot; the bot's turns show a hint alone, and Return points out the results (Rematch is grey there). When the match
ends, the match server marks it done and gives 100 coins and the starter weapons, Grenade and Shotgun (no crate since
2026-11-15). Back in the lobby the guide opens the picker for a free slot by itself, once for each starter weapon while no other window is open (2026-11-16: most players never pressed the slot), and points at that weapon in it; a player who closes it is pointed at the slot instead; once both
are in the loadout, the tutorial is done and never shows again. Studio skips the whole tutorial (`Skip`) unless
Workspace's `StudioTutorial` is true; then the Studio map plays the whole flow on one server, and the Lobby map alone,
which can't start the match, skips it and goes straight to the loadout. Each guide shows only where it belongs (the
`InMatch` Player attribute), and takes down only the hint it put up, so on the Studio map the match guide never hides
the lobby's.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Tutorial` |
| Runs on | Server, Client · every map |
| Exposes | `I.Tutorial` (server) |
| Uses | `I.Currency`, `I.Inventory`, `I.Loadout`, `I.Match` (client), `I.Replicator`, `I.Topic`, `I.Platform`, `I.Console` (client: the pad's button names) |
| Saves | `Profile.Tutorial` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Saved progress, the match's end, the starter weapons, the equip step |
| `Client.lua` | Starts the spotlight, the match guide on the Match map, the lobby guide on the Lobby map, both on the Studio map |
| `Scripts/Client/Spotlight.lua` | The `TutorialHint` gui: the ring over a gui element, a part or a world spot, the red arrow pointing at it (from under it near the screen's top), the hint panel beside them; the first time a funnel step shows it reports it (`Tutorial_Step`) |
| `Scripts/Client/MatchHints.lua` | The guide during the tutorial match, a step per round (`TOUCH_HINTS` on touch, `PAD_HINTS` with the pad's button names on a pad) |
| `Scripts/Client/LobbyHints.lua` | The guide to the loadout in the lobby: opens the picker (`I.Loadout.OpenPicker`), reports the equip step |
| `Settings.lua` | `Tutorial_Settings` |

## API

### Server: `I.Tutorial`

| Function | Returns | What it does |
| --- | --- | --- |
| `CompleteMatch(player)` | `boolean` | Marks the tutorial match played and gives `MATCH_COINS` and `STARTER_WEAPONS`, once |
| `Skip(player)` | | Marks the whole tutorial done without playing it: no coins, no weapons (Studio playtests without `StudioTutorial`) |
| `IsMatchDone(player)` | `boolean` | Whether the tutorial match is played |
| `IsDone(player)` | `boolean` | Whether the whole tutorial is finished |

## Network

### Server

**Receive: RemoteEvents**

- `Tutorial_Step @ (player: Player, step: string)`: a step of `FUNNEL_STEPS` whose hint the player saw for the first time
  (the spotlight reports it), which the server logs once in the Roblox onboarding funnel
  (`AnalyticsService:LogOnboardingFunnelStepEvent`, its number its place in the list) while the tutorial isn't done;
  `"Equipped"` finishes the tutorial once the server sees both starter weapons in the loadout, its last funnel step.
  Rate limit 5 per second.

It listens to `Match_Ended` on the Match map.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Tutorial` | `{ MatchDone = false, CrateOpened = false, Done = false }`; `CrateOpened` is whether the starter weapons were given (named for the crate that gave them until 2026-11-15; one who played the match then and never opened it gets them on their next join) |
| Replicator `Tutorial` | `MatchDone`, `EquipReady`, `Done` | Which step waits (`EquipReady`: weapons given, not done) |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MATCH_COINS` | `"100"` | Coins the tutorial match gives |
| `STARTER_WEAPONS` | `{ "Grenade", "Shotgun" }` | What the tutorial match gives, and what the equip step checks |
| `MATCH_MAP`, `LOBBY_MAP`, `MATCH_KIND` | `"Match"`, `"Lobby"`, `"Tutorial"` | The maps that run only the match guide or only the lobby guide, and the match kind |
| `GRENADE` | `"Grenade"` | The weapon round 2 teaches (its slot on MatchHud's bar, the held item) |
| `HINTS` | Drop, Aim, Grenade, Throw, Wind, Finish, BotTurn, Lobby, Equip, Pick | What each step's hint says (`Pick`'s `%s` is the weapon's name) |
| `TOUCH_HINTS` | Drop, Aim, Grenade, Throw, Wind | What those match steps say on a touch screen, where a finger aims and FIRE shoots |
| `PAD_HINTS` | Drop, Aim, Grenade, Throw, Wind | What those match steps say on a pad: each `{Action}` becomes that action's button in the Console module's scheme, named for the player's pad (`I.Console.GetButtonName`: "RT" or "R2") |
| `FUNNEL_STEPS` | Drop, Aim, Grenade, Throw, Wind, Lobby, Equip, Pick, Equipped | The tutorial's onboarding funnel (Creator Hub → Analytics → Funnels), in order (changed 2026-11-15, so its numbers before and after don't compare); hints only some players see (BotTurn, Finish) aren't in it |
| `HOLE_PADDING`, `WORLD_HOLE_RADIUS`, `HOLE_MIN`, `RING_PULSE_RATE` | `10`, `4`, `72`, `4` | The ring: pixels past a gui element, studs around a world spot or snail, its smallest size in pixels, and its pulse |
| `ARROW_GAP`, `ARROW_FLIP_SHARE`, `ARROW_BOB`, `ARROW_BOB_RATE` | `8`, `0.3`, `14`, `6` | The red arrow: pixels from the ring, the top share of the screen where it turns over to point up, and its bob |
| `HINT_GAP`, `HINT_EDGE`, `HINT_TOP`, `HINT_TEXT_SIZE`, `HINT_BOTTOM_PADDING` | `24`, `16`, `0.25`, `32`, `18` | Where the hint panel sits (past the ring and the arrow, in from the screen's edges, or at this share of the height with no ring, under the turn banner) and its text's design size |
| `HINT_GUI_NAME`, `MATCH_HUD_GUI_NAME`, `RESULTS_GUI_NAME`, `LOADOUT_GUI_NAME`, `PICKER_GUI_NAME` | | The guide's gui, and the guis whose parts it points at |

## In the place

Drives `TutorialHint` (`U_Spotlight`, `U_Arrow`, `U_Hint` › `S_Text`). Points at, without changing them: MatchHud's
bar slot for the Grenade (`U_Slots` › `Grenade`) and wind (`S_Wind`), Results' `S_Lobby`, the Loadout slots
(`Slot<n>`) and the LoadoutPicker cards (named by item id). The tutorial bot's play and health are the Bots module's
(`TUTORIAL_BRAIN`, `SKILLS.Tutorial`, `HEALTH`); the tutorial's drop, loadout, wind and turn order are the Match
module's (`TUTORIAL_*`); its prediction line is MatchHud's (`PREDICTION_*`).
