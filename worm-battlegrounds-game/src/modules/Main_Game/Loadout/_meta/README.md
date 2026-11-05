# Loadout

The weapons and utilities a player takes into a match: 3 slots, plus slot 4 and slot 5, opened with coins or a game
pass. The Bazooka is always there and takes no slot. The lobby's `Loadout` panel shows the slots; pressing an open
slot opens the `LoadoutPicker` widget with the owned weapons and utilities, and pressing the next locked slot asks
whether to open it with coins. Match reads `GetMatchLoadout` when it seats the player.

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
| `Server.lua` | Setting slots, opening slots, the match loadout |
| `Client.lua` | Starts the panel and the picker |
| `Scripts/Client/Panel.lua` | The `Loadout` panel's slots |
| `Scripts/Client/Picker.lua` | The `LoadoutPicker` widget |
| `Settings.lua` | `Loadout_Settings` |

## API

### Server: `I.Loadout`

| Function | Returns | What it does |
| --- | --- | --- |
| `Set(player, slot: number, itemId: string?)` | `boolean` | Puts an owned weapon or utility in an open slot, or empties it; refuses an item another slot already holds |
| `UnlockSlot(player, slot: number)` | `boolean` | Opens the next locked slot with coins |
| `GetUnlocked(player)` | `number` | How many slots are open (base, coins and passes) |
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
| Profile | `Loadout.Slots` | Five item ids, `""` when empty |
| Profile | `Loadout.CoinSlots` | `{ Slot4 = false, Slot5 = false }`: slots opened with coins |
| Replicator `Loadout` | `Slot1` … `Slot5`, `Unlocked` | For the panel and the tutorial |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `BASE_SLOTS`, `MAX_SLOTS` | `3`, `5` | Slots everyone has, and the most |
| `SLOT_PRICES` | 4: 2,500 · 5: 6,000 | Coins to open slot 4 and 5 |
| `SLOT_PASSES` | 4: `Slot4` · 5: `Slot5` | The game passes that open them |
| `SLOT_CATEGORIES` | `{ "Weapon", "Utility" }` | Inventory categories a slot takes |
| `SHINY_COPIES` | `10` | Copies that make an item shiny |
| `PANEL_GUI_NAME`, `PICKER_GUI_NAME` | `"Loadout"`, `"LoadoutPicker"` | The guis |
| `EMPTY_NAME_COLOR` | `(255, 255, 255)` | An empty slot's name colour; a filled slot's name takes its item's rarity colour |
| `EMPTY_ICON` | the kit's plus (`rbxassetid://134817447648270`) | An empty slot's picture; a locked slot shows only its cover |
