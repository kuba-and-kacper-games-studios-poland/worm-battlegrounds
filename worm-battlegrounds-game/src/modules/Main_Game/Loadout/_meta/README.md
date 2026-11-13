# Loadout

The weapons and utilities a player takes into a match: 3 slots, plus one opened with coins (`COIN_SLOT_PRICE`) and
one for each slot game pass owned (`SLOT_PASSES`, in any order), 6 at most. The Bazooka (`BASIC_WEAPON`) is always there and takes no slot. The lobby's `Loadout` panel (LOADOUT, at the
right) shows two rows of cards (four on top, `SLOTS_PER_ROW`, three below) numbered like the match's bar: the Bazooka, then each slot with its item's picture,
name in its rarity's colour, copies (x5) and shiny mark, a + on an empty slot, and the lock with its price on the
next slot to open (later ones hide): coins while the coin slot is closed, else the next pass's live Robux price. Pressing an open slot shows it selected and opens the `LoadoutPicker` widget
(INVENTORY): every weapon and utility, owned ones first by rarity with their copies (the one in this slot selected,
those in other slots in the equipped look, uses and cooldown in the hover info), then the ones not owned yet,
locked; **Empty** empties the slot. Pressing the next locked slot asks whether to open it with coins, or prompts the next slot pass once the coin
slot is open. Buying a slot pass opens its slot at once. Match reads `GetMatchLoadout` when it seats the player.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Loadout` |
| Runs on | Server, Client · both maps |
| Exposes | `I.Loadout` (server) |
| Uses | `I.Inventory`, `I.G_Inventory`, `I.G_Arsenal`, `I.Currency`, `I.G_Marketplace`, `I.Rarity`, `I.WidgetManager`, `I.Replicator` |
| Saves | `Profile.Loadout` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Setting slots, opening the coin slot, counting the pass slots (republished when one is bought), the match loadout |
| `Client.lua` | Starts the panel and the picker |
| `Scripts/Client/Panel.lua` | The `Loadout` panel's cards: the basic weapon and the slots, the selected look while the picker is open |
| `Scripts/Client/Picker.lua` | The `LoadoutPicker` widget |
| `Settings.lua` | `Loadout_Settings` |

## API

### Server: `I.Loadout`

| Function | Returns | What it does |
| --- | --- | --- |
| `Set(player, slot: number, itemId: string?)` | `boolean` | Puts an owned weapon or utility in an open slot, or empties it; refuses an item another slot already holds |
| `UnlockSlot(player, slot: number)` | `boolean` | Opens the coin slot as the next locked slot, once per player |
| `GetUnlocked(player)` | `number` | How many slots are open: base, plus the coin slot, plus one per slot pass owned |
| `GetMatchLoadout(player)` | `{ string }, { [string]: boolean }` | The items in open slots, and which are shiny |

## Network

### Server

**Receive: RemoteEvents**

- `Loadout_Set @ (player: Player, slot: number, itemId: string?)`. Rate limit 5 per second.

**Receive: RemoteFunctions**

- `Loadout_UnlockSlot @ (player: Player, slot: number)`: returns whether it opened

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Loadout.Slots` | Six item ids, `""` when empty (older profiles have five) |
| Profile | `Loadout.CoinSlots` | `{ Slot4 = false }`: the coin slot. Each `true` opens one slot, so a `Slot5` saved before 2026-11-13 (when slot 5 cost 6,000 coins) still counts |
| Replicator `Loadout` | `Slot1` … `Slot6`, `Unlocked`, `CoinSlotOpen` | For the panel and the tutorial |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `BASE_SLOTS`, `MAX_SLOTS` | `3`, `6` | Slots everyone has, and the most |
| `COIN_SLOT_PRICE` | `"2500"` | Coins for the one coin slot |
| `SLOT_PASSES` | `{ "Slot5", "Slot6" }` | Game passes that each open one more slot; the panel offers them in this order |
| `SLOT_CATEGORIES` | `{ "Weapon", "Utility" }` | Inventory categories a slot takes |
| `SHINY_COPIES` | `10` | Copies that make an item shiny |
| `PANEL_GUI_NAME`, `PICKER_GUI_NAME` | `"Loadout"`, `"LoadoutPicker"` | The guis |
| `BASIC_WEAPON` | `"Bazooka"` | The weapon every loadout has: first on the panel, never in the picker |
| `SLOTS_PER_ROW`, `ITEMS_PER_ROW` | `4`, `3` | Cards in the panel's top row (the rest go below), and in each of the picker's rows |
| `COIN_ICON`, `ROBUX_ICON` | asset ids | The picture beside a locked slot's price |
