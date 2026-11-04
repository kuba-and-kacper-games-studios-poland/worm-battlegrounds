# Crates

The lobby's right panel: the 4 crates (weapon, premium, utility, skin), each with its prices, **Open**, **Open 10** and **Details**; the free tutorial crate; and the **Skins** button showing the equipped skin.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Each crate card has three rows: the picture and name, the currencies as tabs (slate, the paying one blue), then Open and Open 10 in green (prices) and Details in blue. The panel is 560 wide, so it clears Play on tablets, and hangs from the bottom-right corner. On phones and tablets it's 520 × 820 at scale 0.9, its list scrolling. The tutorial's free crate keeps the one yellow.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Crates"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
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

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Crates`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size. Prices are read live and odds shown before buying (Roblox's paid random items rules).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Skins | Click | Tap | Select and A | `U_Skins` tags (WidgetManager `Toggle`) |
| Pick a currency, Open, Open 10, Details | Click | Tap | Select and A | Crates connects the card buttons |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
| Paying currency | `CrateCard` › `S_PayCoins`, `S_PayDiamonds` › `Face` | The paying one wears its `Kit_SelectedImage` (blue), the other its `Kit_Image` (slate); Crates' `Panel` |
