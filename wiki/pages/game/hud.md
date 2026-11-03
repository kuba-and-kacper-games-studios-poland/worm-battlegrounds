---
title: "Match screen"
summary: "What the player sees during a match: the top bar with Leave game, Mute music and Settings, and their loadout at the bottom."
icon: frame
status: planned
order: 4
type: "Screen"
tags: [game, ui]
infobox:
  Top left: "Leave game · Mute music · Settings · Chat · Voice chat"
  Bottom: "The player's loadout"
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
---

The match screen keeps the battlefield clear: a row of round buttons at the top left, and the player's loadout along
the bottom. It follows Roworld's in-game top bar.

## Top bar (top left)

| Button | What it does |
|---|---|
| **Leave game** | Leaves the match and goes back to the [[Lobby]]. The player's worm **dies and turns into a ghost**, and the player is placed last among the players still alive, which sets their coins (see [[Currencies & crates#Coins from a match]]) |
| **Mute music** | Turns the music off and on with one tap |
| **Settings** | Opens the Settings panel below |
| **Chat** | Opens the match chat |
| **Voice chat** | Mutes and unmutes the player's microphone |

Every button works with a mouse, a tap or a controller (see [[Controls & platforms]]).

## Stamina bar

During the player's turn, a **stamina bar** shows how much farther the worm can walk. Jumping doesn't use it.

## Teams and kill feed

- **Team colors:** Red, Blue, Green and Yellow. A worm's name, health and outline are in its team's color. In a
  free-for-all, each player gets their own color.
- **Kill feed:** at the **top right**, a line for every knockout, like "Bax knocked out Ninja with the Black hole grenade".

## Knocked out

A player whose worm is knocked out can **spectate** the rest of the match or **leave** at once. Leaving after a
knockout keeps their place and coins (it's not the same as the Leave game button while still alive).

## End of match

When a match ends, every player sees a **results screen**:

- **Placings:** every player's place, in team colors
- **What they earned:** coins and XP
- **Match stats:** damage dealt, knockouts and the best shot
- **Rematch:** play again with the same players, or go back to the lobby

## Settings

A panel like Roworld's: **"Settings — saved for next time"**, one row per setting, and a **Done** button.

| Setting | Kind |
|---|---|
| Music | Volume slider, 0–100% |
| Sound effects | Volume slider, 0–100% |
| Damage numbers | On / off: numbers that pop up when a worm is hit |
| Camera follows the shot | On / off |

## Whose turn, wind and health

- **Whose turn:** for the player whose turn it is, a banner at the **top of the screen** with the 15-second timer.
  Everyone else sees the marker and timer **above that worm's head**.
- **Wind:** an arrow and its strength (0–10) at the top, beside the timer. It changes every turn.
- **Health:** every worm shows a **number and a bar** above its head, in its team's color. Worms start with 200.

## Loadout bar (bottom)

A **smiley button** sits just above the loadout bar and opens the emote wheel (see [[Emotes]]).

The bottom of the screen always shows the player's **current loadout**: one box per slot (3, up to 5), each with the
weapon's or utility's icon. The selected one is highlighted. Players pick from it with :kbd[1]–:kbd[5] or a click on
PC, a tap on phone and tablet, and :kbd[LB] / :kbd[RB] on console. See [[Loadout & inventory]].

::navbox{from="game"}
