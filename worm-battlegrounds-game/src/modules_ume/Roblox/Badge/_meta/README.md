# Badge

Roblox badges by name. Badges are defined in `src/global_data/Badge/Badges.lua` with their id and, optionally, the places they can be awarded in and reward functions. The server awards them and runs their rewards: once ever (`SingleReward`, saved with the badge's `Version` so a new version rewards again), once per session (`SessionReward`), or on every character spawn (`CharacterReward`). Every reward a player is owed runs automatically when their character spawns. Ownership is read once per session (batched, 10 badges per request, only for badges with a reward to run here) and kept in the session, and badge info is cached for 5 minutes, so respawns make no web calls.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Badge` |
| Runs on | Server, Global |
| Exposes | `I.Badge` (server), `I.G_Badge` (both) |
| Uses | `BadgeService`, `I.Player`, `I.G_Player`, `I.Topic`, `I.Network`, `I.Config.PlaceLoader` |
| Saves | `Profile.Badge.RewardsClaimed` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Awarding, rewards, the profile and session keys, rewards on character spawn |
| `Global.lua` | Badge info (cached for 5 minutes) and ownership lookups |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `badge` command |
| `_meta/_types.lua` | `Badge_BadgeInfo`, `Badge_BadgesTableEntry`, `Badge_CachedInfo`, `Badge_AwardResult` |

## API

### Server: `I.Badge`

| Function | Returns | What it does |
| --- | --- | --- |
| `Award(player, badgeName: string)` | `boolean`, `Badge_AwardResult` | Awards the badge, when the current place or map is in its `AwardPlaces` (or it has none); tells the client and publishes `Badge_Awarded`. The second value says why: `"Awarded"`, `"AlreadyOwned"`, `"Disabled"`, `"WrongPlace"` or `"Failed"`. A second `Award` of the same badge while one is running fails. |
| `RewardFor(player, badgeName, rewardType: "Single" \| "Session" \| "Character"?, forceReward: boolean?)` | `boolean`, `{ string }?` | Runs the badge's rewards the player is owed (all types, or one), if they own it and the place is in `RewardPlaces`; `forceReward` skips the ownership and claimed checks. Returns the reward types granted. A `SingleReward` or `SessionReward` that errors or returns `false` isn't counted as claimed, so it runs again next time. |
| `RewardForAll(player, rewardType?, forceReward?)` | `{ [string]: { string } }?` | `RewardFor` for every badge the player owns; badge name → granted types |

### Global: `I.G_Badge`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetInfo(badgeName: string)` | `Badge_BadgeInfo?` | Name, description, icon and whether it's enabled (display fields on the client only) |
| `Owns(playerId: number, badgeName: string)` | `boolean` | Whether the user owns the badge (`false` when the request fails) |
| `OwnsMany(userId: number, badgeNames: { string })` | `{ [string]: boolean }?` | Ownership of several badges, 10 per request; `nil` when a request fails. On the client only for the local player. |

## Usage

```lua
I.Badge.Award(player, "FirstWin")
```

## Network

### Server

**Topics**

- `Badge_Awarded @ (player: Player, badgeName: string)`: after a badge is awarded.

**Send: RemoteEvents**

- `Badge_Awarded @ (player: Player, badgeName: string)`

### Client

**Receive: RemoteEvents**

- `Badge_Awarded @ (badgeName: string)`: created by `Global.lua` for client code to listen to; nothing in this module listens.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Badge.RewardsClaimed[badgeName]` | The badge `Version` whose `SingleReward` was claimed |
| Session | `Badge.RewardsClaimed[badgeName]` | Session rewards claimed this session |
| Session | `Badge.Owned[badgeName]` | Ownership read this session |
| Session | `Badge.Awarding[badgeName]` | An `Award` in progress |
| `src/global_data/Badge/Badges.lua` | `[badgeName]` | `Id`, `Version`, `AwardPlaces`, `RewardPlaces` (`PlaceId` or `PlaceId_MapId`), `SingleReward`, `SessionReward`, `CharacterReward` (`(player) -> boolean?`; `false` means not granted) |

## Commands

`badge` (server):

| Subcommand | Arguments |
| --- | --- |
| `award` | `player badgeName` |
| `reward_for` | `player badgeName [rewardType]` |
| `reward_for_all` | `player [rewardType] [forceReward]` |
| `get_info` | `badgeName` |
| `owns by_player` / `by_name` / `by_id` | `player` / `playerName` / `playerId`, then `badgeName` |
