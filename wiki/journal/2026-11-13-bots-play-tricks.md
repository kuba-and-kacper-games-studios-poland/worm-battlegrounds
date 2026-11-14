---
title: "Bots play tricks: higher air shots, grenade bank shots, bounces into the sea, more wind"
date: 2026-11-13
status: open
kind: changed
pages: ["Match modules", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Sim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Gym.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - bot-gym/engine/boot.luau
---

**What changed.** The owner asked for bots that "play like pros", Nightmare "super op": jetpack shots where the
landing costs nothing or the trade is worth it, grenade bounces and projectile tricks, more use of the wind.

- **Air shots, higher.** A bot with `AirShots` now also weighs hovering as high as its flight goes, not only as high
  as a safe fall: the spot's `Fall` (1 health per stud over Snails' `SAFE_FALL_HEIGHT` 10, at most `MAX_FALL_DAMAGE`)
  counts as its own damage, and as a knockout when it's more than its health left, so it takes the drop only when the
  shot pays for it. Hard now flies too (`AirShots` 2), Nightmare more (6, was 4).
- **Bank shots.** With `Banks`, a bouncing weapon (Grenade, Cluster bomb) whose direct arc at a target misses by more
  than `BANK_MISS` (3) also tries landing `BANK_STEP` (5) studs either side of the target, on a wall `BANK_HEIGHT`
  (6) up past it, then twice as far out, each flown in full: it bounces grenades into holes and round cover. Hard 2,
  Nightmare 6.
- **Bounces into the sea.** The forecast of a thrown snail now flies like Snails' flight (bounces over Combat's
  `REST_SPEED`, a short slide after landing, `KNOCK_SLIDE_SECONDS` 0.25, off an edge too), so a bot sees a blow that
  bounces an enemy off its ledge into the sea and weighs it as a knockout.
- **Wind.** Every difficulty reads more of it (`WindRead` Easy 0.3 → 0.4, Medium 0.7 → 0.8), and arcs are also tried
  at 0.3 power (`POWER_STEPS`), for lobs the wind carries. The gym's wind now holds for a whole round, as the game's
  does, so bots train on a round's wind.
- **Sharper skills.** Medium aims at the feet too (`AimPoints` 2); Hard simulates 10 finalists (was 8); Nightmare
  shakes less (`AimNoise` 0.8° → 0.5°, `PowerNoise` 0.012 → 0.008, `RangingMin` 0.2 → 0.15) and weighs 14 spots and
  24 finalists (were 12 and 16).
- **The gym** rolls each seat's potion as live bots do, and the PC gym's engine provides Combat's `GetCrawlStep`.

**Where.** Bots' `SKILLS` (`Banks`, `StartNoise` new), `BANK_*`, `KNOCK_SLIDE_SECONDS`, `POWER_STEPS`;
`Brain._getAirSpots`, `_getBanks`, `_isBouncing`, `_getPlace` (Fall), `_simulate`; `Predict.GetThrow`; `Sim.Play`
(wind per round); `Gym._playMatch` (potions).

**How to check.** A logged Nightmare match on the PC gym (Picnic Plains, 2026-11-13): 77 % hits, 31 % of shots from
the air, no errors.

**For the wiki.** Bots: the tricks each difficulty plays.

Not done yet: the genomes weren't retrained for this. PC runs (seed 31) found champions for Easy, Medium and Hard
that beat the shipped genomes on the PC's four maps, but Studio's exam over every map (Lakeside Showdown included,
which the PC gym's saved place lacks) had Medium losing 0.607 to 0.737 over 48 matches; on the four PC maps alone
it tied, 0.673 to 0.676. Nothing was shipped; the runs wait for a fresh place file with Lakeside Showdown.
