# SoloSetup

**Unused since 2026-11-06:** the lobby's MatchBoard panel shows the public matches and the solo setup itself, and no
code or button opens this gui any more. It stays until the owner says to remove it (the gui folder and its export in
StarterGui).

**Play solo**: a 1v1 against a bot. The player picks Easy, Medium or Hard (each with the coins a win pays) and presses **Start**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). The difficulties are slots with the bot's picture and the pay in the coins' colour (`Item` `Difficulty`), not rarity tiles; Start is the one yellow.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/SoloSetup"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `SoloSetup`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Easy`, `S_Medium`, `S_Hard` | Item | The difficulties; `S_Info` holds the coins a win pays (20, 35, 60). MatchBoard marks the picked one |
| `U_Widget` › `S_Start` | Button (`Primary`) | Starts the match |

## Driven by

The game's `MatchBoard` module draws it on `WidgetManager_Opened` with `SoloSetup`.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `SoloSetup`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "SoloSetup"`, or `I.WidgetManager.Open("SoloSetup")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Start | Click | Tap | A (Cross) | `S_Start` tags (`Utils_ButtonKey`); MatchBoard connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
| Picked difficulty | `S_Easy`, `S_Medium`, `S_Hard` › `Body` | Fill rgb(40, 140, 255) at 0.2 transparency when picked, else black at 0.7 (MatchBoard's `SELECTED_*` and `TILE_*` settings) |
