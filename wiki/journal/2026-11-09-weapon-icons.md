---
title: "Weapon and utility icons from the studio"
date: 2026-11-09
status: open
kind: changed
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Utilities/
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/
  - worm-battlegrounds-gui/src/themes/WormBattlegrounds/Icons.lua
---

**What changed.** 16 weapons and utilities show the studio's new icons (uploaded 2026-11-09; the source pictures and
ids are in the game home's `assets/ui/icons/items/`, `uploaded.json`):

Bandage 101586916045478, Bazooka 89888640314244, Black hole grenade 126733567159283, Cluster bomb 125982425140000,
Dynamite 99998769993186, Grenade 88613468948489, Homing missile 107350591430267, Jetpack 99911728604760, Medkit
85030401627405, Minigun 93480916921558, Shotgun 104705832389891, Spartan spear 120095788569892, Speed potion
129368162518915, Spider bomb 126313994651146, Uzi 79744307043186, Variety grenade 132575441840814.

Baseball bat, One Punch, Low gravity potion and Parachute keep their old pictures (no new icon came).

**Where.** Arsenal rows' `Icon`, Inventory rows' `IconId` (the Bazooka has no Inventory row), and the theme's
`Icons.lua` (`wb-bazooka`, `black-hole-grenade`, `cluster-bomb`, `grenade`, `jetpack`, `shotgun`).

**For the wiki.** Arsenal: the item pictures (infobox images) for these 16.
