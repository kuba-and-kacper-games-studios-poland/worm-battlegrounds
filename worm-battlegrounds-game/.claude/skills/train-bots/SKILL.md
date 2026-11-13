---
name: train-bots
description: Train or recalibrate Worm Battlegrounds' bots by self-play with the Bots module's gym (on the PC with the repo's bot-gym, checked in Studio), read what they did well and badly, and ship a better genome for a difficulty (Easy, Medium, Hard or the secret Nightmare). Use only when the owner asks to train, retrain, tune or recalibrate the bots, or to teach them something new the game added (a weapon, a map object such as explosive barrels, a hazard).
argument-hint: <difficulty, e.g. Hard> [generations]
---

# Training the bots

The bots' brain, the gym and every setting are described in `src/modules/Main_Game/Bots/_meta/README.md`: read it
first. A run evolves one difficulty's **genome** (`ServerData/Brains.lua`) by self-play on the real maps, then examines the
champion against the shipped genome. Training happens only when the owner asks for it.

Runs happen on the PC (`../bot-gym/`, its README): the same gym code outside Roblox, about 5 matches a second against
Studio's one every 4 s. Studio sits the champion's last exam before it ships (step 5).

## 1. Teach it what's new (when the game changed)

When the owner asks to recalibrate after the game changed, first make sure the brain can see the change; a run only
tunes the weights of what the brain already knows.

| The game added | Teach the brain |
| --- | --- |
| A weapon | `Predict.GetShot` handles its `Kind` (or it's skipped); give it to a difficulty in `LOADOUTS` |
| A utility | How `Server.lua`'s turn and `Sim._playTurn` use it, and when the brain picks it (a genome key if it's a trade-off) |
| A map object (explosive barrels, mines, bounce pads) | `Predict.GetEffects` (what a blast does to it, what it does back), a spot feature in `Brain._getSpot` if it makes ground dangerous, a target point in `Brain._getAimPoints` if shooting it pays |
| A hazard or a rule (new liquids, sudden death changes, turn length) | `Predict.GetThrow`/`GetDrop`, the spot features, `Sim.Play` |
| A new map | Nothing: the gym plays every map in `ServerStorage_Assets.Arenas` |

A new genome key goes in `Bots_Genome` (`_meta/_types.lua`), every row of `ServerData/Brains.lua`, `GENOME_KEYS` in
`Scripts/Server/Gym.lua`, and the README's genome table. Run a short logged match (step 3, `"Log": true`) to see it
used before a full run.

## 2. Ready the PC gym

- In `../bot-gym/`: `rokit install` once, and `gym.local.json` pointing at a saved copy of the place (the owner saves it
  with File → Save to File As…; again after map changes). Code changes need nothing: it reads the code folder's files.
- After a change to what the engine stands in for (Combat's casts or Ballistics, the Arena's Carver, Debris or
  Liquid, a new kind of map part), run the parity probe in both places first (`../bot-gym/README.md` → Parity) and
  look at the blocks that differ.

## 3. Run

On the PC, from `../bot-gym/` (the report: `runs/<Difficulty>-<seed>.json`, the champion as Lua in the output):

```sh
lune run gym train --difficulty Hard --generations 10 --population 16 --matches 64 --exam 48 --seed 11
```

- `--maps PicnicPlains`, `--max-rounds`, `--start runs/<…>-champion.json` (train on from a champion),
  `--baseline <genome.json>`, `--generations 0` for a head-to-head; `lune run gym match --map X --log` prints every
  turn of one match.
- More matches per genome make the fitness less noisy: a run of 10 generations of 16 with 64 matches each takes a few
  minutes.

### In Studio

For the champion's last exam, or a run in Studio:

- The place is open with both projects synced (`.claude/rules/luau/studio.md`), on the **Studio map** (the Workspace
  attribute `Ume_StudioMapId` is `Studio`): the Match map starts a match, and a run needs the arena free.
- Start a play test (`start_stop_play`) and give it a few seconds to boot. Don't start a match while a run goes.

Run Luau on the **Server** datamodel to set the trigger, with the options as JSON (`Bots_TrainOptions`; the defaults
are `TRAIN_DEFAULTS`):

```lua
workspace:SetAttribute("Bots_Train", '{"Difficulty":"Hard","Generations":8,"Population":10,"MatchesPerGeneration":10,"ExamMatches":10,"Seed":11}')
```

- A match takes about 4 seconds. Poll `workspace:GetAttribute("Bots_TrainStatus")`
  every few minutes with short calls (never one long blocking call); `"stop"` in `Bots_Train` ends it after its match.
- `"Log": true` prints every turn (weapon, target, spot, jetpack, planned score, damage dealt); use it on short runs.
- `"Maps": ["PicnicPlains"]` limits the maps, `"MaxRounds"` shortens matches.
- `"Start": { …genome… }` trains on from a genome (a champion of an earlier run) instead of the shipped one;
  `"Baseline": { … }` is what the exam plays against. `"Generations": 0` with both is a head-to-head: run it to pick
  between two champions.
## 4. Read the report

The PC gym prints each generation and writes `runs/<Difficulty>-<seed>.json`; in Studio, when the status says `Done`,
read `ServerStorage.Bots_TrainResult` (JSON) and the Output's `[Bots::Gym]` lines. Both reports have the same parts:

- **History:** each generation's best and mean fitness, and how they played: hit rate, hits on their own side, damage
  per shot, knockouts (and how many were throws into the sea or off the arena), how often they moved and flew, heals,
  the weapons they fired. Good runs raise the mean, keep own-side hits low and show thrown knockouts on Hard and up.
- **Exam:** the champion's and the shipped genome's mean points per seat over the exam matches. Ship the champion only
  when it beats the shipped genome; a tie or a loss means the run found nothing better (run longer, or with another
  seed).

## 5. Ship it

1. Sit the champion's exam in Studio too: `{"Difficulty": "Hard", "Generations": 0, "Start": {…champion…},
   "ExamMatches": 24}`. Ship it only when it beats the shipped genome there as well.
2. Paste the report's `Lua` over that difficulty's row in `ServerData/Brains.lua`.
3. StyLua and selene (`AGENTS.md` → Commands), then a playtest with bots of that difficulty to watch them play.
4. Write a wiki journal entry (`../wiki/JOURNAL.md`): the difficulty, the run's options and seed, both exams' results,
   and how the play stats changed.
5. Tell the owner what changed, with the numbers. Commit only when asked.
