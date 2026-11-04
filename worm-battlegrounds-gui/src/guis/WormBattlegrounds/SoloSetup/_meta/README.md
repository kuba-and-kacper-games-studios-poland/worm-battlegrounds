# SoloSetup

**Play solo**: a 1v1 against a bot. The player picks Easy, Medium or Hard (each with the coins a win pays) and presses **Start**.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/SoloSetup"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
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

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `SoloSetup`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "SoloSetup"`, or `I.WidgetManager.Open("SoloSetup")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Start | Click | Tap | A (Cross) | `S_Start` tags (`Utils_ButtonKey`); MatchBoard connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
