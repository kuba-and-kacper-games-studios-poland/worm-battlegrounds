---
title: "Admin `combat give` gives utilities too (jetpack, potions, bandage, medkit, parachute)"
date: 2026-11-10
status: open
kind: fixed
pages: ["Architecture", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Uses.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/_meta/README.md
---

**What changed.** The admin command `combat give <itemId> [participantId]` only worked for weapons: a utility's id
wasn't offered or accepted, and giving one failed silently. Now it gives any utility as well: `Jetpack`,
`SpeedPotion`, `LowGravityPotion`, `Bandage`, `Medkit`, `Parachute`, with full uses and no cooldown, like a weapon.

**Where.** `I.G_Arsenal.GetAll()` returns two tables, weapons then utilities, and both places only read the first. In
`Combat/Scripts/AdminPanel/CommandBar/Server.lua`, `_registerCommands` now fills the `Combat_ItemIds` dictionary (the
`itemId` argument's autocomplete, `requireDict`) from both. In `Combat/Scripts/Server/Uses.lua`, `Module.Give` (the
server's `I.Combat.Give`) looks the row up in either (`weapons[itemId] or utilities[itemId]`). Fixes the claim in
`2026-11-08-test-commands` ("Adds any weapon or utility"), which wasn't true until now; the rest of that entry holds.

**How to check.** In a Studio match, open the command bar (Ctrl + [) and type `combat give Jet`: `Jetpack` is
offered. Give it: the Jetpack slot appears in the loadout bar with its uses. Not checked in Studio by the docs pass.

**For the wiki.** Architecture (admin commands): `combat give` takes any weapon or utility id. Match modules: nothing
else.
