# Shop

The Robux shop and VIP. The client draws the `Shop` widget: the diamond packs (developer products) and the game
passes, each with its live price, bought through ume's Marketplace prompts. The currency bar's **+** opens it through
its tags (the lobby keeps the top bar clear). **A bought pack plays once the shop closes** (the owner, 2026-11-25:
"make it feel REALLY good"): as a pack is paid for, every diamonds counter (the shop's own, the lobby's) holds at the count from before the first press
(`I.Progression.HoldPurchase`), and when the shop closes the packs bought in it play as Progression's payout, with a
fanfare and a gem blue vignette (`I.Progression.PlayPurchase`; nothing plays while it's open). A pack granted while the
shop isn't open (Roblox retrying a receipt) plays at once. The server marks VIP players (the `Vip` Player attribute,
which gives a gold snail name and a chat tag) and keeps VIP's free skin crate, once per UTC day.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Shop` |
| Runs on | Server, Client · every map |
| Exposes | `I.Shop` (server) |
| Uses | `I.G_Marketplace`, `I.Marketplace` (the admin command), `I.Replicator`, `I.WidgetManager`, `I.Progression` (the client's payout), `I.Currency`, `I.BN`, `I.AdminPanel_CommandBar`, `I.DoEvery`, `TextChatService` |
| Saves | `Profile.Shop` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | VIP, the daily free crate, a check every minute for a new day |
| `Client.lua` | The `Shop` widget, the bought packs' payout once it closes, the VIP chat tag |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `shop buy_pack` command |
| `Settings.lua` | `Shop_Settings` |
| `_meta/_types.lua` | `Shop_Pack`, `Shop_Pass` |

The products and passes themselves (ids, rewards) are in `src/global_data/Marketplace/`; every id is a placeholder `0`
until the owner creates them.

## API

### Server: `I.Shop`

| Function | Returns | What it does |
| --- | --- | --- |
| `ClaimVipCrate(player)` | `boolean` | Uses up today's free crate; false when it isn't ready |
| `IsVip(player)` | `boolean` | Whether the player owns the VIP pass |
| `CanClaimVipCrate(player)` | `boolean` | Whether a VIP player hasn't opened today's crate |

## Network

No remotes of its own: purchases use Marketplace's `Marketplace_PromptProductPurchase` and
`Marketplace_PromptGamePassPurchase`, and state travels in the Replicator and a Player attribute. It listens to
`Marketplace_GamePassPurchaseSucceeded-VIP` (server) and `Marketplace_ProductPurchaseSucceeded` (client: a pack was
paid for), and the WidgetManager's `WidgetManager_Opened` and `WidgetManager_Closed` Topics.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Shop.VipCrateDay` | The UTC day (`os.time() // 86400`) of the last free crate |
| Replicator `Shop` | `VipCrateReady` | Whether today's free crate waits |
| Player attribute | `Vip` | Whether the player owns VIP (Match copies it to the snail). Set, with `VipCrateReady`, on a thread of its own a moment after the player joins, since the pass check is a web call |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PACKS` | Handful 250, Pouch 500, Bag 1,000, Chest 1,500, Vault 2,500 | `{ Product, Name, Icon, Diamonds }` per pack, in order; `Icon` is the studio's pack picture |
| `PASSES` | VIP, Double Diamonds ("Twice the diamonds from every match"; its `GamePass` key is still `DoubleCoins`); the loadout slot passes left on 2026-11-25 (slots are sold on the loadout's locked slot, as developer products) | `{ GamePass, Name, Icon, Benefits }` per pass, in order; `Icon` is the studio's pass picture; Double Diamonds' is the owner's 2x diamonds picture since 2026-11-25 (`art/shop`) |
| `VIP_PASS` | `"VIP"` | The VIP pass's Marketplace name |
| `VIP_CHAT_TAG` | gold `[VIP] ` | Put in front of a VIP player's chat messages |
| `VIP_CHECK_SECONDS` | `60` | How often the server looks for a new day's crate |
| `GUI_NAME` | `"Shop"` | The widget |

## Commands

| Command | What it does |
| --- | --- |
| `shop buy_pack <player> <product>` | Buys a diamond pack (`Diamonds_Handful` … `Diamonds_Vault`) for a player without Robux, for testing: grants its reward (`I.Marketplace.Product_Gift`) and fires `Marketplace_ProductPurchaseSucceeded` to them as a real receipt does, so the payout plays once their shop closes. Permission 255 |

## In the place

Drives the `Shop` widget (`U_Packs` › `PREFAB | Pack`: `S_Icon`, `S_Name`, `S_Info`, `S_Buy` › `S_Price`; `U_Passes` ›
`PREFAB | Pass`: `S_Icon`, `S_Name`, `S_Benefits`, `S_Buy` › `S_RobuxIcon`, `S_Price`, coloured from the button's `Look_*` and
`Look_Owned*` attributes, "Owned" once owned). Prices are the number alone (`GetProductPrice(…, false)`, with
thousands separators), beside the button's Robux picture. Sets
`TextChatService.OnIncomingMessage` on the client.
