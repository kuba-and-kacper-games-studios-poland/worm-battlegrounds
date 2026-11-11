---
title: "The game's own sounds and level music: classic 2005-2009 Roblox soundscape, 37 uploads, music per map"
date: 2026-11-10
status: open
kind: changed
pages: ["Sounds", "Music", "Match screen", "Maps", "Lobby", "Match modules"]
files:
  - art/sfx/README.md
  - art/sfx/make_classic.py
  - art/sfx/make_levels.py
  - art/sfx/ambience.py
  - art/sfx/tracker.py
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Mood.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Reactions.lua
  - worm-battlegrounds-game/src/modules/Main_Controllers/BGM_Controller/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main/WidgetManager/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Client.lua
---

**What changed.**

- **Every sound is now the game's own, in the classic 2005-2009 Roblox soundscape** (the owner's pick: "use the
  roblox 2005 soundscape... Great Strategy is the vibe"), replacing the free Creator Store placeholders. 18 effects
  are Roblox's own 2009 sounds played from their ids (the old rocket launch for the Bazooka, the rubber-band sling
  for every thrown weapon, the classic clicks, splat steps, spring jump, "Ouch", glass break, the official OOF).
  28 effects and 9 music pieces were made in the repo's sound kit (`art/sfx`) and uploaded to The Snail Studio group
  (all approved by moderation), under plain titles starting "Snail" (`art/sfx/README.md` → Uploading has the table).
- **Music per place, as Worms Armageddon's level streams:** each map's track mixes its ambience with a light song
  (mostly one instrument at a time playing a bit of the map's tune), loops seamlessly, and crossfades in 2.5 s
  (Atmosphere's `MUSIC_FADE`) into a faster, driving sudden-death version when sudden death starts:
  - Picnic Plains: 104 BPM, F Lydian, meadow (birds, crickets, leaves, breeze), 74 s; sudden death 132 BPM, 58 s.
  - Desert: 96 BPM, D Phrygian dominant, hot wind, sand, lava sea left, oasis drips right, hand drums, 80 s; sudden
    death 124 BPM, 62 s.
  - Rockslide Ridge: 92 BPM half-time, A Dorian, mountain wind, rockfalls, a hawk, echoing horn call, 84 s (kept
    epic all through, the owner's pick); sudden death 120 BPM, 64 s.
  - Lobby: 84 BPM, G major, the game's signature tune barely there over a meadow, no drums, 91 s.
  The separate `Ambient` loop no longer plays (the music carries the ambience).
- **New sounds:** your turn's bugle call (a snare ruff into a bugle G-G-C-E-G) and others' turns' drum roll with two
  horn notes; time up when your turn runs out without a shot; a ding on a knockout blow (with the punch-in); the sea
  rising at the start of each sudden-death turn; a hiss with obsidian's steam (at most every 1.2 s); a harp pluck
  when a window opens; the teleport card's whoosh as it slides in, and its arrival sound on the next server.

**Where.** Ids: `SoundsList.lua` (`BGM`, `Music_<MapId>`, `Music_<MapId>_SuddenDeath`, `Turn_TimeUp`,
`Match_Knockout`, `Match_WaterRise`, `Liquid_Obsidian`, `Window_Open`, `Teleport_Out`, `Teleport_In` are new names;
`Ambient` is gone). Music: Atmosphere's `PROFILES` rows (`Music`, `SuddenDeathMusic`) and `Mood._refreshMusic`,
played through `I.BGM_Controller.Play`; BGM_Controller's `_playStartTracks` starts only `BGM`. Hooks: MatchHud
`Turn._tick` (time up) and `_onTurnStarted` (sea), Combat `Effects._onHit` (knockout), Atmosphere
`Reactions._steamObsidian` (`OBSIDIAN_SOUND_GAP`), WidgetManager `Open` (UI group), Transition `_onGuiAdded` and
`Start`. Asset ids: `BGM` 112211761861428, `Music_PicnicPlains` 137510858152490 (sudden death 92872423963988),
`Music_Desert` 71795470444674 (73282690663044), `Music_RockslideRidge` 83665320995374 (105098553957434),
`Turn_Yours` 106047322621411, `Turn_Start` 124997372774741, `Match_Win` 96177429150503, `Match_Lose`
123846876335583; the rest are in `SoundsList.lua`.

**How to check.** In Studio the lobby plays "Snail Lobby Theme" (91.4 s, Music group); every SoundsList id preloads
(checked 2026-11-10: 61 names, all Success). In a match the map's track plays and switches at sudden death; the
Output shows no "is not a valid SoundName".

**For the wiki.** A Sounds/Music page: the soundscape choice, the music per map and its sudden-death switch, the
new match sounds, and credits (the classic samples, NotRoblox's soundfonts CC BY 3.0, Roblox's 2009 sounds).
Supersedes the turn sounds in 2026-11-10-your-turn-callout ("turn sting", "softer chime" are now the bugle call and
the drum roll); the rest of that entry holds.

**Unsure.** Not yet heard in a full match in Studio (map music and sudden death were checked by playing the ids,
not by a played match). The place has to be saved and published for live servers to get the new code.
