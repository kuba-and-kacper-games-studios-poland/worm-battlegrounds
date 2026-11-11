# Currency

System's `Currency` made the game's own: the orbs area ume's Currency slots fly orbs across, and a bar in the top-right corner with the player's coins and diamonds and a **+** that opens the shop.

**Look.** The gui maker's bar (2026-11-11), in the studio's Gacha design pictures, as `Primitive` nodes laid out by screen fractions with aspect-ratio constraints (no `S_ScreenScale`, not in ScreenScale's `GUIS`): a dark chip per currency (the design's slanted card, its icon on the left and the count in white Londrina Solid, Heavy Italic, with a scaled black outline) and an orange **+** square. From 10,000 up the slot writes a count short ("18.62k", its `Currency_ShortFrom`), so it stays on one line. Before, it was the GUI kit's dark pill (`Box` `Pill`).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Currency"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Currency`: `Enabled` off, `DisplayOrder` -999, `ScreenInsets` `DeviceSafeInsets`, tagged `UserInterface_PreventHiding` (the UserInterface server enables it at start) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_OrbsContainer` | Frame | System's orb area, kept as it is |
| `U_Bar` | Frame, top right | The bar: `Content` › `Stack`, a chip per currency then `S_Add` |
| `U_Bar` › `S_CoinIcon`, `S_DiamondIcon` | ImageLabel | The currency icons |
| `U_Bar` › `S_Coins` | TextLabel, tagged `Currency_Slot` (`Currency_Name = "Coins"`, `Currency_ShortFrom = 10000`) | ume's Currency writes the amount |
| `U_Bar` › `S_Diamonds` | TextLabel, tagged `Currency_Slot` (`Currency_Name = "Diamonds"`, `Currency_ShortFrom = 10000`) | ume's Currency writes the amount |
| `U_Bar` › `S_CoinsScale`, `S_DiamondsScale` | UIScale, on each chip | The count's `Currency_Slot` pulses it as orbs arrive (its `Currency_UIScale`) |
| `U_Bar` › `S_Add` | Frame › `Button` (ImageButton) | Opens `Shop` (the button's tags) |

## Driven by

ume's Currency module (`Main/2_Currency`) finds it as `I.UserInterface.UI["Currency"]`, `U_OrbsContainer` inside it, and fills every `Currency_Slot`.

## Integration

### Setup

Export it with the Gui tool over System's copy: a ScreenGui named `Currency`, tagged `UserInterface_PreventHiding`. Currency's `CURRENCIES` (in the code folder's `Main/2_Currency/Settings.lua`) holds the `Coins` and `Diamonds` entries the slots name.

After each export, point the `Currency_UIScale` ObjectValue under `S_Coins` at `S_CoinsScale`, and the one under `S_Diamonds` at `S_DiamondsScale` (TagList+ adds the empty ObjectValues with the `Currency_Slot` tag, a moment after the export). An empty one warns at start and stops the slot there, so its count stays at 0.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open the shop | Click + | Tap + | Select and A | `S_Add` › `Button` tags (WidgetManager `Toggle`, `Shop`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | `S_Add` | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Orbs arriving | `S_CoinsScale`, `S_DiamondsScale` | Currency's slot grows the chip a little with each orb (up to ×1.5) and eases it back (`ORB_UI_SCALE_*` in its `Components/Slot.lua`). Only with `Currency_SpawnOrbs` on, which both counts have off |
