---
title: "Party invite popup in the new look, drawn as the confirmation dialog"
date: 2026-11-13
status: open
kind: changed
pages: ["Lobby", "Guis", "Lobby & meta modules", "Controls & platforms"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/PartyInvited/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Scripts/Client/Invites.lua
---

**What changed.** The owner said the party invite gui "is using the old ui version". That is the popup an invited
player gets (`PartyInvited`). It was still the GUI kit's Hazard plate `Small` window (`WormBattlegroundsBrawl`), with a
yellow "Join party", a red "No thanks" and a close ✕. Now it is drawn the way `WidgetManager_Confirmation` is: one
rounded dark panel (25, 25, 35) with the grey inner line (130, 130, 130) and **PARTY INVITE** on top. Below the title,
the inviter's head shot sits beside "Name invited you to their party!" in white Londrina. Under them are the crate
shop's slanted buttons: green **JOIN PARTY** and red **NO THANKS**.

There is no close button any more. Pad keys: A joins, and B now says no thanks (before, B closed it and let the invite
run out, and X said no thanks). The Console module's `Decline` action (X) is now used by nothing. The `PartyInvite`
list (Invite players) was already in the new look and is unchanged.

**Where.** The gui table `PartyInvited/init.lua` is now `Primitive` nodes (no theme), with the same Ids: `U_Widget`,
`S_Avatar`, `S_Text`, `S_Accept`, `S_Decline`, plus the console badges `S_AcceptHint` and `S_DeclineHint`.
`S_Accept` and `S_Decline` are the ImageButtons themselves, so `Invites.lua` no longer looks for their `Button` child.
The export in StarterGui is replaced; the old export is kept as `ServerStorage.!dump.PartyInvited_before_2026-11-13`.

**How to check.** Have a second player invite you in the lobby: the popup shows their avatar and name, JOIN PARTY joins,
and NO THANKS or B closes it and says no. Checked in Studio on 2026-11-13: the gui builds with no errors, the capture
matches the confirmation dialog, and Party's client starts with the new elements. A real invite between two players,
phone sizes and the pad keys weren't checked.

**For the wiki.** Lobby (party part): the invite popup's look and its buttons, and that B says no thanks and there is
no close. Guis: PartyInvited is in the new look (Primitive, like the confirmation), no longer the GUI kit. Controls &
platforms: B answers no on the party invite; X (Decline) has no use now.
