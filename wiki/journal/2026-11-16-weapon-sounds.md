---
title: "New weapon sounds and six map themes, uploaded and playing"
date: 2026-11-16
status: open
kind: added
pages: ["Sounds", "Homing missile", "Black hole grenade", "Variety grenade", "Cluster bomb"]
files:
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - art/sfx/README.md
  - art/sfx/make_classic.py
  - art/sfx/make_sfx.py
  - art/sfx/make_levels.py
  - art/sfx/ambience.py
  - art/sfx/make_preview.py
---

**What changed.** Ten new sounds play by name: `Homing_Lock`, `Homing_Boost` (the homing missile locking on and
diving), `BlackHole_Open`, `BlackHole_Hum` (looped while open), `BlackHole_Collapse`, `BlackHole_Burst`,
`Variety_Burst`, `Variety_Dig`, `Variety_Squeak` (the variety grenade and its worms) and `Cluster_Split` (the Cluster
bomb's split). For now each plays a classic 2009 Roblox sound already in the list (a `shortcut:` comment in
SoundsList's "Weapon moments" section). Separately, the sound kit (`art/sfx`) has a draft "Update 16 Nov" (the
README's section): these ten effects built for real, six weapons' own throw sounds, and music and ambience for six
maps (Volcano Isle, Echo Caverns, Rolling Plains, Fluffy Fallout, Mirage Mesa, Lakeside Showdown). It is in the
preview only: not approved, nothing uploaded.

**Where.** `SoundsList.lua` → "Weapon moments": `Homing_Lock` 12221967, `Homing_Boost` 135875715949879,
`BlackHole_Open` 12221984, `BlackHole_Hum` 135875715949879, `BlackHole_Collapse` 12221984, `BlackHole_Burst` 12222084,
`Variety_Burst` 83470903795378, `Variety_Dig` 12222046, `Variety_Squeak` 12222152, `Cluster_Split` 12222046. Played
by Combat (server: `Snail.PlaySound`, Bouncer's `BurstSound`; clients: `Shots._playAt`, `Vortex._play`). The kit's
`make_classic.py` (`UPDATE_2026_11_16`), `make_levels.py` (`NEW_MAPS`), renders in `art/sfx/out/update_2026-11-16/`.

**How to check.** In a match each sound plays at its moment. Once the owner approves the update, the uploaded ids
replace these in SoundsList and the shortcut comment goes.

**For the wiki.** Sounds: the new weapon moments (and later, the new maps' music once it ships).

**Update (same day).** The owner approved the whole set ("Sounds and songs are great"). All 28 were uploaded to The Snail Studio group and their ids replace the stand-ins in `SoundsList.lua`: the ten names above, the six throw sounds (`Fire_Grenade`, `Fire_ClusterBomb`, `Fire_VarietyGrenade`, `Fire_BlackHoleGrenade`, `Fire_SpiderBomb`, `Fire_SpartanSpear`, which shared one classic throw before), and the six maps' music: `Music_<MapId>` and `…_SuddenDeath` for Volcano Isle (was Desert's), Echo Caverns (was Rockslide Ridge's), Rolling Plains, Fluffy Fallout, Lakeside Showdown (were Picnic Plains') and Mirage Mesa (was Desert's), set in Atmosphere's `PROFILES`. Titles and the table: `art/sfx/README.md`. Wiki: each map page's music line, and the Sounds page.
