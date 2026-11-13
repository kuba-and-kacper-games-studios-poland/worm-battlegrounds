# Bots

Computer players for solo, public, party and tutorial matches. Match asks for a bot participant when it fills the
seats, where each bot parachutes in (`GetStart`), and for a bot's turn when one is active, or the turn of a player who
dropped out (Match's `Autopilot`: the bot plays their snail with their loadout at `TAKEOVER_DIFFICULTY` until they
come back). A bot plays its turn like a
player, through its **brain**: a planner that weighs every plan it can see with a **genome** (the weights in
`ServerData/Brains.lua`, trained by self-play in the **gym**) and plays it through its difficulty's **skill** (its hand, its
reading of the wind, how far it looks: `SKILLS`).

**A turn.** While it thinks (`THINK_TIME`), the brain makes its plan:

1. **Heal** when its health is under the genome's `HealBelow`, with the heal that fills most of what it's missing.
2. **Spots.** Where it stands, the ground every `MOVE_STEP` studs its walk reaches within its stamina (step by step:
   up a ledge its jump reaches, never into a wall it can't get over or under a ceiling it can't fit under), past that
   the ground its jetpack reaches (up to `CLIMB_MAX` higher, over gaps, at a height clear of walls and ceilings), and
   the spots beside each target it could swing or place Dynamite from. With its skill's `AirShots`, it also weighs
   spots in the air, hovering on its jetpack (at least `AIR_MIN` studs up, no higher than a safe fall), to shoot from
   mid-flight. Each spot knows how near a deadly drop is (`Edge`), how badly a
   blast at its feet would drop it (`Footing`: through thin ground or a floating ledge into the sea), how low it is
   over the sea as sudden death nears (`Low`), whether terrain within `COVER_HEIGHT` over it shields it from shots
   dropping on it (`Cover`), what standing with its head in a pond would cost (Match's `UNDERWATER_DAMAGE`, counted
   `POND_TURNS` times, as danger), its height over the enemies, how many enemies see it or stand near it, and how many
   friends stand near it. The skill's `MapSense` says how much it minds the map's dangers. It keeps the
   `Spots` its genome likes best.
3. **Targets.** Its `Targets` nearest enemies, nearer still when wounded (`Focus`), the last to hurt it (`Grudge`,
   the snail's `LastAttacker` attribute), or a player rather than a bot (the skill's `Hunt`).
