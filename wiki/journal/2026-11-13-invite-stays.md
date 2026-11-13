---
title: "A party invite stays until it's answered or runs out"
date: 2026-11-13
status: open
kind: fixed
pages: ["Party"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Scripts/Client/Invites.lua
---

**What changed.** An invite box that another window (the + button's invite list) pushes away comes back when that window closes, while the invite still runs (`INVITE_SECONDS`). It used to be lost.

**Where.** `Invites._onInvitedClosed`, on WidgetManager's `WidgetManager_Closed`; `inviteEndsAt`.

**How to check.** Get an invite, press + and close its window: the invite box opens again.

**For the wiki.** Party: invites wait until answered or they run out. A History line.

**From.** The testers: "if you get invite, and click and plus the invite dissapears".
