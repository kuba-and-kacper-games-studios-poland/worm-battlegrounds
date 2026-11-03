---
title: "Arsenal"
summary: "The 13 weapons and 6 utilities Worm Battlegrounds launches with."
icon: sword
status: idea
order: 6
type: "Item list"
image: "/assets/weapons.png"
caption: "The weapons, in studded-brick style"
tags: [game, items]
infobox:
  Weapons: "13"
  Utilities: "6"
questions:
  - id: weapon-list
    text: "Worm Battlegrounds launches with 13 weapons. Which are they? One line per weapon: its name and what it does (like 'Grenade: bounces, explodes after 3 seconds')."
    status: resolved
    answer: "Grenade, Shotgun, Uzi, Spider bomb, Cluster bomb, Dynamite, Baseball bat, Homing missile, Sheep, Variety grenade, Minigun, Hadoken, Spartan spear"
    decided: 2026-11-03
  - id: utility-list
    text: "Worm Battlegrounds launches with 5 utilities, with a jetpack and a speed boost among them. What are the other 3? One line each: name and what it does."
    status: resolved
    answer: "Jetpack, Speed, Parachute, Bandage, Medkit, Low gravity (6 utilities)"
    decided: 2026-11-03
  - id: rarity
    text: "Weapons in Worm Battlegrounds drop from the coin and diamond crates. Do weapons have rarities that set how often they drop?"
    options: ["Yes: Common, Rare, Epic, Legendary", "Yes: Common, Rare, Legendary", "No rarities"]
    status: resolved
    answer: "5 tiers: Common, Uncommon, Rare, Epic, Legendary"
    decided: 2026-11-03
  - id: dynamite-turn
    text: "In Worm Battlegrounds, a turn ends as soon as the player shoots. Dynamite is dropped at the worm's own feet, so the worm can't run before it explodes. Should the Dynamite be the one exception that gives 3 seconds to run, or should it be thrown instead of dropped?"
    options: ["Dynamite gives 3 seconds to run", "Dynamite is thrown a short way", "Dynamite has a long fuse and goes off on the next turn"]
    status: resolved
    answer: "Dynamite explodes the moment it lands: a stronger grenade"
    decided: 2026-11-03
  - id: weapon-rarities
    text: "Worm Battlegrounds' 13 crate weapons each need one of the 5 rarities (Common, Uncommon, Rare, Epic, Legendary). One line per weapon: the weapon, then its rarity, like 'Grenade: Common'."
    status: resolved
    answer: "Common: Grenade, Shotgun. Uncommon: Uzi, Baseball bat, Dynamite, Spartan spear. Rare: Cluster bomb, Spider bomb, Minigun. Epic: Homing missile, One Punch. Legendary: Variety grenade, Sheep"
    decided: 2026-11-03
  - id: utility-turn
    text: "In Worm Battlegrounds, a turn ends as soon as the player shoots. Does using a utility (Jetpack, Speed potion, Parachute, Bandage, Medkit, Low gravity) also end the turn, or can the player use one and still shoot?"
    options: ["Using a utility doesn't end the turn", "Using a utility ends the turn", "Healing ends the turn; moving utilities don't"]
    status: resolved
    answer: "Using a utility doesn't end the turn; only shooting does"
    decided: 2026-11-03
  - id: big-three-uses
    text: "Worm Battlegrounds' One Punch has a 3-turn cooldown, and the Variety grenade and Sheep a 4-turn cooldown. A cooldown only matters when a weapon can be used more than once in a match. How many uses per match do these three get?"
    options: ["2 uses each", "Unlimited, with the cooldown as the only limit", "One Punch 2; Sheep and Variety grenade 1"]
    status: resolved
    answer: "1 use each"
    decided: 2026-11-03
  - id: utility-uses
    text: "Worm Battlegrounds' weapons have uses per match. Proposal for the utilities: Bandage 2, Medkit 1, Jetpack 2, Speed potion 2, Parachute 2, Low gravity 1. Use it, or one line per utility you'd change?"
    options: ["Use the proposal", "Change some (write which)"]
    status: resolved
    answer: "Use the proposal"
    decided: 2026-11-03
