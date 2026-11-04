# Crates

The lobby's crates. The server opens a crate or a 10-pack: it checks the crate takes the currency (or VIP's free
daily crate), refuses diamond prices where the player's policy restricts paid random items, takes the price, rolls
each item by the crate's odds, gives it, and reports which copies just made an item shiny. The client draws the
Crates panel (one card per crate with its prices, **Open**, **Open 10** and **Details**), the `CrateOdds` widget and
the `CrateOpen` reveal. The tutorial crate is a hidden, fixed crate that opens once, while `Tutorial` says it waits.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Crates` |
| Runs on | Server, Client, Global · Lobby map |
| Exposes | `I.Crates` (server), `I.G_Crates` (both) |
| Uses | `I.Currency`, `I.Inventory`, `I.G_Inventory`, `I.Policy`, `I.Shop`, `I.Tutorial`, `I.Random`, `I.Rarity`, `I.WidgetManager`, `I.Replicator`, `I.Notify` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | `Open`: checks, paying, rolling, giving |
| `Global.lua` | The crate rows; warns at start when a crate's odds don't add up to 100 or name an unknown item |
| `Client.lua` | Starts the three client handlers |
| `Scripts/Client/Panel.lua` | The Crates panel: cards, the pay toggle, the free badge, the tutorial crate card, opening |
| `Scripts/Client/Odds.lua` | The `CrateOdds` widget |
| `Scripts/Client/Reveal.lua` | The `CrateOpen` reveal: the crate shakes, then shows one card or ten |
| `Settings.lua` | `Crates_Settings` |
| `Data/Crates/<CrateId>.lua` | One row per crate (`Crates_CrateData`): `Weapon`, `Premium`, `Utility`, `Skin`, `Tutorial` |

## API

### Server: `I.Crates`

| Function | Returns | What it does |
| --- | --- | --- |
| `Open(player, crateId: string, count: number, payWith: string)` | `{ Crates_Result }?` | Opens 1 or 10 crates paid in `"Coins"`, `"Diamonds"` or `"VipDaily"`; nil when it can't |

### Global: `I.G_Crates`

| Function | Returns | What it does |
| --- | --- | --- |
| `Get(crateId: string)` | `Crates_CrateData?` | A crate's row; warns when it has none |
| `GetAll()` | `{ [string]: Crates_CrateData }` | Every row, by id |

## Network

### Server

**Topics**

- `Crates_Opened @ (player: Player, crateId: string, results: { Crates_Result })`: after a crate gave its items (Tutorial listens)

**Receive: RemoteFunctions**

- `Crates_Open @ (player: Player, crateId: string, count: number, payWith: string)`: returns the results, or nil. Rate limit 2 per second.

## Data

Owned items are Inventory items. The panel reads three Replicator folders other modules write:

| Where | Key | What |
| --- | --- | --- |
| Replicator `Shop` | `VipCrateReady` | Shows the free badge on the VIP crate, and makes its **Open** pay with `VipDaily` |
| Replicator `Tutorial` | `CrateReady` | Shows the tutorial crate card in place of the list |
| Replicator `Policy` | `ArePaidRandomItemsRestricted` | Hides diamond prices (and the Premium crate) while not `false` |

A crate row: `Name`, `Picture`, `LayoutOrder`, `Hidden` (not on the panel), `Prices` (`{ [currency]: { One, Ten } }`),
`OddsByCurrency` (`{ [currency]: { [itemId]: percent } }`, each adding up to 100), `Fixed` (items always given, in
place of a roll).

| Crate | Prices | Odds |
| --- | --- | --- |
| `Weapon` | 100 coins, 10 for 900 | Uzi, Baseball Bat, Dynamite, Spartan Spear 14.75 % each; Cluster Bomb, Spider Bomb, Minigun 10 %; Homing Missile, One Punch 5 %; Variety Grenade, Black Hole Grenade 0.5 % |
| `Premium` | 250 diamonds, 10 for 2,250 | Cluster, Spider, Minigun 26 % each; Homing, One Punch 10 %; Variety, Black Hole 1 % |
| `Utility` | 100 coins (900) or 200 diamonds (1,800) | Coins: Parachute, Bandage 27.5 %; Jetpack, Speed 15 %; Medkit 10 %; Low Gravity 5 %. Diamonds: 15, 15, 20, 20, 20, 10 |
| `Skin` | 100 coins (900) or 50 diamonds (450) | Soldier, Pirate, Cowboy 20 % each; Ninja, Knight, Clown 10 %; Devil 7 %; Robot 2 %; Skeleton 1 % |
| `Tutorial` | 100 coins | Fixed: Grenade and Shotgun. Hidden |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `COUNTS` | `{ 1, 10 }` | Pack sizes the server accepts |
| `SHINY_COPIES` | `10` | Copies that make an item shiny |
| `PAID_CURRENCIES` | `{ "Diamonds" }` | Currencies bought with Robux: rolls with them are paid random items |
| `VIP_CRATE`, `VIP_ODDS` | `"Skin"`, `"Coins"` | VIP's free daily crate, and which odds it rolls |
| `TUTORIAL_CRATE` | `"Tutorial"` | The hidden crate the tutorial gives once |
| `SHAKE_SECONDS`, `SHAKE_DEGREES` | `1.2`, `12` | The reveal's shake |
| `GUI_NAME`, `ODDS_GUI_NAME`, `OPEN_GUI_NAME` | `"Crates"`, `"CrateOdds"`, `"CrateOpen"` | The guis it drives |
| `SELECTED_COLOR`, `TILE_COLOR` | `(210, 240, 244)`, `(52, 140, 156)` | A pay button's face when picked, and when not |

## In the place

Drives the `Crates` panel (`U_CrateList` › `PREFAB | CrateCard`, `U_TutorialCrate`), `CrateOdds` (`U_Odds` ›
`PREFAB | OddsRow`) and `CrateOpen` (`U_Stage`, `U_Cards` › `PREFAB | ResultCard`, `S_OpenAgain`). The `U_Skins`
button on the panel is Cosmetics'. The reveal's `S_Burst` effect isn't built yet.
