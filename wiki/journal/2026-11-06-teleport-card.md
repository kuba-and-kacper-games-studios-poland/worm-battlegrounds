---
title: "A teleport card slides over the screen between the lobby and a match"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: added
pages: ["Lobby", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Client.lua
  - worm-battlegrounds-game/src/replicated_first/Transition.client.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TeleportGui/init.lua
---

**What changed.** Before: starting a match showed a "Heading to the match…" card only for a moment, then Roblox's
own teleport screen, then the game's letter loading screen in the match. Now the card slides down over the screen
(0.4 s), says where the player is going ("Heading to Picnic Plains…", with the map's picture once maps have one),
stays up through the teleport and the match server's loading, and slides off downwards once the player is in. The
same card says "Back to the lobby…" after a match and "Back to your match…" on a rejoin. Joining the game from the
website still shows the letter loading screen.

**Where.** `I.Transition.SetDestination(players, text, image)` and the remote `Transition_Destination @ (text, image)`
(server to each teleported player), called from MatchBoard's `Launch`, Match's `Connection.SendToLobby` and Lobby's
rejoin. The card is the `TeleportGui` gui (in `ServerStorage.Ume.UtilityGuis`), with `GuiAnimDuration` 0.45;
Transition's `WIPE_TWEENINFO` 0.4 s. The arrival is `src/replicated_first/Transition.client.lua`.

**How to check.** Studio with `Ume_StudioMapId = "Lobby"` (both places saved to Roblox first): Play solo → Start.
Checked 2026-11-06: the card slid down reading "Heading to Desert…" / "Heading to Picnic Plains…", arrived on Arena
with no letter loading screen and slid off once the client started; after the match it read "Back to the lobby…"
and arrived in the lobby the same way. The rejoin's "Back to your match…" wasn't tried.

**For the wiki.** Lobby: what starting a match looks like. Match modes & maps: maybe a line on going back to the
lobby. Unsure: map pictures (`Thumbnail` in MatchBoard's `MAPS`) are all empty for now, so the card shows only text.

**From.** The owner's request (2026-11-06): "add now transition gui when you're loading into match".
