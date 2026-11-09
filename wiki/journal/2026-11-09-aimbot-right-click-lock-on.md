---
title: "Admin aim guide: a right click eases the aim onto the guide in 0.4 s, a left click fires"
date: 2026-11-09
status: open
kind: added
pages: ["Admin tools", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Aimbot.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Client.lua
---

**What changed.** The owner asked for the admin aim guide (the `aimbot` command, level 255) to aim for them. On their
turn, with the guide showing, a right click locks on to the guide whose target is nearest the mouse: the angle and
power slide there smoothly over 0.4 seconds and stay there whatever the mouse does. The next left click fires at that
aim (at the guide's numbers even if clicked mid-slide). Esc cancels. With a homing missile the lock-on also picks
that snail as its target. Without the guide, a right click still cancels the aim as before. Players without the
aimbot see no change.

**Where.** MatchHud's new setting `AIMBOT_EASE = 0.4`. `Module._lockOn` and `Module._easeLock` in
`MatchHud/Scripts/Client/Aim.lua` (a new `"Lock"` aiming mode); the left-click fire is in `_onInputBegan`. Combat's
client keeps the last guides the server sent (`Combat_AimbotGuide`) and exposes them as `I.Combat.GetAimGuides()`.
The guide is still solved on the server and sent only to that player.

**How to check.** In Studio, set the `Aimbot` Player attribute (or run `aimbot`), start a match, and on your turn
right-click near an enemy: the HUD's angle and power slide to the guide's label (26° 70% in the 2026-11-09 test, in
about 0.4 s); a left click fires the Bazooka. Checked in Studio on 2026-11-09 with no errors. Not tested: a pad, touch
screens (no right click there), several guides at once.

**For the wiki.** Admin tools: the aim guide's right-click lock-on and left-click fire. Controls: right click locks
on only with the aim guide; otherwise it cancels the aim.
