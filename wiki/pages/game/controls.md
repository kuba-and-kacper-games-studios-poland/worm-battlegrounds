---
title: "Controls & platforms"
summary: "How players move, aim with the crosshair, charge the power and fire on PC, phone and tablet, and console."
icon: compass
status: active
order: 3
type: "System"
tags: [game, controls]
infobox:
  Platforms: "PC · Phone · Tablet · Console"
  Turn: "15 seconds to move, aim and fire"
  Aim: "Crosshair, hold to charge, let go to fire"
  Full charge: "1.6 seconds"
questions:
  - id: pc-aim
    text: "In this first draft, Worm Battlegrounds players on PC aim with the mouse: the shot goes toward the cursor. Should keyboard aiming (W and S raise and lower the angle, like Worms) also work, for players who prefer it?"
    options: ["Mouse only", "Mouse and keyboard both work", "Keyboard only, like Worms"]
    status: resolved
    answer: "A crosshair that points at the mouse; hold the button to charge, let go to fire (changed 2026-11-06 at the owner's request; was a mouse drag, its direction the angle and its length the power)"
    decided: 2026-11-06
  - id: touch-aim
    text: "In this first draft, Worm Battlegrounds players on phone and tablet aim by dragging back from their worm like a slingshot: the direction sets the angle, the length sets the power, and letting go fires. Is that the touch control you want, or a GunBound-style angle wheel with a hold-to-charge Fire button?"
    options: ["Slingshot drag", "Angle wheel and hold-to-charge Fire button"]
    status: resolved
    answer: "Press and hold where you want to aim: the crosshair points at the finger, holding charges, letting go fires (changed 2026-11-06 with PC aiming; was the slingshot drag)"
    decided: 2026-11-06
  - id: power-same
    text: "On PC and console, Worm Battlegrounds players set power by holding the fire button: a bar fills and the shot fires on release. Should the bar fill once and stop at full, or go up and down until released (like GunBound)?"
    options: ["Fill once and stop at full", "Go up and down until released"]
    status: resolved
    answer: "Go up and down until released, on every device: full in 1.6 seconds, back to none in 1.6, and only letting go fires (changed 2026-11-06 at the owner's request; PC and touch used the drag before)"
    decided: 2026-11-06
  - id: leave-rules
    text: "Worm Battlegrounds has a Leave game button at the top left during a match, and a player who leaves is placed last among the players still alive. What happens to their worm on the map?"
    options: ["Their worm is removed", "An AI takes over their worm", "Their worm stays and skips its turns"]
    status: resolved
    answer: "The worm dies and turns into a ghost"
    decided: 2026-11-03
suggestions:
  - id: trajectory-preview
    text: "Show a short dotted line from the worm's weapon in Worm Battlegrounds while aiming (the first part of the shot's path, without wind), so aiming feels the same on every device?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Built on 2026-11-03, then replaced on 2026-11-06 by the crosshair and power circles at the owner's request: no path preview"
    decided: 2026-11-06
  - id: last-shot
    text: "Mark where the player's last shot was aimed and how much power it had in Worm Battlegrounds (a ghost line and a tick on the power bar), so they can adjust from it next turn like in GunBound?"
    options: [Yes, Later, No]
  - id: camera
    text: "Let Worm Battlegrounds players pan the 2D camera during their 15-second turn (drag on touch, right stick on console, edge of the screen or right mouse on PC) to see where they're shooting on the HUGE map?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Yes"
    decided: 2026-11-03
  - id: pad-zoom
    text: "Worm Battlegrounds' match camera zooms between 45 and 200 studs with the mouse wheel and a pinch, but a controller has no way to zoom. Let console players zoom with the right stick's up and down while LT is held (LT plus left and right already pans)?"
    options: [Yes, Later, No]
  - id: feel-setting
    text: "Worm Battlegrounds blasts shake the camera and vibrate phones and controllers, and no setting turns either off. Add a 'Screen shake and vibration' switch (on by default) to the Settings panel, for players who get motion sick or play on a quiet phone?"
    options: [Yes, Later, No]
---

