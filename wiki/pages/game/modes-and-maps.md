---
title: "Match modes & maps"
summary: "Round-based matches of 2 to 8 players, 15 seconds a turn, free-for-all or teams, on 5 maps plus 1 HUGE map for 8."
icon: map
status: planned
order: 2
type: "System"
tags: [game, matches]
infobox:
  Players: "2 · 4 · 6 · 8"
  Teams: "Solo · Duo · Trio · Quads"
  Turn: "15 seconds"
  Maps: "5 + 1 HUGE map (8 players)"
questions:
  - id: trio-sizes
    text: "Worm Battlegrounds matches hold 2, 4, 6 or 8 players. Trios fit 6 players (3v3) but not 4 or 8. Should Trio matches only exist at 6 players, or should a 9-player size be added for 3v3v3?"
    options: ["Trios only at 6 players (3v3)", "Add 9 players for 3v3v3", "Trios fill 8 with one team of 2"]
    status: resolved
    answer: "Trios only at 6 players (3v3)"
    decided: 2026-11-03
  - id: big-map-modes
    text: "Worm Battlegrounds launches with 5 maps and 1 bigger map. Is the bigger map only for 8-player matches, or for any size?"
    options: ["Only 8-player matches", "6 and 8 players", "Any size"]
    status: resolved
    answer: "Only 8-player matches"
    decided: 2026-11-03
  - id: turn-time
    text: "How long does one Worm Battlegrounds turn last? A number of seconds to aim and fire (Worms uses about 45)."
    status: resolved
    answer: "15 seconds"
    decided: 2026-11-03
  - id: after-shot
    text: "A Worm Battlegrounds turn gives the player 15 seconds to aim and fire. After the shot, does the worm get a few seconds to move to cover (Worms gives 3), or does the turn end at once?"
    options: ["3 seconds to move after the shot", "The turn ends at once"]
    status: resolved
    answer: "The turn ends as soon as the player shoots"
    decided: 2026-11-03
  - id: map-names
    text: "What should Worm Battlegrounds' 6 maps be called? One per theme: rocky, grasslands, clouds, a lake in the middle, lava and rock pillars, and the HUGE 8-player map."
    status: resolved
    answer: "Rockslide Ridge, Picnic Plains, Fluffy Fallout, Lakeside Showdown, Molten Spires, The Big Mashup"
    decided: 2026-11-03
suggestions:
  - id: match-end
    text: "Add sudden death to Worm Battlegrounds matches: after a set number of rounds the water rises each turn, so long matches always end?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Yes"
    decided: 2026-11-03
  - id: party-fill
    text: "When a party of 2 joins a Trio or Quads match in Worm Battlegrounds, fill its team with random players from the queue (instead of making the party play short-handed)?"
    options: [Yes, No]
    status: resolved
    answer: "Yes"
    decided: 2026-11-03
  - id: worms-per-player
    text: "How many worms does each Worm Battlegrounds player control? Worms gives each player a team of several worms; GunBound gives each player one character."
    options: ["One worm each", "Two worms each", "Fewer worms in bigger matches"]
    status: resolved
    answer: "One worm each"
    decided: 2026-11-03
---

Every match has 2, 4, 6 or 8 players, as a free-for-all deathmatch or a team deathmatch. Matches are round based,
like Worms: players take turns, and the last player or team standing wins.

## Starting a match

- **Bots fill empty spots:** when a public lobby's 30-second timer runs out before it's full, AI bots take the
  empty places. Coins are paid by place as usual: bots count as players.
- **The drop:** every player picks where their worm lands, all at once, with a **15-second timer**. Everyone can see
  where the others are aiming to drop. Then the worms fall onto the map with **parachutes**.
- Matches run on **their own servers**: the lobby teleports the players to a private match server.

## Turns

- Each player controls **one worm**, with **200 health**.
- Turns go **team by team**, like Worms: one player from each team in turn, then round again.
- Each player has **15 seconds** per turn.
- In that time they move their worm, **aim** (the direction of the shot) and set the **power** (how far it flies),
  then fire. How that works on each device is on [[Controls & platforms]].
- **The turn ends as soon as the player shoots**, or when the 15 seconds run out. Using a utility (a Jetpack, a
  Medkit) doesn't end it: the player still has to shoot. Then it passes to the next player.
- **Wind** changes every turn and pushes shots, like in GunBound. See [[Match screen]].

### Sudden death

After **10 rounds**, **sudden death** starts: the water rises every turn, so long matches always end.

## Modes

| Mode | Players | Teams |
|---|---|---|
| Deathmatch (free-for-all) | 2, 4, 6 or 8 | Everyone for themselves |
| Duo team deathmatch | 4, 6 or 8 | 2v2 · 2v2v2 · 2v2v2v2 |
| Trio team deathmatch | 6 | 3v3 |
| Quads team deathmatch | 8 | 4v4 |

Trios only happen on maps made for 6 players. A party plays together on one team; when a party is smaller than its
team (2 friends in a Trio or Quads match), the rest of the team is **filled with random players** from the queue. The lobby offers a random mix of
these modes and maps; see [[Lobby]].

## Maps

6 maps at launch: 5 maps for matches of 2, 4 and 6 players, and 1 **HUGE map for 8-player matches**. All are 2D and
built from studded Roblox bricks (see [[The game#Look and sound]]). The 5 smaller maps each have one theme; the HUGE map
combines several.

| Map | Theme | Players | What it's like |
|---|---|---|---|
| **Rockslide Ridge** | Rocky | 2 · 4 · 6 | Rock cliffs and ledges that crumble under fire |
| **Picnic Plains** | Grasslands | 2 · 4 · 6 | Rolling green hills, open and easy to read: a good first map |
| **Fluffy Fallout** | Clouds | 2 · 4 · 6 | Floating cloud islands high in the sky, with long drops between them |
| **Lakeside Showdown** | A lake in the middle | 2 · 4 · 6 | Land on both sides of a lake: knock enemies into the water |
| **Molten Spires** | Lava and rock pillars | 2 · 4 · 6 | Small rock pillars standing in lava everywhere: every jump counts |
| **The Big Mashup** | Rocky, grassy and small lakes | 8 | One HUGE map that combines rocky ground, grassy hills and small lakes |

## Movement and physics

- **Walking:** free, as far as the **stamina bar** allows: about **20 studs** a turn (a proposal). Walking drains
  it; it refills each turn.
- **Jumping:** unlimited jumps, at any time in the turn.
- **Wind:** medium strength. At high values players must aim around it. It changes every turn.
- **Knockback:** Worms-style. Explosions throw worms, so falls, water and lava matter.
- **Terrain:** the maps are built from **studded blocks**. A blast removes the blocks in a circle around it, and
  blocks left floating **fall down**.

## Disconnects

A player who disconnects can **rejoin within 60 seconds**. Their worm skips its turns meanwhile. After 60 seconds
it counts as leaving (see [[Match screen]]).

::navbox{from="game"}
