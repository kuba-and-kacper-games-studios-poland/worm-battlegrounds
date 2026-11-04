# TutorialHint

The tutorial's speech bubble: a line of text and an arrow, placed beside the element or spot it points at.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). 640 wide (was 440), so the hint fits on one line at the kit's heading size. It hangs from 18 % down the screen, under a match's turn panel and above the lobby's Play panel, instead of being centred at 35 % (where it covered Play). At 0.55 on phones and tablets, so it fits there too.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TutorialHint"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `TutorialHint`: `Enabled` off, `DisplayOrder` 0 (under widget windows, which cover it while open), `ScreenInsets` `DeviceSafeInsets` |

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

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `TutorialHint`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
