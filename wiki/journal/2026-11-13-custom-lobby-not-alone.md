---
title: "A custom lobby without bots can't start with only its owner: Start says so in a message window"
date: 2026-11-13
status: open
kind: changed
pages: ["Match modes & maps", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Custom.lua
---

**What changed.** A custom lobby with only its owner in it and Bots set to Off already couldn't start, but the only
sign was a small notification ("Invite at least one more player, or add bots."). Now pressing Start there shows a
message window (`I.WidgetManager.ShowMessage`): "You can't start a custom lobby by yourself. Invite a player or turn
bots on!" (MatchBoard's `CUSTOM_ALONE_MESSAGE`), and nothing is sent; the server's `MatchBoard_StartCustom` still
refuses it too, with the same text as a notification. With bots (Easy to Nightmare) the owner still starts it alone.

For a while on the same day it refused any lone start, bots or not; the owner then asked for alone-with-bots back, so
that rule never shipped.

**Where.** The client's `Custom._onStart` (MatchBoard), the server's `Custom.Start`; `CUSTOM_ALONE_MESSAGE` in
MatchBoard's Settings. The Teams check (a party with no rival and no bots) is unchanged.

**How to check.** Make a custom lobby alone with Bots Off and press Start: the message shows and nothing starts. Turn
bots on, or have a second player join, and Start sends everyone to the match.

**For the wiki.** Match modes & maps (Custom): without bots it needs two players, and Start says so.
