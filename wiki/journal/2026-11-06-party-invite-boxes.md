---
title: "Party invites are boxes: a list of players to invite, and an invite to answer"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/PartyInvite/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/PartyInvited/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Scripts/Client/Invites.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Settings.lua
---

**What changed.** Before: Invite players asked "Invite X to your party?" in a plain system popup, one player after
another, and the invited player got another plain popup. Now **Invite players** opens an "Invite players" window in
the game's look: everyone in the server who isn't in a party, each with Invite (it turns grey and reads Sent), and
Invite friends; with nobody to invite it says so. The invited player gets a "Party invite" window: the inviter's
avatar, "Name invited you to their party!", **Join party** (yellow) or **No thanks**. Closing it lets the invite run
out (30 seconds).

**Where.** Widgets `PartyInvite` and `PartyInvited` (Party Settings `INVITE_GUI_NAME`, `INVITED_GUI_NAME`). Remotes
unchanged: `Party_Invite`, `Party_Invited`, `Party_Answer`; `INVITE_SECONDS` 30.

**How to check.** Needs two players: one presses Invite players, then Invite beside the other; the other sees the
Party invite window. Not checked yet in a two-player test; both windows were built and captured in Studio.

**For the wiki.** Lobby → Party: inviting from the list, and answering an invite.

**From.** The owner's bug list (2026-11-06): "invite doesn't appear as box".
