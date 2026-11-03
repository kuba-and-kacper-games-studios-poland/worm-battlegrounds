---
title: "Controls & platforms"
summary: "How players move, aim, set power and fire on PC, phone and tablet, and console."
icon: compass
status: idea
order: 3
type: "System"
tags: [game, controls]
infobox:
  Platforms: "PC · Phone · Tablet · Console"
  Turn: "15 seconds to move, aim and fire"
questions:
  - id: pc-aim
    text: "In this first draft, Worm Battlegrounds players on PC aim with the mouse: the shot goes toward the cursor. Should keyboard aiming (W and S raise and lower the angle, like Worms) also work, for players who prefer it?"
    options: ["Mouse only", "Mouse and keyboard both work", "Keyboard only, like Worms"]
    status: resolved
    answer: "Mouse drag: drag direction sets the angle, drag length sets the power, release fires"
    decided: 2026-11-03
  - id: touch-aim
    text: "In this first draft, Worm Battlegrounds players on phone and tablet aim by dragging back from their worm like a slingshot: the direction sets the angle, the length sets the power, and letting go fires. Is that the touch control you want, or a GunBound-style angle wheel with a hold-to-charge Fire button?"
    options: ["Slingshot drag", "Angle wheel and hold-to-charge Fire button"]
    status: resolved
    answer: "Slingshot drag"
    decided: 2026-11-03
  - id: power-same
    text: "On PC and console, Worm Battlegrounds players set power by holding the fire button: a bar fills and the shot fires on release. Should the bar fill once and stop at full, or go up and down until released (like GunBound)?"
    options: ["Fill once and stop at full", "Go up and down until released"]
    status: resolved
    answer: "PC and touch use the drag (no bar). On console the power bar goes up and down while RT is held"
    decided: 2026-11-03
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
  - id: last-shot
    text: "Mark where the player's last shot was aimed and how much power it had in Worm Battlegrounds (a ghost line and a tick on the power bar), so they can adjust from it next turn like in GunBound?"
    options: [Yes, Later, No]
  - id: camera
    text: "Let Worm Battlegrounds players pan the 2D camera during their 15-second turn (drag on touch, right stick on console, edge of the screen or right mouse on PC) to see where they're shooting on the HUGE map?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Yes"
    decided: 2026-11-03
---

Worm Battlegrounds plays on **PC, phone, tablet and console**, so every action needs a control that feels natural on each.
A turn is always the same: in 15 seconds the player **moves** their worm, picks an item from their loadout, **aims**
(the direction) and sets the **power** (how far), then **fires**. See [[Match modes & maps#Turns]].

## Controls

| Action | PC | Phone & tablet | Console |
|---|---|---|---|
| Move left / right | :kbd[A] :kbd[D] or arrow keys | On-screen ◀ ▶ buttons, bottom left | Left stick or D-pad |
| Jump (unlimited) | :kbd[Space] | Jump button, bottom right | :kbd[A] (Xbox) / :kbd[✕] (PlayStation) |
| Pick an item | :kbd[1] to :kbd[5], or click it in the bar | Tap it in the bar at the bottom | :kbd[LB] / :kbd[RB] |
| Aim | Drag with the mouse: the drag's direction sets the angle | Drag with a finger, the same way | Right stick |
| Power | The length of the drag | The length of the drag | Hold :kbd[RT]: the power bar goes up and down |
| Fire | Release the mouse button | Let go | Release :kbd[RT] at the power you want |
| Cancel the aim | Right mouse or :kbd[Esc] | Drag back onto the worm | :kbd[B] |
| Look around the map | Drag with the right mouse, or the screen edge | Drag with two fingers | Hold :kbd[LT] and move the right stick |

PC, phone and tablet share **one drag mechanic**: press, drag (direction = angle, length = power), let go to fire.
Console can't drag, so it aims with the right stick and sets power with a bar that rises and falls while :kbd[RT] is
held. Players can **pan the camera** during their turn to see where they're shooting, which matters most on the
HUGE map.

## In a match

The buttons on screen during a match (Leave game, Mute music, Settings) and the loadout bar at the bottom are on the
[[Match screen]] page.

## Rules for every device

- **The same steps everywhere:** pick, aim, set power, fire. Only the input changes.
- **Aim and power are always visible:** an angle marker on the worm and a power bar, on every device.
- **Big touch targets** on phone and tablet, kept at the edges so fingers don't cover the worm.
- **Console works without a mouse:** every lobby menu can be reached with the D-pad, and the selected button is
  highlighted.
- **The timer is always on screen,** counting down from 15.

::navbox{from="game"}
