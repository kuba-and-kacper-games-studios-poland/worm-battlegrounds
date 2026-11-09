---
name: train-bots
description: Train or recalibrate Worm Battlegrounds' bots by self-play in Studio with the Bots module's gym, read what they did well and badly, and ship a better genome for a difficulty (Easy, Medium, Hard or the secret Nightmare). Use only when the owner asks to train, retrain, tune or recalibrate the bots, or to teach them something new the game added (a weapon, a map object such as explosive barrels, a hazard).
argument-hint: <difficulty, e.g. Hard> [generations]
---

# Training the bots

The bots' brain, the gym and every setting are described in `src/modules/Main_Game/Bots/_meta/README.md`: read it
first. A run evolves one difficulty's **genome** (`ServerData/Brains.lua`) by self-play on the real maps, then examines the
champion against the shipped genome. Training happens only when the owner asks for it.

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

## 2. Ready Studio

- The place is open with both projects synced (`.claude/rules/luau/studio.md`), on the **Studio map** (the Workspace
  attribute `Ume_StudioMapId` is `Studio`): the Match map starts a match, and a run needs the arena free.
- Start a play test (`start_stop_play`) and give it a few seconds to boot. Don't start a match while a run goes.

## 3. Run

Run Luau on the **Server** datamodel to set the trigger, with the options as JSON (`Bots_TrainOptions`; the defaults
are `TRAIN_DEFAULTS`):

```lua
workspace:SetAttribute("Bots_Train", '{"Difficulty":"Hard","Generations":8,"Population":10,"MatchesPerGeneration":10,"ExamMatches":10,"Seed":11}')
```

- A full match takes 10 to 40 seconds, so that's about 45 minutes. Poll `workspace:GetAttribute("Bots_TrainStatus")`
  every few minutes with short calls (never one long blocking call); `"stop"` in `Bots_Train` ends it after its match.
- `"Log": true` prints every turn (weapon, target, spot, jetpack, planned score, damage dealt); use it on short runs.
- `"Maps": ["PicnicPlains"]` limits the maps, `"MaxRounds"` shortens matches.
- `"Start": { …genome… }` trains on from a genome (a champion of an earlier run) instead of the shipped one;
  `"Baseline": { … }` is what the exam plays against. `"Generations": 0` with both is a head-to-head: run it to pick
  between two champions.
- **Parallel runs:** one Studio plays one match at a time (one arena). To train several difficulties or seeds at
  once, save the place to a file (the owner saves it; the game home's `saves/`), copy it to the scratchpad once per
  extra run, open each copy in Studio (`Start-Process <copy>.rbxl`), and start a play test and a run in each (each
  Studio has its own `studio_id`). Copies don't sync: save again after code changes. Each Studio takes 1 to 2 GB.

## 4. Read the report

When the status says `Done`, read `ServerStorage.Bots_TrainResult` (JSON) and the Output's `[Bots::Gym]` lines:

- **History:** each generation's best and mean fitness, and how they played: hit rate, hits on their own side, damage
  per shot, knockouts (and how many were throws into the sea or off the arena), how often they moved and flew, heals,
  the weapons they fired. Good runs raise the mean, keep own-side hits low and show thrown knockouts on Hard and up.
- **Exam:** the champion's and the shipped genome's mean points per seat over the exam matches. Ship the champion only
  when it beats the shipped genome; a tie or a loss means the run found nothing better (run longer, or with another
  seed).

## 5. Ship it

1. Paste the report's `Lua` over that difficulty's row in `ServerData/Brains.lua`.
2. StyLua and selene (`AGENTS.md` → Commands), then a playtest with bots of that difficulty to watch them play.
3. Write a wiki journal entry (`../wiki/JOURNAL.md`): the difficulty, the run's options and seed, the exam result,
   and how the play stats changed.
4. Tell the owner what changed, with the numbers. Commit only when asked.
