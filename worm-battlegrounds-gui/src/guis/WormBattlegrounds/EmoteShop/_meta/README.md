# EmoteShop

The emotes bought with coins: each row has the emote's name, the level it needs, its price, and **Buy** (or Owned).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/EmoteShop"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
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

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `EmoteShop`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "EmoteShop"`, or `I.WidgetManager.Open("EmoteShop")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Buy | Click | Tap | Select and A | Cosmetics connects `S_Buy` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
