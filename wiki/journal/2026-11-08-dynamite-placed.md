---
title: "Dynamite is placed at your feet, 4× bigger, with 3 s and full stamina to run"
date: 2026-11-08
status: open
kind: changed
pages: ["Arsenal", "Controls & platforms", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Dynamite.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/_meta/_types.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Control.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds.rbxl
---

**What changed.** Dynamite is no longer thrown: firing drops it where the snail stands, with no aim or charge. The
stamina bar fills up again and the player keeps control of their snail for 3 s to run, then the turn ends; the fuse
goes off 3.5 s after it was placed. It no longer bursts on contact. The placed stick is 4× the old one (6.4 studs
tall); the stick the snail holds in its hand is the old size. Damage, blast radius, uses and cooldown are unchanged.

**Where.** Dynamite's row: `Kind = "Bouncer"`, `Aim = "Feet"`, `MinSpeed` and `MaxSpeed` 0, `Fuse = 3.5`,
`Elasticity = 0.2`, `Retreat = 3` (a new row field, typed in `Arsenal/_meta/_types.lua`). `Fire` starts a `Feet`
weapon at the snail's root and, for a row with `Retreat`, calls `I.SnailControl.Retreat(participantId, row.Retreat)`
instead of `EndTurn`; `Retreat` refills `Stamina` to `STAMINA_STUDS` and ends control after 3 s. `Bouncer` takes the
snail back before the blast if it's still running. `Turns.RunTurn` now ends control after the shot resolves. The model
is `Workspace.Ume.ReplicatedStorage_Assets.Arsenal.Projectiles.Dynamite` in the place (4× the held model's scale,
RootPart half a stud above its bottom): saved only once the owner saves the place.

**How to check.** Place it in a match: the snail can walk away for 3 s with a full stamina bar, and the blast comes at
3.5 s. A bot placed one and ran in Studio (2026-11-08).

**For the wiki.** Arsenal: Dynamite's row (placed, 3.5 s fuse, 3 s to run with full stamina), a History line.
Controls & platforms: Dynamite needs no aim.

**From.** The tester's notes ("increase dynamite size by 4x", "tnt is placeable only on you; reset stamina after it's
placed and give the player 3 s to run").
