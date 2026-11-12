---
title: "The shop is the studio's full-screen Shop design"
date: 2026-11-12
status: open
kind: changed
pages: ["Currencies & crates"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Shop/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
---

**What changed.** The currency bar's + opens the studio's `Shop` design (ported 1:1), filling the screen: SHOP,
the player's diamonds and coins and BACK at the top, the five diamond packs over the four game passes, each price on a
green button. An owned pass's button turns grey and reads Owned. The lobby's own guis hide while it shows (it joined
Lobby's `FULL_SCREEN_WIDGETS`). Packs, passes and prices are unchanged (live from Roblox).

**Where.** The Shop gui; Shop's `Client.lua`; Lobby's `FULL_SCREEN_WIDGETS`.

**How to check.** In the lobby, press + on the currency bar.

**For the wiki.** Currencies & crates (the shop): the new look.
