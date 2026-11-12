---
title: "Potions show: an aura on the snail, a coloured vignette on your turn"
date: 2026-11-12
status: open
kind: added
pages: ["Speed potion", "Low gravity potion", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Potions.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/PotionVignette/init.lua
---

**What changed.** A snail under a potion streams particles: a cyan aura for the Speed potion, a violet one for the
Low gravity potion (both at once with both). On the player's own turn, while their snail is under a potion, the
screen's edges glow: cyan for Speed, violet for Low gravity, pink with both. It fades in and out in 0.4 s.

**Where.** Snails' client `Potions` handler; settings `POTION_AURAS`, `POTION_VIGNETTE_SPEED` (70, 200, 255),
`POTION_VIGNETTE_LOW_GRAVITY` (165, 95, 255), `POTION_VIGNETTE_BOTH` (255, 95, 205), `POTION_VIGNETTE_TWEENINFO`; the
place's Vfx prefabs `PREFAB | Aura_Speed` and `PREFAB | Aura_LowGravity`; the `PotionVignette` gui. Driven by the
snail's `SpeedMultiplier` and `LowGravity` attributes, no remote.

**How to check.** Drink a potion on your turn: the edges glow and the snail sparkles; at the next turn it's gone.

**For the wiki.** Speed potion and Low gravity potion: what you see while it lasts.
