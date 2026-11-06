---
title: "Match modes & maps"
summary: "Round-based matches of 2 to 8 players, 15 seconds a turn, free-for-all or teams. Picnic Plains and Desert play now; 6 maps are planned for launch."
icon: map
status: active
order: 2
type: "System"
tags: [game, matches]
infobox:
  Players: "2 · 4 · 6 · 8"
  Teams: "Solo · Duos · Trios · Quads"
  Turn: "15 seconds"
  Maps now: "Picnic Plains · Desert"
  Planned: "5 + 1 HUGE map (8 players)"
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
  - id: sudden-death-start
    text: "Worm Battlegrounds' sudden death starts after 10 rounds. With 15-second turns plus the shot's flight, a round of 8 players takes about 2½–3 minutes, so an 8-player match on The Big Mashup can run 25 minutes or more before the water rises, while a 2-player match takes about 7. Roblox PvP sessions last about 11–14 minutes. When should sudden death start?"
    options: ["After 10 rounds, whatever the number of players", "After 8 minutes of match time, whatever the round", "After fewer rounds the more players there are: 10 rounds at 2 players, 6 at 4, 5 at 6, 4 at 8"]
    status: resolved
    answer: "After a few rounds with small rises, then larger ones if the match drags on (built: from round 4 the liquid rises half a stud every turn, from round 8 two studs every turn)"
    decided: 2026-11-05
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
  - id: desert-map
    text: "Worm Battlegrounds' 6 planned maps are Rockslide Ridge, Picnic Plains, Fluffy Fallout, Lakeside Showdown, Molten Spires and The Big Mashup. A map that wasn't on that list, Desert (two storeys of sand over lava, with an oasis pool), is now built and in the match rotation beside Picnic Plains. Is Desert a seventh map, or does it take one of the planned six's place?"
    options: ["A seventh map at launch", "It replaces Molten Spires (both have lava)", "It replaces another planned map (write which)"]
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
  - id: supply-drops
    text: "Worm Battlegrounds matches have nothing that changes from round to round besides the wind. Every 3 rounds, drop a supply crate by parachute onto a random spot of the map: the worm that walks into it gets one free use of a random weapon or 25 health. It gives players a reason to move, a comeback chance for whoever is behind, and races to film. Add supply drops?"
    options: [Yes, Later, No]
  - id: update-slot
    text: "Worm Battlegrounds is decided to launch with no limited-time events or weekly featured modes. For the updates after launch, Roblox games that release on the same weekday and hour every time, announced a week ahead as a Roblox Experience Event, get their biggest player peaks then; 53% of tracked events start on a Saturday, most between 14:00 and 21:00 UTC. Pick a fixed release slot for Worm Battlegrounds' updates now?"
    options: ["Saturday 16:00 UTC, every update", "Friday evening in Europe", "No fixed slot: release when ready"]
  - id: drop-hint
    text: "At the start of a Worm Battlegrounds match, players place their worm by clicking or tapping anywhere it fits in the arena, but the drop panel still says 'Pick where to land', and the camera shows about 118 × 59 studs of a 282-stud-wide map, so spots off screen need a pan first. Change the drop panel's line to 'Click where to land' on PC and 'Tap where to land' on phones, with 'Drag with the right mouse (two fingers) to look around' under it?"
    options: [Yes, Later, No]
---

Every match has 2, 4, 6 or 8 players, as a free-for-all deathmatch or a team deathmatch. Matches are round based,
like Worms: players take turns, and the last player or team standing wins.

## Starting a match

- **Matches run on their own servers:** the lobby sends the players to a private match server. A card slides over the
  screen on the way ("Heading to Picnic Plains…") and stays up until the match is ready, then slides off; the same card
  says "Back to the lobby…" after the match.
- **Waiting for players:** the map loads first and shows behind the "Waiting for players" screen while everyone
  arrives. The match starts once everyone is in, or after 20 seconds without the late ones. A match that can't start
  sends everyone back to the lobby.
- **Bots fill empty seats:** when a public match's 30-second timer runs out before it's full, bots take every empty
  seat, so one player can start a Trios match with two bot teammates against three bots. Coins are paid by place as
  usual: bots count as players.
- **The drop:** every player places their worm, all at once, with a **15-second timer**. Click, tap or press :kbd[A]
  anywhere in the arena where a worm fits (not inside the ground or a wall, not in water or lava); the marker is faded
  where it doesn't fit, and clicking again moves it. Everyone sees the others' markers, faded until they're placed.
  The drop ends as soon as every player has placed, or when the 15 seconds run out.
- **The landing:** a worm whose player placed it floats down from there by **parachute**. Bots, and players who
  didn't place, start **standing on the ground**: a random flat spot on any storey, never over water or lava, at least
  16 studs from the next worm while there's room.

## Turns

- Each player controls **one worm**, with **200 health**.
- Turns go **team by team**, like Worms: one player from each team in turn, then round again. The turn panel tells
  each player whose turn it is and how many turns until theirs (see [[Match screen]]).
- Each player has **15 seconds** per turn.
- In that time they move their worm, **aim** with the crosshair and hold to charge the **power**, then let go to
  fire. How that works on each device is on [[Controls & platforms]].
- **The turn ends as soon as the player shoots**, or when the 15 seconds run out. Using a utility (a Jetpack, a
  Medkit) doesn't end it: the player still has to shoot. Then it passes to the next player.
- **Wind** changes every turn and pushes shots, like in GunBound: a whole number from −10 to 10. See [[Match screen]].
- **Bots** take a few seconds to think (2.5 to 4), then turn their crosshair toward their target for 1.5 seconds and
  charge their shot where everyone can see it, then fire.

