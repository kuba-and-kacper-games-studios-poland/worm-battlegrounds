# Crates

The **GACHA** screen: a full-screen window over the lobby, where crates are bought and opened. The title and one tab
per crate across the top left (Weapons, Premium, Utility, Skins; only the tutorial's free crate while it waits), the
balance of the currencies the selected crate takes and a red BACK at the top right, the crate's odds down the left (a
section per rarity, rarest first, each a grid of item cards with their chance), the crate on a pedestal in the middle
in its own light, and the x1, x3 and x10 buy buttons with their prices at the bottom, QUICK OPEN beside them. The odds
are always shown before buying (Roblox's paid random items rules); it took over the old `CrateOdds` widget's job.

Opening a crate plays on the same screen, laid out like CS2's case opening: the shop slides away and the bought
crates drop in as 3D models (`U_Stage`: one, three or ten in a ViewportFrame, over the crate's glow and rays, TAP TO
OPEN at the bottom). A tap opens them, then the reels (`U_Open`): one band of item cards under a fixed line with a lens on it, three stacked bands
for a 3-pack, or ten columns under a horizontal line for a 10-pack, with the crate's name and the pack size on top
and SKIP at the bottom right. The result (`U_Result`) follows: one big card with its rarity bar, name and copies to
shiny, or a pack's row or grid of cards with a summary, over rays, glows and effects, with OPEN AGAIN and CONTINUE. It
took over the old `CrateOpen` gui's job.

**Look.** Ported 1:1 from the studio's `Gacha` gui (2026-11-09) as `Primitive` nodes: its slanted dark cards, green
buy buttons, pictures and fonts, its screen-fraction layout (sizes and positions as screen shares with aspect-ratio
constraints, so it scales with the screen by itself, with no `S_ScreenScale`). Added to it: a row layout for the tabs
(one cloned per crate from the design's WEAPONS tab), a second balance chip for diamonds under the coins one (the
design shows one; the diamond icon is the Currency module's), button tags (`Utils_ButtonScale`, `Utils_ButtonSound`),
and since 2026-11-11 the showcase (pedestal, glow, rays, beam, halo, STANDARD or PREMIUM tag, name plate), QUICK OPEN,
the 3D crates' stage, the opening and the result, built from the design's own pictures and fonts (its card, plate and button pictures,
Londrina) as `Primitive` nodes. The showcase and effect pictures are `art/crates`' (its README → Uploading).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Crates"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Crates`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

### Shop

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame, full screen | The widget WidgetManager opens; holds `Content` with `U_TopLeft`, `U_TopRight`, `U_Left`, `U_Center`, `U_BottomCenter`, `U_BottomRight`, and the opening's `U_Open` and `U_Result` |
| `U_Widget` › `S_Close` | ImageButton (BACK) | Closes the widget (its tags), or B on a pad |
| `U_Backdrop` | Frame, full screen, behind everything | The dim: clear in the shop, violet for the premium crate (with its light `S_Light`), near black while a crate opens |
| `U_TopLeft`, `U_TopRight`, `U_Left`, `U_BottomCenter`, `U_BottomRight` | Frame | The shop's regions, which slide off the screen while a crate opens |
| `U_Tabs` | Frame (a row) | Holds one `CrateTab` per crate |
| `U_PayCoins`, `U_PayDiamonds` | ImageButton | A currency's balance (`S_Amount`, a `Currency_Slot`); pressing one pays with it. Shown for the currencies the selected crate takes; the paying one in the picked look (`S_Stroke`, `S_Amount` colours) |
| `U_Center` | Frame | The showcase: `S_Beam`, `S_Glow`, `S_Rays`, `S_Halo` (premium only), `S_Pedestal`, `S_PedestalRing`, `S_Particles` (the ambient particles' layer), `S_Tier` (`S_TierMain`, `S_TierStroke`, `S_TierText`: STANDARD or PREMIUM) and `S_Plate` (`S_PlateStroke`, `S_Name`) |
| `U_Center` › `U_Crate` | ViewportFrame | The selected crate's 3D model, which the game clones into a WorldModel it makes there, with a camera; its `Ambient`, `LightColor` and `LightDirection` are the stage's |
| `U_BuyX1`, `U_BuyX3`, `U_BuyX10` | ImageButton | Buy 1, 3 or 10: `S_Main`, `S_Stroke` (tinted by the paying currency), `S_Icon` (its icon), `S_Price` |
| `U_Quick` | ImageButton | QUICK OPEN, on or off: `S_Stroke`, `S_Text` |
| `U_Odds` | ScrollingFrame | Holds one `RaritySection` per rarity the crate gives, between its `TopGap` and `BottomTail` spacers |

### Opening

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Stage` | Frame, full screen, hidden | The 3D crates' layer, shown from the intro until they open, and again for a legendary's golden crate |
| `U_Stage` › `S_Glow`, `S_Rays` | ImageLabel | The glow and turning rays behind the crates, in the crate's `Glow` (gold for the golden crate) |
| `U_Stage` › `S_Viewport` | ViewportFrame | Where the game puts its camera and a WorldModel it clones the crate models into; its `Ambient`, `LightColor` and `LightDirection` are the crates' light (gold for the golden crate, from the module's settings) |
| `U_Stage` › `S_Tap` | TextLabel, hidden | TAP TO OPEN or TAP TO OPEN ALL under the crates; `S_TapScale` (UIScale) beats while it waits |
| `U_Stage` › `S_TapSub` | TextLabel, hidden | LEGENDARY CRATE, in gold under it, for the golden crate |
| `U_Stage` › `S_Hit` | ImageButton, full screen, clear, hidden | The tap that opens the crates, shown while they wait |
| `U_Open` | Frame, full screen, hidden | The reels' layer, shown while they roll; its `S_Swallow` (UIScale) shrinks it into the black hole |
| `U_Open` › `S_Title` | Frame | The crate's name (`S_Name`) and the pack size (`S_Count` › `S_CountText`, "x3") |
| `U_Open` › `S_BarTop`, `S_BarBottom` | Frame | The letterbox bars that slide in under a rare result's heartbeat and for a legendary; the title and SKIP draw over them |
| `U_Reels` | Frame | Holds the `Band`s or `Column`s, and the line: `S_MarkerV` (down a band; diamond caps) or `S_MarkerH` (across the columns) |
| `U_Skip` | ImageButton | SKIP: brings every reel in (`S_Stroke`, `S_Text`) |
| `U_Result` | Frame, full screen | The result's layer: `S_Tint` (a colour over the screen), `S_Glow`, `S_Rays`, `S_Disk` and `S_Core` (the black hole's disk and core), `S_FxBack` (effects behind the cards), `S_FxFront` (in front), `S_Flash` (a full-screen flash) |
| `U_Single` | Frame | The big card: `S_CardSlot` (a CanvasGroup the card is built in) › `S_CardScale`, then `S_RowPop` › `S_RarityBar` (`S_BarStroke`, `S_BarMask`, `S_Rarity`), `S_NamePop` › `S_Name`, `S_CopiesPop` › `S_Copies` (`S_Label`, `S_Bar` › `S_Fill`) |
| `U_Cards` | Frame | Holds a pack's cards, each over a `ResultInfo` |
| `U_Summary` | Frame (a row) | Holds a `SummaryChip` per rarity, and one for new items |
| `U_Buttons` | Frame | `U_Again` (OPEN AGAIN: `S_Main`, `S_Stroke`, `S_Icon`, `S_Price`, `S_Amount`) and `U_Continue` (`S_Stroke`, `S_Text`) |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| CrateTab` | `U_Tabs` | An ImageButton: `S_Name` (capitals by `TextCase_Upper`), `S_Stroke2`, `S_Stroke`. Its looks are attributes on the root: `Look_SelectedStroke2`, `Look_SelectedStroke`, `Look_SelectedStrokeColor`, `Look_SelectedTextColor` (the design's WEAPONS), `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor`, `Look_TextColor` (SKINS), and the premium crate's gold `Look_PremiumStrokeColor`, `Look_PremiumTextColor`, `Look_PremiumSelectedStrokeColor`, `Look_PremiumSelectedTextColor` |
| `PREFAB \| RaritySection` | `U_Odds` | A frame: the title bar (`S_Rarity`, capitals by `TextCase_Upper`, with a UIGradient; `S_TitleStroke`, `S_TitleMask`) over `S_Items`, a grid of three across. Each rarity's look is on the root: `Look_<Rarity>_Color` (title, card outline, and the opening's rarity colours), `Look_<Rarity>_Mask`, `Look_<Rarity>_Gradient`, for Legendary, Epic, Rare, Uncommon and Common |
| `PREFAB \| OddsItem` (nested in `RaritySection` › `S_Items`) | | An item card: `S_Icon`, `S_Model` (a hidden ViewportFrame above the name, lit like the cards, where a skin's snail stands), `S_Name`, `S_Chance`, `S_Stroke` (tinted with its rarity's colour) |
| `PREFAB \| Band` | `U_Reels` | One horizontal reel: `S_Strip` (its cards), `S_Dim` (darkens it beside the lens), `S_Lens` (the window over the line) › `S_Zoom` › `S_ZoomScale` › `S_LensStrip` (the cards again, enlarged), `S_LineTop`, `S_LineBottom` (in the crate's `Glow`) |
| `PREFAB \| Column` | `U_Reels` | One of the ten-pack's vertical reels: `S_Strip` |
| `PREFAB \| Card` | `U_Reels` | An item card: `S_Glow`, `S_Stroke` (its rarity's colour), `S_Icon`, `S_Model` (a hidden ViewportFrame in the picture's place, lit like the cards, where a skin's snail stands), `S_Name` (a padded box inside the card's slanted sides, scaled and wrapped, with a `UITextSizeConstraint` the game caps per card), `S_Star` (the gold card's ★, its name "???"), the `S_New` and `S_Best` tags. On the root: `Look_NoNameIconPosition`, `Look_NoNameIconSize`, `Look_NoNameStarPosition`, the picture's place on a card with no name |
| `PREFAB \| ResultInfo` | `U_Cards` | Under a pack's card: `S_RarityBar` (`S_BarStroke`, `S_BarMask`, `S_Rarity`) and `S_Name` |
| `PREFAB \| SummaryChip` | `U_Summary` | `S_Swatch` (a rarity's colour) and `S_Text` ("3 Epic", "1 new") |

## Driven by

The game's `Crates` module: `Scripts/Client/Panel.lua` (tabs, balance, buy buttons), `Odds.lua` (the odds list),
`Showcase.lua` (the pedestal, the 3D crate on it and the crate's look), `Stage3D.lua` (the 3D crates in `U_Stage`), `Reel.lua` (the
reels), `Effects.lua` and `Drops.lua` (the effects and the legendaries' drops), `Result.lua` (the result's cards and
summary), `Reveal.lua` (the opening from start to end). The crate models are the place's
`ReplicatedStorage_Assets/Crates` (the module's README → In the place). The `Currency` module's
`Currency_Slot` writes the balances.

## Preview

`Preview.lua` fills the four tabs (Weapons selected), the weapon crate's odds by rarity, its coin prices, and its 3D
model in `U_Crate` (found in the place by name, `PREFAB | Crate_Weapon`; left empty when the place hasn't got it). The
opening and the result are built by the game at runtime and aren't previewed.

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
| Pick a crate | Click a tab | Tap | LB / RB (L1 / R1), or select | Crates (`I.Interact.OnPress`; the pad through `I.Console`: `TabPrevious`, `TabNext`); LB and RB show at the tab row's ends on Console (`U_Tabs` › `PadHint`) |
| Pick the currency | Click a balance chip | Tap | Select | Crates (`I.Interact.OnPress`) |
| Buy 1, 3 or 10 | Click x1, x3, x10 | Tap | Select | Crates (`I.Interact.OnPress`) |
| Quick open on or off | Click QUICK OPEN | Tap | Select | Crates (`I.Interact.OnPress`) |
| Open the 3D crates | Click anywhere, or Space | Tap anywhere | A | `S_Hit`'s `Utils_ButtonKey` (`ButtonA`, `Space`); Crates (`I.Interact.OnPress`) |
| Skip the reels | Click SKIP, or Space | Tap | A | `U_Skip`'s `Utils_ButtonKey` (`ButtonA`, `Space`) and its `Confirm` hint; Crates (`I.Interact.OnPress`) |
| Open again | Click OPEN AGAIN | Tap | Select | Crates (`I.Interact.OnPress`) |
| Continue | Click CONTINUE | Tap | B | `U_Continue`'s `Utils_ButtonKey` (`ButtonB`) and its `Back` hint; Crates (`I.Interact.OnPress`) |
| Close | BACK | BACK | B | `S_Close` tags (`Interact_Button`, `Utils_ButtonKey`); its `PadHint` badge on Console |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Tabs, chips, buy buttons, QUICK OPEN, SKIP, OPEN AGAIN, CONTINUE, BACK | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Selected crate | `CrateTab` | `S_Stroke2`, `S_Stroke` and `S_Name` take the `Look_Selected*` attributes; the others the `Look_*` ones; the premium crate's tab the `Look_Premium*` gold ones |
| Paying currency | `U_Pay<Currency>` | `S_Stroke` and `S_Amount` take `Look_SelectedStrokeColor` and `Look_SelectedTextColor` (white); the other `Look_StrokeColor`, `Look_TextColor` (grey) |
| Paying currency | `U_BuyX<count>`, `U_Again` | `S_Main` and `S_Stroke` take `Look_<Currency>MainColor` and `Look_<Currency>StrokeColor` (green for coins, blue for diamonds), `S_Icon` `Look_<Currency>Icon` |
| Free | `U_BuyX1` | `S_Price` reads FREE and `S_Icon` hides |
| No name | `Card` (the big card, a pack's cards, the ten-pack's columns) | `S_Name` hides and `S_Icon` (`S_Star`) moves to the middle and grows, from the `Look_NoName*` attributes; with a name they keep the prefab's own place |
| Skin with a snail | `OddsItem`, `Card` | `S_Model` shows the snail live and `S_Icon` hides, `S_Model` in `S_Icon`'s place; on a reel card `S_Model` stays hidden and `S_Icon` shows the snail's picture (the Crates module's `SKIN_PICTURES`) |
| Crate tier | `U_Center` › `S_Tier` | `S_TierText` reads STANDARD or PREMIUM; `S_TierMain` and `S_TierStroke` take `Look_StandardMainColor` / `Look_StandardStrokeColor` or `Look_PremiumMainColor` / `Look_PremiumStrokeColor` |
| Crate theme | `U_Center`, `Band`, `U_Stage` | The showcase's glow, rays, beam and ring, a band's lines, and the stage's `S_Glow` and `S_Rays` take the crate row's `Glow` (`Accent` for the premium ring) |
| Golden crate | `U_Stage` | `S_Glow` and `S_Rays` turn gold, `S_Viewport`'s `Ambient` and `LightColor` take the module's `STAGE_GOLD_*`, and `S_TapSub` shows |
| Quick open | `U_Quick` | `S_Stroke` and `S_Text` take `Look_OnStrokeColor` / `Look_OnTextColor` (yellow) or `Look_OffStrokeColor` / `Look_OffTextColor` |
| Rarity | `RaritySection`, `OddsItem`, `Card`, `ResultInfo`, `SummaryChip`, `U_Single` | `S_TitleStroke` and the card's `S_Stroke` take `Look_<Rarity>_Color`, `S_TitleMask` `Look_<Rarity>_Mask`, `S_Rarity`'s UIGradient `Look_<Rarity>_Gradient` (Common's for a rarity the design has no look for); the opening reads the same colours from the `RaritySection` prefab |
| Motion | the showcase, the 3D crates, the reels, the result | Played by the Crates module (its README → Opening, Settings): the showcase turns and bobs while the widget is open, every loop stops when it closes |
