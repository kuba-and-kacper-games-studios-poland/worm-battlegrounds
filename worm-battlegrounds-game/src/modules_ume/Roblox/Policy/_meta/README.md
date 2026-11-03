# Policy

Roblox's per-player policies (ads, paid random items, external links, trading, commerce…), loaded once when the player joins and kept for the session. Check them before showing anything a player's region or age may not allow. Loading makes up to 4 attempts, 1, 2 and 4 seconds apart, stops when the player leaves, and warns with the player's name when every attempt failed. Until the policy has loaded, and for the whole session when loading failed, every getter returns its fail-safe default: restrictions `true`, permissions `false`, no external link references. The server also writes the policy into the player's Replicator folder, so client code reads it from there.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Policy` |
| Runs on | Server |
| Exposes | `I.Policy` (server) |
| Uses | `PolicyService`, `I.G_Player`, `I.Replicator`, `I.Topic` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Loading each player's policy on join, the fail-safe defaults, the getters, the Replicator folder |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `policy` command |
| `_meta/_types.lua` | `Policy_PlayerPolicy` |

## API

### Server: `I.Policy`

Every function takes the `player`. The value in brackets is what a getter returns until the policy has loaded.

| Function | Returns | What it does |
| --- | --- | --- |
| `GetAll(player)` | `Policy_PlayerPolicy?` | Every loaded policy; `nil` until loaded |
| `GetAllowedExternalLinkReferences(player)` | `{ string }` | External link references the player may see (`{}`) |
| `GetAreAdsAllowed(player)` | `boolean` | `AreAdsAllowed` (`false`) |
| `GetArePaidRandomItemsRestricted(player)` | `boolean` | `ArePaidRandomItemsRestricted` (`true`) |
| `GetIsContentSharingAllowed(player)` | `boolean` | `IsContentSharingAllowed` (`false`) |
| `GetIsEligibleToPurchaseCommerceProduct(player)` | `boolean` | `IsEligibleToPurchaseCommerceProduct` (`false`) |
| `GetIsEligibleToPurchaseSubscription(player)` | `boolean` | `IsEligibleToPurchaseSubscription` (`false`) |
| `GetIsPaidItemTradingAllowed(player)` | `boolean` | `IsPaidItemTradingAllowed` (`false`) |
| `GetIsSubjectToChinaPolicies(player)` | `boolean` | `IsSubjectToChinaPolicies` (`true`) |
| `IsLoaded(player)` | `boolean` | Whether the player's policy has loaded |

## Usage

```lua
-- Server
if I.Policy.GetArePaidRandomItemsRestricted(player) then
	return false
end
I.Topic.Subscribe("Policy_Loaded", Module._onPolicyLoaded) -- (player: Player)

-- Client, I.OnLoaded
local policyRep: Folder? = I.Replicator.GetFolder("Policy")
policyRep:GetAttributeChangedSignal("AreAdsAllowed"):Connect(Module._refreshAds)
```

## Network

No remotes: the client reads its own policy from the Replicator `Policy` folder (Data).

### Server

**Topics**

- `Policy_Loaded @ (player: Player)`: after the player's policy was saved and replicated.

## Data

| Where | Key | What |
| --- | --- | --- |
| Replicator `Policy` folder | `AreAdsAllowed`, `ArePaidRandomItemsRestricted`, `IsContentSharingAllowed`, `IsEligibleToPurchaseCommerceProduct`, `IsEligibleToPurchaseSubscription`, `IsPaidItemTradingAllowed`, `IsSubjectToChinaPolicies` | The player's policy booleans; the fail-safe defaults until it has loaded |
| | `AllowedExternalLinkReferences` | The allowed link references, JSON-encoded (`"[]"` until loaded) |

## Commands

`policy` (server): `get` with one subcommand per getter (`get_are_ads_allowed`, …), each taking a `player`.
