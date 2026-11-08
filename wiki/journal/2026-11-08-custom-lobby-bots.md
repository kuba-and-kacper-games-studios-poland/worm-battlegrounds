---
title: "Custom lobbies get a Bots row; Nightmare bots only there"
date: 2026-11-08
status: open
kind: added
pages: ["Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Rows.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
---

**What changed.** The custom lobby's create step has a new **Bots** row under Players: Off, Easy, Medium, Hard and
Nightmare (Off is picked at first). Bots of the picked difficulty fill the lobby's empty places when it starts, live too
(custom matches used to have no bots outside Studio). Nightmare is offered only here: solo and party setups still list
Easy, Medium and Hard, and public matches still use Medium. A lobby without bots still needs 2 or more players; with
bots its owner may start it alone. The room's line now ends with the bots ("Deathmatch • Picnic Plains • 1 / 4 players
• Nightmare bots"). Custom matches still pay no coins, bots or not.

**Where.** `CUSTOM_DIFFICULTIES` (`{ "None", "Easy", "Medium", "Hard", "Nightmare" }`) in MatchBoard's Settings. The
remote `MatchBoard_CreateCustom` (client → server) gained a fifth argument, `difficulty`, checked against that list.
Each board row carries `Difficulty` (an attribute on its `Configuration` in `ReplicatedStorage.Ume.MatchBoard`), and
`Rows.StartRow` launches with it. `MatchBoard_StartCustom` refuses a lone owner only when the row has no bots ("Invite
at least one more player, or add bots."). Match's roster adds bots whenever `metadata.Difficulty ~= "None"`, custom
matches included. The gui's buttons are `S_BotsNone` … `S_BotsNightmare` in `CustomLobby`, exported to StarterGui.

**How to check.** Studio playtest, Studio map: Custom → Bots: Nightmare → Create lobby → Start alone. The match seats
the player plus 3 bots (size 4), and the room line read "Nightmare bots". Not checked: a live server with friends.

**For the wiki.** Match modes & maps: the custom lobby's Bots row, that bots can fill custom matches, and that Nightmare
is only in custom lobbies (still private until the owner releases it). Match modules: MatchBoard's custom rooms and the
new remote argument.

Supersedes 2026-11-08-bots-trained-brain on one point: Nightmare is no longer unreachable ("How players reach it is
still the owner's call"); it's picked in a custom lobby. The rest of that entry still holds.

**From.** The owner: "make it only in custom match, add button and export the gui".
