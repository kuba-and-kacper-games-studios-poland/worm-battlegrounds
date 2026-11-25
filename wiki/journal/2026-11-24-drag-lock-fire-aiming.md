---
title: "Aiming is drag, lock, FIRE; health and stamina bottom left; compact tag on your turn"
date: 2026-11-24
status: open
kind: changed
pages: ["Controls", "Match", "Weapons", "Tutorial"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/ControlHints/init.lua
---

**What changed.** Players' reviews called hold-to-charge aiming confusing, mobile players most. The owner picked the
"Ring: trackpad" scheme with medium dots from a playable drafts page, backed by a research report on how mobile
artillery games aim. Supersedes the 2026-11-10 Worms Armageddon hold-to-charge (practices' "Shooting is Worms
Armageddon's").

- **Drag to aim.** On your turn, press anywhere on the arena and drag. The crosshair moves like a trackpad from where
  it was, never jumping to your finger. Its direction from the snail is the angle, and its distance the power, up to a
  ring round the snail (full power).
  - The drag is scaled per device: a phone thumb gets 42% of the screen's height for the whole power, a mouse 22%
    (`AIM_DRAG_SHARE`).
- **Let go to lock, then FIRE.** FIRE sits over the weapon bar on every device (`U_Fire`). F, Enter or the pad's RT
  also fire.
  - Esc or the pad's B clears the aim, and so does dragging back to the snail.
  - Holding to charge, the power slider and the full charge that fired by itself are gone.
- **Your aim is kept** into your snail's next turn. Your first turn starts at 50% power, 45° toward your nearest enemy.
- **The aim's look.**
  - Kept light (the owner, the same day: "too much bloated… more subtle"): no power cone or bar. A small crosshair
    (`CROSSHAIR_SIZE` 2.6 units, was 3.4) rides the power's end, and a faint ring (2 px, 75% see-through) shows full
    power.
  - The power shows as the preview dots' colour, yellow at little through orange to red at full (`POWER_COLORS`).
  - The readout over the crosshair reads "62% · 41°" (18 px), or the angle alone for guns and swings.
  - FIRE is the button's text alone: the weapon icon under it is gone.
  - The aim zooms with the map, within limits (the owner's pick, the same day): never smaller than 0.75 or bigger than
    1.4 times its size at the camera's starting distance (`AIM_ZOOM_SCALE`). Fully zoomed in it's a little bigger
    still, so it stays clear of the snail. Before this it stayed one size on screen and only grew zoomed in. The drag
    needed for full power doesn't change with the zoom. Measured in Studio: the ring is 399 px across at the start,
    299 px zoomed out, 629 px zoomed in (1080 px tall screen).
- **Preview dots.** An arced weapon shows 9 small dots (0.75 to 0.45 units, was 12 at 1.1 to 0.6) along the start of
  its path, without wind, over 20% of a full-power shot's flight time (was 30%), so they reach further with more power
  (`PREVIEW_*`). The tutorial and the admin aimbot still
  show the whole path.
- **Other weapons.**
  - Guns and swings use the angle only.
  - Dynamite fires on FIRE with no aim.
  - A homing missile's press places its target, then FIRE.
  - Utilities are still used by any press.
- **Pad:** the right stick moves the crosshair the same way, finer for a gentle lean (`STICK_*`).
- **Bottom left:** your health ("Health 165", red) over your stamina, both in the stamina bar's look (`U_Bars`), each
  bar's text tilted 5° up along its slant (the owner's pick, the same day). The
  jetpack's fuel bar sits over both. On phones they sit above the walk buttons, and on pads above the hint strip.
  Health shows through the turns while your snail is in play.
- **Over your snail on your turn:** the turn arrow alone, all turn long: no name, badges or health bar (your health
  is at the bottom left), close over the snail (Snails' `OWN_TURN_TAG_OFFSET` 1.9 studs, raised from 1.5 so the held
  weapon shows under it; the full tag is 2.4; `OWN_TURN_TAG_SCALE` is gone). The arrow bobs only upward from its slot,
  never down into the health bar under it. After your turn the full tag comes back. No tag shows a level any more.
- **Other screens:** a snail's turn arrow hides when it moves, turns its aim or changes its power. Just having power
  no longer counts, since a kept aim starts with some.
- **Hints:**
  - The tutorial's hints are "Drag to aim" (pad: "Aim with {Aim}"), then "Press FIRE" ("Tap FIRE", pad "Press
    {Fire}"); its Throw and Wind steps are gone (`2026-11-24-tutorial-one-shot`).
  - The control hints read Aim and Fire.
  - The tips explain drag, lock, FIRE and the kept aim.
  - The pad's hints read "Aim and power", "Fire" and "Clear aim".

**How to check.** In a match on your turn, drag from empty space: the crosshair moves from where it was and the
readout changes. Let go, then press FIRE: the shot goes. On your next turn the crosshair is where you left it.

**Checked.** In a Studio match on Picnic Plains: the dots over the terrain in the power's colour, the small
crosshair on the faint ring, FIRE with its text alone, shown once the turn's intro ends. The compact tag over the snail
wasn't seen in captures (they skip AlwaysOnTop billboards); its values were confirmed in code: name hidden, offset
1.9, arrow visible.

**For the wiki.** Controls: the new aiming on mouse, touch and pad. Match: the HUD's bottom-left bars, the FIRE
button, the tag on your turn. Tutorial: its Aim and Fire steps (`2026-11-24-tutorial-one-shot`).
