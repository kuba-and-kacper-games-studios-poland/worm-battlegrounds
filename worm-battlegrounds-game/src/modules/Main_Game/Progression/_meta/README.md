# Progression

Levels from XP. XP is the `XP` statistic; the level is worked out from it, up to `MAX_LEVEL`. Reaching level L takes
`LEVEL_BASE_XP × (L − 1) + LEVEL_STEP_XP × (L − 1) × L / 2` XP in total. MatchRewards adds XP after a match; a level
up shows a toast, updates the Level leaderstat and gives the skin `LEVEL_REWARDS` names for that level.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Progression` |
| Runs on | Server · both maps |
| Exposes | `I.Progression` (server) |
| Uses | `I.Statistic`, `I.Leaderstats`, `I.Inventory`, `I.Notify`, `I.Replicator` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Adding XP, the level, rewards, publishing |
| `ServerSettings.lua` | `Progression_Settings`, under a server name so clients never get the level curve |

## API

### Server: `I.Progression`

| Function | Returns | What it does |
| --- | --- | --- |
| `AddXP(player, amount: number)` | `number, boolean` | Adds XP; returns the level and whether it went up |
| `GetLevel(player)` | `number` | The player's level |

## Network

### Server

**Topics**

- `Progression_LevelUp @ (player: Player, level: number)`

No remotes: the level travels in the Replicator and a Player attribute.

## Data

| Where | Key | What |
| --- | --- | --- |
| Statistic | `XP` | Total XP (saved by the Statistic module) |
| Replicator `Progression` | `Level`, `XPIntoLevel`, `XPForLevel` | For the client's level bars |
| Player attribute | `Level` | Seen by other players (party list, match roster) |
| Leaderstats | `Level` | The player list |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MAX_LEVEL` | `100` | The highest level |
| `LEVEL_BASE_XP`, `LEVEL_STEP_XP` | `100`, `4` | Level 2 takes 104 XP, and each level 4 more than the one before |
| `LEVEL_REWARDS` | 25 Prisoner, 50 FBI Agent, 100 Wizard | The skin item given on reaching a level |
