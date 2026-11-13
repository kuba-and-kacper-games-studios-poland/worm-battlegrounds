---
title: "Damage numbers stay where the hit landed"
date: 2026-11-13
status: open
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
---

**What changed.** A damage number rode the hit snail, so a rocket that threw it far carried the number off the screen. Now it's pinned to where the snail was hit.

**Where.** Snails' client `Tags._popDamage` (an Attachment in `Workspace.Terrain`, removed when the pop ends).

**How to check.** Hit a snail with the Bazooka: the number rises where it was hit while the snail flies off.

**For the wiki.** Match screen: damage numbers.

**From.** The testers: "dmg popup missing when i hit with rocket sometimes".
