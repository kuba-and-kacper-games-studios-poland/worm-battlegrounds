---
title: "Emote shop: fast presses no longer hit the buy rate limit"
date: 2026-11-25
status: open
kind: fixed
pages: ["Emotes"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/EmoteShop.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Settings.lua
---

**What changed.** When emotes were bought quickly, the server refused the calls over `Cosmetics_BuyEmote`'s rate
limit (2 a second) and warned "went over the rate limit". The shop could also say "You need level … and … diamonds"
for an emote that had just been bought. Now the shop sends one buy at a time, at most one every `EMOTE_BUY_INTERVAL`
(0.55 s), and ignores presses in between. It shows no message for an emote the player owns by the time the answer
comes.

**Where.** `_buy` in Cosmetics' `Scripts/Client/EmoteShop.lua`; `EMOTE_BUY_INTERVAL` in Cosmetics' `Settings.lua`. The
server's rate limit is unchanged.

**How to check.** In the lobby, open EMOTES and click several locked emotes as fast as you can: they buy one by one,
the Output has no rate-limit warning, and no "You need level" message shows for emotes you could afford.

**For the wiki.** Nothing players need to know beyond "buying is one emote at a time".
