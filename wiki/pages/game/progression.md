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
suggestions:
  - id: weapon-mastery
    text: "RIVALS gives every weapon its own kills track, with rewards from the 5th kill up to finishers at 20,000–40,000 kills, so long-time players always have a goal that never changes match balance. Give each Worm Battlegrounds weapon a mastery track: at 10, 50, 250 and 1,000 knockouts it gives a cosmetic (a badge, then a gold trim, then a knockout effect, then a title)?"
    options: [Yes, Later, No]
  - id: past-100
    text: "Worm Battlegrounds' levels stop at 100, about 300 matches, after the Wizard skin; then XP has no use. Let levels keep counting past 100, with a prestige star beside the player's name every 100 levels and 100 coins every 10 levels?"
    options: [Yes, Later, No]
  - id: weekly-board
    text: "Roblox PvP games keep their best players with a board that resets every week: Jujutsu Shenanigans' weekly kills board gives a title to its top 6. Add a weekly Worm Battlegrounds leaderboard in the lobby, counting public-match wins, where the top 10 wear a title over their worm the next week?"
    options: [Yes, Later, No]
  - id: daily-challenges
    text: "A Worm Battlegrounds daily login reward is decided against. Daily challenges are different: 3 small goals that reset each day at a fixed hour ('knock a worm into water', 'win a match with the Grenade'), paid only for playing; RIVALS, Murder Mystery 2 and Fisch use them to bring players back. Add 3 daily challenges, and what do they pay?"
    options: ["Yes, each pays 25 coins", "Yes, each pays 50 XP on top of the XP from playing", "No daily challenges"]
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
