# EmoteShop

The emotes bought with coins: each row has the emote's name, the level it needs, its price, and **Buy** (or Owned).

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Rows on slots; Buy is green (a price), Owned is grey.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/EmoteShop"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `EmoteShop`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Emotes` | Cells | Holds one `EmoteRow` per emote |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | EmoteRow` | `U_Emotes` | `S_Icon`, `S_Name`, `S_Level`, `S_Price`, `S_Buy`, `S_Owned` |

## Driven by

The game's `Cosmetics` module draws it on `WidgetManager_Opened` with `EmoteShop`.

## Preview

`Preview.lua` fills the 8 emotes from the wiki.

| Setting | What it does |
| --- | --- |
| `S_Owned` (Slider, 0 to 8) | How many are owned |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `EmoteShop`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "EmoteShop"`, or `I.WidgetManager.Open("EmoteShop")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Buy | Click | Tap | Select and A | Cosmetics connects `S_Buy` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
