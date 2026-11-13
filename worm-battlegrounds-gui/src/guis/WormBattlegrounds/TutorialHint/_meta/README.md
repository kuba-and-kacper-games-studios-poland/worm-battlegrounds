# TutorialHint

The tutorial's guide: a spotlight that blacks out the screen around what to press next, and a hint panel beside it.

**Look.** Built from `Primitive` nodes in the new screens' look, from the confirmation dialog's parts
(`WidgetManager_Confirmation`): the dark panel (fill 25, 25, 35, a dark outer line and the grey 130 line inside, both
`Utils_UIStroke`), a gold TUTORIAL title (255, 215, 110) and white Londrina text with a black outline. The spotlight
is a lighter rounded square (white at 0.88 transparency, 18 px corners) whose 4000 px dark outline (8, 8, 14 at 0.3)
covers the rest of the screen, with a gold ring inside that pulses (the testers, 2026-11-13: "the screen is blacked
out around where you need to click and like a lighter square with rounded corners").

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
| `U_Spotlight` | Frame | The hole: Tutorial places and sizes it over the target every frame, hidden with no target |
| `U_Spotlight` › `S_Ring` | Frame | The gold ring; Tutorial pulses its `UIStroke`'s transparency |
| `U_Blockers` › `Top`, `Bottom`, `Left`, `Right` | Frame (`Active`) | Invisible; Tutorial fits them around the hole so presses elsewhere never reach the world or other guis |
| `U_Hint` | Frame | The panel; Tutorial places it beside the hole (under it in the screen's top half, over it in the bottom half), and sets its height to the text. Has `S_ScreenScale` |
| `U_Hint` › `S_Title` | TextLabel | TUTORIAL |
| `U_Hint` › `S_Text` | TextLabel | The hint; Tutorial writes it and sets its height to its lines at 32 px |

## Driven by

The game's `Tutorial` module (`Scripts/Client/Spotlight.lua`): the match guide on the Match map, the lobby guide on the
Lobby map.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `TutorialHint`, `Enabled` off. Its module
turns it on while a step shows. The panel is laid out for a 1920 × 1080 screen: the game's ScreenScale module (its
`GUIS` list) sets `S_ScreenScale` to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on
Mobile screens shorter than 500 px and never under 0.6 on other devices.

### Input

None of its own: the blockers only stop presses outside the hole.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Shown | `S_Ring` › `UIStroke` | Transparency pulses between 0.2 and 0.7 (Tutorial's `RING_PULSE_RATE`) |
