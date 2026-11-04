# TutorialHint

The tutorial's speech bubble: a line of text and an arrow, placed beside the element or spot it points at.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TutorialHint"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `TutorialHint`: `Enabled` off, `DisplayOrder` 10, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Hint` | Box (`Panel`) | The bubble; Tutorial moves it. Has `S_ScreenScale` |
| `U_Hint` › `S_Text` | Label (`Heading`) | The hint |
| `U_Hint` › `S_Arrow` | Picture (`Glyph`) | Turned toward what it points at |

## Driven by

The game's `Tutorial` module: the match hints on the Match map, the crate and equip hints in the lobby. `S_Arrow` stays hidden (the lobby's arrow is `Lobby` › `U_Pointer` › `S_Arrow`).

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `TutorialHint`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
