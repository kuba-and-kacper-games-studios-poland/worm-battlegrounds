---
title: "Lobby: match rows, solo, custom rooms, parties, rejoin, voice chat"
date: 2026-11-03
status: merged
merged: 2026-11-06
kind: added
pages: ["Lobby", "Match modes & maps", "Lobby & meta modules", "Architecture", "Data & networking"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/
  - worm-battlegrounds-game/src/modules/Main_Game/Party/
  - worm-battlegrounds-game/src/modules/Utils/VoiceChat/
---

**What changed.**

- **Match rows:** public deathmatch rows of 2, 4, 6 and 8 and two team rows. A party leader joins a row for the
  whole party. A row starts when full, when its 30 s timer ends with 2 or more players (`ROW_SECONDS`), or when 2/3 of
  its players vote (`VOTE_FRACTION`); bots fill the rest at Medium. A started row is replaced by a fresh one.
- **Solo:** Easy, Medium or Hard bots, alone only. **Custom:** a room with a map, mode and size; the owner invites
  players or friends and starts it with 2 or more.
- **Maps:** only Picnic Plains is in rotation (`MAP_POOL`).
- **Parties:** up to 4 (`MAX_PARTY`); invites stay open 30 s; the leader invites and kicks; the next member leads
  when the leader leaves. **Invite** asks about each player in the server in turn (a stand-in for a picker).
- **Rejoin:** a player who dropped out of a match within 60 s is asked "Rejoin your match?" in the lobby.
- **Voice chat** works without avatars: everyone hears everyone at the same volume.

**Where.** `I.MatchBoard.Launch` / `GetMap`; remotes `MatchBoard_Join`, `_Leave`, `_Vote`, `_PlaySolo`,
`_CreateCustom`, `_InviteCustom`, `_InviteAnswer`, `_StartCustom`, `_LeaveCustom`, `_Invited`; rows as
`Configuration`s in `ReplicatedStorage.Ume.MatchBoard`. `I.Party`; remotes `Party_Invite`, `_Answer`, `_Leave`,
`_Kick`, `_Invited`; Player attributes `PartyId`, `PartyLeader`. Lobby remotes `Lobby_RejoinOffer`, `Lobby_Rejoin`.

**How to check.** Needs a published place with two accounts: join a row together in a party, start, land in one match.
In Studio, launching prints the metadata instead of teleporting.

**For the wiki.** Lobby (the middle panel and parties), Match modes & maps. `VoiceChatService.EnableDefaultVoice` has
to be off in the place.
