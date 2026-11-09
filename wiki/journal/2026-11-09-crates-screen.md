---
title: "Crates screen becomes the studio's Gacha screen, with a 3-pack"
date: 2026-11-09
status: open
kind: changed
pages: ["Crates", "Lobby", "Shop"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Odds.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/
---

**What changed.** The `Crates` widget is the studio's `Gacha` design, ported almost 1:1, full screen:

- One tab per crate: WEAPONS, PREMIUM, UTILITY, SKINS (the tutorial crate shows alone as STARTER while it waits).
  Each crate's `TabName` is in its data row.
- The odds sit on the screen itself, on the left: one section per rarity, rarest first, each item with its icon,
  name and chance ("Always" for fixed items). The separate CrateOdds window is no longer used.
- Balance chips at the top right pick what to pay with (Coins, or Diamonds for crates that take them; diamonds
  hidden where policy restricts them). BACK closes (B on a pad).
- Buy **x1, x3 or x10**. The 3-pack is new: `COUNTS = { 1, 3, 10 }`, priced by the new `Three` field, three times
  the single price with no discount: Weapon 300 coins, Premium 750 diamonds, Utility 300 coins or 600 diamonds, Skin
  300 coins or 150 diamonds. The server prices every pack through `I.G_Crates.GetPrice(crateId, currency, count)`.
- Crates keep their crate picture (`121731184312632`): the design's own crate and coin pictures (`100590108858476`,
  `98038820274339`, by the studio's designer) draw blank in the game, so the coin icon is the theme's `wb-coin`.
- VIP's daily skin crate shows "FREE" on the Skins tab's x1 (the "Free with VIP today!" line is gone).
- Opened from the lobby's new WEAPONS and SKINS menu buttons, which pick the tab; the badge on WEAPONS works as before.

**How to check.** `Crates_Open` accepts count 3; in game, x3 on WEAPONS costs 300 coins and reveals three items.

**For the wiki.** Crates: the screen, the 3-pack and its prices, odds on the screen. Shop/VIP: the daily crate's FREE
label. Lobby: the menu buttons that open it.
