# Progression

Levels from XP, the lobby's level plate, the XP replay after a match, and the prestige frames.

XP is the `XP` statistic; the level is worked out from it, up to `MAX_LEVEL`. Reaching level L takes
`LEVEL_BASE_XP × (L − 1) + LEVEL_STEP_XP × (L − 1) × L / 2` XP in total. MatchRewards adds XP after a match, line by
line (playing, a win, knockouts), and queues those lines for the lobby. A level up shows a toast, updates the Level
leaderstat and gives the skin `LEVEL_REWARDS` names for that level.

In the lobby, the `LevelPlate` gui shows the player's level at the top centre, on the currency slots' plate: a diamond
with the level number in the colours of their prestige frame, `LEVEL n`, `into / for XP`, the bar, and the next thing a level opens (a frame, an
emote to buy, a level skin). When they come back from a match that gave XP, the plate moves to the middle over the
dimmed lobby, each XP line pops in with a chime and fills the bar with rising ticks and sparks flying into it, every
level-up bursts with stars, LEVEL UP! and what it opened (a new frame first, with its own sting), and then the plate
flies back. A tap, click or A skips the rest. The client then tells the server, which forgets the replay.

Prestige frames are tiers of a player's level (`FRAME_TIERS`): Rookie (1), Bronze (5), Silver (15), Gold (25), Emerald
(50), Diamond (75), Mythic (100). Each is a set of rim colours; Gold and up sweep a light across the rim every few
seconds, and Mythic's colours spin round. `I.G_Progression.ApplyFrame` paints any UIGradient (on a stroke picture or a
fill) in a level's tier; the party cards and the plate use it.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Progression` |
| Runs on | Server, client and both (Global) · both maps; the plate shows in the lobby only |
| Exposes | `I.Progression` (server), `I.G_Progression` (both) |
| Uses | `I.Statistic`, `I.Leaderstats`, `I.Inventory`, `I.Notify`, `I.Replicator`, `I.AdminPanel_CommandBar`, `I.G_Cosmetics`, `I.G_Inventory`, `I.UIEmitter`, `I.Sound`, `I.Utils` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Adding XP, the level, rewards, publishing, the saved replay |
| `Client.lua` | The lobby's level plate and the XP replay |
| `Global.lua` | Prestige frames (`ApplyFrame`, `GetTier`, the shine and spin) and the next unlock |
| `Settings.lua` | `Progression_Settings`: what both sides read (level rewards, frames, the plate and the replay) |
| `ServerSettings.lua` | `Progression_ServerSettings`, under a server name so clients never get the level curve |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `progression` command |
| `_meta/_types.lua` | `Progression_Progress`, `Progression_XpLine`, `Progression_Replay`, `Progression_Tier` |

## API

### Server: `I.Progression`

| Function | Returns | What it does |
| --- | --- | --- |
| `AddXP(player, amount: number)` | `number, boolean` | Adds XP; returns the level and whether it went up |
| `AddLevels(player, levels: number)` | `number, boolean` | Adds the XP those levels take (to `MAX_LEVEL` at most), through `AddXP`, so their rewards and toast come too; returns the level and whether it went up |
| `SetReplay(player, replay: Progression_Replay)` | | Saves the XP lines, level before and after, and fills in each level's cost on the way (`Costs`), for the lobby to play back; replicates it |
| `GetLevel(player)` | `number` | The player's level |
| `GetProgress(player)` | `Progression_Progress` | The level, the XP into it and the XP it takes (0 at `MAX_LEVEL`) |
| `GetReplay(player)` | `Progression_Replay?` | The replay still waiting, or nil |

### Both: `I.G_Progression`

| Function | Returns | What it does |
| --- | --- | --- |
| `ApplyFrame(gradient: UIGradient, level: number)` | | Paints the gradient in the level's tier; on clients a tier that shines or spins keeps moving while the gradient is shown |
| `GetTier(level: number)` | `Progression_Tier` | The highest tier the level has unlocked |
| `GetNextUnlock(level: number)` | `string?, number?` | What the next level with an unlock opens ("Silver frame", "Dance emote", "Prisoner skin", joined with "and"), and that level; nil at the top |

