# Loadout

The lobby's **LOADOUT**, a column hanging from the right edge under the corner menu: numbered cards two a row, the
Bazooka then slots 1 to 6 (an item's picture, name and copies, a + on an empty slot, the lock and price on the next
slot to open), and under them **EMOTES**, one button with Wave's icon (the waving hand) that opens the emote panel. Both headings are right-aligned
(the owner, 2026-11-15).

**Look.** Ported 1:1 from the studio's `LobbyInventory` gui (its `Right` frame, 2026-11-09) as `Primitive` nodes,
laid out in screen fractions with aspect-ratio constraints (no `S_ScreenScale`). The design's slot looks are kept as
attributes on the slot prefab (normal, selected, the + slot's darker outline). Added: the shiny mark, the lock cover
(the design's locked inventory card) with the price, and EMOTES, which the design lacks, built from copies of
its header and slot card; button tags (`Utils_ButtonScale`, `Utils_ButtonSound`). The gui maker polished the lock cover
(2026-11-11): the design's darker locked card with a coin before the price. Changed from the design (2026-11-15): a
column two cards wide instead of rows of four and three, and the emote row is one button, showing Wave's icon (`Emote_Wave`'s `IconId`) instead of a +. EMOTES is placed
under all four rows; Loadout moves it up to sit under the last row shown. Restyled for reading (the owner,
2026-11-15): the picture keeps the card's middle, the number sits top left, the copies top right with Shiny under
them, and the name in a band along the bottom; every text is heavy, on one line and outlined in black, and the lock
shows its price under the lock, as tall as the name band, with the coin or Robux icon left of it. Shiny and Golden
cards (2026-11-17): a Shiny item's card wears a holo foil (`S_Foil`: the card's own picture in white with rainbow
colours scrolling through it, a white sheen sweeping across, two twinkling sparkles), a Golden one a gold rim
(`S_Gold`: the card's outline picture in gold with a white glint running round it, a faint gold wash, a sheen and
gold sparkles), both over the card's background and under its picture and texts; the mark under the copies reads
Shiny (pearly pink) or Golden (gold). The lock's coin and price are centred as one under the lock (they hung off
to the right before): the price is a centred label as wide as the card, and Loadout places the picture left of
its text.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Loadout"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Loadout`: `Enabled` off, `DisplayOrder` -1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Loadout` | Frame, top right (anchored at its top-right corner) | The panel (the design's `Right`) |
| `U_Slots` | Frame (a vertical list of four rows) | The cards; the tutorial points at it |
| `U_Row1` to `U_Row4` | Frame (horizontal list, right-aligned) | Loadout clones the cards two a row into them, in order, so a lone last card sits on the right |
| `U_EmoteSection` | Frame | EMOTES: its heading and `U_Emotes`. Loadout moves it up a row for each row of cards not shown |
| `U_Emotes` | Frame | Holds `S_Shop`, at the right |
| `U_Emotes` › `S_Shop` | ImageButton (Wave's icon in `Icon`, where a slot card has its picture) | Opens `EmoteShop` (its tags) |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Slot` | `U_Row1` | An ImageButton: `S_Number` (top left), `S_Icon` (the middle, fitted), `S_Name` (the bottom band), `S_Amount` ("x5", top right), `S_Plus` (empty slot), `S_Shiny` (under `S_Amount`: "Shiny" or "Golden"), `S_Lock` (the gui maker's locked card, 2026-11-11: `Main`, `Stroke`, `LockIcon`) › `S_Price` (white, centred, as wide as the card, with its `CurrencyIcon` that Loadout places left of the text). `Background` › `Stroke2` / `Stroke` take the looks in its attributes; `Background` › `S_Foil` (`Holo`, `Sheen`, two `Sparkle`s) and `S_Gold` (`Wash`, `Sheen`, `Rim`, two `Sparkle`s), hidden, the Shiny and Golden cards |

## Driven by

The game's `Loadout` module (`Scripts/Client/Panel.lua`); `Tutorial` points at `U_Slots`.

## Preview

`Preview.lua` fills the cards and moves EMOTES under the last row, as Loadout does.

| Setting | What it does |
| --- | --- |
| `S_Unlocked` (Slider, 3 to 5) | Open slots; the next one shows its lock and price, later ones hide |
| `S_Selected` (Slider, 0 to 5) | The slot whose picker is open (selected look) |
| `S_Shiny` (Toggle) | The first slot's item shiny |
| `S_Golden` (Toggle) | The second slot's item golden |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Loadout`, `Enabled` off. The Lobby module
turns it on outside matches (and off while a full-screen widget is open). It keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a slot (opens `LoadoutPicker`, or asks to open a locked slot) | Click | Tap | Select and A | Loadout (`I.Interact.OnPress`) |
| Open the emote panel (owned emotes play from there) | Click the EMOTES button | Tap | Select and A | `S_Shop` tags (WidgetManager `Toggle`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Cards | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Picker open for the slot | `Slot` › `Background` | `Stroke2`, `Stroke`, colour from `Look_SelectedStroke2`, `Look_SelectedStroke`, `Look_SelectedStrokeColor` (white); otherwise `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor` |
| Empty slot | `Slot` | `S_Plus` shown, the outline `Look_EmptyStrokeColor` |
| Item | `Slot` › `S_Name` | The item's rarity colour (`I.Rarity.GetLook(rarity).Base`) |
| Locked | `Slot` › `S_Lock` | Shown, with the price in `S_Price` (the number alone, "2,500") and `CurrencyIcon` beside it: Loadout's `COIN_ICON` for the coin slot, `ROBUX_ICON` and the pass's live price for a pass slot. The two are centred as one: `S_Price` moves right by half the picture and its gap, the picture sits the gap (`Look_PriceGap`, 0.15 of its width) left of the text (`TextBounds`), again whenever they change |
| Shiny item (Loadout's `SHINY_COPIES`) | `Slot` › `Background` › `S_Foil`, `S_Shiny` | Shown; the mark "Shiny" in `Look_ShinyColor` (255, 175, 235). `Holo`'s gradient scrolls (`Utils_UIGradientMove`, speed 0.25), `Sheen`'s sweeps (`Utils_Motion` `Sweep`), the sparkles twinkle (`Utils_Motion` `Twinkle`), only while shown |
| Golden item (`GOLDEN_COPIES`) | `Slot` › `Background` › `S_Gold`, `S_Shiny` | Shown instead of `S_Foil`; the mark "Golden" in `Look_GoldenColor` (255, 196, 0). `Rim`'s gold gradient glints (`Utils_Motion` `Glint`), `Sheen` sweeps, the sparkles twinkle |
