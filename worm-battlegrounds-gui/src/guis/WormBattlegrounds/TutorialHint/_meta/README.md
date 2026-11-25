# TutorialHint

The tutorial's guide: a red arrow pointing at what to do next, a short hint by it, a soft white ring round a spot in
the world (the drop's lit spot), and under "Drag to aim" a touch point sliding as a drag would. Nothing else is
darkened or blocked (the testers, 2026-11-15: "no blackout just red arrow").

**Look** (the owner, 2026-11-24: "more subtle", "VERY VERY SIMPLE"). No panel: the hint is the HUD's own text, white
Londrina Solid Heavy Italic with the title outline (ScaledSize 0.06, black), 48 px at design size, bigger than YOUR
TURN!, in capitals (`TextCase_Upper`). The arrow is the snail tag's own turn arrow picture (SnailTag's `S_Arrow`,
`rbxassetid://107929925047000`), 48 × 60. The ring is a white circle at 0.88 transparency with a 3 px white line,
only round world spots. The touch point is a 40 px white dot with an 8 px white glow line. Until 2026-11-24 it was a
gold square, a ▼ arrow drawn from frames and text, and the hint in the confirmation dialog's dark panel with a gold
TUTORIAL title; until 2026-11-15 the square's dark outline blacked out the rest of the screen.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TutorialHint"` |
| Theme | None (Primitive nodes only) |
| Modes | Night only |
| Devices | Every device the same; the arrow, the hint and the touch point scale by their `S_ScreenScale` |
| Export | A ScreenGui named `TutorialHint`: `Enabled` off, `DisplayOrder` 50 (over every gui but the teleport card's 100), `IgnoreGuiInset` on, `ScreenInsets` `None`, so its pixels are the screen's |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Spotlight` | Frame | The ring's circle: Tutorial places and sizes it round a world spot every frame; hidden for a gui target or with no target |
| `U_Spotlight` › `S_Ring` | Frame | The white ring; Tutorial pulses its `UIStroke`'s transparency |
| `U_Arrow` | Frame | The arrow, its tip the bottom middle; Tutorial places it over the target pointing down, turns it over to point up from under it (below a world spot or a button, or near the screen's top) or a quarter to point right from its left, and bobs it toward the target. Has `S_ScreenScale` |
| `U_Arrow` › `S_Image` | ImageLabel | The arrow picture |
| `U_Swipe` | Frame | The touch point under "Drag to aim": Tutorial slides it, fading in and out. Has `S_ScreenScale` |
| `U_Swipe` › `S_SwipeGlow` | UIStroke | Its glow; Tutorial fades it with the dot |
| `U_Hint` | Frame | The hint's box (900 × 58 at design size, no look of its own); Tutorial places it past the arrow, or under the target when the hint shows alone. Has `S_ScreenScale` |
| `U_Hint` › `S_Text` | TextLabel | The hint; Tutorial writes it ("" for the arrow alone) |
| `U_Hint` › `S_Tip` | TextLabel (28 px, light grey, hidden) | A smaller line under the hint (2026-11-25): how to do the step on the player's device ("Walk with A and D"), or on its own the lobby's public matches line; Tutorial writes and shows it |

## Driven by

The game's `Tutorial` module (`Scripts/Client/Spotlight.lua`, `Spotlight.Show(text, target, step, place)`): the match
guide on the Match map, the lobby guide on the Lobby map, both on the Studio map.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `TutorialHint`, `Enabled` off. Its module
turns it on while a step shows. The arrow, the hint and the touch point are laid out for a 1920 × 1080 screen: the
game's ScreenScale module (its `GUIS` list) sets each `S_ScreenScale` to the screen's height / 1080 (width / 1920 on
screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices. A
restyled copy keeps its `Name` and Ids.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Shown round a world spot | `S_Ring` › `UIStroke` | Transparency pulses between 0.15 and 0.6 (Tutorial's `RING_PULSE_RATE`) |
| Pointing | `U_Arrow` | Bobs up to `ARROW_BOB` pixels toward the target, `ARROW_BOB_RATE` radians a second (Tutorial's settings) |
| "Drag to aim" | `U_Swipe` | Every `SWIPE_SECONDS` it fades in, slides `SWIPE_DISTANCE` design pixels right and `SWIPE_RISE` up, `SWIPE_GAP` under the hint, and fades out: `BackgroundTransparency` 0.2 to 1, `S_SwipeGlow` 0.7 to 1 |