## Network

### Server

**Topics**

- `Progression_LevelUp @ (player: Player, level: number)`

**Receive: RemoteEvents**

- `Progression_ReplaySeen @ (player: Player)`: the lobby played the replay; the server forgets it.

The level and the replay travel in the Replicator and a Player attribute.

## Data

| Where | Key | What |
| --- | --- | --- |
| Statistic | `XP` | Total XP (saved by the Statistic module) |
| Profile `Progression` | `Replay` | The XP replay the lobby hasn't played, a JSON `Progression_Replay` ("" when none), so it survives the teleport back |
| Replicator `Progression` | `Level`, `XPIntoLevel`, `XPForLevel` | The plate and the bars |
| Replicator `Progression` | `Replay` | The saved replay's JSON |
| Player attribute | `Level` | Seen by other players (party list, match roster, frames) |
| Leaderstats | `Level` | The player list |

## Settings

`ServerSettings.lua`:

| Key | Default | What |
| --- | --- | --- |
| `MAX_LEVEL` | `100` | The highest level |
| `LEVEL_BASE_XP`, `LEVEL_STEP_XP` | `100`, `4` | Level 2 takes 104 XP, and each level 4 more than the one before |

`Settings.lua`:

| Key | Default | What |
| --- | --- | --- |
| `LEVEL_REWARDS` | 25 Prisoner, 50 FBI Agent, 100 Wizard | The skin item given on reaching a level |
| `FRAME_TIERS` | Rookie 1, Bronze 5, Silver 15, Gold 25, Emerald 50, Diamond 75, Mythic 100 | Each tier's name, level, rim colours, `Shine` and `Spin` |
| `FRAME_SHINE_SECONDS`, `FRAME_SHINE_PAUSE` | `1.2`, `2` | A shining rim's light sweep, then the pause before the next |
| `FRAME_SPIN_SPEED` | `120` | Degrees a second Mythic's colours turn |
| `PLATE_POSITION`, `REPLAY_POSITION`, `REPLAY_SCALE` | top centre, `0.5, 0.3`, `1.8` | The plate at rest, and where and how big it shows during the replay |
| `PLATE_TWEENINFO`, `PLATE_BACK_TWEENINFO` | Back 0.55 s, Quad 0.5 s | The plate moving to the middle and back |
| `REPLAY_DIM` | `0.45` | How dark the lobby gets behind the replay |
| `REPLAY_DELAY` | `1.2` | Seconds after the lobby shows before the replay starts |
| `REPLAY_LINE_GAP`, `REPLAY_FILL_SECONDS` | `0.35`, `0.9` | Between lines, and the longest a line takes to fill the bar |
| `REPLAY_TICKS`, `REPLAY_TICK_PITCH` | `14`, `0.9` to `1.6` | Ticks per line, their pitch from empty to full |
| `REPLAY_LEVEL_HOLD`, `REPLAY_END_HOLD` | `1.6`, `1.2` | How long a level-up and the end hold |
| `FRAME_UNLOCK_LEAD` | `0.5` | The new frame's sting swells this long before its hit, where the burst lands |
| `REPLAY_TEXTURES`, `REPLAY_SPARKS`, `REPLAY_STARS`, `REPLAY_COLORS` | the crates' spark and star, `10`, `60`, gold, white, orange | The replay's particles |

Sounds: `Xp_Line`, `Xp_Tick`, `Level_Up`, `Frame_Unlock` (SoundsList; stand-ins until the sound kit's 17 Nov set is
approved and uploaded).

## Commands

`progression` (server, level 255):

| Subcommand | Arguments |
| --- | --- |
| `add_level` | `player`, `levels` (a whole number above 0) |
