---
title: "The old Desert is now Mirage Mesa (id MirageMesa), so a new map could take the Desert's name"
date: 2026-11-15
status: open
kind: changed
pages: ["Match modes & maps", "Desert", "Mirage Mesa", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
---

**What changed.** The owner: "change current desert name to something different, and import new Desert map". The
Desert as it was (two storeys over lava: a main island with dunes and an oasis pool, two long floating sand islands
above, a red mesa backdrop, 24 props) is now **Mirage Mesa**, map id `MirageMesa`, in the rotation for 2, 4 and 6
snails. Nothing in it changed: the same land (705 parts, 2 ledges), the same lava sea and `Oasis` pond, the Desert's
mood (`Lighting.Presets.Desert`, `Music_Desert`, the sand ambience) and its lobby card picture
(rbxassetid://140014161821553). `Desert` is now the new map (`2026-11-15-new-desert-map`).

**Where.** `MAPS.MirageMesa` and `MAP_POOL` in MatchBoard's Settings; `PROFILES.MirageMesa` (a copy of the Desert's
row) in Atmosphere's Settings. In the dev place: the arena template renamed
`Workspace.Ume.ServerStorage_Assets.Arenas.MirageMesa` (slot 2, X 500), its MapLab lab build and kit module
(`_Kit.Maps.mirage_mesa`); its MapLab files moved to the game home's `assets/models/maps/mirage_mesa/`.

**How to check.** A Studio playtest loaded `MirageMesa`: 705 terrain parts, 24 props, the oasis and lava drawn, no
errors. Mentions of "Desert's oasis" in the rules and READMEs now say Mirage Mesa's.

**For the wiki.** A Mirage Mesa page from the Desert page's facts (the oasis is a safe pond, poison 5 a turn); the
Desert page then describes the new map. Match modes & maps: the map list.
