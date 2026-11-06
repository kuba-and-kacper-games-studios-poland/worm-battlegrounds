# PlayModes

**Unused since 2026-11-06:** the lobby's MatchBoard panel shows the public matches and the solo setup itself, and no
code or button opens this gui any more. It stays until the owner says to remove it (the gui folder and its export in
StarterGui).

The lobby's **Modes** window: every way to play besides the quick match. **Play solo** (opens `SoloSetup`), **Custom lobby** (opens `CustomLobby`), and the open public matches, each with **Join**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). A default `Widget` (1000 × 700) titled Modes. Play solo and Custom lobby are purple `Event` buttons side by side, as modes are; the window has no one next step, so no yellow. Open matches are purple event cards (a picture, mode, the map in green, players and timer) with a blue Join, under a "Public matches" heading; the list scrolls.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/PlayModes"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`) |
| Export | A ScreenGui named `PlayModes`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Widget | The window WidgetManager opens. Has `S_ScreenScale` |
| `U_Solo` | Button (`Event`, `Large`) | Opens `SoloSetup` (its tags) |
| `U_Custom` | Button (`Event`, `Large`) | Opens `CustomLobby` (its tags) |
| `U_Rows` | Cells | Holds one `Row` per open public match |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Row` | `U_Rows` | `S_Thumbnail` (map picture), `S_Mode`, `S_Map`, `S_Players` ("3 / 8"), `S_Timer` ("0:30"), `S_Join` ("Join" or "Join teams") |

## Driven by

The lobby's `MatchBoard` › `S_Modes` button opens it through WidgetManager. The game's `MatchBoard` module fills the rows, joins the picked match and closes the window.

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_PlayModes_Preview`) fills example rows and scales the window to the screen.

| Setting | What it does |
| --- | --- |
| `S_Rows` (Slider, 0 to 3) | How many public matches are listed |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `PlayModes`, `Enabled` off. WidgetManager turns it on. The window is laid out for a 1920 × 1080 screen; the game's ScreenScale module sizes its `S_ScreenScale` (it's in ScreenScale's `GUIS` list).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Play solo / Custom lobby | Click | Tap | Select and A | `U_Solo`, `U_Custom` tags (`Interact_Button` → WidgetManager `Open`) |
| Join | Click | Tap | Select and A | MatchBoard connects each row's `S_Join` |
| Close | Click the close | Tap the close | B | The `Widget`'s close button (WidgetManager `CloseCurrent`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
