---
title: "Aim: Ring: point, a thicker wedge, the crosshair in the power's colour"
date: 2026-11-25
status: open
kind: changed
pages: ["Match HUD", "Aiming", "Controls"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The owner picked "Ring: point" from the aim drafts page (the "Snail aim drafts" artifact), in place
of 2026-11-24's "Ring: trackpad", and asked for these changes to the aim's look:

- **Ring: point.** On the player's turn, a press on the arena (the mouse button or a finger) puts the crosshair under
  it, and a drag moves it with the pointer. The way from the snail is the angle, and the distance is the power, up to
  the power ring. Letting go still locks the aim, and FIRE shoots it. The trackpad's per-device drag scale is gone
  (`AIM_DRAG_SHARE`, which was Desktop 0.22, Mobile 0.42). The right stick still nudges the crosshair from where it
  is (`STICK_*`).
- **A thicker wedge.** The owner said "too thin at the max power": `POWER_WEDGE_SPREAD` is 0.26, up from 0.16. The far
  end is 0.26 of the wedge's length across.
- **The crosshair takes the power's colour.** It's yellow at little power and red at full (`POWER_COLORS`, the
  wedge's), on every screen. It used to be the snail's team colour (its `Color` attribute).
- **A smaller crosshair** (`CROSSHAIR_SIZE` 2.2 units, was 2.6) and **a bigger power ring** (`POWER_LENGTH` 8.5 units,
  was 7). The ring's radius is `POWER_START` + `POWER_GAP` + half the crosshair + `POWER_LENGTH`, now about 11.4 units,
  up from about 10.

Supersedes the trackpad drag in 2026-11-24-drag-lock-fire-aiming. Everything else in that entry still holds: lock,
FIRE, the kept aim and the first aim. Also supersedes the crosshair's colour, and the wedge's 0.16 in
2026-11-25-aim-power-wedge.

**Where.** `_startDrag` and `_drag` in MatchHud's `Scripts/Client/Aim.lua`: the press's offset from the snail's
middle goes straight to `_setFromOffset`. The colour is in `_draw`, and the values are in MatchHud's `Settings.lua`
(Aiming).

**How to check.** In a match, on your turn, click or tap somewhere near your snail: the crosshair jumps there, and the
wedge and the crosshair turn from yellow to red as you move it out to the ring.

**For the wiki.** Aiming and Controls: "press where to aim, drag to adjust" in place of the trackpad drag. Match HUD:
the crosshair's colour follows the power. The tutorial's "Drag to aim" hint is unchanged.

**Later the same day.** The power ring a little bigger again (the owner, after a phone test: "make the circle a little
bit bigger"): `POWER_LENGTH` 9.5 units (was 8.5), so the ring's radius is about 12.4 units.
