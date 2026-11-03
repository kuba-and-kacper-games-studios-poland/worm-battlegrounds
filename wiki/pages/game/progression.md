---
title: "Levels & XP"
summary: "Players earn XP from matches, level up, and unlock 3 exclusive worm skins at levels 25, 50 and 100."
icon: bookmark
status: planned
order: 8
type: "System"
image: "/assets/level-skins.png"
caption: "Prisoner, Wizard and FBI Agent"
tags: [game, progression]
infobox:
  Earn: "XP from matches"
  Max level: "100 (about 300 matches)"
  Reward skins: "Prisoner (25) · FBI Agent (50) · Wizard (100)"
questions:
  - id: xp-source
    text: "Worm Battlegrounds players earn XP to level up. What gives XP? Pick every one."
    multiple: true
    options: ["Playing a match", "Finishing place", "Each knockout", "Damage dealt"]
    status: resolved
    answer: ["Playing a match"]
    decided: 2026-11-03
  - id: level-pace
    text: "How long should it take a Worm Battlegrounds player to reach level 100, the last reward skin? A number of matches, or of weeks of regular play."
    status: resolved
    answer: "About 300 matches"
    decided: 2026-11-03
  - id: level-skins
    text: "Worm Battlegrounds gives 3 exclusive worm skins for reaching levels 25, 50 and 100. What are they? One line each: the level, then the skin."
    status: resolved
    answer: "Level 25: Prisoner. Level 50: FBI. Level 100: Wizard (grey)"
    decided: 2026-11-03
---

Every match played gives the player **XP**: the same for every match, win or lose. Reaching **level 100**, the
maximum, takes about **300 matches**. Enough XP raises their **level**, which shows next to their name in the
[[Lobby]] and in matches.

## XP and levels

A first proposal: every match gives **100 XP**. Going from level *n* to *n + 1* takes **100 + 4 × n XP**, so early
levels come fast and later ones slower:

| Level | XP for the next level | Total XP to reach it | ≈ Matches |
|---|---|---|---|
| 10 | 140 | 1,080 | 11 |
| 25 | 200 | 3,600 | 36 |
| 50 | 300 | 9,800 | 98 |
| 100 | — | 29,700 | **297** |

## Level rewards

Three worm skins can't be found in any crate: they're unlocked only by reaching a level.

| Level | Reward |
|---|---|
| 25 | **Prisoner** worm skin |
| 50 | **FBI Agent** worm skin |
| 100 | **Wizard** worm skin (grey) |

![The level reward skins: Prisoner, Wizard and FBI Agent](/assets/level-skins.png "Level rewards: Prisoner (25), Wizard (100), FBI Agent (50)")

All skins are built from **studded bricks**, like the rest of the game. The Wizard is grey, with a grey hat, beard
and robe; the FBI Agent wears a black suit, hat and sunglasses.

:::callout{tone="warning"}
**The Prisoner in this picture is wrong.** It must wear a **black-and-white striped** prison shirt and a
**black-and-white striped cap**, with the 017 number tag, not the orange jumpsuit. It needs a redraw in the studded
style.
::: See [[Currencies & crates#Skin crate]] for the crate skins.

::navbox{from="game"}