4. **Rough shots.** Every usable weapon from every spot at every target and each of its `AimPoints` on it: the snail,
   its feet, then the ground under it on the side nearer a deadly drop, then the other side (to blast the ground out
   from under it). Arcs are solved exactly with the wind it reads (Combat's `I.Combat.GetArcs` at `POWER_STEPS`) and checked against the
   terrain; guns need a clear line in range; the homing missile is marked on the point; a swing or Dynamite only from
   beside the target. With no arc reaching any target, it aims at the terrain toward each one instead, at points every
   `DIG_STEP` studs along the way from `DIG_MIN` studs off (never over its own head): it digs or blasts its way there.
5. **Simulation.** The `Finalists` nearest misses are simulated in full (`Scripts/Server/Predict.lua`): the shot flies
   by Combat's own simulation (`I.G_Combat.StepBody`) from where Combat would start it (`I.Combat.GetShotStart`),
   with bounces, fuses, bomblets, bullets, swings and flight on through water or lava as Combat's behaviors do them;
   its blasts hurt and throw snails as Combat's do; thrown snails are followed to where they land
   (into the sea knocks them out, a long drop costs fall damage), and snails whose ground the craters cut away drop
   through them. Each plan's score is the genome's weighing of what it does (damage and knockouts to enemies, harm to
   friends and itself, the ammo it spends) and of the spot it shoots from. A shot that hurts no enemy is still worth the
   genome's `Pressure` the nearer it lands to one (none from `PRESSURE_RANGE` studs), so it shoots toward enemies it
   can't reach instead of anywhere; one that knocks out the last enemy is worth `WIN_VALUE` more, so it hurts its own
   side only when that wins the match.
6. **Choice.** The best plan, or with the skill's `Choice` above 0, a good-enough one more often the better it is.

Then it walks to the spot (flying its jetpack when the spot needs it, or before placing Dynamite: it rises first,
keeps `HEADROOM` clear of ceilings and gives up on a wall after `WALL_JUMPS` jumps at it), hovers there for an air
spot while it aims, plans again from
where it stands if the walk fell short, holds its weapon, swings its crosshair and charges its power for everyone to
see (`AIM_TIME`, Combat's `CHARGE_SECONDS`), and fires with its hand's error (`AimNoise`, `PowerNoise`), which narrows
by `Ranging` with each shot in a row at the same target from about the same spot, as players walk their shots in.
From placed Dynamite it runs toward the side with more ground, flying when it wears a jetpack.

**It never passes.** When the brain has no plan at all (at the start of the turn, or again after a walk that fell
short), the bot still fires the Bazooka at the nearest snail not on its team (its `Team` attribute): on the first arc
`I.Combat.GetArcs` gives at `POWER_STEPS`, or, when no arc reaches, on the arc that lands nearest it and not within
`DIG_MIN` of itself (never a shot straight up that falls back on its head). Only with no enemy left does it fire nothing.

The tutorial bot doesn't know how to shoot: it raises the Bazooka at the sky, charges it to
`TUTORIAL_FUMBLE_POWER`, gives up without firing and passes its turn (`I.Match.SkipTurn`), the one bot that does. It
starts with `HEALTH`'s 10 health, so any hit knocks it out.

**Difficulties.** Easy, Medium, Hard and the secret Nightmare (only in custom lobbies: `SKILLS`, `LOADOUTS`) share the brain
and differ in their skill and genome. Harder bots read more of the wind, shake less, weigh more spots, targets and
aim points, mind the map more, and always take their best plan.

**The gym** (`Scripts/Server/Gym.lua`, Studio only) trains a difficulty's genome by self-play: a population of
genomes, from the shipped one and mutants of it, plays headless matches against itself (`Scripts/Server/Sim.lua`: the
real arena, craters and sea, stand-in snails that teleport to their spot instead of walking, the same brain, hand and
predictions, turns as Match orders them, sudden death), free-for-alls and 2 v 2s on every map. Each seat scores
`PLACE_POINTS` for its place (a team match: 1 to the winners), plus `DAMAGE_POINTS` for each point of damage it dealt
enemies, less its own side's. The best (`Elites`) carry on, the rest are bred from the better ones and mutated, and
after the last generation the champion sits an exam against the shipped genome, the two swapping who sits first every
two matches (the first seat moves first, worth about a quarter of a point). The report says what the bots did (hits,
own-side hits, damage per shot, knockouts and how many were throws into the sea, moves, jetpack use, heals, weapons)
and gives the champion as Lua for `ServerData/Brains.lua`. The same gym also runs on the PC, many matches at once: the
repo's `bot-gym/` runs this module's code outside Roblox, and the **parity probe** (`Scripts/Server/Parity.lua`)
checks that both play alike. The code folder's `train-bots` skill is the procedure.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Bots` |
| Runs on | Server · Match map (the gym: Studio only) |
| Exposes | `I.Bots` (server) |
| Uses | `I.Match`, `I.Combat`, `I.G_Combat`, `I.G_Arsenal`, `I.Snails`, `I.Arena`, `I.Settings["SnailControl"]`, `I.Settings["Snails"]`, `I.Settings["Combat"]`, `I.Settings["Match"]` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Making bot participants, a bot's turn: its view, healing, walking to its plan's spot, aiming, firing, running from Dynamite, firing anyway when the brain has no plan (`_fireAnyway`); the tutorial bot; drop spots |
| `ServerData/Brains.lua` | Each difficulty's trained genome (`Bots_Genome`) |
| `Scripts/Server/Brain.lua` | The planner: spots and what it knows of them, targets, aim points, rough shots, the full simulations and scores, the choice; heals and drop spots |
| `Scripts/Server/Aim.lua` | Where an arc first touches, the hand's error, and the self-check of Combat's arc solver (`GetArcs`) |
| `Scripts/Server/Predict.lua` | What a shot would do: its flight, blasts and strikes, where thrown snails land, the ground along a column and drops through craters |
| `Scripts/Server/Move.lua` | Moving a bot's snail: walking to an X, ledges, walls and ceilings, jumps, the jetpack and hovering, stamina, safe ground and runways |
| `Scripts/Server/Sim.lua` | One headless self-play match for the gym |
| `Scripts/Server/Gym.lua` | Training runs: the trigger, generations, breeding, the exam, the report; the parity probe's trigger |
| `Scripts/Server/Parity.lua` | The parity probe: on every map, the same stand spots, shots, plans and carves, as lines of text, for Studio's and the PC gym's to be compared (`bot-gym/README.md` → Parity) |
| `ServerSettings.lua` | `Bots_Settings`, under a server name so clients never get it (practices → Bots stay on the server) |
| `_meta/_types.lua` | `Bots_Genome`, `Bots_Skill`, `Bots_View`, `Bots_Snail`, `Bots_Spot`, `Bots_Plan`, `Bots_Shot`, `Bots_Blast`, `Bots_Strike`, `Bots_Effect`, `Bots_Outcome`, `Bots_Ranging`, `Bots_TrainOptions`, `Bots_Seat`, `Bots_Stats` |

## API

### Server: `I.Bots`

| Function | Returns | What it does |
| --- | --- | --- |
| `CreateParticipant(difficulty: string, number: number)` | `Match_Participant` | A new bot (`Id` `B_<number>`) with an unused name, its difficulty's loadout and `MaxHealth` (`HEALTH`'s, or nil for Snails' `MAX_HEALTH`). Number 1 starts the names and the bots' memory over |
| `TakeTurn(participantId: string)` | | Plays a bot's turn, or a dropped player's (a participant with no `Difficulty` plays at `TAKEOVER_DIFFICULTY`); with no plan it still fires the Bazooka toward the nearest enemy; gives up quietly when the turn ends meanwhile |
| `GetStart(difficulty: string, spots: { Vector3 }, taken: { Vector3 })` | `Vector3` | The land spot a bot parachutes onto: the one its genome likes best (away from deadly edges and thin ground, high, apart from the spots taken) |

## Usage

```lua
-- Match, filling a seat, dropping it, and its turn
local bot = I.Bots.CreateParticipant("Hard", 2)
local spot = I.Bots.GetStart("Hard", landSpots, takenSpots)
task.spawn(I.Bots.TakeTurn, bot.Id)
```

## Network

No remotes: bots move their server-owned snails and fire through `I.Combat` on the server. They read the snail
attributes (`Health`, `Team`, `Stamina`, `LastAttacker`) and the match's `Round`.

## In the place

| Where | What |
| --- | --- |
| `Workspace.Ume.Bots` | Studio only: the gym's folder, its stand-in snails in `Snails` (anchored balls in the `Snail` group, named `G_<seat>`, only during a run) |
| Workspace attributes | Studio only: `Bots_Train` starts a run (its options as JSON, `{}` for the defaults) or stops one after its match (`"stop"`); `Bots_Parity` runs the parity probe (`{}` for every map, or `{"Maps": [...]}`); `Bots_TrainStatus` shows the progress of either |
| `ServerStorage.Bots_TrainResult` | Studio only: a StringValue with the last run's report (JSON): `Difficulty`, `Minutes`, `History` (each generation's best and mean fitness and how they played), `Exam` (`Champion`, `Baseline`, `Matches`), `ExamPlay`, `Champion`, `Lua` |
| `ServerStorage.Bots_ParityResult` | Studio only: a Folder with the last parity probe's report, its lines in StringValues named `1`, `2`… (each under `PARITY_CHUNK` characters) |

A run or a probe needs the Studio map with no match playing: it loads each map into the arena and carves it.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `BOT_NAMES` | a list of names | Picked without repeats in a match |
| `LOADOUTS` | Easy: Grenade, Shotgun, Jetpack · Medium: Grenade, Shotgun, Dynamite, Jetpack, Bandage · Hard: Dynamite, Cluster Bomb, Uzi, Homing Missile, Golf Club, Jetpack, Medkit · Nightmare: Hard's and a Grenade | What each difficulty takes into a match (others use Easy's) |
| `SKILLS` | Easy, Medium, Hard, Nightmare (below) | Each difficulty's skill (`Bots_Skill`); others use Easy's |
| `TAKEOVER_DIFFICULTY` | `"Medium"` | The difficulty a bot plays a dropped player's snail at, with that player's own loadout |
| `THINK_TIME` | `{ 0.8, 1.5 }` | Seconds a bot thinks (and plans) before it moves and takes aim |
| `ACTION_PAUSE` | `0.4` | Its pause after a heal or a walk |
| `AIM_TIME`, `AIM_STEP` | `1.2`, `0.1` | How long its crosshair swings to the shot (the charge follows), and how often its aim is sent |
| `HEALTH` | Tutorial 10 | The health a difficulty's bot starts with, where it isn't Snails' `MAX_HEALTH` (any hit knocks the tutorial bot out) |
| `TUTORIAL_FUMBLE_POWER` | `0.3` | How far the tutorial bot charges its Bazooka before it gives up without firing |
| `POWER_STEPS` | 0.4 to 1 by 0.1 | The powers arcs are solved for (a low and a high arc each), for plans and for a shot fired with no plan |
| `ARC_SECONDS`, `ARC_STEP` | `4`, `1 / 20` | How far ahead a rough arc is checked against the terrain |
| `PREDICT_SECONDS` | `6.4` | A full simulation's longest flight, in the shot's own (slowed) time |
| `THINK_SLICE` | `0.008` | Seconds of planning before it gives the server a frame |
| `MOVE_STEP`, `CLIMB_MAX` | `4`, `14` | How far apart the spots it weighs are, and how high its jetpack takes it |
| `MELEE_GAP`, `DYNAMITE_GAP`, `CLOSE_HEIGHT` | `3`, `2`, `3` | Where it stands to swing or place Dynamite, and how level with the target |
| `EDGE_LOOK`, `HEIGHT_SCALE`, `SIGHT_RANGE`, `CROWD_RANGE` | `10`, `20`, `60`, `8` | What a spot knows: deadly drops within this far, a full point of height per this many studs, who sees it within this far, who stands within this far |
| `UNDERMINE_RADIUS`, `LOW_RANGE`, `URGENCY_ROUNDS` | `6`, `15`, `3` | A spot's footing is judged by a blast this big at its feet; ground this close over the sea is low, more so from this many rounds before sudden death |
| `UNDER_SIDE`, `UNDER_DEPTH` | `4`, `2` | Where under a target it aims to blast the ground away: this far to its side, this far below its feet |
| `KNOCK_SECONDS`, `KNOCK_STEP` | `3`, `1 / 30` | How long, and in what steps, a thrown snail is followed |
| `MOVE_SECONDS`, `ARRIVE_DISTANCE`, `STUCK_DISTANCE`, `STUCK_SECONDS`, `LAND_SECONDS` | `4`, `0.75`, `0.3`, `0.8`, `2` | A walk's longest time, how close counts as there, when it's stuck, and how long it waits to land before aiming |
| `WALK_LOOK`, `FALL_LOOK` | `1`, `60` | How far past its ball it checks the ground before a step, and how far down |
| `CLOSE_SLACK` | `1.5` | A walk that ends this much further off than planned makes it plan again from there |
| `ESCAPE_HEIGHT` | `8` | How high it flies over its placed Dynamite with a jetpack on |
| `COVER_HEIGHT`, `POND_TURNS` | `12`, `3` | Terrain this close over a spot is cover; a pond's damage counts this many turns |
| `PRESSURE_RANGE`, `WIN_VALUE` | `30`, `6` | How far from an enemy a shot is still worth its `Pressure`; what knocking out the last enemy adds |
| `DIG_MIN`, `DIG_STEP` | `10`, `8` | Where it aims at the terrain toward a target it can't reach: from this far off, this far apart |
| `HEADROOM`, `WALL_JUMPS`, `AIR_MIN` | `1.5`, `2`, `5` | Flying: room kept under ceilings, jumps at a wall before giving up, and an air spot's least height |
| `TRAIN_ATTRIBUTE`, `TRAIN_STATUS_ATTRIBUTE`, `TRAIN_RESULT` | `"Bots_Train"`, `"Bots_TrainStatus"`, `"Bots_TrainResult"` | The gym's trigger, progress and report |
| `TRAIN_DEFAULTS` | Hard, 6 generations of 8, 6 matches each, 6 exam matches, 2 elites, mutation 0.35 at 0.35, 14 rounds, seed 0 (the clock), no log | A run's options (`Bots_TrainOptions`; `Maps` limits the maps, `Log` prints every turn, `Start` trains on from a genome instead of the shipped one, `Baseline` is what the exam plays against; with `Generations` 0 the exam is `Start` against `Baseline`) |
| `PLACE_POINTS`, `DAMAGE_POINTS` | `{ 1, 0.45, 0.15, 0 }`, `0.002` | A seat's fitness |
| `SETTLE_LIMIT` | `1.5` | The longest a gym turn waits for cut ground to land |
| `GYM_THINK_SLICE` | `0.1` | Seconds the gym's bots think before giving the server a frame |
| `PARITY_ATTRIBUTE`, `PARITY_RESULT`, `PARITY_CHUNK` | `"Bots_Parity"`, `"Bots_ParityResult"`, `150000` | The parity probe's trigger, its report's folder, and the most characters in each of its StringValues |

