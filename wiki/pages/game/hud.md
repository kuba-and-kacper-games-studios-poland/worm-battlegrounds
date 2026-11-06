---
title: "Match screen"
summary: "What the player sees during a match: the turn panel at the top, the worms' tags, the crosshair and power, the loadout bar with stamina and power at the bottom, and the results."
icon: frame
status: active
order: 4
type: "Screen"
tags: [game, ui]
infobox:
  Top: "Whose turn · timer · wind"
  Top left: "Leave · Music · Settings · Chat · Voice chat"
  Top right: "Kill feed"
  Bottom: "Stamina and power · the loadout bar"
questions:
  - id: settings-list
    text: "The Worm Battlegrounds in-match Settings panel holds the settings listed on the Match screen page (music and sound volume, trajectory line, damage numbers, camera follows the shot, show tips again). Which should be in it at launch? Pick every one."
    multiple: true
    options: ["Music volume", "Sound effects volume", "Trajectory line", "Damage numbers", "Camera follows the shot", "Show tips again"]
    status: resolved
    answer: ["Music volume", "Sound effects volume", "Damage numbers", "Camera follows the shot"]
    decided: 2026-11-03
  - id: top-bar-extra
    text: "Roworld's top bar also has chat, voice chat, help and a leaderboard. Which of these should the Worm Battlegrounds match screen's top bar have? Pick every one."
    multiple: true
    options: ["Chat", "Voice chat mute", "Help", "Leaderboard of the match"]
    status: resolved
    answer: ["Chat", "Voice chat mute"]
    decided: 2026-11-03
  - id: rematch-map
    text: "Worm Battlegrounds' results screen has a Rematch button that plays again with the same players on the same server. Does the rematch replay the same map, or a new random map that fits the same number of players?"
    options: ["The same map", "A new random map of the same size"]
  - id: tag-timer
    text: "Worm Battlegrounds shows the turn's 15-second timer only in the turn panel at the top of the match screen, which now names whose turn it is for every player; the active worm's tag shows just a down arrow. It was decided earlier that the timer shows above the active worm's head for everyone but its player. Put the timer back on the active worm's tag as well, or keep it only in the turn panel?"
    options: ["Only in the turn panel at the top", "On the tag too, for everyone but the active player"]
suggestions:
  - id: turn-banner
    text: "Show whose turn it is at the top middle of the Worm Battlegrounds match screen, with that player's name, team color and the 15-second timer, so everyone knows who's shooting?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Above the active worm's head for everyone else, and at the top of the screen for the player whose turn it is"
    decided: 2026-11-03
  - id: wind-hud
    text: "Put the wind arrow and its strength next to the turn timer at the top of the Worm Battlegrounds match screen, so aiming and wind are read in one place?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Yes"
    decided: 2026-11-03
  - id: health-bars
    text: "Show each worm's health as a number above its head on the Worm Battlegrounds match screen, in its team's color, like in Worms?"
    options: [Yes, Later, No]
    status: resolved
    answer: "A number and a bar above each worm's head"
    decided: 2026-11-03
  - id: knockout-moment
    text: "On Roblox, ring-outs are the PvP moment players clip and share, and a Worm Battlegrounds worm knocked into water or lava or off the map is one. When that happens, slow the match screen's camera to half speed for 1 second on the falling worm, with a splash or sizzle sound sting, for every player?"
    options: [Yes, Later, No]
  - id: best-shot-replay
    text: "Worm Battlegrounds' results screen lists each match's best shot as a stat. Play the best shot back as a 5-second replay on the results screen, before the placings, so the match ends on its funniest moment?"
    options: [Yes, Later, No]
  - id: quick-chat
    text: "Since January 2026, Roblox players need an age check to chat, so many players in a Worm Battlegrounds match can't type. Add a free quick-chat wheel on the match screen with 6 preset lines ('Nice shot!', 'Oops', 'GG', 'Watch this', 'Missed!', 'Help!') shown above the worm?"
    options: [Yes, Later, No]
  - id: win-streak
    text: "RIVALS shows each player's win streak in its lobby, and players chase it. Show a Worm Battlegrounds player's win streak beside their name in the waiting room and above their worm during a match, once it reaches 3 public wins in a row?"
    options: [Yes, Later, No]
  - id: best-shot-weapon
    text: "Worm Battlegrounds' results screen shows each player's best shot as its damage only ('Best shot: 95'). Name the weapon too ('Best shot: 95 with the Bazooka'), so the line reads like a highlight?"
    options: [Yes, Later, No]
---

The match screen keeps the battlefield clear: whose turn it is at the top, a row of buttons at the top left, the kill
feed at the top right, and the player's stamina, power and loadout along the bottom. The coins and diamonds bar from
the lobby is hidden during a match: what the match pays shows on the results.

## Before the turns

- **Waiting for players:** the map shows behind "Waiting for players" and the count of who has arrived (`1 / 2`).
  A match that can't start sends everyone back to the lobby.
