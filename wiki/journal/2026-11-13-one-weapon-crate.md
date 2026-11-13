---
title: "One Weapon crate, paid in coins or diamonds; the Premium crate is hidden"
date: 2026-11-13
status: open
kind: changed
pages: ["Crates", "Currencies & crates", "Shop"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Weapon.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Premium.lua
---

**What changed.** The Weapon crate takes coins (100, 300, 900, its old odds) or diamonds (250, 750, 2,250), and its diamond odds are the old Premium crate's: Cluster, Spider, Minigun 26 % each; Homing, One Punch 10 %; Variety, Black Hole 1 %. The Premium crate's tab is gone (`Hidden = true`; its row stays so its id is known). Utility and Skin already took both.

**Where.** The two crate rows in Crates' `Data/Crates`.

**How to check.** The crates screen shows Weapons, Utility, Skins; Weapons has a diamonds chip, with the premium odds.

**For the wiki.** Crates and Currencies & crates: the crate list, prices and odds.

**From.** The testers: "make one crate for premium and regular utilities and make it for both diamond and coins". Read as the Weapon and Premium crates becoming one, as Utility already was; unsure.
