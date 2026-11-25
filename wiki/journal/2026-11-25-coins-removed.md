---
title: "Coins removed: diamonds are the only currency (rewards and prices halved at 2:1)"
date: 2026-11-25
status: open
kind: removed
pages: ["Shop", "Arsenal", "Emotes", "Matches", "Tutorial", "Loadout"]
files:
  - worm-battlegrounds-game/src/modules/Main/2_Currency/Settings.lua
  - worm-battlegrounds-game/src/modules/Main/2_Currency/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Scripts/Client/Payout.lua
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Data/Emotes/
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Currency/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Shop/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/init.lua
---

**What changed.** Coins are gone; diamonds are the only currency (earned in matches and the tutorial, bought with
Robux, spent on crates, emotes and loadout slots). Every coin amount became half as many diamonds, the crates' rate
(100 coins or 50 diamonds), halves rounded up. A player's saved coins turn into diamonds once on their next join, 2
coins for 1 diamond rounded up (Currency's `CONVERSIONS`).

| What | Before (coins) | Now (diamonds) | Where |
| --- | --- | --- | --- |
| Public deathmatch, 2 players | 50, 15 | 25, 8 | MatchRewards `DEATHMATCH_DIAMONDS` |
| Public deathmatch, 4 | 100, 50, 25, 15 | 50, 25, 13, 8 | same |
| Public deathmatch, 6 | 125, 75, 50, 30, 20, 15 | 63, 38, 25, 15, 10, 8 | same |
| Public deathmatch, 8 | 150, 100, 70, 50, 35, 25, 20, 15 | 75, 50, 35, 25, 18, 13, 10, 8 | same |
| Team matches (2, 3, 4 teams) | 100/15; 100/50/15; 100/60/30/15 | 50/8; 50/25/8; 50/30/15/8 | `TEAM_DIAMONDS` |
| Winning a 2v2 | 75 | 38 | `TEAM_2V2_WIN` |
| Solo win Easy/Medium/Hard | 20/35/60 | 10/18/30 | `SOLO_DIAMONDS`, MatchBoard `SOLO_WIN_DIAMONDS` |
| Tutorial | 100 | 50 | Tutorial `MATCH_DIAMONDS` |
| Emotes (Thumbs up … Victory Trumpet) | 100, 250, 500, 900, 1400, 1900, 2400, 3000 | 50, 125, 250, 450, 700, 950, 1200, 1500 | emote rows' `Diamonds` |
| Loadout slots 2–6 | 750, 2000, 5000, 12000, 25000 (set that morning) | 375, 1000, 2500, 6000, 12500 | Loadout `DIAMOND_SLOT_PRICES` |
| Crates | 100/300/1000 coins or 50/150/500 diamonds | 50/150/500 diamonds only | crate rows' `Prices` |

Party matches pay as before relative to deathmatch (half without bots). The Double Coins pass is now **Double
Diamonds** (same pass id; its Creator Hub name and picture still say coins). The lobby payout flies diamonds into the
diamonds counter (`DIAMONDS_PER_ICON` 5, so as many icons as before). The coin chip left the top-right bar, the shop
and the crates screen (one row of diamond buttons, centred in the space the two rows took: `U_BottomCenter`'s list centres it since the owner's "we can center them now"), and the knocked-out and results screens say "+N diamonds". VIP's
free daily crate now sits on the diamond row's x1, shown alone where paid random items are restricted by policy.

**How to check.** In Studio: a profile with a `Currency.Currencies.Coins` entry of 101 loads with 51 more diamonds and
no Coins entry. The lobby payout of 75 shows "+75" with the diamond and 15 diamonds flying in. The crates screen shows
one row: 50, 150, 500.

**For the wiki.** Shop: one currency, crate prices in diamonds only, the Double Diamonds pass. Matches: the reward
tables above. Emotes and Loadout: the new prices. Tutorial: 50 diamonds. Remove coins wherever a page names them.

**Sounds.** The payout has sounds of its own, approved and uploaded the same day: `Diamond_Burst` (Snail Diamond Burst,
93979449268444) as the diamonds burst out, `Diamond_Collect` (Snail Diamond Clink, 128397948588694) for each landing,
its pitch climbing (in `src/global_data/Sound/SoundsList.lua`; played by Progression's `Payout`).

**Still open.** The pass's Creator Hub picture and name still show coins. In game the shop's Double Diamonds card
shows the owner's 2x diamonds picture since the same evening (Shop's `PASSES` icon `rbxassetid://122604385822529`,
decal 110197305865795, uploaded to The Snail Studio group).
