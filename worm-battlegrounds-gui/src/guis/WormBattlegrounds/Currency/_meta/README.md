# Currency

System's `Currency` made the game's own: the orbs area ume's Currency slots fly orbs across, and a bar in the top-right corner with the player's coins and diamonds and a **+** that opens the shop (the lobby's logo has the top middle).

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Coins and diamonds sit on a dark pill (`Box` `Pill`) instead of a panel, 480 wide; each count is 104 wide and left-aligned, so "100" stays on one line, and from 10,000 up the slot writes it short ("18.62k", its `Currency_ShortFrom`); + is a green square button with the kit's plus (it opens the Shop, a price).

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
| `U_Bar` | Box (`Pill`) | The top bar. Has `S_ScreenScale` |
| `U_Bar` › `S_CoinIcon`, `S_DiamondIcon` | Picture (`Glyph`) | The currency icons |
| `U_Bar` › `S_Coins` | Label, tagged `Currency_Slot` (`Currency_Name = "Coins"`, `Currency_ShortFrom = 10000`) | ume's Currency writes the amount |
| `U_Bar` › `S_Diamonds` | Label, tagged `Currency_Slot` (`Currency_Name = "Diamonds"`, `Currency_ShortFrom = 10000`) | ume's Currency writes the amount |
| `U_Bar` › `S_CoinsScale`, `S_DiamondsScale` | UIScale, on a transparent frame around each icon and its count | The count's `Currency_Slot` pulses it as orbs arrive (its `Currency_UIScale`) |
| `U_Bar` › `S_Add` | Button (`Price`, `Square`) | Opens `Shop` (its tags) |

## Driven by

ume's Currency module (`Main/2_Currency`) finds it as `I.UserInterface.UI["Currency"]`, `U_OrbsContainer` inside it, and fills every `Currency_Slot`.

## Integration

### Setup

Export it with the Gui tool over System's copy: a ScreenGui named `Currency`, tagged `UserInterface_PreventHiding`. Currency's `CURRENCIES` (in the code folder's `Main/2_Currency/Settings.lua`) holds the `Coins` and `Diamonds` entries the slots name.

After each export, point the `Currency_UIScale` ObjectValue under `S_Coins` at `S_CoinsScale`, and the one under `S_Diamonds` at `S_DiamondsScale` (TagList+ adds the empty ObjectValues with the `Currency_Slot` tag). An empty one warns at start and stops the slot there, so its count stays at 0. Never point one at `S_ScreenScale`: the slot puts its UIScale back to the value it read at start after every pulse, which would undo the screen scaling.

Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open the shop | Click + | Tap + | Select and A | `S_Add` tags (WidgetManager `Toggle`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Orbs arriving | `S_CoinsScale`, `S_DiamondsScale` | Currency's slot grows the icon and count a little with each orb (up to ×1.5) and eases them back (`ORB_UI_SCALE_*` in its `Components/Slot.lua`). Only with `Currency_SpawnOrbs` on, which both counts have off |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
