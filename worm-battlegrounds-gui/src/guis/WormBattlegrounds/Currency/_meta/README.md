# Currency

System's `Currency` made the game's own: the orbs area ume's Currency slots fly orbs across, and a top bar with the player's coins and diamonds and a **+** that opens the shop.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Currency"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `Currency`: `Enabled` off, `DisplayOrder` -999, `ScreenInsets` `DeviceSafeInsets`, tagged `UserInterface_PreventHiding` (the UserInterface server enables it at start) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_OrbsContainer` | Frame | System's orb area, kept as it is |
| `U_Bar` | Box (`Panel`) | The top bar. Has `S_ScreenScale` |
| `U_Bar` › `S_CoinIcon`, `S_DiamondIcon` | Picture (`Glyph`) | The currency icons |
| `U_Bar` › `S_Coins` | Label, tagged `Currency_Slot` (`Currency_Name = "Coins"`) | ume's Currency writes the amount |
| `U_Bar` › `S_Diamonds` | Label, tagged `Currency_Slot` (`Currency_Name = "Diamonds"`) | ume's Currency writes the amount |
| `U_Bar` › `S_Add` | Button (`Primary`, `Small`) | Opens `Shop` (its tags) |

## Driven by

ume's Currency module (`Main/2_Currency`) finds it as `I.UserInterface.UI["Currency"]`, `U_OrbsContainer` inside it, and fills every `Currency_Slot`.

## Integration

### Setup

Export it with the Gui tool over System's copy: a ScreenGui named `Currency`, tagged `UserInterface_PreventHiding`. Currency's `CURRENCIES` (in the code folder's `Main/2_Currency/Settings.lua`) needs `Coins` and `Diamonds` entries: it has only the template's `Cash` today. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open the shop | Click + | Tap + | Select and A | `S_Add` tags (WidgetManager `Toggle`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
