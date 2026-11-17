---
title: "Gamepad: calmer stick aim, camera pan with the zoom, a free cursor in the lobby"
date: 2026-11-17
status: open
kind: changed
pages: ["Controls & platforms", "Lobby", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Cursor.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Selection.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Binds.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Client.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Settings.lua
---

**What changed.** The owner's polish pass for pads (approved 2026-11-17).
- **Stick aim:** the right stick still points the aim where it's pushed, but calmer. Under 0.3 of lean it does
  nothing (as before). A gentle push (0.3 to 0.55) only nudges the aim toward the stick, 5 to 30 degrees a second as it
  leans further, for fine aiming. A firm push (0.55 up) turns the aim there in a quick ease (rate 8 to 18 a second; at
  full lean 95% there in about a sixth of a second), never in one jump. Before, any lean past 0.3 set the aim to the
  stick's angle at once. The aim holds still while the lean drops faster than 1.5 a second (the stick springing back
  as it's let go, right before RT fires), and after LT (camera pan) until the stick has come back to the middle, so
  letting go of LT no longer snaps the aim. Constants: MatchHud's `STICK_DEADZONE` (0.3), `STICK_FIRM_LEAN` (0.55),
  `STICK_NUDGE_SPEED` ({ 5, 30 } °/s), `STICK_TURN_SPEED` ({ 8, 18 }), `STICK_DROP_RATE` (1.5), in its `Pad Aim`
  settings category; the code is `Aim._aimWithStick`, every frame of the player's turn. The aim is still sent with
  `Combat_Aim` as before.
- **Camera pan on a pad** (LT + right stick): its speed now scales with the zoom, `STICK_PAN_SPEED` (60 studs a second)
  at the starting distance times zoom ÷ 110: about 25 at the closest zoom, 109 at the farthest, so it crosses the
  screen as fast at any zoom.
- **Any pad counts:** `I.Console.IsHeld` (LT for the camera, B backing out) reads every connected pad, not only the
  first slot (Gamepad1).
- **A free cursor in the lobby:** on a pad (Console, or a pad used on PC), the left stick moves a white ring with a dot
  over the lobby's guis and any open window; it speeds up while held near full lean, slows over buttons, and let go
  over a button drifts to its middle. The button under it is Roblox's selection, so A presses it; B backs out as before,
  LB / RB and the other shortcuts work as before, the D-pad hops the selection to the next button with the cursor
  following, the right stick scrolls the list under the cursor, and View brings the cursor back to where the selection
  starts. A window that opens, a panel that wants the selection, or the first press of a pad sends the cursor onto its
  main button. In a match it shows only while a window is open (Results, a confirmation, the settings), never while
  aiming or walking, and a mouse or touch hides it. Roblox's own gamepad virtual cursor was checked first and not used:
  it can't be tuned, scrolls only at a list's edge, draws its own picture and doesn't run with the game's
  `AutoSelectGuiEnabled` off. Constants: the Console module's `CURSOR_*` and `SCROLL_*` settings (`CURSOR_SPEED`
  { 0.18, 0.9 } screen heights a second, `CURSOR_BOOST` 1.9, `CURSOR_BUTTON_SLOW` 0.45, `CURSOR_MAGNET` 6, `SCROLL_SPEED`
  1.5, `CURSOR_SIZE` 0.034 of the screen's height); new scheme rows `Cursor` (left stick) and `Scroll` (right stick).
  No remotes, no saved data, no new picture.

**Where.** `Aim._aimWithStick` and `Aim._onInputChanged` (MatchHud); `MatchCamera._update`'s stick pan; the Console
module's new `Scripts/Client/Cursor.lua` (built in code as `PlayerGui.ConsoleCursor`), `Selection.lua` (sends the
cursor where the selection would go), `Binds.IsHeld`.

**How to check.** Not play-tested yet (the lead tests on a pad). In a match on a pad: a small push turns the aim
slowly, a full push swings it smoothly, letting go then pressing RT fires where it pointed, letting go of LT while the
stick leans doesn't move the aim; LT + stick zoomed in pans slower than zoomed out. In the lobby on a pad: the cursor
shows over SOLO VS BOTS, moves with the left stick, slows on buttons, A presses the button under it, B closes a window,
the right stick scrolls ACTIVE LOBBIES and long lists, moving the mouse hides it.

**For the wiki.** Controls & platforms: the pad's aim (gentle nudge, firm turn, spring-back ignored), the camera pan
following the zoom, and the lobby's free cursor (left stick, A, B, D-pad, right stick scrolls, View) replacing "the
left stick and D-pad move the selection" in menus. Lobby: the pad's cursor. A History line for each.
