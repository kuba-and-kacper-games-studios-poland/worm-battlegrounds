# Bots

Computer players for solo, public, party and tutorial matches. Match asks for a bot participant when it fills the
seats, where each bot parachutes in (`GetStart`), and for a bot's turn when one is active. A bot plays its turn like a
player, through its **brain**: a planner that weighs every plan it can see with a **genome** (the weights in
`Data/Brains.lua`, trained by self-play in the **gym**) and plays it through its difficulty's **skill** (its hand, its
reading of the wind, how far it looks: `SKILLS`).

**A turn.** While it thinks (`THINK_TIME`), the brain makes its plan:

1. **Heal** when its health is under the genome's `HealBelow`, with the heal that fills most of what it's missing.
2. **Spots.** Where it stands, the ground every `MOVE_STEP` studs its walk reaches within its stamina (up a ledge its
   jump reaches), past that the ground its jetpack reaches (up to `CLIMB_MAX` higher, over gaps), and the spots beside
   each target it could swing or place Dynamite from. Each spot knows how near a deadly drop is (`Edge`), how badly a
   blast at its feet would drop it (`Footing`: through thin ground or a floating ledge into the sea), how low it is
   over the sea as sudden death nears (`Low`), its height over the enemies, how many enemies see it or stand near it,
   and how many friends stand near it. The skill's `MapSense` says how much it minds the map's dangers. It keeps the
   `Spots` its genome likes best.
