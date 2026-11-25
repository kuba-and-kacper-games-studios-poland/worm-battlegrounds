---
title: "Eight items disabled: out of the crates, hidden from new players"
date: 2026-11-25
status: open
kind: removed
pages: ["Arsenal", "Shop", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Weapon/BlackHoleGrenade.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Weapon/Dynamite.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Weapon/Minigun.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Weapon/OnePunch.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Weapon/SpartanSpear.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Utility/Parachute.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Utility/SpeedPotion.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Utility/LowGravityPotion.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Weapon.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Premium.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Utility.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Picker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
---

**What changed.** The owner kept eleven items: Variety Grenade, Homing Missile, Medkit, Cluster Bomb, Jetpack,
Spider Bomb, Bandage, Golf Club (`BaseballBat`), Uzi, Grenade and Shotgun. The rest are disabled: Black Hole Grenade,
Dynamite, Minigun, One Punch, Spartan Spear, Parachute, Speed Potion and Low Gravity Potion. No crate rolls them, and
the loadout picker no longer shows them as locked cards to players who don't own them. Players who already have one
keep it: it still shows in their picker, they can equip it and use it in matches.

**Where.** The item rows' new `Disabled = true` (`Inventory_ItemData.Disabled`); the picker's filter in
`Picker.lua`. The crates' odds, the kept items scaled up by the same factor so they add up to 100:

| Crate | Before | After |
| --- | --- | --- |
| Weapon | Uzi, Golf Club, Dynamite, Spartan Spear 14.75; Cluster, Spider, Minigun 10; Homing, One Punch 5; Variety, Black Hole 0.5 | Uzi, Golf Club 26.82; Cluster, Spider 18.18; Homing 9.09; Variety 0.91 |
| Premium (hidden) | Cluster, Spider, Minigun 26; Homing, One Punch 10; Variety, Black Hole 1 | Cluster, Spider 41.27; Homing 15.87; Variety 1.59 |
| Utility | Parachute, Bandage 27.5; Jetpack, Speed 15; Medkit 10; Low Gravity 5 | Bandage 52.38; Jetpack 28.57; Medkit 19.05 |

Grenade and Shotgun stay the tutorial's gift (`Tutorial` crate's `Fixed`), in no rolling crate, as before.

**How to check.** The crates screen's odds list shows only the kept items; a fresh profile's weapon picker lists no
disabled item; an admin `give Dynamite` makes it show again in that player's picker.

**For the wiki.** Arsenal: mark the eight as no longer obtainable (kept by those who have them). Shop: the crates'
new odds.

**Bots.** The bots carry no disabled item either (Bots' `LOADOUTS`, `POTIONS` in `ServerSettings.lua`):

| Difficulty | Before | After |
| --- | --- | --- |
| Easy | Grenade, Shotgun, Jetpack | unchanged |
| Medium | Grenade, Shotgun, Dynamite, Spider Bomb, Jetpack, Bandage | Grenade, Shotgun, Spider Bomb, Jetpack, Bandage |
| Hard | Dynamite, Cluster Bomb, Uzi, Homing Missile, Golf Club, Spider Bomb, Jetpack, Medkit | the same without Dynamite |
| Nightmare | Hard's, Grenade, Black Hole, Spartan Spear, One Punch | Hard's and Grenade |

Every bot rolled none, a Speed potion or a Low gravity potion at even odds; now none (`POTIONS = { "" }`). A bot
that takes over a dropped player's snail still plays that player's own loadout. Nightmare is weaker for it; the
brains weren't retrained.
