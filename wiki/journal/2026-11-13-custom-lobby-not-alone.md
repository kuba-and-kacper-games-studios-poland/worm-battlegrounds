---
title: "A custom lobby can't start with only its owner in it, bots or not"
date: 2026-11-13
status: open
kind: changed
pages: ["Match modes & maps", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Custom.lua
---

**What changed.** A custom lobby's owner could start it alone when it had bots (Easy to Nightmare); without bots the
server refused with a small notification, "Invite at least one more player, or add bots." Now it always needs 2 or more
players: pressing Start with only the owner in it shows a message window (`I.WidgetManager.ShowMessage`) saying "You
can't start a custom lobby by yourself. Invite at least one more player!" (MatchBoard's `CUSTOM_ALONE_MESSAGE`), and
the server's `MatchBoard_StartCustom` refuses it too, with the same text as a notification. Playing alone is Solo vs
bots. Nightmare bots, offered only in a custom lobby's Bots row, now need at least two players.

**Where.** The client's `Custom._onStart` (MatchBoard), the server's `Custom.Start`; `CUSTOM_ALONE_MESSAGE` in
MatchBoard's Settings. The Teams check (a party with no rival and no bots) is unchanged.

**How to check.** Make a custom lobby alone, with any Bots choice, and press Start: the message shows and nothing
starts. With a second player in it, Start sends everyone to the match.

**For the wiki.** Match modes & maps (Custom): it needs two players; Solo vs bots is the way to play alone. Nightmare
is offered only there, so it needs a friend too.
