---
title: "Icons for the Golf club and Low gravity potion, and a redrawn Speed potion"
date: 2026-11-12
status: open
kind: added
pages: ["Golf club", "Low gravity potion", "Speed potion"]
files:
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Weapon/BaseballBat.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Utility/LowGravityPotion.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Utility/SpeedPotion.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Utilities/LowGravityPotion.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Utilities/SpeedPotion.lua
---

**What changed.** The studio's new pictures: the Golf club (image 74452433921921), the Low gravity potion
(124337153270952; it had a placeholder before) and a redrawn Speed potion (106475672506690). Uploaded to The Snail
Studio group after PrepKit's pixel-fix. The Low gravity potion also has a model now (the studio's `gravity_potion`
bottle, `Arsenal.Models.LowGravityPotion` in the place).

**Where.** `IconId` in the Inventory rows, `Icon` in the Arsenal rows; the game home's `assets/ui/icons/items/` card
and `uploaded.json`.

**How to check.** The loadout, crates and HUD slots show the three pictures.

**For the wiki.** The three items' infobox pictures.
