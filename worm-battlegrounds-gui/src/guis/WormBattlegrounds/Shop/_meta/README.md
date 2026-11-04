# Shop

The shop: the 5 diamond packs and the 4 game passes, every benefit listed, prices read live from Roblox.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). 1600 × 920. Diamond packs are slots (200 × 240) with the price in green over the picture; game passes are 340 × 376 slots with the price beside a green Buy: the shop has no one next step, so no yellow.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Shop"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `Shop`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Packs` | Cells (horizontal, `Fixed`) | Holds one `Pack` per diamond pack |
| `U_Passes` | Cells (`Tiles`) | Holds one `Pass` per game pass |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Pack` | `U_Packs` | An Item (`S_Name` = pack, `S_Info` = diamonds; a press prompts the purchase) and `S_Price` |
| `PREFAB | Pass` | `U_Passes` | `S_Name`, `S_Benefits`, `S_Price`, `S_Buy` |

## Driven by

The game's `Shop` module draws it on `WidgetManager_Opened` with `Shop`.

## Preview

`Preview.lua` fills the wiki's packs and passes.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Shop`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "Shop"`, or `I.WidgetManager.Open("Shop")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size. Prices come from `GetProductInfoAsync`, never hard-coded.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Buy | Click | Tap | Select and A | Shop connects the packs and `S_Buy` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
| Owned pass | `Pass` › `S_Buy` › `Face` | `Kit_DisabledImage` (grey) with "OWNED", else `Kit_Image`; Shop's `Client` |
