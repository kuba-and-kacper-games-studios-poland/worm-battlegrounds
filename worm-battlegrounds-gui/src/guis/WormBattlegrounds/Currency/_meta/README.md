# Currency

System's `Currency` made the game's own: the orbs area ume's Currency slots fly orbs across, and a bar in the top-right corner with the player's coins and diamonds and a **+** that opens the shop (the lobby's logo has the top middle).

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Coins and diamonds sit on a dark pill (`Box` `Pill`) instead of a panel, 440 wide; + is a green square button with the kit's plus (it opens the Shop, a price).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Currency"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
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

Export it with the Gui tool over System's copy: a ScreenGui named `Currency`, tagged `UserInterface_PreventHiding`. Currency's `CURRENCIES` (in the code folder's `Main/2_Currency/Settings.lua`) needs `Coins` and `Diamonds` entries: it has only the template's `Cash` today. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open the shop | Click + | Tap + | Select and A | `S_Add` tags (WidgetManager `Toggle`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
