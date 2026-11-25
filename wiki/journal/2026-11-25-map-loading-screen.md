---
title: "Teleport card: the map's own scene, with parallax"
date: 2026-11-25
status: open
kind: changed
pages: ["Lobby", "Architecture", "Desert", "Echo Caverns", "Rolling Plains"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Settings.lua
  - worm-battlegrounds-game/src/replicated_first/TransitionMotion.lua
  - worm-battlegrounds-game/src/replicated_first/Transition.client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TeleportGui/init.lua
---

**What changed.** The loading card between the lobby and a match was a small map picture on a grey backdrop, its
line sometimes in capitals and sometimes not. It is now the destination map's own scene, full screen: its sky and its
parallax layers (far range, clouds, near hills, ground) from Atmosphere's `PROFILES`, drawn with the match camera's
numbers so each layer slides at its true depth as the camera sways, with the map's weather (Desert sand, Echo Caverns
snow, Rolling Plains pollen and leaves). On the scene, in the map's accent colour and white: "HEADING TO" over the map's name, the mode's glyph with "DEATHMATCH · 6 SNAILS", a tip that changes every 5 s
on a slim navy bar along the bottom, whose top edge is the progress line with the shell glyph rolling at its head. Every line is in capitals and has no "…".

- **JOIN on a public card:** the card comes up at once ("PUBLIC MATCH" / "FINDING A MATCH" with pulsing dots) and the
  camera whip-pans between the rotation's maps every 1.6 s until the match is found, then whips to its map and its
  name punches in ("MATCH FOUND" while waiting for a match another lobby opened, then "HEADING TO").
- **Intro:** the scene whips in from the side while the plate rises, under half a second.
- **Teleport:** Roblox holds the card's last frame; the game hands it a fresh copy every 0.5 s.
- **Arrival:** the next server keeps the scene moving, fills the bar once the player has loaded, then the plate drops
  and the camera flies through the layers into the map.
- **Back to the lobby:** "BACK TO" / "THE LOBBY" over the lobby's own sky; a rejoin says "BACK TO" / "YOUR MATCH".

**Where.** Transition's `LOOKS` (accent, weather, horizon per map), `LOBBY_LOOK`, `WEATHER`, `TIPS`,
`SEARCH_WHIP_SECONDS` (1.6), `HANDOVER_SECONDS` (0.5); `I.Transition.SetDestination(players, destination)` and
`Show(players, destination)` now take a destination (`Kicker`, `Title`, `MapId`, `Mode`, `ModeIcon`, `Detail`,
`Pool`); the remote `Transition_Destination` carries it. MatchBoard's `Launch.GetDestination`, `JOIN_SEARCH_KICKER`
("Public match"), `JOIN_SEARCH_MESSAGE` ("Finding a match"), `JOIN_WAIT_MESSAGE` ("Match found"),
`DESTINATION_KICKER` ("Heading to"), `DESTINATION_DETAIL` ("%d snails"). The motion is
`src/replicated_first/TransitionMotion.lua` (new, in ReplicatedFirst). The gui `TeleportGui` was exported into
`ServerStorage.Ume.UtilityGuis` (the old one is in `ServerStorage.!dump.TeleportGui_Old`).

**How to check.** Studio play tests, 25 Nov: the search whipped between maps, "match found" punched Rolling Plains in,
the teleport's own card took over the scene with no second intro, the reveal ran and removed the card; Desert, Echo
Caverns, Rolling Plains and the lobby each showed their scene; no errors. Not checked: a real teleport between the
places (Studio can't), phones' screen shapes, and the fly-through over the real map (Studio's 3D view was blank that
session). The place isn't saved or published.

**For the wiki.** Lobby (or a Loading page): what the loading card shows and how a public Join looks while it searches.
Architecture: the teleport row's "Heading to Picnic Plains…" (and the map's `Thumbnail`) becomes the destination table
and the map's scene; ReplicatedFirst now holds `TransitionMotion` beside the arrival script. Each map page: its
loading look (accent colour, weather).
