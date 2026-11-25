---
title: "Coins paid fly into the coins slot back in the lobby (1 coin per 10, max 30)"
date: 2026-11-24
status: open
kind: added
pages: ["Coins", "Lobby", "Levels & XP", "Tutorial"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Scripts/Client/Payout.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Server.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/init.lua
---

**What changed.** Back in the lobby after a match (or the tutorial), the coins it paid play out like Brawl Stars'
trophies (the owner: "like Brawl Stars with the trophies"): the coins slot at the top right keeps the old count,
"+amount" with the coin pops up over the player's snail on the stage, then one coin for every 10 (at least 1, at most
30) bursts out and flies into the slot, which counts up as each lands with a tick that climbs in pitch. The XP replay
follows when there is XP. The coins are paid at once as before; only the slot's number waits.

**Where.** `I.Progression.AddReplayCoins(player, amount)` (called by MatchRewards' `_payPlayer` and Tutorial's
`CompleteMatch`) adds to the replay's new `Coins` field (profile `Progression.Replay`). The client plays it in
`Payout.Hold` and `Payout.Play`; settings `COINS_PER_ICON` 10, `COIN_ICONS_MAX` 30, `COIN_ICON_SIZE` 46,
`COIN_BURST_DELAY` 0.55, `COIN_FLIGHT_TIMEOUT` 4, `COIN_TICK_CLIMB` 0.6. LevelPlate gui: `S_CoinGain`
(`S_CoinGainScale`, `S_CoinText`, `S_CoinIcon`). Sounds: `Xp_Line` for the pop, `Crate_Tick` for each landing (no
coin sound exists yet).

**How to check.** Win a 4-player public match for 100 coins: back in the lobby "+100" shows over the snail and 10
coins fly into the slot, which climbs from the old count to the new.

**For the wiki.** Coins: how a match's coins are shown on return. Lobby: the payout. Tutorial: its 100 coins fly in
too.

Still unsure: a press skips the XP replay but not the coins.
