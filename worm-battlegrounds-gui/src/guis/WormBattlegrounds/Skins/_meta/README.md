# Skins

The worm skins the player owns, each in a 3D preview with its copies toward shiny and **Equip**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Equip is blue: a grid of skins has no one next step.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Skins"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `Skins`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Skins` | Cells (`Tiles`) | Holds one `SkinTile` per owned skin |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | SkinTile` | `U_Skins` | `S_Preview` (Viewport: its `ViewportFrame` and `Camera` take the worm model; caption = name and copies), `S_Equip` ("Equip", or "Equipped" on the worn skin) |

## Driven by

The game's `Cosmetics` module draws it on `WidgetManager_Opened` with `Skins`.

## Preview

`Preview.lua` fills example skins.

| Setting | What it does |
| --- | --- |
| `S_Skins` (Slider, 1 to 6) | Owned skins |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Skins`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "Skins"`, or `I.WidgetManager.Open("Skins")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Equip | Click | Tap | Select and A | Cosmetics connects `S_Equip` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
