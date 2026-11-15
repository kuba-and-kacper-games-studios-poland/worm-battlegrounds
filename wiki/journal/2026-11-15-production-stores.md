---
title: "Live servers save to the Production stores; every player starts over"
date: 2026-11-15
status: dropped
kind: changed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/core/game_instance/Start/configs/general.lua
---

**What changed.** The owner turned on ume's `IsProductionReady` (`general.lua`, false since the scaffold). On live
servers (never in Studio), in both the main and the dev experience, the start task `config.Update` now renames the
place loader's `UmeTesting_-1` store names to `Production`:

- Profiles: the `PlayerProfiles` DataStore, keys `PlayerProfile_<userId>_<namespace>_Production` (namespaces: the
  main profile and `Inventory`), before `…_UmeTesting_-1`.
- Global leaderboards: OrderedDataStores `GL_<storeName>_Production`, before `GL_<storeName>_UmeTesting_-1`.

The new keys are empty, so every player starts over on their next join: coins, diamonds, level, skins, pieces,
emotes, items, crates, the tutorial (it plays again). Their old saves stay under the old keys and nothing reads them.
Game passes still count, since Roblox owns them; diamonds bought with developer products before this are in the old
saves. Matchmaking's MemoryStore (`PublicLobbies_1_`) and the other DataStores (`CountryData`, Limited's stock, the
lobby store id) don't use the flag.

**Where.** `IsProductionReady` in `core/game_instance/Start/configs/general.lua`; the rename in
`core/game_instance/Start/tasks/config.lua` (`Update`); the names in `configs/place_loader.lua`.

**How to check.** On a live server, a player who had progress joins with a new profile and gets the tutorial; Studio
still loads the `UmeTesting_-1` profile.

**For the wiki.** Architecture: player data lives under the `Production` profile keys on live servers,
`UmeTesting_-1` in Studio; the reset of 2026-11-15. A newer ume replaces `general.lua`, so the flag is set on again
after an update.

Dropped the same day: the owner took the reset back. Superseded by
2026-11-15-live-stores-keep-saves.
