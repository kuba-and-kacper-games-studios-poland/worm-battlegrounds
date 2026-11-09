# Crates

The **GACHA** screen: a full-screen window over the lobby. The title and one tab per crate across the top left
(Weapons, Premium, Utility, Skins; only the tutorial's free crate while it waits), the balance of the currencies the
selected crate takes and a red BACK at the top right, the crate's odds down the left (a section per rarity, rarest
first, each a grid of item cards with their chance), the crate's picture in the middle and the green x1, x3 and x10
buy buttons with their prices at the bottom. The odds are always shown before buying (Roblox's paid random items
rules); it took over the old `CrateOdds` widget's job.

**Look.** Ported 1:1 from the studio's `Gacha` gui (2026-11-09) as `Primitive` nodes: its slanted dark cards, green
buy buttons, pictures and fonts, its screen-fraction layout (sizes and positions as screen shares with aspect-ratio
constraints, so it scales with the screen by itself, with no `S_ScreenScale`). Added to it: a row layout for the tabs
(one cloned per crate from the design's WEAPONS tab), a second balance chip for diamonds under the coins one (the
design shows one; the diamond icon is the Currency module's), and button tags (`Utils_ButtonScale`,
`Utils_ButtonSound`).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Crates"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Crates`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame, full screen | The widget WidgetManager opens; holds `Content` with the design's `TopLeft`, `TopRight`, `Left`, `Center` and `BottomCenter` |
| `U_Widget` › `S_Close` | ImageButton (BACK) | Closes the widget (its tags), or B on a pad |
| `U_Tabs` | Frame (a row) | Holds one `CrateTab` per crate |
| `U_PayCoins`, `U_PayDiamonds` | ImageButton | A currency's balance (`S_Amount`, a `Currency_Slot`); pressing one pays with it. Shown for the currencies the selected crate takes; the paying one in the picked look (`S_Stroke`, `S_Amount` colours) |
| `U_Crate` | ImageLabel | The selected crate's picture |
| `U_BuyX1`, `U_BuyX3`, `U_BuyX10` | ImageButton | Buy 1, 3 or 10: `S_Icon` (the paying currency's icon, from the button's `Look_CoinsIcon` / `Look_DiamondsIcon`), `S_Price` |
| `U_Odds` | ScrollingFrame | Holds one `RaritySection` per rarity the crate gives, between its `TopGap` and `BottomTail` spacers |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| CrateTab` | `U_Tabs` | An ImageButton: `S_Name` (capitals by `TextCase_Upper`), `S_Stroke2`, `S_Stroke`. Its looks are attributes on the root: `Look_SelectedStroke2`, `Look_SelectedStroke`, `Look_SelectedStrokeColor`, `Look_SelectedTextColor` (the design's WEAPONS), and `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor`, `Look_TextColor` (SKINS) |
| `PREFAB \| RaritySection` | `U_Odds` | A frame: the title bar (`S_Rarity`, capitals by `TextCase_Upper`, with a UIGradient; `S_TitleStroke`, `S_TitleMask`) over `S_Items`, a grid of three across. Each rarity's look is on the root: `Look_<Rarity>_Color` (title and card outline), `Look_<Rarity>_Mask`, `Look_<Rarity>_Gradient`, for Legendary, Epic, Rare, Uncommon and Common |
| `PREFAB \| OddsItem` (nested in `RaritySection` › `S_Items`) | | An item card: `S_Icon`, `S_Name`, `S_Chance`, `S_Stroke` (tinted with its rarity's colour) |

## Driven by

The game's `Crates` module (`Scripts/Client/Panel.lua`: tabs, balance, buy buttons; `Scripts/Client/Odds.lua`: the
odds list). The `Currency` module's `Currency_Slot` writes the balances.

## Preview

`Preview.lua` fills the four tabs (Weapons selected), the weapon crate's odds by rarity and its coin prices.

| Setting | What it does |
| --- | --- |
| `S_Diamonds` (Toggle) | Picks the diamonds chip and the diamond icon on the buy buttons |
| `S_Free` (Toggle) | Shows x1 as FREE (VIP's daily skin crate) |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Crates`, `Enabled` off. WidgetManager opens
it: the `Lobby` gui's corner menu (`U_Menu` › `S_Weapons`, `S_Skins`) through the Crates module, which selects that
button's crate (`Crates_CrateId`) first. It keeps its `Name`, Ids and prefab names.

After each export, point the `Currency_UIScale` ObjectValue under each chip's `S_Amount` (`U_PayCoins`,
`U_PayDiamonds`) at the `S_AmountScale` UIScale inside it (TagList+ adds the empty ObjectValues with the
`Currency_Slot` tag). An empty one warns at start and stops the slot, so its count stays at the design's 9,999.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a crate | Click a tab | Tap | Select | Crates (`I.Interact.OnPress`) |
| Pick the currency | Click a balance chip | Tap | Select | Crates (`I.Interact.OnPress`) |
| Buy 1, 3 or 10 | Click x1, x3, x10 | Tap | Select | Crates (`I.Interact.OnPress`) |
| Close | BACK | BACK | B | `S_Close` tags (`Interact_Button`, `Utils_ButtonKey`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Tabs, chips, buy buttons, BACK | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Selected crate | `CrateTab` | `S_Stroke2`, `S_Stroke` and `S_Name` take the `Look_Selected*` attributes; the others the `Look_*` ones |
| Paying currency | `U_Pay<Currency>` | `S_Stroke` and `S_Amount` take `Look_SelectedStrokeColor` and `Look_SelectedTextColor` (white); the other `Look_StrokeColor`, `Look_TextColor` (grey) |
| Free | `U_BuyX1` | `S_Price` reads FREE and `S_Icon` hides |
| Rarity | `RaritySection`, `OddsItem` | `S_TitleStroke` and the card's `S_Stroke` take `Look_<Rarity>_Color`, `S_TitleMask` `Look_<Rarity>_Mask`, `S_Rarity`'s UIGradient `Look_<Rarity>_Gradient` (Common's for a rarity the design has no look for) |
