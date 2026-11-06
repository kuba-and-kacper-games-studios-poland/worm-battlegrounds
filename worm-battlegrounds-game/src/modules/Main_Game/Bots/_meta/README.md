# Bots

Computer players for solo, public and tutorial matches. Match asks for a bot participant when it fills the seats, and
for a bot's turn when one is active. A bot thinks for a moment, picks a target and a weapon for its difficulty, searches
angles and powers with Combat's arc prediction and raycasts until a shot lands near the target, misses on purpose often
enough to match its `HIT_RATE`, then holds its weapon, swings its crosshair from level to the shot over `AIM_TIME` and
charges its power as a player would (Combat's `CHARGE_SECONDS` for full power; guns and melee weapons skip it), shown
to every player like a player's aim (`I.Combat.ShowAim`), and fires through Combat like a player (falling back to the
Bazooka). The tutorial bot
aims beside the player, never hits, and takes `DAMAGE_TAKEN` times each hit.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Bots` |
| Runs on | Server · Match map |
| Exposes | `I.Bots` (server) |
| Uses | `I.Match`, `I.Combat`, `I.G_Combat`, `I.G_Arsenal`, `I.Worms` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Making bot participants, playing a bot's turn, the shot search |
| `Settings.lua` | `Bots_Settings` |

## API

### Server: `I.Bots`

| Function | Returns | What it does |
| --- | --- | --- |
| `CreateParticipant(difficulty: string, number: number)` | `Match_Participant` | A new bot (`Id` `B_<number>`) with an unused name, its difficulty's loadout and `DamageTaken`. Number 1 starts the name list over |
| `TakeTurn(participantId: string)` | | Plays a bot's turn; gives up quietly when the turn ends meanwhile |

## Network

No remotes: bots fire through `I.Combat.Fire` on the server.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `BOT_NAMES` | a list of names | Picked without repeats in a match |
| `LOADOUTS` | Easy: Grenade, Shotgun · Medium: + Dynamite · Hard: Dynamite, Cluster Bomb, Uzi, Homing Missile, Baseball Bat | Weapons by difficulty (others use Easy's) |
| `THINK_TIME` | `{ 2.5, 4 }` | Seconds a bot thinks before it takes aim |
| `AIM_TIME`, `AIM_STEP` | `1.5`, `0.1` | How long its crosshair swings to the shot (the charge follows), and how often its aim is sent |
| `HIT_RATE` | Easy 0.3, Medium 0.6, Hard 0.85, Tutorial 0 | How often a shot lands where it aimed |
| `DAMAGE_TAKEN` | Tutorial 3 | Damage multiplier on a difficulty's bot (two Bazooka hits, 35 × 3, knock out 200 health) |
| `MISS_ANGLE`, `MISS_POWER` | `0.25`, `0.25` | How far a deliberate miss is off, at most |
| `ANGLE_STEP`, `POWER_STEP` | `6`, `0.1` | The search grid, in degrees and share of power |
| `ARC_SECONDS`, `ARC_STEP` | `4`, `1 / 20` | How far ahead each candidate arc is predicted |
| `SEARCH_BATCH` | `20` | Candidates tried per frame |
| `MELEE_RANGE`, `GUN_RANGE` | `5`, `40` | Distances under which a bot prefers melee, then guns |
