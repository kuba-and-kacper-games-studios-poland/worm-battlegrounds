---
title: "Live servers keep the players' saves (UmeTesting_-1); Studio moves to UmeTesting_-2"
date: 2026-11-15
status: open
kind: changed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/core/game_instance/Start/tasks/config.lua
  - worm-battlegrounds-game/src/core/game_instance/Start/configs/place_loader.lua
---

**What changed.** Supersedes 2026-11-15-production-stores (none of it holds but the flag). The owner, "so no-one will
lose their data": `IsProductionReady` stays on, but on live servers the start task `config.Update` now renames the
store names to `UmeTesting_-1` instead of `Production`. That's the name every player's save has been under since the
game went live, so nobody starts over:

- Profiles: the `PlayerProfiles` DataStore, keys `PlayerProfile_<userId>_<namespace>_UmeTesting_-1` (live).
- Global leaderboards: OrderedDataStores `GL_<storeName>_UmeTesting_-1` (live).

Studio now uses `UmeTesting_-2` (the place loader's `ProfileStoreName` and `LeaderboardStoreName` on all four maps),
so playtests never read or write live saves. Studio's own test saves under `UmeTesting_-1` are left behind.

**Where.** `Update` in `core/game_instance/Start/tasks/config.lua`; the names in `core/game_instance/Start/configs/place_loader.lua`.

**How to check.** On a live server, a player who played before keeps their coins, items and level. In Studio the
server's `I.Config.Map.ProfileStoreName` is `UmeTesting_-2`.

**For the wiki.** Architecture: player data lives under `UmeTesting_-1` on live servers and `UmeTesting_-2` in Studio;
a newer ume replaces these files, so the names are set again after an update. Still unsure: anyone who played on a live
server published while the stores were `Production` keeps that progress only there, unread.
