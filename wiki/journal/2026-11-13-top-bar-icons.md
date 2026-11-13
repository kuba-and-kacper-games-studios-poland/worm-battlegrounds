---
title: "Top bar: Leave game and the music button are icons"
date: 2026-11-13
status: open
kind: changed
pages: ["Match screen", "Lobby", "Guis"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/TopBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Controllers/TopBar_Controller/Client.lua
  - art/topbar/make_icons.py
---

**What changed.** The top bar's text buttons "Leave game" and "Mute music" / "Play music" are now round icon buttons
beside the Settings gear: white glyphs drawn for the game (the repo's `art/topbar` kit). The music button shows two
notes while music plays and the notes crossed out while it's muted. It's one button now, in the lobby and in matches
(the match used to add its own text copy). In a match the order is Settings, music, Leave game.

**Where.** TopBar_Controller's `MUSIC_ICON` `rbxassetid://101278000628566`, `MUSIC_OFF_ICON`
`rbxassetid://117397305535105` (`_refreshMusicButton`); MatchHud's `LEAVE_ICON` `rbxassetid://107990939394341`
(replaces `LEAVE_TEXT` and `MUSIC_TEXT`), Leave game at `LayoutOrder` 3. Uploaded as Decals to The Snail Studio group
(566704940): TopBar Leave 119082518528503, TopBar Music 109719345334471, TopBar Music Off 85078518159765, all approved.

**How to check.** In a match the top left shows gear, notes, door; pressing the notes crosses them out and the music
stops. Checked in Studio on 2026-11-13.

**For the wiki.** Match screen and Lobby: the top bar's icons. Guis: the top bar's buttons are icons.