3. **Targets.** Its `Targets` nearest enemies, nearer still when wounded (`Focus`) or the last to hurt it (`Grudge`,
   the snail's `LastAttacker` attribute).
4. **Rough shots.** Every usable weapon from every spot at every target and each of its `AimPoints` on it: the snail,
   its feet, then the ground under it on the side nearer a deadly drop, then the other side (to blast the ground out
   from under it). Arcs are solved exactly with the wind it reads (`Scripts/Server/Aim.lua`) and checked against the
   terrain; guns need a clear line in range; the homing missile is marked on the point; a swing or Dynamite only from
   beside the target. With no shot at anyone at all, it aims at the terrain in the way to a target instead, from the
   spot nearest it (it digs).
5. **Simulation.** The `Finalists` nearest misses are simulated in full (`Scripts/Server/Predict.lua`): the shot flies
   by Combat's own simulation (`I.G_Combat.StepBody`), with bounces, fuses, bomblets, bullets and swings as Combat's
   behaviors do them; its blasts hurt and throw snails as Combat's do; thrown snails are followed to where they land
   (into the sea knocks them out, a long drop costs fall damage), and snails whose ground the craters cut away drop
   through them. Each plan's score is the genome's weighing of what it does (damage and knockouts to enemies, harm to
   friends and itself, the ammo it spends) and of the spot it shoots from.
6. **Choice.** The best plan, or with the skill's `Choice` above 0, a good-enough one more often the better it is.

Then it walks to the spot (flying its jetpack when the spot needs it, or before placing Dynamite), plans again from
where it stands if the walk fell short, holds its weapon, swings its crosshair and charges its power for everyone to
see (`AIM_TIME`, Combat's `CHARGE_SECONDS`), and fires with its hand's error (`AimNoise`, `PowerNoise`), which narrows
by `Ranging` with each shot in a row at the same target from about the same spot, as players walk their shots in.
From placed Dynamite it runs toward the side with more ground, flying when it wears a jetpack. The tutorial bot stays
put and fires the Bazooka beside the nearest enemy, never at it, and takes `DAMAGE_TAKEN` times each hit.

**Difficulties.** Easy, Medium, Hard and the secret Nightmare (only in custom lobbies: `SKILLS`, `LOADOUTS`) share the brain
and differ in their skill and genome. Harder bots read more of the wind, shake less, weigh more spots, targets and
aim points, mind the map more, and always take their best plan.

**The gym** (`Scripts/Server/Gym.lua`, Studio only) trains a difficulty's genome by self-play: a population of
genomes, from the shipped one and mutants of it, plays headless matches against itself (`Scripts/Server/Sim.lua`: the
real arena, craters and sea, stand-in snails that teleport to their spot instead of walking, the same brain, hand and
predictions, turns as Match orders them, sudden death), free-for-alls and 2 v 2s on every map. Each seat scores
`PLACE_POINTS` for its place (a team match: 1 to the winners), plus `DAMAGE_POINTS` for each point of damage it dealt
enemies, less its own side's. The best (`Elites`) carry on, the rest are bred from the better ones and mutated, and
after the last generation the champion sits an exam against the shipped genome. The report says what the bots did
(hits, own-side hits, damage per shot, knockouts and how many were throws into the sea, moves, jetpack use, heals,
weapons) and gives the champion as Lua for `Data/Brains.lua`. The code folder's `train-bots` skill is the procedure.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Bots` |
| Runs on | Server · Match map (the gym: Studio only) |
| Exposes | `I.Bots` (server) |
| Uses | `I.Match`, `I.Combat`, `I.G_Combat`, `I.G_Arsenal`, `I.Snails`, `I.Arena`, `I.Settings["SnailControl"]`, `I.Settings["Snails"]`, `I.Settings["Combat"]`, `I.Settings["Match"]` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Making bot participants, a bot's turn: its view, healing, walking to its plan's spot, aiming, firing, running from Dynamite; the tutorial bot; drop spots |
| `Data/Brains.lua` | Each difficulty's trained genome (`Bots_Genome`) |
| `Scripts/Server/Brain.lua` | The planner: spots and what it knows of them, targets, aim points, rough shots, the full simulations and scores, the choice; heals and drop spots |
| `Scripts/Server/Aim.lua` | Exact arc solutions under wind, where an arc first touches, the hand's error, and the solver's self-check |
| `Scripts/Server/Predict.lua` | What a shot would do: its flight, blasts and strikes, where thrown snails land, the ground along a column and drops through craters |
| `Scripts/Server/Move.lua` | Moving a bot's snail: walking to an X, ledges, jumps, the jetpack, stamina, safe ground and runways |
| `Scripts/Server/Sim.lua` | One headless self-play match for the gym |
| `Scripts/Server/Gym.lua` | Training runs: the trigger, generations, breeding, the exam, the report |
| `Settings.lua` | `Bots_Settings` |
| `_meta/_types.lua` | `Bots_Genome`, `Bots_Skill`, `Bots_View`, `Bots_Snail`, `Bots_Spot`, `Bots_Plan`, `Bots_Shot`, `Bots_Blast`, `Bots_Strike`, `Bots_Effect`, `Bots_Outcome`, `Bots_Ranging`, `Bots_TrainOptions`, `Bots_Seat`, `Bots_Stats` |

## API

### Server: `I.Bots`

| Function | Returns | What it does |
| --- | --- | --- |
| `CreateParticipant(difficulty: string, number: number)` | `Match_Participant` | A new bot (`Id` `B_<number>`) with an unused name, its difficulty's loadout and `DamageTaken`. Number 1 starts the names and the bots' memory over |
| `TakeTurn(participantId: string)` | | Plays a bot's turn; gives up quietly when the turn ends meanwhile |
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
| Workspace attributes | Studio only: `Bots_Train` starts a run (its options as JSON, `{}` for the defaults) or stops one after its match (`"stop"`); `Bots_TrainStatus` shows the run's progress |
| `ServerStorage.Bots_TrainResult` | Studio only: a StringValue with the last run's report (JSON): `Difficulty`, `Minutes`, `History` (each generation's best and mean fitness and how they played), `Exam` (`Champion`, `Baseline`, `Matches`), `ExamPlay`, `Champion`, `Lua` |

A run needs the Studio map with no match playing: it loads each map into the arena and carves it.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `BOT_NAMES` | a list of names | Picked without repeats in a match |
| `LOADOUTS` | Easy: Grenade, Shotgun, Jetpack · Medium: Grenade, Shotgun, Dynamite, Jetpack, Bandage · Hard: Dynamite, Cluster Bomb, Uzi, Homing Missile, Baseball Bat, Jetpack, Medkit · Nightmare: Hard's and a Grenade | What each difficulty takes into a match (others use Easy's) |
| `SKILLS` | Easy, Medium, Hard, Nightmare (below) | Each difficulty's skill (`Bots_Skill`); others use Easy's |
| `THINK_TIME` | `{ 1.2, 2.2 }` | Seconds a bot thinks (and plans) before it moves and takes aim |
| `ACTION_PAUSE` | `0.4` | Its pause after a heal or a walk |
| `AIM_TIME`, `AIM_STEP` | `1.5`, `0.1` | How long its crosshair swings to the shot (the charge follows), and how often its aim is sent |
| `DAMAGE_TAKEN` | Tutorial 3 | Damage multiplier on a difficulty's bot (two Bazooka hits, 35 × 3, knock out 200 health) |
| `POWER_STEPS` | 0.4 to 1 by 0.1 | The powers arcs are solved for (a low and a high arc each) |
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
| `TRAIN_ATTRIBUTE`, `TRAIN_STATUS_ATTRIBUTE`, `TRAIN_RESULT` | `"Bots_Train"`, `"Bots_TrainStatus"`, `"Bots_TrainResult"` | The gym's trigger, progress and report |
| `TRAIN_DEFAULTS` | Hard, 6 generations of 8, 6 matches each, 6 exam matches, 2 elites, mutation 0.35 at 0.35, 14 rounds, seed 0 (the clock), no log | A run's options (`Bots_TrainOptions`; `Maps` limits the maps, `Log` prints every turn, `Start` trains on from a genome instead of the shipped one, `Baseline` is what the exam plays against; with `Generations` 0 the exam is `Start` against `Baseline`) |
| `PLACE_POINTS`, `DAMAGE_POINTS` | `{ 1, 0.45, 0.15, 0 }`, `0.002` | A seat's fitness |
| `SETTLE_LIMIT` | `1.5` | The longest a gym turn waits for cut ground to land |

