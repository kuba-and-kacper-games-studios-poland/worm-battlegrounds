# Loadout

The weapons and utilities a player takes into a match: 1 slot (`BASE_SLOTS`, 3 before 2026-11-25), plus one for each
slot opened with diamonds (`DIAMOND_SLOT_PRICES`, each dearer than the last) or bought with Robux (slots 3 to 6, each
its own developer product, `SLOT_PRODUCTS`: R$39, 69, 99, 149 since 2026-11-25), and one for each old slot game pass
owned (`SLOT_PASSES`, no longer sold), 6 at most. A player from before 2026-11-25 (their tutorial match played, or a slot
filled) keeps `KEPT_SLOTS` (2) more, saved once as diamond slots. The Bazooka (`BASIC_WEAPON`) is always there and takes no slot. The lobby's `Loadout` panel (LOADOUT, at the
right) shows a column of cards, two a row (`SLOTS_PER_ROW`, the gui's `U_Row1` to `U_Row4`, a lone last card on the right), with EMOTES moved up under the last row shown, numbered like the match's bar: the Bazooka, then each slot with its item's picture,
name in its rarity's colour, copies (x5) and its Shiny or Golden mark (`SHINY_COPIES`, `GOLDEN_COPIES`: the card in
the gui's holo foil, `S_Foil`, or gold rim, `S_Gold`), a + on an empty slot, and the lock with its price on the
next slot to open (later ones hide), the diamond picture (`DIAMOND_ICON`) and that slot's diamonds centred under the lock as one. Pressing an open slot shows it selected and opens the `LoadoutPicker` widget
(INVENTORY): every weapon and utility, owned ones first by rarity with their copies, a Shiny one in its foil and a Golden one in its gold rim (the one in this slot selected,
those in other slots in the equipped look, uses and cooldown in the hover info), then the ones not owned yet,
locked; **Empty** empties the slot. Pressing the next locked slot asks whether to open it for its diamonds, naming its
product's Robux price too ("Open slot 3 for 1,000 diamonds? (or R$ 39)"); when the server won't open it (not enough
diamonds), it offers that product for Robux instead ("Open slot 3 now with Robux for R$ 39?"), or says "Not enough
diamonds yet." for slot 2, which has no product. The product opens the slot as Marketplace grants it (`AddBoughtSlot`). Match reads `GetMatchLoadout` when it seats the player
(through Matchmaking's card: `ShinyItems` and `GoldenItems`). Levels open the starter weapons' looks too (Progression's
`WEAPON_REWARDS`, `I.G_Progression.GetWeaponVariant`, 2026-11-24): an item is Shiny or Golden by its copies, the
player's level or a look an admin gave (`I.G_Progression.GetPlayerWeaponVariant`), whichever is better, on the panel, in the picker and in the match, and the Bazooka, which has no copies,
by its level alone (Shiny at 30, Golden at 90). Golden is a look only (the owner, 2026-11-17): a golden
item is shiny too and deals and boosts as a shiny one; Combat draws it gold on every screen.

**Players pick the look each weapon wears** (the owner's pick, 2026-11-25, "the look tab"): pressing the Bazooka's card
or a slot's card opens the picker and, when the weapon has a look past Normal, the **look tab** left of the column, its
top on that card's row: LOOK and three copies of the slot card (`LOOKS`: Normal, Shiny, Golden), the weapon's
picture in each look's foil or rim, the worn one selected (white outline) and tagged EQUIPPED (the card's top tag in
the picker's equipped green), a look not had yet locked with how it opens
("Level 90", "100 copies": `I.G_Loadout.GetLookUnlock`). Pressing a look asks the server (`Loadout_SetLook`), which saves
it per weapon (`Loadout.Looks`, "Look:Best") and writes `WeaponLooks` on the Player. A pick holds until a better look
opens, which then shows instead. The panel, the picker, the match (Matchmaking's card `ItemLooks`: the held weapon, its
shots and blasts, the match's weapon bar) and the lobby stage's Bazooka all wear the picked look; the damage follows
the best look owned (the owner, 2026-11-25), so a Golden weapon worn as Normal still deals +5%. The tab shuts with the
picker. The picker opened from the Bazooka (the owner, 2026-11-25: "it opens the loadout as any other weapon") shows
the Bazooka selected (listed first, drawn from its Arsenal row in `BASIC_WEAPON_RARITY`, as it has no inventory row);
nothing replaces it there, so the other cards take no press and **Empty** hides. While the picker is open the panel
draws over its dim (`PICKING_DISPLAY_ORDER`), so the column and the look tab stay bright, and EMOTES hides; the open
picker draws again when another card is pressed or a look changes.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Loadout` |
| Runs on | Server, Client · both maps |
| Exposes | `I.Loadout` (server, client), `I.G_Loadout` (both) |
| Uses | `I.Progression` (server: the level), `I.G_Progression` (the level rewards' looks), `I.Player` (the profile), `I.Inventory`, `I.G_Inventory`, `I.G_Arsenal`, `I.Currency`, `I.G_Marketplace`, `I.Rarity`, `I.WidgetManager`, `I.Replicator` |
| Saves | `Profile.Loadout` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Setting slots, keeping an older player's slots (once), opening a slot with diamonds, counting the pass slots (republished when one is bought), the match loadout |
| `Client.lua` | Starts the panel and the picker, the client `I.Loadout` |
| `Global.lua` | `I.G_Loadout`: a player's best and worn look for a weapon, a look's rank, how a look opens |
| `Scripts/Client/Panel.lua` | The `Loadout` panel's cards: the basic weapon and the slots, their Shiny or Golden mark and card in the look they wear (redrawn when the `Level`, `WeaponVariants` or `WeaponLooks` Player attribute changes), the look tab (`U_Looks`: a slot card copy per look, opened from the Bazooka's or a slot's card), the selected look while the picker is open, the lock's price centred with its picture (`_centrePrice`, again whenever its `TextBounds` change); EMOTES (`U_EmoteSection`) moved up under the last row shown |
| `Scripts/Client/Picker.lua` | The `LoadoutPicker` widget, each card in the look it wears (foil or rim); a `Disabled` item shows only to players who own it |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `loadout` command |
| `Settings.lua` | `Loadout_Settings` |

## API

### Server: `I.Loadout`

| Function | Returns | What it does |
| --- | --- | --- |
| `Set(player, slot: number, itemId: string?)` | `boolean` | Puts an owned weapon or utility in an open slot, or empties it; refuses an item another slot already holds |
| `SetLook(player, itemId: string, look: string)` | `boolean` | Picks the look the Bazooka or an owned weapon or utility wears, any of `LOOKS` up to the best the player has; saved as `"Look:Best"` (nothing when it's the best), so a better look opening later shows instead; false for another item or a look not had |
| `UnlockSlot(player, slot: number)` | `boolean` | Opens the next locked slot for its `DIAMOND_SLOT_PRICES` diamonds, saved as a diamond slot; false when it isn't the next one, has no price or the player can't pay |
| `AddBoughtSlot(player, slot: number)` | `boolean` | Opens one more slot for a slot product bought with Robux (Marketplace's `LoadoutSlot<n>` Reward), saved as `Robux<n>` beside the diamond slots |
| `OpenAllSlots(player)` | `boolean` | Opens every slot for good, whatever passes they own, by saving each slot past the base as a diamond slot (the `loadout unlock_slots` command) |
| `GetUnlocked(player)` | `number` | How many slots are open: `BASE_SLOTS`, plus one per saved slot (bought with diamonds or Robux, or kept), plus one per old slot pass owned, up to `MAX_SLOTS` |
| `GetMatchLoadout(player)` | `{ string }, { [string]: boolean }, { [string]: boolean }, { [string]: string }` | The items in open slots, which are shiny (`SHINY_COPIES` or more, or a level reward: the +5% damage), which golden (`GOLDEN_COPIES` or more, or a level reward, shiny too), and the look each wears (`"Normal"`, `"Shiny"`, `"Golden"`: Matchmaking's card `ItemLooks`); every map also carries `BASIC_WEAPON` |

### Global: `I.G_Loadout`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetBestLook(player: Player, itemId: string)` | `string` | The best look a player has for a weapon: `"Golden"` (`GOLDEN_COPIES` or a level reward), `"Shiny"` (`SHINY_COPIES` or a level reward) or `"Normal"`. Copies count on the server and the player's own screen; the Bazooka's level alone counts |
| `GetWornLook(player: Player, itemId: string)` | `string` | The look it wears: the one picked (the profile's `Loadout.Looks`, the `WeaponLooks` attribute on clients) while no better look opened since, else the best |
| `GetLookRank(look: string)` | `number` | The look's place in `LOOKS` (1 to 3), 0 for an unknown one |
| `GetLookUnlock(itemId: string, look: string)` | `string` | How a look not had yet opens: its level (Progression's `WEAPON_REWARDS`, "Level 90"), else its copies ("100 copies") |

### Client: `I.Loadout`

| Function | Returns | What it does |
| --- | --- | --- |
| `OpenPicker(slot: number)` | | Opens the picker for an open slot (0: the Bazooka), showing that card selected and the look tab beside it, as pressing it does (the Tutorial's lobby guide) |

## Network

### Server

**Receive: RemoteEvents**

- `Loadout_Set @ (player: Player, slot: number, itemId: string?)`. Rate limit 5 per second.
- `Loadout_SetLook @ (player: Player, itemId: string, look: string)`: a press on the look tab. Rate limit 5 per second.

**Receive: RemoteFunctions**

- `Loadout_UnlockSlot @ (player: Player, slot: number)`: returns whether it opened

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Loadout.Slots` | Six item ids, `""` when empty (older profiles have five) |
| Profile | `Loadout.CoinSlots` | The diamond slots (the key keeps its coin-days name, since it's saved data): each `true` opens one slot, whatever its key. A slot bought with diamonds is `Slot<n>`, one bought with Robux `Robux<n>` (a `_` added while that key is taken), the kept ones `Kept1` and `Kept2`, and older saves' coin slots (`Slot4`, a `Slot5` from before 2026-11-13) still count; the `loadout unlock_slots` command saves `Slot2` to `Slot6` |
| Profile | `Loadout.Looks` | The looks picked below a weapon's best, by item id: `"Look:Best"` (`"Normal:Golden"`), the best then, so a better look opening later shows instead |
| Profile | `Loadout.SlotsKept` | Whether the kept slots were decided (`false` until the player's first join from 2026-11-25) |
| Replicator `Loadout` | `Slot1` … `Slot6`, `Unlocked` | For the panel and the tutorial |
| Player attribute | `WeaponLooks` | `Loadout.Looks` as JSON, for every screen (the panel, the picker, others' lobby stages) |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `BASE_SLOTS`, `MAX_SLOTS` | `1`, `6` | Slots everyone has besides the Bazooka, and the most |
| `DIAMOND_SLOT_PRICES` | `[2]` 375, `[3]` 1,000, `[4]` 2,500, `[5]` 6,000, `[6]` 12,500 | Diamonds that open each slot past the base, by slot number (halved from the coin prices on 2026-11-25) |
| `KEPT_SLOTS` | `2` | Slots past the base a player from before 2026-11-25 keeps |
| `SLOT_PRODUCTS` | `{ [3] = "LoadoutSlot3", [4] = "LoadoutSlot4", [5] = "LoadoutSlot5", [6] = "LoadoutSlot6" }` | The developer product that opens each slot for Robux (`src/global_data/Marketplace/Products.lua`: ids 3736173219, 3736173750, 3736173966, 3736174180; R$39, 69, 99, 149), each sold only while it's the player's next slot (its `Requirements`) |
| `SLOT_PASSES` | `{ "Slot5", "Slot6" }` | The game passes that opened one more slot each before the products: still counted for their owners, no longer sold |
| `SLOT_CATEGORIES` | `{ "Weapon", "Utility" }` | Inventory categories a slot takes |
| `SHINY_COPIES`, `GOLDEN_COPIES` | `10`, `100` | Copies that make an item shiny, and golden (a look only: Combat's `VARIANT_LOOKS`) |
| `LOOKS` | `{ "Normal", "Shiny", "Golden" }` | The looks a weapon can wear, plainest first: the look tab's cards |
| `PANEL_GUI_NAME`, `PICKER_GUI_NAME` | `"Loadout"`, `"LoadoutPicker"` | The guis |
| `PICKING_DISPLAY_ORDER` | `0` | The panel's DisplayOrder while the picker is open: over WidgetManager's dim (-1), under the picker (1) |
| `BASIC_WEAPON`, `BASIC_WEAPON_RARITY` | `"Bazooka"`, `"Common"` | The weapon every loadout has: first on the panel and in the picker (where nothing replaces it), and the rarity the picker draws it in |
| `SLOTS_PER_ROW`, `ITEMS_PER_ROW` | `2`, `3` | Cards in each of the panel's rows, and in each of the picker's rows |
| `DIAMOND_ICON` | the diamond picture (`rbxassetid://98200575516825`) | The picture beside a locked slot's price |

## Commands

`loadout` (server, level 255):

| Subcommand | Arguments | What |
| --- | --- | --- |
| `unlock_weapons` | `player` | Gives one copy of every weapon and utility (`SLOT_CATEGORIES`) the player doesn't own yet |
| `unlock_slots` | `player` | Opens all `MAX_SLOTS` slots for good (`OpenAllSlots`) |

Giving one item, or more copies of it, is the Inventory's `inventory add_standard player itemId quantity?`.