suggestions:
  - id: hadoken-name
    text: "'Hadoken' is a Capcom (Street Fighter) trademark. Should Worm Battlegrounds' energy-blast weapon get its own name, like Ki Blast, Power Wave or Fist Blast, to stay clear of trouble on Roblox?"
    options: ["Yes, rename it", "Keep Hadoken"]
    status: resolved
    answer: "Renamed to One Punch: a single heavy punch"
    decided: 2026-11-03
  - id: aim-type
    text: "Sort the 13 Worm Battlegrounds weapons by how they're aimed (angle-and-power shots that wind pushes, straight shots, placed explosives, air strikes), so the arsenal has a mix of each?"
    options: [Yes, No]
  - id: wind
    text: "Show the wind in Worm Battlegrounds like GunBound (an arrow and a strength from 0 to 10 at the top of the screen) that changes every turn and pushes angle-and-power shots?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Yes"
    decided: 2026-11-03
---

## Weapons

![All the weapons in studded-brick style](/assets/weapons.png "The weapons in studded-brick style. The Black hole grenade's art is still to come.")

All weapons are built from **studded bricks**, like the rest of the game.

:::callout{tone="warning"}
**Two pieces of this art need a redraw:**
- **Black hole grenade:** the first draft showed a sheep. It needs its own studded art: a dark grenade with a
  swirling purple black hole inside.
- **Spider bomb:** the red body with a black web and blue legs looks like Spider-Man's colors (Marvel). Give it
  other colors, like a black or green spider.
:::

