---
title: "Snails are lighter and thrown on the game's own physics"
date: 2026-11-12
status: open
kind: changed
pages: ["Snails", "Knockback", "Movement", "Low gravity potion"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Helpers/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Health.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Bodies.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Effects.lua
---

**What changed.** Snails feel 55 % of gravity, so they fall slower and a blow throws them further and higher, by its
angle, as in Worms. A thrown snail flies the game's own simulation (the one shots use), not Roblox physics: it
bounces softly off what it hits and lands once it rests on the ground. A jump still reaches about 5 studs. The Low
gravity potion still lightens a snail on top of that.

**Where.** Snails' `GRAVITY_SCALE` (0.55), `FLIGHT_BOUNCE` (0.2; 0.3 until the owner asked for less bounce on hit snails, later on 2026-11-12), `FLIGHT_LAND_KEEP` (0.4), `FLIGHT_MAX_SECONDS` (8);
SnailControl's `JUMP_SPEED` 44 → 33. The snail's `FlightFrom`, `FlightVelocity` and `FlightStart` attributes carry a
throw to every screen. Knockback speeds are unchanged (Arsenal's knockback levels).

**How to check.** Hit a snail with the Bazooka: it arcs up and away, floats down, bounces a little and stops.

**For the wiki.** Knockback and Movement: snails are light; a History line. Still unsure: the knockback speeds may
want retuning now that snails fly further; the bots weren't retrained (their jump and throw predictions use the new
gravity).
