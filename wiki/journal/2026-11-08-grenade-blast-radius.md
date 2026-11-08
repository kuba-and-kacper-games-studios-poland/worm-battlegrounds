---
title: "Grenade blast radius 6 → 6.9 (+15%)"
date: 2026-11-08
status: open
kind: changed
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Grenade.lua
---

**What changed.** The Grenade's blast reaches 6.9 studs, up from 6 (15% more). Its damage is unchanged.

**Where.** `BlastRadius` in `Arsenal/Data/Weapons/Grenade.lua`.

**How to check.** `BlastRadius = 6.9`; its `Combat_Explosion` carries radius 6.9.

**For the wiki.** Arsenal: the Grenade's blast radius, a History line.

**From.** The tester's notes ("increase grenade aoe by 15%").