13 at launch, plus the **Bazooka**, the basic weapon every player always has. Every player starts with the
Bazooka, the **Grenade** and the **Shotgun**; the other **11** drop from the weapon crate (100 coins) and the premium
crate (250 diamonds). Drop chances are on [[Currencies & crates#Drop chances]].

Collecting **10 copies** of a weapon turns it into its **shiny** version: a new look and a small boost. See
[[Currencies & crates#Duplicates and shiny items]].

Worms have **200 health**. "Max" is a direct hit; a blast does less the farther the worm is from its center.

| # | Weapon | Rarity | Damage | Aim | How it works |
|---|---|---|---|---|---|
| 0 | **Bazooka** (basic) | Always owned | 35 max | Arc, wind | A rocket that explodes on impact: medium blast, medium hole |
| 1 | **Grenade** | :badge[Common]{tone="neutral"} | 55 max | Arc, no wind | Bounces, then explodes after 3 seconds |
| 2 | **Shotgun** | :badge[Common]{tone="neutral"} | 5 pellets × 10 = 50 up close | Straight | 5 pellets that spread; up close all 5 hit, farther away fewer do. Small knockback |
| 3 | **Uzi** | :badge[Uncommon]{tone="good"} | 5 bullets × 10 = 50 | Straight | A short burst; each bullet pushes the worm a little, which can push it off a ledge |
| 4 | **Spider bomb** | :badge[Rare]{tone="accent"} | 70 max | Thrown, then crawls | Crawls along the ground and up walls toward the nearest enemy for 5 seconds, then explodes |
| 5 | **Cluster bomb** | :badge[Rare]{tone="accent"} | 25 + 5 bomblets × 15 = up to 100 | Arc, wind | Explodes on impact and scatters 5 bomblets that each explode |
| 6 | **Dynamite** | :badge[Uncommon]{tone="good"} | 85 at the center, 40 at the edge | Arc, no wind | A stronger grenade: explodes the moment it lands, with a big blast and a big hole |
| 7 | **Baseball bat** | :badge[Uncommon]{tone="good"} | 60 | Melee, pick a direction | Hits a worm right next to you and launches it far: the way to knock worms into water or lava |
| 8 | **Homing missile** | :badge[Epic]{tone="warn"} | 65 max | Tap a target, then fire | Flies up, then curves toward the marked spot; wind stops pushing it once it locks on |
| 9 | **Black hole grenade** | :badge[Legendary]{tone="bad"} | 100 at the center, 25 at the outer edge | Released at your feet | Rolls forward along the ground and hops over bumps. When it goes off, it bursts into a black hole. Tap fire again to blow it up at any time; it never explodes on its own. Much bigger blast than any other weapon |
| 10 | **Variety grenade** | :badge[Legendary]{tone="bad"} | 50 + 4 snails × 40 = up to 210 | Arc, no wind | A yellow ball that deals 50, then releases **4 snails** that eat down through the ground. Each snail hits 8 times as it crawls, 5 damage a hit, 40 in all. The 4 snails split off in **4 different directions**, so all 4 rarely hit the same worm; when they do, the full 210 can knock out a worm at full health, and that's intended |
| 11 | **Minigun** | :badge[Rare]{tone="accent"} | 20 bullets × 4 = 80 | Straight | A long spray of 20 bullets at long range with a strong total push |
| 12 | **One Punch** | :badge[Epic]{tone="warn"} | 80 | Melee | One huge punch that launches the worm sky-high |
| 13 | **Spartan spear** | :badge[Uncommon]{tone="good"} | 65 | Arc, wind | Pierces: hits every worm along its path, then sticks in the ground |

## Uses and cooldowns

Every weapon except the Bazooka has a number of **uses per match**. Some also have a **cooldown**: after using one, the
player waits that many of their own turns before using it again.

| Weapon | Uses per match | Cooldown (own turns) |
|---|---|---|
| Bazooka | Unlimited | — |
| Grenade | 2 | 1 |
| Shotgun | 4 | — |
| Uzi | 3 | — |
| Baseball bat | 3 | — |
| Dynamite | 2 | 2 |
| Spartan spear | 4 | — |
| Cluster bomb | 2 | 2 |
| Spider bomb | 2 | 2 |
| Minigun | 3 | — |
| Homing missile | 2 | 3 |
| One Punch | 1 | — |
| Variety grenade | 1 | — |
| Black hole grenade | 1 | — |

One Punch, Variety grenade and Black hole grenade can be used once per match, so they need no cooldown.

## Blast sizes and knockback

A first proposal, in studs. A worm is about 3 studs tall. Knockback is how far an explosion or hit throws a worm.

| Weapon | Blast radius | Knockback |
|---|---|---|
| Bazooka | 6 | Medium |
| Grenade | 6 | Medium |
| Shotgun | 1 per pellet | Small |
| Uzi | 1 per bullet | Small per bullet |
| Spider bomb | 6 | Medium |
| Cluster bomb | 4, bomblets 3 | Medium |
| Dynamite | 9 | High |
| Baseball bat | None (hit) | Very high |
| Homing missile | 6 | Medium |
| Black hole grenade | **14** | High |
| Variety grenade | 5, snails 2 each | Medium, snails small |
| Minigun | 1 per bullet | Small per bullet, high in total |
| One Punch | None (hit) | Extreme |
| Spartan spear | None (pierces) | Medium |

## Hazards

- **Water, lava and falling off the map** knock a worm out at once, whatever its health.
- **Falls** cost 1 health per stud above a safe height, 40 at most.

## Utilities

6 at launch. They move the worm, heal it or change how it moves, and use a loadout slot like a weapon (see
[[Loadout & inventory]]).

| # | Utility | Rarity | Uses per match | What it does |
|---|---|---|---|---|
| 1 | **Jetpack** | :badge[Rare]{tone="accent"} | 2 | Fly for a short time |
| 2 | **Speed potion** (blue) | :badge[Rare]{tone="accent"} | 2 | Drink it to move faster for the turn |
| 3 | **Parachute** | :badge[Uncommon]{tone="good"} | 2 | Float down slowly instead of falling, so a big drop doesn't hurt |
| 4 | **Bandage** | :badge[Uncommon]{tone="good"} | 2 | Heals 40 health |
| 5 | **Medkit** | :badge[Epic]{tone="warn"} | 1 | Heals 100 health |
| 6 | **Low gravity potion** | :badge[Legendary]{tone="bad"} | 1 | Drink it: the worm jumps higher and falls slower for the turn. The best utility |

![The utilities in studded-brick style](/assets/utilities.png "The utilities. The Low gravity potion's art is still to come.")

The Speed potion is **blue**. The Low gravity potion is a **potion bottle** too, so it needs its own studded art
(a purple bottle, to tell it apart from the blue Speed potion).

Utilities drop from the **utility crate** (see [[Currencies & crates#Utility crate]]).
Using a utility **doesn't end the turn**: the player still has to shoot. Worms start with 200 health, which is also the most they can have: healing never goes above 200.

::navbox{from="game"}