### Skills

| Difficulty | AimNoise | PowerNoise | WindRead | Ranging (min) | Spots | Targets | Finalists | AimPoints | MapSense | Choice |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Easy | 9° | 0.1 | 0.3 | 0.8 (0.5) | 2 | 1 | 3 | 1 | 0.5 | 0.5 |
| Medium | 4.5° | 0.06 | 0.7 | 0.75 (0.35) | 4 | 2 | 5 | 1 | 0.75 | 0.2 |
| Hard | 1.8° | 0.025 | 1 | 0.7 (0.25) | 7 | 3 | 8 | 3 | 1 | 0 |
| Nightmare | 0.8° | 0.012 | 1 | 0.6 (0.2) | 10 | 4 | 14 | 4 | 1 | 0 |

### The genome

What each weight in `Data/Brains.lua` makes a bot value (positive) or avoid (subtracted):

| Key | What |
| --- | --- |
| `EnemyDamage`, `Knockout`, `Focus`, `Grudge` | Damage to enemies (per 100), each enemy knocked out, damage to wounded enemies, damage to the last to hurt it |
| `AllyDamage`, `AllyKnockout`, `SelfDamage`, `SelfKnockout` | Harm to its own side and itself (subtracted) |
| `Ammo` | A limited weapon's use, by 1 / uses left (subtracted) |
| `Walk`, `Jetpack` | Walking there (share of its stamina) and flying there (subtracted) |
| `Edge`, `Footing`, `Low` | The map's dangers at the spot, times the skill's `MapSense` (subtracted) |
| `Height` | Height over the enemies |
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