Worm Battlegrounds plays on **PC, phone, tablet and console**, so every action needs a control that feels natural on each.
A turn is always the same: in 15 seconds the player **moves** their worm, picks an item from their loadout, **aims**
the crosshair (the direction), **holds** to charge the power (how far), then **lets go** to fire. See
[[Match modes & maps#Turns]].

## Controls

| Action | PC | Phone & tablet | Console |
|---|---|---|---|
| Move left / right | :kbd[A] :kbd[D] or arrow keys | On-screen ◀ ▶ buttons, bottom left | Left stick or D-pad |
| Jump (from the ground, unlimited) | :kbd[Space] | Jump button, bottom right | :kbd[A] (Xbox) / :kbd[✕] (PlayStation) |
| Pick an item | :kbd[1] the Bazooka, :kbd[2] to :kbd[6] the slots, or click it in the bar | Tap it in the bar at the bottom | :kbd[LB] / :kbd[RB] |
| Aim | Move the mouse: the crosshair points at it | Press where you want to aim | Right stick |
| Power | Hold the left mouse button | Keep the finger down | Hold :kbd[RT] |
| Fire | Let go | Let go | Let go of :kbd[RT] |
| Cancel a charge | Right mouse or :kbd[Esc] | Put a second finger down | :kbd[B] |
| Look around the map | Drag with the right mouse | Drag with two fingers | Hold :kbd[LT] and move the right stick |
| Zoom | Mouse wheel | Pinch | — |

**Aiming works like Worms.** On the player's turn a **crosshair** sits beside their worm, 9 studs away, in the
direction they aim. Holding the button charges the power, drawn as a **row of circles** from the tip of the weapon's
barrel to the crosshair that light up yellow to red. The power climbs to full in **1.6 seconds**, falls back to none
in 1.6, and keeps going up and down until the player lets go; letting go fires at the power shown. Nothing fires by
itself: if the turn runs out while charging, no shot goes. Guns and melee weapons (Shotgun, Uzi, Minigun, Baseball
bat, One Punch) fire on the press, at the crosshair, with no charge. There is no line showing the shot's path: the
crosshair shows the direction only.

- **Homing missile:** tap or click a target first, then aim and fire.
- **Black hole grenade:** it's released at the worm's feet; press fire again while it rolls to set it off.
- **Utilities** are used as soon as they're picked in the bar on the player's turn.

**The camera.** It follows the active worm, and the shot in flight while the **Camera follows the shot** setting is
on. Players pan to see where they're shooting, which matters most on the HUGE map, and zoom between 45 and 200 studs
from the arena; the zoom stays for the rest of the match.

## Feel

Blasts **shake the camera**, harder for bigger blasts and those nearer the middle of the view. Phones and controllers
**vibrate**: a short tick when the player fires, a thump for a big or near blast (a lighter one for a small or far
one), and a longer rumble when the player's own worm is hurt. Nothing shakes or vibrates in the lobby, and no setting
turns it off yet.

## In a match

The buttons on screen during a match (Leave and Music at the top) and the loadout bar at the bottom are on the
[[Match screen]] page.

## Rules for every device

- **The same steps everywhere:** pick, aim, charge, let go. Only the input changes.
- **Aim and power are always visible:** the crosshair and the power circles on the worm, and the power and angle on
  the loadout bar ("Power 60%", "45°"), on every device. Every player in the match sees the active worm's crosshair
  and power, bots' included.
- **Big touch targets** on phone and tablet, kept at the edges so fingers don't cover the worm.
- **Console works without a mouse:** every lobby menu can be reached with the D-pad, and the selected button is
  highlighted.
- **The timer is always on screen,** counting down from 15.

## History

:::changelog
- 2026-11-03: First controls: a drag to aim on PC and touch (direction for the angle, length for the power), the right stick and a rising-and-falling power bar on console; panning on every device.
- 2026-11-05:
  - Every player sees the active worm's aim, bots' too.
  - Zoom with the mouse wheel and a pinch.
  - Blasts shake the camera; phones and controllers vibrate.
- 2026-11-06:
  - Aiming is a crosshair and a held charge on every device; the charge goes up and down until the player lets go.
  - The power circles start at the weapon's barrel, and the crosshair keeps its size when zooming.
:::

::navbox{from="game"}
