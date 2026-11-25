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
(2026-11-11): the design's darker locked card with a currency picture before the price (the diamond since 2026-11-25). Changed from the design (2026-11-15): a
column two cards wide instead of rows of four and three, and the emote row is one button, showing Wave's icon (`Emote_Wave`'s `IconId`) instead of a +. EMOTES is placed
under all four rows; Loadout moves it up to sit under the last row shown. Restyled for reading (the owner,
2026-11-15): the picture keeps the card's middle, the number sits top left, the copies top right with Shiny under
them, and the name in a band along the bottom; every text is heavy, on one line and outlined in black, and the lock
shows its price under the lock, as tall as the name band, with the diamond icon left of it. Shiny and Golden
cards (2026-11-17): a Shiny item's card wears a holo foil (`S_Foil`: the card's own picture in white with rainbow
colours scrolling through it, a white sheen sweeping across, two twinkling sparkles), a Golden one a gold rim
(`S_Gold`: the card's outline picture in gold with a white glint running round it, a faint gold wash, a sheen and
gold sparkles), both over the card's background and under its picture and texts; the mark under the copies reads
Shiny (pearly pink) or Golden (gold). The lock's diamond and price are centred as one under the lock (they hung off
to the right before): the price is a centred label as wide as the card, and Loadout places the picture left of
its text. The look tab (2026-11-25, the owner's pick of three designs) hangs left of the column beside the card it
opened from: LOOK, a copy of the LOADOUT heading, over one copy of the slot card per look, the weapon's picture in each
look's foil or rim; nothing new was drawn for it.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Loadout"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Loadout`: `Enabled` off, `DisplayOrder` -1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Loadout` | Frame, top right (anchored at its top-right corner) | The panel (the design's `Right`): its top at Y 0.2511 and 0.4776 high since 2026-11-25 (lowered under the lobby menu for the level plate, its bottom where it was) |
| `U_Slots` | Frame (a vertical list of four rows) | The cards; the tutorial points at it |
| `U_Row1` to `U_Row4` | Frame (horizontal list, right-aligned) | Loadout clones the cards two a row into them, in order, so a lone last card sits on the right |
| `U_EmoteSection` | Frame | EMOTES: its heading and `U_Emotes`. Loadout moves it up a row for each row of cards not shown |
| `U_Emotes` | Frame | Holds `S_Shop`, at the right |
| `U_Emotes` › `S_Shop` | ImageButton (Wave's icon in `Icon`, where a slot card has its picture) | Opens `EmoteShop` (its tags) |
| `U_Looks` | Frame inside `U_Loadout`, hidden, as wide as the column and hanging left of it (AnchorPoint 1, 0 at X −0.03) | The look tab (the owner's pick, 2026-11-25): LOOK (a copy of the LOADOUT heading) over `S_Cards`. Loadout shows it beside the card it opened from, moving its Y to that card's row (a row's step, as EMOTES moves) |
| `U_Looks` › `S_Cards` | Frame (a vertical list, right-aligned), `Look_CardSize` attribute (0.5, 0.3048: a slot card's size there), `Look_WornTag` (the EQUIPPED tag's green, 190, 255, 200 to 120, 255, 140: the picker's equipped green) | Loadout clones `PREFAB \| Slot` into it once per look (Normal, Shiny, Golden), sized `Look_CardSize`, its number, copies, + and tag hidden; the look's name goes in `S_Name`, a look not had yet shows `S_Lock` with how it opens in `S_Price` (its `CurrencyIcon` hidden) |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Slot` | `U_Row1` | An ImageButton: `S_Number` (top left, the slot's key in the control hints' key cap), `S_Icon` (the middle, fitted), `S_Name` (the bottom band), `S_Amount` ("x5", top right, a quiet count in a dark pill, hidden on an empty slot), `S_Plus` (empty slot), `S_Shiny` (a tag across the card's top edge, the reward card's NEXT tag: `S_ShinyText` "Shiny" or "Golden" over `S_ShinyGradient` in the variant's colours, since 2026-11-25: the owner, the loose word "looks out of place"), `S_Lock` (the gui maker's locked card, 2026-11-11: `Main`, `Stroke`, `LockIcon`) › `S_Price` (white, centred, as wide as the card, with its `CurrencyIcon` that Loadout places left of the text). `Background` › `Stroke2` / `Stroke` take the looks in its attributes; `Background` › `S_Foil` (`Holo`, `Sheen`, two `Sparkle`s) and `S_Gold` (`Wash`, `Sheen`, `Rim`, two `Sparkle`s), hidden, the Shiny and Golden cards |

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
| `S_LookTab` (Segmented: Off, Bazooka, Slot 1) | The look tab beside the Bazooka (every look) or slot 1's Grenade (Golden locked at "Level 60") |
| `S_Worn` (Segmented: Normal, Shiny, Golden) | The look the tab's weapon wears (selected), up to its best |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Loadout`, `Enabled` off. The Lobby module
turns it on outside matches (and off while a full-screen widget is open). It keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a slot (opens `LoadoutPicker` and, for a weapon with a look past Normal, the look tab beside it; or asks to open a locked slot) | Click | Tap | Select and A | Loadout (`I.Interact.OnPress`) |
| Open `LoadoutPicker` for the Bazooka (selected, nothing replaces it) and its look tab | Click the Bazooka's card | Tap | Select and A | Loadout (`I.Interact.OnPress`) |
| Pick the look a weapon wears | Click a look card | Tap | Select and A | Loadout (`I.Interact.OnPress`; fires `Loadout_SetLook`) |
| Open the emote panel (owned emotes play from there) | Click the EMOTES button | Tap | Select and A | `S_Shop` tags (WidgetManager `Toggle`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Cards | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Picker open for the slot | `Slot` › `Background` | `Stroke2`, `Stroke`, colour from `Look_SelectedStroke2`, `Look_SelectedStroke`, `Look_SelectedStrokeColor` (white); otherwise `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor` |
| Empty slot | `Slot` | `S_Plus` shown, the outline `Look_EmptyStrokeColor` |
| Item | `Slot` › `S_Name` | The item's rarity colour (`I.Rarity.GetLook(rarity).Base`) |
| Locked | `Slot` › `S_Lock` | Shown, with the price in `S_Price` (the number alone, "2,500") and `CurrencyIcon` beside it: Loadout's `DIAMOND_ICON` (the diamond picture, also the gui's default) and that slot's `DIAMOND_SLOT_PRICES`. The two are centred as one: `S_Price` moves right by half the picture and its gap, the picture sits the gap (`Look_PriceGap`, 0.15 of its width) left of the text (`TextBounds`), again whenever they change |
| Shiny item (Loadout's `SHINY_COPIES`) | `Slot` › `Background` › `S_Foil`, `S_Shiny` | Shown; the tag "Shiny" in `Look_ShinyTag` (255, 205, 245 to 230, 130, 215). `Holo`'s gradient scrolls (`Utils_UIGradientMove`, speed 0.25), `Sheen`'s sweeps (`Utils_Motion` `Sweep`), the sparkles twinkle (`Utils_Motion` `Twinkle`), only while shown |
| Look tab card | `S_Cards` › `Normal` / `Shiny` / `Golden` | The card's foil or rim for its look; the worn look in the selected outline (white) with its `S_Shiny` tag reading EQUIPPED in `Look_WornTag`, the others grey and untagged; a look not had yet under `S_Lock` |
| Picker open | The ScreenGui, `U_EmoteSection` | `DisplayOrder` raised to Loadout's `PICKING_DISPLAY_ORDER` (0, over WidgetManager's dim), so the column and the look tab aren't dimmed; EMOTES hidden |
| Look picked | Every card of that weapon (here and in `LoadoutPicker`) | Wears the picked look, not the best owned: a Golden weapon worn as Normal shows no foil, rim or tag |
| Golden item (`GOLDEN_COPIES`) | `Slot` › `Background` › `S_Gold`, `S_Shiny` | Shown instead of `S_Foil`; the tag "Golden" in `Look_GoldenTag` (255, 224, 102 to 255, 181, 31). `Rim`'s gold gradient glints (`Utils_Motion` `Glint`), `Sheen` sweeps, the sparkles twinkle |