### Skills

| Difficulty | AimNoise | PowerNoise | WindRead | Ranging (min) | Spots | Targets | Finalists | AimPoints | MapSense | Choice | AirShots | Hunt |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Easy | 9° | 0.1 | 0.3 | 0.8 (0.5) | 2 | 1 | 3 | 1 | 0.5 | 0.5 | 0 | 0 |
| Medium | 4.5° | 0.06 | 0.7 | 0.75 (0.35) | 4 | 2 | 5 | 1 | 0.75 | 0.2 | 0 | 0 |
| Hard | 1.8° | 0.025 | 1 | 0.7 (0.25) | 7 | 3 | 8 | 3 | 1 | 0 | 0 | 0 |
| Nightmare | 0.8° | 0.012 | 1 | 0.6 (0.2) | 12 | 4 | 16 | 4 | 1 | 0 | 4 | 0.5 |

### The genome

What each weight in `ServerData/Brains.lua` makes a bot value (positive) or avoid (subtracted):

| Key | What |
| --- | --- |
| `EnemyDamage`, `Knockout`, `Focus`, `Grudge` | Damage to enemies (per 100), each enemy knocked out, damage to wounded enemies, damage to the last to hurt it |
| `Pressure` | A shot that hurts no enemy landing near one (`PRESSURE_RANGE`) |
| `AllyDamage`, `AllyKnockout`, `SelfDamage`, `SelfKnockout` | Harm to its own side and itself (subtracted) |
| `Ammo` | A limited weapon's use, by 1 / uses left (subtracted) |
| `Walk`, `Jetpack` | Walking there (share of its stamina) and flying there (subtracted) |
| `Edge`, `Footing`, `Low` | The map's dangers at the spot, times the skill's `MapSense` (subtracted) |
| `Height`, `Cover` | Height over the enemies, terrain over its head |
| `Exposure`, `Crowd`, `Threat` | Enemies seeing it, friends near it, enemies near it (subtracted) |
| `HealBelow` | The health under which it heals |

## Limits

- The gym's matches are a shortcut of real ones: stand-in snails teleport to their spot (a real walk can fall short,
  and the bot plans again), and a thrown snail lands where Predict's throw says (no rolling or bouncing). A floating
  ledge's smaller piece falling after a cut isn't foreseen, only ground cut away under a snail.
- The brain foresees the Bazooka, Spartan spear, Grenade, Cluster bomb, Variety grenade's blast, Dynamite, guns,
  swings and the homing missile. It skips weapons whose shot it can't foresee (the spider bomb, the black hole
  grenade): no loadout gives them to bots.
- New things in the game (weapons, map objects such as explosive barrels, hazards, utilities) need the brain and the
  predictor taught about them, then a new training run. That's done only when the owner asks for it.
