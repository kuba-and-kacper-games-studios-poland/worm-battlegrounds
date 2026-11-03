---
title: "Lobby"
summary: "The first screen: play solo or join a match in the middle, party and loadout on the left, crates on the right."
icon: home
status: planned
order: 1
type: "Screen"
tags: [game, ui]
infobox:
  Layout: "Like Roworld's lobby, in our own art"
  Left: "Party · Loadout"
  Middle: "Play solo · Active matches"
  Right: "Weapon crate · Premium crate · Utility crate · Skin crate"
questions:
  - id: lobby-background
    text: "Roworld's lobby sits on top of its world map. What should be behind the Worm Battlegrounds lobby's panels?"
    options: ["A live 3D scene: the player's worm on a hilltop", "One of the game's maps, slowly panning", "A flat illustrated background"]
    status: resolved
    answer: "A flat illustrated background"
    decided: 2026-11-03
  - id: solo-means
    text: "The lobby's Play solo button sits above the list of active matches. What does Play solo start: a match against bots, or quick matchmaking into the next free-for-all with other players?"
    options: ["A match against bots", "Quick matchmaking into a free-for-all", "Both: two buttons"]
    status: resolved
    answer: "Like Roworld: Play solo is its own button, above the public matches"
    decided: 2026-11-03
  - id: solo-opponents
    text: "The Worm Battlegrounds lobby's Play solo button starts a match the player plays alone, like Roworld's. Who do they fight: bots, and can they pick how many and how hard?"
    options: ["Bots, with a choice of how many and how hard", "Bots, a fixed number and difficulty", "No opponents: a practice range"]
    status: resolved
    answer: "AI opponents, 1v1 or 2v2, with a choice of difficulty"
    decided: 2026-11-03
  - id: vote-start
    text: "In a Worm Battlegrounds public match's waiting room, players can vote to start before the 30-second timer ends. How many votes start it? (Roworld asks for about two thirds: 14 of 21 players.)"
    options: ["Two thirds of the players", "More than half", "Everyone"]
    status: resolved
    answer: "Two thirds of the players"
    decided: 2026-11-03
  - id: ai-levels
    text: "Worm Battlegrounds' Play solo is against AI, 1v1 or 2v2, and the player picks the difficulty. Which difficulty levels are there?"
    options: ["Easy, Normal, Hard", "Easy, Normal, Hard, Insane"]
    status: resolved
    answer: "Easy, Normal, Hard"
    decided: 2026-11-03
  - id: solo-rewards
    text: "Do Worm Battlegrounds' Play solo matches against AI give coins, so players can earn them without playing other people?"
    options: ["Yes, the same as public matches", "Yes, but fewer coins", "No coins from solo"]
    status: resolved
    answer: "Yes, but fewer coins"
    decided: 2026-11-03
  - id: custom-options
    text: "Worm Battlegrounds' custom lobby lets a player invite friends to a private match (like a 1v1 duel) that pays no coins. What can the player who makes it choose? Pick every one."
    multiple: true
    options: ["The map", "Deathmatch or teams", "Number of players", "Turn time", "Which weapons are allowed"]
    status: resolved
    answer: ["The map", "Deathmatch or teams", "Number of players"]
    decided: 2026-11-03
suggestions:
  - id: worm-preview
    text: "Show the player's equipped worm skin in the middle of the Worm Battlegrounds lobby, standing behind the match list and playing its idle animation, so a new skin from the skin crate is seen right away?"
    options: [Yes, Later, No]
  - id: currency-bar
    text: "Put a currency bar at the top of the Worm Battlegrounds lobby showing coins and diamonds, with a + beside diamonds that opens the Robux shop?"
    options: [Yes, Later, No]
  - id: daily-reward
    text: "Add a daily login reward to the Worm Battlegrounds lobby (coins every day, a coin crate on day 7) to bring players back each day?"
    options: [Yes, Later, No]
    status: resolved
    answer: "No"
    decided: 2026-11-03
---

The lobby is the first thing a player sees. Its panels sit on a **flat illustrated background**. It follows the layout of Roworld's lobby (a central panel for playing,
a party panel on the left, crates on the right), drawn in Worm Battlegrounds' own art.

## First time playing

A new player starts with **0 coins** and goes straight into a match, not the lobby:

1. **Tutorial match:** a 1v1 against a bot. The game shows how to aim and attack; two hits knock the bot out.
2. **To the lobby:** the player gets coins for a **tutorial crate** and opens it. It gives the **Grenade and the
   Shotgun**, the two starter weapons.
3. **Equip:** the game points to the loadout on the left and shows how to put them in.

## Middle: play

Like Roworld's lobby, the middle panel has two parts.

- **Play solo**, the big button at the top: a **1v1 match against AI**, at the difficulty the player picks: **Easy,
  Medium or Hard**. The AI hits its shots about **30%** of the time on Easy, **60%** on Medium and **85%** on Hard,
  where it also uses the wind and picks good weapons. Only a win pays: 20, 35 or 60 coins by difficulty (see [[Currencies & crates]]).
- **Public matches** under it: **3 open lobbies** at a time, **1 deathmatch** (free-for-all) and **2 bigger
  matches** for more players. Each row shows:
  - the **map's layout** as a small picture, like Roworld's map thumbnails
  - the mode (deathmatch, or the teams: Duo, Trio, Quads), the map, and the players who joined (as `3 / 8`)
  - a **30-second timer**: anyone can join until it runs out, then the match starts
  - **Join**, or **Join teams** for team matches
- The rows **keep refreshing**: when a lobby starts, a new one replaces it with a random map, player count, and team
  size or deathmatch. Trios only appear on 6-player maps. See [[Match modes & maps]].

## Custom lobby

Players can make a **custom lobby** to play friends privately, for example a **1v1 duel**: create it, invite friends,
and start when everyone's in. Custom matches pay **no coins**, so they can't be farmed.

Whoever makes a custom lobby chooses the **map**, **deathmatch or teams**, and the **number of players**.

## After joining a match

Joining a public match swaps the middle panel for the match's waiting room, like Roworld's. The map it will be played
on fills the background. The panel shows:

- **The match:** its mode and map (as "Duo team deathmatch • Map name").
- **The countdown:** "Match starts in 0:29", counting down from the 30-second timer.
- **The players:** how many have joined and how many fit (`5 / 8 players`), then every player's name.
- **Vote to start**, with the votes so far and how many are needed (`4 / 6`). When **two thirds** of the players
  vote, the match starts before the timer runs out.
- **Leave match**, which goes back to the lobby.

## Left: party and loadout

- **Party:** invite up to 3 friends, for a party of 4. A party joins matches together and plays on the same team in
  team modes. See [[Match modes & maps]].
- **Loadout:** the items the player takes into the next match, 3 to 5 slots. See [[Loadout & inventory]].
- **Emotes:** a smiley button above the loadout expands into the emotes the player owns. See [[Emotes]].

## Right: crates

- **Weapon crate:** 100 coins (free to play), drops weapons.
- **Premium crate:** 250 diamonds (Robux), drops weapons with better odds for the rarer ones.
- **Utility crate:** 100 coins, or 200 diamonds for better odds; drops utilities.
- **Skin crate:** 100 coins or 50 diamonds (same odds), drops skins for your worms. Each crate also comes as a 10-pack at 10% off. The same panel is where you equip a worm skin.

See [[Currencies & crates]].

::navbox{from="game"}
