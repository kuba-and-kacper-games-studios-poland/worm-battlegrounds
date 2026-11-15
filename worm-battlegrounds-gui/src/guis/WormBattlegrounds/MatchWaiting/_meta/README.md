# MatchWaiting

A public match's waiting room, on the match server, at the bottom middle of the screen while the match takes joins
from every lobby (the owner, 2026-11-15): **MATCH STARTS IN 0:12**, the mode and seats ("DUO  |  3 / 4 PLAYERS"),
everyone seated (a player still on the way reads "Joining…", one who pressed it **READY**), **Ready** (with how many
of the players here are) and **Leave match**.

**Look.** The studio's `MatchWaiting` design (2026-11-12), ported 1:1 as `Primitive` nodes: a dark slanted panel with
the yellow Ready and red Leave buttons. It lived in `MatchBoard` as the lobby's waiting room until public matches
moved to their own servers (2026-11-15): now it hangs from the bottom middle (AnchorPoint 0.5, 1 at 50 % across,
97.8 % down), 28 % of the screen wide. Each seat's READY is green (120, 230, 90) at its right.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchWaiting"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and an aspect-ratio constraint, no `S_ScreenScale` |
| Export | A ScreenGui named `MatchWaiting`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_WaitingRoom` | Frame | The waiting room |
| `U_WaitingRoom` › `S_Countdown` | TextLabel | "Match starts in 0:12" |
| `U_WaitingRoom` › `S_Info` | TextLabel | "Duo  \|  3 / 4 players" |
| `U_Players` | ScrollingFrame with a UIListLayout | Holds one `PlayerName` per seat |
| `U_WaitingRoom` › `S_Ready` | ImageButton | Ready; its `S_Text` reads "Ready 1/2", or "Waiting 1/2" once the player pressed it |
| `U_WaitingRoom` › `S_Leave` | ImageButton | Leaves the match, back to the lobby |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| PlayerName` | `U_Players` | `S_Avatar`, `S_Name`, `S_Username` ("Joining…" while on the way), `S_ReadyTag` (READY, hidden until they pressed Ready) |

## Driven by

The game's `Match` module (`WaitingRoom` client handler): it turns the ScreenGui on while the player's public match
takes joins (`Workspace.Ume.Match`'s `RoomEndsAt`), and off when it starts.

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchWaiting_Preview`) fills example seats.

| Setting | What it does |
| --- | --- |
| `S_Players` (Slider, 1 to 8) | Seats in the room; the last one reads "Joining…" |
| `S_Ready` (Slider, 0 to 8) | How many of them show READY |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchWaiting`, `Enabled` off. A restyled
copy keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Ready | Click | Tap | A (Cross) | `S_Ready` tags (`Utils_ButtonKey`); Match connects it (`Match_Ready`) |
| Leave match | Click | Tap | B (Circle) | `S_Leave` tags (`Utils_ButtonKey`); Match connects it (`Match_Leave`) |

The room holds the pad's selection while it shows (`I.Console.Focus`). On Console `S_Ready` and `S_Leave` show their
button in a badge (`PadHint`, `Console_Action` `Confirm`, `Back`), a `Console_Hint` the game's Console module shows
only on Console.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Ready | A seat's `S_ReadyTag` | Visible once that player pressed Ready |