### Sudden death

From **round 4**, **sudden death** starts: the map's liquid (the sea on Picnic Plains, the lava on Desert) rises
**half a stud every turn**. From **round 8**, when a match drags on, it rises **2 studs every turn**, so long matches
always end.

## Modes

| Mode | Players | Teams |
|---|---|---|
| Deathmatch (free-for-all) | 2, 4, 6 or 8 | Everyone for themselves |
| Duos | 4, 6 or 8 | 2v2 · 2v2v2 · 2v2v2v2 |
| Trios | 6 | 3v3 |
| Quads | 8 | 4v4 |

The lobby always has **one public match of each mode** open: Deathmatch for 4, Duos for 4, Trios for 6 and Quads
for 8. When one starts, a fresh one of the same mode replaces it. A party plays together on one team; when a party is
smaller than its team (2 friends in a Trio or Quads match), the rest of the team is **filled with random players**
from the queue, or bots once the timer ends. See [[Lobby]].

Besides the public matches:

- **Solo:** a 1v1 against a bot, at Easy, Medium or Hard.
- **Party match:** a friends-only deathmatch for a party (everyone for themselves), with one bot per party member or
  with no bots at all. Without bots it pays half the coins (see [[Currencies & crates#Coins from a match]]).
- **Custom lobby:** a private match with a map, mode and size its creator picks, for friends only. No coins, and no
  bots: only the players who joined play.

## Maps

6 maps are planned for launch: 5 maps for matches of 2, 4 and 6 players, and 1 **HUGE map for 8-player matches**.
All are 2D and built from studded Roblox bricks (see [[The game#Look and sound]]). The 5 smaller maps each have one
theme; the HUGE map combines several.

**Picnic Plains** and **Desert** are built and in the match rotation now; every mode and size plays on one of them
until the other maps are made.

| Map | Theme | Players | What it's like |
|---|---|---|---|
| **Picnic Plains** | Grasslands | 2 · 4 · 6 | Built. Three grassy rock islands at the waterline and four floating ledges above them, with pines, oaks, birches, bushes and rocks, over the sea: a good first map |
| **Desert** | Sand and lava | 2 · 4 · 6 | Built. Two storeys over lava: a long island with a hill, a valley, an oasis pool, a plateau and a ridge, and two long floating islands 20 or more studs above it. Cacti (some in flower), dry bushes, red sandstone rocks and palms by the oasis |
| **Rockslide Ridge** | Rocky | 2 · 4 · 6 | Rock cliffs and ledges that crumble under fire |
| **Fluffy Fallout** | Clouds | 2 · 4 · 6 | Floating cloud islands high in the sky, with long drops between them |
| **Lakeside Showdown** | A lake in the middle | 2 · 4 · 6 | Land on both sides of a lake: knock enemies into the water |
| **Molten Spires** | Lava and rock pillars | 2 · 4 · 6 | Small rock pillars standing in lava everywhere: every jump counts |
| **The Big Mashup** | Rocky, grassy and small lakes | 8 | One HUGE map that combines rocky ground, grassy hills and small lakes |

Desert wasn't one of the 6 planned maps; whether it's a seventh or takes one's place is asked below.

## Movement and physics

- **Walking:** free, as far as the **stamina bar** allows: **20 studs** a turn, at 8 studs a second. Walking drains
  it; it refills each turn. At 0 the worm stops walking but can still jump.
- **Jumping:** unlimited jumps, at any time in the turn, but only from the ground (about 5 studs high). Ledges up to
  2 studs high are climbed by walking into them.
- **Wind:** medium strength. At high values players must aim around it. It changes every turn.
- **Knockback:** Worms-style. Explosions throw worms, so falls, water and lava matter.
- **Terrain:** a blast removes every one-stud square of ground within its reach, so craters are **stepped like
  blocks**. Every island can be blasted right through, down to the water or lava. Ground cut loose from the island
  under it falls and lands where it stops; a floating ledge keeps floating, and a piece cut off it keeps floating
  while it's big enough (24 square studs), while smaller crumbs fall.
- **Water and lava** move like a stop-motion brick film: they flow into craters, spill out of broken pools and level
  out.
- **Trees, bushes and rocks** break under blasts: the blast cuts its hole through them, and the pieces cut free fly
  off, lie for 3 seconds and fade. A tree whose ground is blasted away falls whole. They never block worms or shots.

## Disconnects

A player who disconnects can **rejoin within 60 seconds**: back in the lobby, the game asks "Rejoin your match?".
Their worm skips its turns meanwhile. After 60 seconds it counts as leaving (see [[Match screen]]).

## History

:::changelog
- 2026-11-03: The first build: drop, 15-second turns, wind, sudden death from round 10, rejoin and rematch; bots at Easy, Medium and Hard; Picnic Plains as a grey test map.
- 2026-11-05:
  - Place your worm anywhere it fits; the drop ends once everyone has placed. Worms that aren't placed start standing on land, on any storey.
  - Picnic Plains built: three islands, four floating ledges, trees, bushes and rocks.
  - Desert added: two storeys over lava, with an oasis.
  - Craters are stepped like blocks; islands can be blasted down to the water; floating ledges float; trees, bushes and rocks break apart.
  - Sudden death from round 4 (half a stud a turn), faster from round 8 (2 studs a turn).
  - Bots take longer to think and aim where everyone can see.
- 2026-11-06:
  - One public match of every mode is always open, and bots fill every empty seat when its timer ends.
  - Party matches: friends only, with or without bots.
  - The map shows while players arrive; a card slides over the screen between the lobby and a match.
:::

::navbox{from="game"}
