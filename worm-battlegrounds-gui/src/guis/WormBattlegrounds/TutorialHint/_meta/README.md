# TutorialHint

The tutorial's guide: a gold ring around what to press next, a red arrow pointing at it, and a hint panel beside them.
Nothing else is darkened or blocked (the testers, 2026-11-15: "no blackout just red arrow").

**Look.** Built from `Primitive` nodes in the new screens' look, from the confirmation dialog's parts
(`WidgetManager_Confirmation`): the dark panel (fill 25, 25, 35, a dark outer line and the grey 130 line inside, both
`Utils_UIStroke`), a gold TUTORIAL title (255, 215, 110) and white Londrina text with a black outline. The ring is a
faint rounded square (white at 0.9 transparency, 18 px corners) with a gold 4 px line that pulses. The arrow is red
(235, 64, 52): a rounded shaft and a ▼ head in Builder Sans, both outlined in the panel's dark, 64 × 88 at design
size. Until 2026-11-15 the square's 4000 px dark outline blacked out the rest of the screen and invisible blockers
stopped presses around it (the testers, 2026-11-13).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TutorialHint"` |
| Theme | None (Primitive nodes only) |
| Modes | Night only |
| Devices | Every device the same; the panel scales by its `S_ScreenScale` |
| Export | A ScreenGui named `TutorialHint`: `Enabled` off, `DisplayOrder` 50 (over every gui but the teleport card's 100), `IgnoreGuiInset` on, `ScreenInsets` `None`, so its pixels are the screen's |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Spotlight` | Frame | The ring's square: Tutorial places and sizes it over the target every frame, hidden with no target |
| `U_Spotlight` › `S_Ring` | Frame | The gold ring; Tutorial pulses its `UIStroke`'s transparency |
| `U_Arrow` | Frame | The arrow, its tip the bottom middle; Tutorial places it over the ring pointing down (under it, turned over, near the screen's top) and bobs it. Has `S_ScreenScale` |
| `U_Arrow` › `S_Shaft`, `S_Head` | Frame, TextLabel | Its shaft and ▼ head |
| `U_Hint` | Frame | The panel; Tutorial places it beside the ring (under it in the screen's top half, over it in the bottom half, past the arrow on its side), and sets its height to the text. Has `S_ScreenScale` |
| `U_Hint` › `S_Title` | TextLabel | TUTORIAL |
| `U_Hint` › `S_Text` | TextLabel | The hint; Tutorial writes it and sets its height to its lines at 32 px |

## Driven by

The game's `Tutorial` module (`Scripts/Client/Spotlight.lua`): the match guide on the Match map, the lobby guide on the
Lobby map.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `TutorialHint`, `Enabled` off. Its module
turns it on while a step shows. The panel and the arrow are laid out for a 1920 × 1080 screen: the game's ScreenScale module (its
`GUIS` list) sets `S_ScreenScale` to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on
Mobile screens shorter than 500 px and never under 0.6 on other devices.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Shown | `S_Ring` › `UIStroke` | Transparency pulses between 0.2 and 0.7 (Tutorial's `RING_PULSE_RATE`) |
