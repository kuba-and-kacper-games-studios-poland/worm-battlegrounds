---
title: "A failed teleport is tried again twice, then the card goes away"
date: 2026-11-06
status: open
kind: fixed
pages: ["Lobby", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Settings.lua
---

**What changed.** Before, a teleport that Roblox accepted but that then failed on the way left the player on the
teleport card for good ("Heading to Picnic Plains…" over a frozen lobby). Now the server tries the teleport again up
to **2** times, **2** seconds apart, when it failed with `Failure` or `Flooded`. If it still fails, or failed for
another reason, the card is removed and the player gets the notification "Couldn't get you there. Try again!". This
covers every trip that shows the card: lobby → match (solo, party, public, custom, the tutorial), match → lobby,
and rejoins.

**Where.** `Module._onTeleportFailed` in `Transition/Server.lua`, connected to `TeleportService.TeleportInitFailed`
in `Module.Start`. Settings in `Transition/Settings.lua`: `TELEPORT_RETRIES` (2), `TELEPORT_RETRY_DELAY` (2),
`TELEPORT_RETRY_RESULTS` (`Failure`, `Flooded`), `TELEPORT_FAILED_MESSAGE`. No new remote: the card is removed from
the player's PlayerGui on the server.

**How to check.** Not testable in Studio (it never fires `TeleportInitFailed`). In a live server, a teleport that
fails at the start warns `[Transition::Server]: Teleport for (<name>) to (<placeId>) failed! - (<result>: <message>)`
in the server log, then the card goes and the notification shows.

**For the wiki.** Lobby or Match modes & maps, where the teleport card is described: a line that a failed trip is
tried again, then drops the card and says so. A History line.

**Still unsure.** This was written for a report of duos hanging on "Heading to Picnic Plains" and of a slow trip back
to the lobby. It wasn't reproduced live, so whether `TeleportInitFailed` was the cause is unconfirmed. The slow trip
back is likely the save being handed from the match server to the lobby (ProfileStore waits for the old server to
release it), which this doesn't change.
