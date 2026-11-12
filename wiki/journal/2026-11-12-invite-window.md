---
title: "The invite window is the studio's InvitePlayers design"
date: 2026-11-12
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/PartyInvite/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Scripts/Client/Invites.lua
---

**What changed.** The party's + opens the studio's `InvitePlayers` design (ported 1:1): INVITE PLAYERS, a red ✕, a
list of players (avatar, name, @username, Invite) and a yellow INVITE FRIENDS. A sent invite turns grey and reads
Sent.

**Where.** The PartyInvite gui; `Invites.lua` (the `Look_Sent*` attributes on `S_Invite`).

**How to check.** With two players in a Studio test server, press + in the party column and invite the other.

**For the wiki.** Lobby (party): the invite window's look.
