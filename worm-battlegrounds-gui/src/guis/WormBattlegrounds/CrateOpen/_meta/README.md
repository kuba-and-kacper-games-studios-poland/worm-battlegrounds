# CrateOpen

**Unused since 2026-11-11:** crates open on the `Crates` gui itself (its `U_Open` and `U_Result`), and the Crates
module no longer drives this gui. It stays until the owner says to remove it.

The crate reveal: the crate shakes, bursts in the result's rarity colour, then shows the item ("Shiny!" when it turned shiny), or the 10 items of a 10-pack, with **Open again**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Results are the kit's reward tiles: the rarity's stage inside a silver frame (common to rare) or a gold one with light behind it (epic, legendary). The single result is a big tile (300 × 380) whose frame grows with it (`SliceScale` 0.9). Open again is the one yellow.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/CrateOpen"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `CrateOpen`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Stage` | Frame | The reveal area |
| `U_Stage` › `S_Crate` | Picture | The crate before it opens; Crates shakes it |
| `U_Stage` › `S_Burst` | Frame | `I.UIEmitter` bursts here in the result's rarity colour |
| `U_Stage` › `S_Card` | Item | The single result (`S_Icon`, `S_Name`, `S_Info`); outline in its rarity |
| `U_Stage` › `S_Shiny` | Label | "Shiny!" on `S_Card` |
| `U_Cards` | Cells (`Grid`) | The 10 results of a 10-pack (shown in place of `U_Stage`) |
| `U_Widget` › `S_OpenAgain` | Button (`Primary`) | Opens the same crate again |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | ResultCard` | `U_Cards` | An Item and `S_Shiny` |

## Driven by

The game's `Crates` module draws it on `WidgetManager_Opened` with `CrateOpen` and plays the reveal.

## Preview

`Preview.lua` shows each step.

| Setting | What it does |
| --- | --- |
| `S_Step` (Segmented: Crate, One, Ten) | The closed crate, one result, or 10 |
| `S_Shiny` (Toggle) | Shows "Shiny!" on the single result |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `CrateOpen`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "CrateOpen"`, or `I.WidgetManager.Open("CrateOpen")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Open again | Click | Tap | Select and A | Crates connects `S_OpenAgain` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
| Rarity | `ResultCard` | `Face`, `Stage`, `Rays` and `Glow` from the tile's `Kit_<Rarity>_*` attributes (the theme's README → Item); `S_Info` in the rarity's colour; Crates' `Reveal` |
| Reveal | `U_Stage` | Planned in Crates: shake, burst (`I.UIEmitter`) in the rarity colour, card pop |
