---
title: "Match camera: calmer moves, shots kept in view, hand pan holds 5 s, touch drag and pinch"
date: 2026-11-12
status: open
kind: changed
pages: ["Match screen", "Controls"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.** The owner found the camera too rapid, sometimes losing a projectile or a grenade, and asked for the
player's own camera moves to win for a while, and for touch controls.

- **Calmer.** Every move eases in and out on a damped spring that never goes faster than 140 studs a second at the
  starting zoom (`MAX_SPEED`, faster zoomed out); follow 6 → 3.5 (`FOLLOW_SPEED`), the glide to the next snail
  2.5 → 1.6 for up to 2.5 s (`TRAVEL_SPEED`, `TRAVEL_MAX`), zoom easing 10 → 6. Measured in a Studio bot match: the
  fastest camera move fell from about 1,200 studs a second to 136.
- **Shots stay in view.** A shot, or a snail a blow sent flying, moves the view only once it leaves the middle quarter
  of the screen (`DEAD_ZONE` 0.25), so a grenade's bounces don't shake it; the lead's smoothing 8 → 3; a shot is never
  held back by the speed cap (`SHOT_FOLLOW_SPEED` 5). Fixed with it: a knocked-out snail's ghost kept its ball's last
  speed, so the camera chased the ghost across the map right after a blast instead of holding on it.
- **Your hand wins.** Outside your own turn before your shot, dragging the view (right mouse, a finger, the stick, the
  screen's edge) leaves what the camera follows: it stays where you put it until 5 s after your last move
  (`MANUAL_HOLD`), then glides back to the game. The screen's edge no longer pans while the mouse is outside the
  window, or once the view can't go further.
- **Touch.** One finger drags the view (on your own turn before the shot it points the aim, as before); two fingers
  drag it and pinch to zoom. Read from raw touches, replacing Roblox's two-finger `TouchPan` and `TouchPinch`.

**How to check.** In a match, drag the view during a bot's turn: it stays put for 5 s, even into the next turn, then
glides to the active snail. Watch a grenade bounce: the view stays still while it bounces near the middle. On a phone,
drag with one finger outside your turn, and pinch. Touch wasn't tried on a device (Studio can't send touches here).

**For the wiki.** Controls: one finger drags the camera, two fingers drag and zoom, and a moved camera stays 5 s.
Match screen: the camera holds on what happened and follows shots smoothly.
