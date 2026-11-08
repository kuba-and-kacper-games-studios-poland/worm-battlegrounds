---
title: "Back to the lobby: sent once, failures shown, the tutorial counted when it ends"
date: 2026-11-08
status: open
kind: fixed
pages: ["Architecture", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Connection.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
---

**What changed.** A player going back to the lobby is teleported once: the rematch vote closing no longer sends them
again while the Lobby button's teleport runs. A teleport that can't start now shows "Couldn't get you to the lobby.
Try again!", and the Lobby button works again at once (before, nothing happened). The tutorial match counts as played,
and is saved, as soon as it ends, not only when the player leaves it, so the lobby can't send them back into it.

**Where.** `SendToLobby` and the new `CompleteTutorial` in `Match/Scripts/Server/Connection.lua`; `Phases` calls
`CompleteTutorial` when a tutorial match ends. Settings `LOBBY_RESEND_SECONDS` (15) and `LOBBY_FAILED_MESSAGE`.

**How to check.** On the Studio map the Lobby button after a match brings back the lobby screens, and Play starts a new
match in 0.2 s (2026-11-08).

**For the wiki.** Architecture: the trip back to the lobby. Still unsure: the tester's "back to lobby doesn't work when
you finish a game", "if a party joins any game it doesn't load until one leaves" and "loading too long" were not
reproduced, because they need live servers (two places, reserved servers, several players), which Studio can't run.
These changes cover the likely causes found in the code; the match server's log (F9 → Server) when it happens would
show the real one.

**From.** The tester's notes.
