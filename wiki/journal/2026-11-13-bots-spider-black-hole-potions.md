---
title: "Bots carry the spider bomb, Nightmare the black hole, and any bot may roll a potion"
date: 2026-11-13
status: open
kind: added
pages: ["Match modules", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Move.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Sim.lua
---

**What changed.** Bot loadouts (`LOADOUTS`): Medium, Hard and Nightmare also carry the Spider bomb; Nightmare also
carries the Black hole grenade. Every bot but the tutorial's rolls one of `POTIONS` at even odds: none, a Speed potion
or a Low gravity potion. A bot drinks its potion only when the spot it wants needs it: past its walk (Speed: stamina
times SnailControl's `SPEED_MULTIPLIER` 1.5) or up a ledge higher than its jump (Low gravity: a jump under
`LOW_GRAVITY_SCALE` 0.4 of its weight). Such a spot costs the genome's `Ammo` weight, as a limited weapon's use does.
The brain now foresees both weapons: the spider bomb's flight (no wind, stops on what it touches) and its crawl to the
nearest enemy by Combat's own step (`I.Combat.GetCrawlStep`, `CRAWL_PREDICT_STEP` 1/20 s); the black hole's pull
(Combat's `BLACK_HOLE_PULL_SPEED` 45, `PullRadius` 20, the shooter's teammates aside) then its burst where the pulled
snails land. Bots never open a black hole in the air with a second press.

**Where.** Bots' `LOADOUTS`, `POTIONS`, `CRAWL_PREDICT_STEP`; `Server.CreateParticipant` (the roll), `TakeTurn` (the
drink, `I.Combat.UseUtility`); `Predict.GetShot` (`_crawl`, `_getPulls`), `Predict.GetEffects` (pulls first);
`Brain._getSpots` (`Spot.Potion`), `_getPlace`, `_getPotion`; `Move.GetJump(lowGravity)`, `WalkTo`'s walls; the gym's
`Sim._playTurn` takes the potion's use.

**How to check.** A Nightmare head-to-head in Studio's gym (2 matches, 5 rounds, Picnic Plains, seed 7, 2026-11-13)
planned and landed both: spider bombs dealt 61 to 70, a black hole up to 86, no errors. Not seen yet: a bot drinking a
potion in a live match (the gym's seats take `LOADOUTS` only, without the roll).

**For the wiki.** Match modules (Bots): the loadouts, the potion roll and when bots drink. Arsenal: which bots carry
the spider bomb and the black hole.

The genomes weren't retrained: they weigh the new weapons and potions only through the weights they already have.
Nightmare's shipped `Ammo` is -0.096, so a potion-only spot is a tiny bonus for it rather than a cost.
