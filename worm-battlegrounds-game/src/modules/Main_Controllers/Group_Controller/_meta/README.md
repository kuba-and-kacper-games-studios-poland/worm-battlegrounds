# Group_Controller

Rewards for joining groups. When a player's group data updates, the server runs each group's reward from `REWARDS_BY_GROUP` once per reward `Version` (saved; claimed before the reward runs, and given back if it fails), and works out their bonus, `GROUP_BONUS` while they are in `GROUP_NAME`. The framework doesn't apply the bonus: each game applies it at the `#TODO` in `Server.lua` (a currency multiplier or anything else).

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Group_Controller` |
| Runs on | Server |
| Uses | `I.Group` (`Group_DataUpdated`, `IsMember`), `I.Player` |
| Saves | `Profile.Group_Controller.SettingsRewardsClaimed` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Group rewards and the group bonus on `Group_DataUpdated`; the game applies the bonus at the `#TODO` |
| `Settings.lua` | `REWARDS_BY_GROUP`, the bonus group and amount |
| `_meta/_types.lua` | `Group_Controller_RewardTableEntry` |

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Group_Controller.SettingsRewardsClaimed[groupName]` | Reward `Version` claimed |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `REWARDS_BY_GROUP` | `{}` | `[groupName] = { Version, Reward(player) -> boolean }`; `Reward` returns `true` when it granted the reward; raising `Version` rewards everyone again |
| `GROUP_NAME` | `"Default"` | Group (a name from `Groups.lua`) whose members get the bonus |
| `GROUP_BONUS` | `0.1` | Bonus for its members (`0.1` = 10%) |
