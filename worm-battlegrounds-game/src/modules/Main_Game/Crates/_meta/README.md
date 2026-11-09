# Crates

The lobby's crates. The server opens a crate, a 3-pack or a 10-pack: it checks the crate takes the currency (or VIP's
free daily crate), refuses diamond prices where the player's policy restricts paid random items, takes the pack's
price from the crate's row, rolls each item by the crate's odds, gives it, and reports which copies just made an item
shiny. The client draws the full-screen Crates widget (a tab per crate, the balance of the currencies it takes, its
odds by rarity, its picture and the x1, x3 and x10 buy buttons) and the `CrateOpen` reveal. The tutorial crate is a
hidden, fixed crate that opens once, while `Tutorial` says it waits: its tab is then the only one.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Crates` |
| Runs on | Server, Client, Global · Lobby map |
| Exposes | `I.Crates` (server), `I.G_Crates` (both) |
| Uses | `I.Currency`, `I.Inventory`, `I.G_Inventory`, `I.Policy`, `I.Shop`, `I.Tutorial`, `I.Random`, `I.Rarity`, `I.WidgetManager`, `I.Replicator`, `I.Notify`, `I.Interact`, `I.Format` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | `Open`: checks, paying, rolling, giving |
| `Global.lua` | The crate rows and pack prices; warns at start when a crate's odds don't add up to 100 or name an unknown item |
| `Client.lua` | Starts the three client handlers |
| `Scripts/Client/Panel.lua` | The Crates widget: tabs, the paying currency, the buy buttons, the lobby menu's Weapons and Skins buttons and badge, opening |
| `Scripts/Client/Odds.lua` | The Crates widget's odds list, by rarity |
| `Scripts/Client/Reveal.lua` | The `CrateOpen` reveal: the crate shakes, then shows one card, or a card per crate of a pack |
| `Settings.lua` | `Crates_Settings` |
| `Data/Crates/<CrateId>.lua` | One row per crate (`Crates_CrateData`): `Weapon`, `Premium`, `Utility`, `Skin`, `Tutorial` |

## API

### Server: `I.Crates`

| Function | Returns | What it does |
| --- | --- | --- |
| `Open(player, crateId: string, count: number, payWith: string)` | `{ Crates_Result }?` | Opens 1, 3 or 10 crates (`COUNTS`) paid in `"Coins"`, `"Diamonds"` or `"VipDaily"`; nil when it can't |

### Global: `I.G_Crates`

| Function | Returns | What it does |
| --- | --- | --- |
| `Get(crateId: string)` | `Crates_CrateData?` | A crate's row; warns when it has none |
| `GetAll()` | `{ [string]: Crates_CrateData }` | Every row, by id |
| `GetPrice(crateId: string, currency: string, count: number)` | `string?` | What a pack costs: the row's `One`, `Three` or `Ten` in that currency; nil when the crate doesn't take it |

## Network

### Server

**Topics**

- `Crates_Opened @ (player: Player, crateId: string, results: { Crates_Result })`: after a crate gave its items (Tutorial listens)

**Receive: RemoteFunctions**

- `Crates_Open @ (player: Player, crateId: string, count: number, payWith: string)`: returns the results, or nil. Rate limit 2 per second.

## Data

Owned items are Inventory items. The widget reads three Replicator folders other modules write:

| Where | Key | What |
| --- | --- | --- |
| Replicator `Shop` | `VipCrateReady` | Makes the Skin crate's x1 free (FREE, paid with `VipDaily`) and the badge FREE |
| Replicator `Tutorial` | `CrateReady` | Shows the tutorial crate's tab alone, and the badge FREE |
| Replicator `Policy` | `ArePaidRandomItemsRestricted` | Hides the diamonds chip (and the Premium crate's tab) while not `false` |

A crate row: `Name`, `TabName` (its tab's text), `Picture`, `LayoutOrder` (its tab's place), `Hidden` (no tab unless
it's the waiting tutorial crate; opens only one at a time), `Prices` (`{ [currency]: { One, Three, Ten } }`),
`OddsByCurrency` (`{ [currency]: { [itemId]: percent } }`, each adding up to 100), `Fixed` (items always given, in
place of a roll). The Gacha design's own crate picture draws blank in the game, so crates keep theirs.

| Crate | Prices (1, 3, 10) | Odds |
| --- | --- | --- |
| `Weapon` | 100, 300, 900 coins | Uzi, Baseball Bat, Dynamite, Spartan Spear 14.75 % each; Cluster Bomb, Spider Bomb, Minigun 10 %; Homing Missile, One Punch 5 %; Variety Grenade, Black Hole Grenade 0.5 % |
| `Premium` | 250, 750, 2,250 diamonds | Cluster, Spider, Minigun 26 % each; Homing, One Punch 10 %; Variety, Black Hole 1 % |
| `Utility` | 100, 300, 900 coins or 200, 600, 1,800 diamonds | Coins: Parachute, Bandage 27.5 %; Jetpack, Speed 15 %; Medkit 10 %; Low Gravity 5 %. Diamonds: 15, 15, 20, 20, 20, 10 |
| `Skin` | 100, 300, 900 coins or 50, 150, 450 diamonds | Soldier, Pirate, Cowboy 20 % each; Ninja, Knight, Clown 10 %; Devil 7 %; Robot 2 %; Skeleton 1 % |
| `Tutorial` | 100 coins (one only) | Fixed: Grenade and Shotgun. Hidden |

A 3-pack costs three single crates (no discount, unlike the 10-pack's 10 %).

## Settings

| Key | Default | What |
| --- | --- | --- |
| `COUNTS` | `{ 1, 3, 10 }` | Pack sizes the server accepts, one buy button each (`U_BuyX<count>`) |
| `SHINY_COPIES` | `10` | Copies that make an item shiny |
| `PAID_CURRENCIES` | `{ "Diamonds" }` | Currencies bought with Robux: rolls with them are paid random items |
| `VIP_CRATE`, `VIP_ODDS` | `"Skin"`, `"Coins"` | VIP's free daily crate, and which odds it rolls |
| `TUTORIAL_CRATE` | `"Tutorial"` | The hidden crate the tutorial gives once |
| `SHAKE_SECONDS`, `SHAKE_DEGREES` | `1.2`, `12` | The reveal's shake |
| `GUI_NAME`, `OPEN_GUI_NAME` | `"Crates"`, `"CrateOpen"` | The guis it drives |
| `PAY_CURRENCIES` | `{ "Coins", "Diamonds" }` | The currencies crates are paid in, one balance chip each (`U_Pay<currency>`); a crate pays in the first it takes until another is picked |
| `PRICE_FREE` | `"FREE"` | The x1 price while VIP's daily crate is free |
| `LOBBY_GUI_NAME`, `BADGE_FREE`, `BADGE_MAX` | `"Lobby"`, `"FREE"`, `9` | The gui with the corner menu, and the badge on its Weapons button: `BADGE_FREE` while a free crate waits, else how many crates the coins open, `9+` past `BADGE_MAX` |

## In the place

Drives the `Crates` widget (`U_Tabs` › `PREFAB | CrateTab`, `U_PayCoins` / `U_PayDiamonds`, `U_Crate`, `U_BuyX1`,
`U_BuyX3`, `U_BuyX10`, `U_Odds` › `PREFAB | RaritySection` › `PREFAB | OddsItem`), which WidgetManager opens. The
`Lobby` gui's corner menu opens it: `U_Menu` › `S_Weapons` and `S_Skins` (each with a `Crates_CrateId` attribute,
`"Weapon"` and `"Skin"`) select that crate's tab, then `I.WidgetManager.Open("Crates")`. The badge on Weapons
(`U_Menu` › `S_Badge` › `S_Count`) reads FREE while the tutorial crate or VIP's daily crate waits, else how many of
the cheapest coin crate the player's coins open (`9+` past 9, hidden at none), redrawn on `Currency_Changed`. It also
drives `CrateOpen` (`U_Stage`, `U_Cards` › `PREFAB | ResultCard`, `S_OpenAgain`). The reveal's `S_Burst` effect isn't
built yet. The old `CrateOdds` widget is no longer used.
