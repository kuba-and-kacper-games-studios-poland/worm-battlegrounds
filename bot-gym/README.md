# Bot gym (PC)

Trains the bots' brains on the PC instead of in Studio. It runs the game's own code (the Bots module's brain, gym and
match simulator, Combat's shot simulation and Arsenal rows, the Arena's carving, falling ground and liquid) in
[Lune](https://github.com/lune-org/lune), a standalone Luau runtime, with stand-ins for the few Roblox engine calls
that code makes. The training logic is the Studio gym's own (`Scripts/Server/Gym.lua`); this folder only plays its
matches on every core at once.

| | Studio gym | PC gym |
| --- | --- | --- |
| Speed | About 4 s a match, one at a time per Studio | About 2 s a match per core, 30 at once: about 5 matches a second |
| Source of truth | The game itself | The same code; the engine's stand-ins measured against Studio (Parity, below) |

Use the PC gym for training runs, then check the champion in Studio (the `train-bots` skill).

## Set up

1. Install Lune from this folder: `rokit install`.
2. Save the place to a file (Studio: File → Save to File As…), for example the game home's `saves/`. The gym reads
   the maps (`Workspace.Ume.ServerStorage_Assets.Arenas`) and the gravity from it. Save it again after map changes.
3. Point the gym at it in `gym.local.json` (not committed), or pass `--place <file>` to every command:

   ```json
   { "Place": "D:/path/to/saves/2026-11-12_bot-gym.rbxl" }
   ```

The game's code is read from `../worm-battlegrounds-game/src` as it is on disk, so code changes need no step.

## Commands

Run them from this folder.

| Command | What |
| --- | --- |
| `lune run gym train --difficulty Hard` | A training run, as Studio's (`Bots_TrainOptions`): `--generations` (8), `--population` (16), `--matches` per generation (3 per genome), `--exam` (24), `--seed`, `--maps A,B`, `--max-rounds`, `--start <genome.json>`, `--baseline <genome.json>`, `--workers` (the cores less two). With `--generations 0` it's a head-to-head of `--start` against `--baseline` |
| `lune run gym match --map PicnicPlains --difficulty Hard --log` | One match, every turn printed |
| `lune run gym parity` | The parity probe (below) into `runs/parity-pc.txt` |
| `lune run gym hashes runs/parity-pc.txt` | The probe report's block hashes, to compare with Studio's |
| `lune run gym block runs/parity-pc.txt "PicnicPlains\|shot" 3` | One block of the report |

A run writes `runs/<Difficulty>-<seed>.json` (the same report as Studio's `Bots_TrainResult`) and
`runs/<Difficulty>-<seed>-champion.json` (for `--start` or `--baseline`), and prints the champion as Lua for
`ServerData/Brains.lua`. `--turn-seconds <n>` adds game time after each turn, so liquids flow further between turns.

## How it works

| File | What |
| --- | --- |
| `gym.luau` | The commands; a run's generations are planned up front and played by `lune run gym worker` processes |
| `engine/boot.luau` | The DataModel and services, the code folder's modules mounted from their files, ume's `I` with the framework pieces those modules use (networking, sounds and effects do nothing), the maps read from the saved place |
| `engine/instance.luau` | Instances: the tree, properties, attributes, Clone, models' pivots |
| `engine/world.luau` | Workspace's casts and overlaps, collision groups, and `SubtractAsync` for the arena's boxes |
| `engine/datatypes.luau` | Vector3 (in 32-bit floats, as Roblox's), Vector2, CFrame, Random, Enum and the rest |
| `engine/scheduler.luau` | `task` and Heartbeat on a virtual clock: waits cost nothing, `os.clock()` reads that clock |
| `parity.luau` | The block hashes for comparing probe reports |

The engine covers what the arena and the bots use: axis-aligned blocks, carved pieces as rectangles on the X/Y plane,
balls. A part the game turns and queries would be seen as its bounding box (none does: the arena's turned parts are
props, which no query sees). Props aren't loaded, so blasts don't cut them; nothing in the bots' world depends on them.
A module the gym doesn't provide stops it with `I.<Name> isn't provided by the gym`: add a stub or the module to
`engine/boot.luau`.

## Parity

The Bots module's `Scripts/Server/Parity.lua` probes the simulation the same way in both places: on every map, four
stand spots, 2,592 shots (every weapon a Nightmare bot carries, at six angles, three powers, with and without wind)
with their blasts, strikes and effects on the snails, the Hard brain's plan for each snail, then the ground and the
liquid after six carves. Compare the two reports after changing the engine or anything it stands in for (Combat's
casts, the Arena's carving or debris):

1. Here: `lune run gym parity`, then `lune run gym hashes runs/parity-pc.txt`.
2. In Studio, on the Studio map in a play test, set the Workspace attribute `Bots_Parity` to `{}` (on the server) and
   wait for `Bots_TrainStatus` to say it's done. The report is in `ServerStorage.Bots_ParityResult`, in parts.
3. Hash Studio's report the same way (the code in `parity.luau`, run with the Studio MCP's `execute_luau` on the
   server) and compare the block hashes; look only at the blocks that differ.

Measured on 2026-11-13 (place saved 2026-11-12):

- **Identical:** the stand spots, every liquid row, the sea levels, and 2,544 of the 2,592 shots.
- **Within 0.55 studs, same damage:** 40 shots, all bouncing ones (grenades, bomblets).
- **Diverged:** 4 shots, on chaotic paths: a grenade's long bounce chain, and a homing hit whose thrown snail lands just
  in or just out of the sea.
- **Plans:** 14 of 16 the same.
- **Ground after carving:** the same on the MapLab maps (Picnic Plains, Desert; Volcano Isle all but a few columns).
  Rockslide Ridge, built by hand on a 1/8-stud grid, differs in where some carved pieces end: Roblox's CSG treats
  slivers off the stud grid its own way. Its ground also differs from one PC run to the next: its parts overlap, and
  the Arena's Carver swaps in pieces in `pairs` order over parts, so which of two overlapping pieces a cast reports
  changes from run to run.
- **Matches:** the shipped Hard brain against itself, 48 matches in Studio and 240 here: 31.7 and 30.4 turns a match,
  hits 44.5 % and 47 %, 16.9 and 18.0 damage a shot, 2.1 knockouts a match in both, the same weapons and heals.

Where they differ, it's in float details Roblox doesn't promise either: which of two parts a cast down their shared
seam reports, and Roblox's CSG on parts off the stud grid. Train here, then sit the champion's exam in Studio before
shipping it.
