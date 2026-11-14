---
title: "Crates: a coins row and a diamonds row of buy buttons, one set of odds, new prices (1,000 coins or 500 diamonds for ten)"
date: 2026-11-15
status: open
kind: changed
pages: ["Crates", "Weapon crate", "Utility crate", "Skin crate"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Weapon.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Utility.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Skin.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Server.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
---

**What changed.** The GACHA screen no longer switches currency when the coins or diamonds balance at the top right is
pressed: the balances are only displays now. Under the crate there are two rows of buy buttons, coins on top (green)
and diamonds under them (blue). Every shop crate (Weapon, Utility, Skin) costs:

| Crates | Coins (before) | Diamonds (before) |
| --- | --- | --- |
| 1 | 100 (100) | 50 (Weapon 250, Utility 200, Skin 50) |
| 3 | 300 (300) | 150 (Weapon 750, Utility 600, Skin 150) |
| 10 | 1,000 (900) | 500 (Weapon 2,250, Utility 1,800, Skin 450) |

Paying with diamonds rolls the same odds as coins. Before, the Weapon crate's diamonds rolled only Cluster Bomb,
Spider Bomb, Minigun (26 % each), Homing Missile, One Punch (10 %), Variety and Black Hole Grenade (1 %), and the
Utility crate's diamonds rolled 15/15/20/20/20/10; both now roll their coin odds (Weapon: the four commons 14.75 % each,
Cluster, Spider, Minigun 10 %, Homing, One Punch 5 %, Variety, Black Hole 0.5 %). VIP's free daily Skin crate is the
coins row's x1, as before.

**Where.** Each crate row's `Prices` and `Odds` (was `OddsByCurrency`) in `Crates/Data/Crates/`; `VIP_ODDS` is gone.
The buttons are `U_CoinsX1/3/10` and `U_DiamondsX1/3/10` in `S_CoinsRow` and `S_DiamondsRow` (were `U_BuyX1/3/10`); the
Crates gui is exported into the place (the old export in `ServerStorage.!dump.Crates_Gui_Before_2026-11-15`).

**How to check.** Checked in a Studio playtest on 2026-11-15: the Weapon tab shows both rows with these prices and its
coin odds; one Weapon crate for diamonds took 50, three Utility crates for diamonds 150, ten Skin crates for coins 1,000.

**For the wiki.** Crates: the two rows and the prices table; Weapon and Utility crates: one odds table, no diamond
odds. A History line for the change. Supersedes the diamond odds in earlier entries (2026-11-13's one crate per kind).