- **The drop:** "Pick where to land" and its 15-second timer. The player's marker follows the mouse (or the left
  stick) and is faded where a worm doesn't fit; a click, a tap or :kbd[A] places it. See
  [[Match modes & maps#Starting a match]].

## Top bar (top left)

| Button | What it does |
|---|---|
| **Leave** | Asks first, then leaves the match and goes back to the [[Lobby]]. The player's worm **dies and turns into a ghost**, and the player is placed last among the players still alive, which sets their coins (see [[Currencies & crates#Coins from a match]]) |
| **Music** | Turns the music off and on with one tap |
| **Settings** | Opens the Settings panel below |
| **Chat** | Opens the match chat (Roblox's own) |
| **Voice chat** | Mutes and unmutes the player's microphone (Roblox's own) |

Every button works with a mouse, a tap or a controller (see [[Controls & platforms]]).

## Whose turn, wind and health

- **The turn panel,** at the top middle, for every player:
  - On the player's own turn: **"YOUR TURN!"**.
  - On another worm's turn: that worm's name in its team's colour (**"BAX'S TURN"**), and under it when the
    player's turn comes: **"YOU'RE NEXT!"** or **"YOUR TURN IN 3 TURNS"**, counting down each turn. Knocked-out worms
    drop out of the count, and the line hides once the player's own worm is out.
  - The **timer** with a clock, counting down from 15. It's blank while a shot flies and settles.
  - The **wind**: a wind picture, an arrow for its direction and its strength (0–10). It changes every turn.
- **Worm tags:** every worm has a tag over its head: its name in its team's colour (gold for a VIP), its level
  ("Lv 12"), and its **health as a big number over a bar**. The bar's colour shows the health: green at full, yellow
  at half, red near empty. The worm whose turn it is shows a down arrow over its tag. Tags grow and shrink with the
  screen. Worms start with 200 health.
- **Damage numbers:** a hit pops a number ("-50") over the worm that rises and fades (the **Damage numbers** setting).
- **The held weapon:** on its turn, the active worm holds the weapon it picked, on the side facing the camera, turned
  to its aim, so everyone sees whose turn it is and what they hold.
- **The crosshair and power:** every player sees the active worm's crosshair and its power circles while it aims
  (see [[Controls & platforms#Controls]]).
- **Blasts** flash and smoke, throw chunks of the ground, and shake the screen; phones and controllers vibrate (see
  [[Controls & platforms#Feel]]).

## Bottom: stamina, power and the loadout bar

One row along the bottom, in one dark panel:

- **Stamina:** during the player's turn, a bar reading **"Stamina 70%"** shows how much farther the worm can walk.
  Jumping doesn't use it.
- **Power:** while aiming, a bar beside it reads **"Power 60%"**, with the angle ("45°").
- **The loadout bar** under them: the Bazooka's box, then one box per slot (3, up to 5), each with the weapon's or
  utility's picture (its model when it has no icon yet). The selected one is blue. Each box shows its **uses left**
  in its corner ("x3"; nothing for the Bazooka, which never runs out) and, on PC, its key. Players pick from it with
  :kbd[1]–:kbd[6] or a click on PC, a tap on phone and tablet, and :kbd[LB] / :kbd[RB] on console. See
  [[Loadout & inventory]].
- **The smiley** right of the bar opens the emote wheel (see [[Emotes]]).
- **On phones and tablets** the walk buttons sit in the bottom-left corner and **Jump** in the bottom-right, on the
  bar's line.

## Teams and kill feed

- **Team colors:** Red, Blue, Green and Yellow. A worm's name is in its team's color. In a free-for-all, each player
  gets their own color.
- **Kill feed:** at the **top right**, under the top bar: a line for every knockout, like "Bax knocked out Ninja with
  the Black hole grenade" or "Turbo fell into the water". It shows 4 lines, each for 6 seconds; a long line wraps onto
  two.

## Knocked out

A player whose worm is knocked out can **spectate** the rest of the match or **leave** at once. Leaving after a
knockout keeps their place and coins (it's not the same as the Leave button while still alive).

## End of match

When a match ends, every player sees a **results screen**, which can't be closed:

- **Placings:** a lineup of player cards side by side, one per player: place, avatar, name in team colour, coins.
  Four fit across a widescreen; on a phone six of eight show and the rest scroll.
- **You earned:** the player's coins and XP (with a line when they level up), and their match stats under it:
  damage dealt, knockouts and the best shot (its damage).
- **Rematch:** a vote to play again with the same players on the same server, with the votes so far and 20 seconds to
  vote; or **Back to lobby**. The tutorial match skips the rematch.

## Settings

A panel like Roworld's: **"Settings — saved for next time"**, one row per setting, and a **Done** button.

| Setting | Kind |
|---|---|
| Music | Volume slider, 0–100% |
| Sound effects | Volume slider, 0–100% |
| Damage numbers | On / off: numbers that pop up when a worm is hit (on) |
| Camera follows the shot | On / off (on) |

## History

:::changelog
- 2026-11-03: The first match screen: turn banner, timer, wind, stamina, kill feed, loadout bar, touch buttons, knocked-out panel, results with Rematch, and the Damage numbers and Camera follows the shot settings.
- 2026-11-04: Every part in the GUI kit's look, sized for each device.
- 2026-11-05:
  - The turn panel names whose turn it is and says when the player's turn comes; the timer goes blank while a shot flies; a clock and a wind picture.
  - Worm tags: a big health number, a bar coloured by health, the turn arrow only; tags and damage numbers scale with the screen.
  - One bottom row: stamina and power on the loadout bar, uses left on each slot, models for weapons without a picture.
  - The currency bar is hidden during matches; the waiting screen no longer shows the Roblox avatar.
  - The results show placings as a lineup of player cards.
  - Worms hold their weapon; blasts shake the screen and vibrate phones and controllers.
  - The kill feed wraps long lines; damage numbers are no longer cut off.
- 2026-11-06: The crosshair and power circles replace the aim line, seen by every player.
:::

::navbox{from="game"}
