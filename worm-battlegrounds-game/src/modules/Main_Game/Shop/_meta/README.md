# Shop

The Robux shop and VIP. The client draws the `Shop` widget: the diamond packs (developer products) and the game
passes, each with its live price, bought through ume's Marketplace prompts. The currency bar's **+** opens it through
its tags, and on the Lobby map a top bar button does too. The server marks VIP players (the `Vip` Player attribute,
which gives a gold worm name and a chat tag) and keeps VIP's free skin crate, once per UTC day.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Shop` |
| Runs on | Server, Client · both maps |
| Exposes | `I.Shop` (server) |
| Uses | `I.G_Marketplace`, `I.Replicator`, `I.TopBar`, `I.WidgetManager`, `I.DoEvery`, `TextChatService` |
| Saves | `Profile.Shop` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | VIP, the daily free crate, a check every minute for a new day |
| `Client.lua` | The `Shop` widget, the top bar button, the VIP chat tag |
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
`Marketplace_GamePassPurchaseSucceeded-VIP`.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Shop.VipCrateDay` | The UTC day (`os.time() // 86400`) of the last free crate |
| Replicator `Shop` | `VipCrateReady` | Whether today's free crate waits |
| Player attribute | `Vip` | Whether the player owns VIP (Match copies it to the worm) |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PACKS` | Handful 250, Pouch 500, Bag 1,000, Chest 1,500, Vault 2,500 | `{ Product, Name, Diamonds }` per pack, in order |
| `PACK_ICON` | the local diamond icon | The packs' picture |
| `PASSES` | VIP, Double Coins, Loadout slot 4, Loadout slot 5 | `{ GamePass, Name, Benefits }` per pass, in order |
| `VIP_PASS` | `"VIP"` | The VIP pass's Marketplace name |
| `VIP_CHAT_TAG` | gold `[VIP] ` | Put in front of a VIP player's chat messages |
| `VIP_CHECK_SECONDS` | `60` | How often the server looks for a new day's crate |
| `GUI_NAME` | `"Shop"` | The widget |
| `TOP_BAR_TEXT`, `TOP_BAR_MAPS` | `"SHOP"`, `{ "Lobby" }` | The top bar button, and the maps that show it |

## In the place

Drives the `Shop` widget (`U_Packs` › `PREFAB | Pack`, `U_Passes` › `PREFAB | Pass`). Sets
`TextChatService.OnIncomingMessage` on the client.
