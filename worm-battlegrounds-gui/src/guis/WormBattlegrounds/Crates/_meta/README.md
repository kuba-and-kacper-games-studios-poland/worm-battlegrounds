# Crates

The lobby's right panel: the 4 crates (weapon, premium, utility, skin), each with its prices, **Open**, **Open 10** and **Details**; the free tutorial crate; and the **Skins** button showing the equipped skin.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Crates"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `Crates`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Crates` | Box (`Panel`, `Fixed`) | The panel. Has `S_ScreenScale` |
| `U_TutorialCrate` | Box | The new player's free crate, shown once by Tutorial in place of the list |
| `U_TutorialCrate` › `S_Open` | Button (`Primary`) | Opens it |
| `U_CrateList` | Cells | Holds one `CrateCard` per crate |
| `U_Skins` | Item (`Square`) | Opens `Skins` (its tags); `S_Info` shows the equipped skin's name |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | CrateCard` | `U_CrateList` | `S_Picture`, `S_Name`, `S_Free` (VIP's daily free skin crate), `S_PayCoins` / `S_PayDiamonds` (the price in each currency; the selected one pays; hidden when the crate doesn't take it), `S_Open`, `S_Open10`, `S_Details` (opens `CrateOdds`) |

## Driven by

The game's `Crates` module (cards, the tutorial crate, opening), `Cosmetics` (`U_Skins`) and the `Shop` module's VIP state (`S_Free`, read by Crates).

## Preview

`Preview.lua` fills the 4 crates with their wiki prices.

| Setting | What it does |
| --- | --- |
| `S_Tutorial` (Toggle) | Shows the tutorial crate in place of the list |
| `S_Vip` (Toggle) | Shows the skin crate's free badge |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Crates`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size. Prices are read live and odds shown before buying (Roblox's paid random items rules).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Skins | Click | Tap | Select and A | `U_Skins` tags (WidgetManager `Toggle`) |
| Pick a currency, Open, Open 10, Details | Click | Tap | Select and A | Crates connects the card buttons |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
