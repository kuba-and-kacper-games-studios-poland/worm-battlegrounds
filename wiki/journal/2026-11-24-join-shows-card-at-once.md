---
title: "JOIN puts the teleport card up at once: \"Finding a match…\""
date: 2026-11-24
status: open
kind: changed
pages: ["Public matches", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Client.lua
---

**What changed.** Pressing JOIN on a public card showed nothing for a few seconds while the lobby found or opened
the match and reserved its server, so players pressed it again (the owner, 2026-11-24). Now the teleport card slides
over the screen as soon as the server gets the press (one round trip), reading "Finding a match…"
(MatchBoard's `JOIN_SEARCH_MESSAGE`); it changes to "Match found! Joining..." (`JOIN_WAIT_MESSAGE`, before a
notification) while a match another lobby opened boots, then "Heading to <map>…" as the teleport starts. If the Join
fails the card comes down and the failure message shows. The whole party gets the card. PLAY AGAIN, which joins the
same way from the lobby, shows it too.

**Where.** New `I.Transition.Show(players, text)` and `I.Transition.Hide(players)` (Transition's server, which clones
the `TeleportGui` card from the server's UtilityGuis); `Public.Join` calls them. The client's `_onGuiAdded` lets the
teleport's own card replace one already up without sliding in again. Not on the Studio map, which plays the match on
its own server.

**How to check.** On the live lobby, press JOIN: the card is up within a moment; on a Join that fails, it comes back
down with "Couldn't find a match. Try again!".

**For the wiki.** Public matches / Lobby: pressing JOIN shows the teleport card at once.
