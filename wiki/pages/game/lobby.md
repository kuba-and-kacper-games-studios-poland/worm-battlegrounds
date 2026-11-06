---
title: "Lobby"
summary: "The first screen: the player's worm on a 3D stage, Play solo and the public matches at the bottom, party and loadout on the left, crates and skins in the top-right corner."
icon: home
status: active
order: 1
type: "Screen"
tags: [game, ui]
infobox:
  Layout: "Like Roworld's lobby, in our own art"
  Behind: "A 3D stage with the player's worm"
  Top left: "Party"
  Top right: "Coins and diamonds · Crates · Skins"
  Bottom: "Loadout (left) · Play solo and the public matches"
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
  - id: solo-middle
    text: "Worm Battlegrounds' Play solo difficulties were answered as Easy, Normal and Hard, but the Lobby and Currencies & crates pages call the middle one Medium. Which name does the middle difficulty button show?"
    options: ["Medium", "Normal"]
  - id: custom-teams
    text: "A Worm Battlegrounds custom lobby lets its creator pick the map, deathmatch or teams, and the number of players (2, 4, 6 or 8). When the creator picks teams, how are the players split?"
    options: ["Always two equal teams: 2v2, 3v3 or 4v4", "Teams of two: 2v2, 2v2v2 or 2v2v2v2", "The creator also picks the team size"]
  - id: custom-bots
    text: "A Worm Battlegrounds custom lobby can start before every spot is filled (say 3 friends in a 4-player lobby). Custom matches pay no coins either way. What happens to the empty spots?"
    options: ["Bots at Medium fill them", "The match starts with only the friends who joined", "The creator picks bots or no bots"]
  - id: party-too-big
    text: "A Worm Battlegrounds party holds up to 4 friends and always plays on one team, but a Duo match's teams hold 2. What happens when a party of 3 or 4 presses Join on a Duo match?"
    options: ["The party can't join Duo matches", "The party splits across two teams of the same match"]
suggestions:
  - id: worm-preview
    text: "Show the player's equipped worm skin in the middle of the Worm Battlegrounds lobby, standing behind the match list and playing its idle animation, so a new skin from the skin crate is seen right away?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Built on 2026-11-05: the lobby is a 3D stage with the player's worm on a podium in its equipped skin (no idle animation yet: the skins have none)"
    decided: 2026-11-06
  - id: currency-bar
    text: "Put a currency bar at the top of the Worm Battlegrounds lobby showing coins and diamonds, with a + beside diamonds that opens the Robux shop?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Built: coins and diamonds at the top right, with a green + that opens the shop"
    decided: 2026-11-06
  - id: daily-reward
    text: "Add a daily login reward to the Worm Battlegrounds lobby (coins every day, a coin crate on day 7) to bring players back each day?"
    options: [Yes, Later, No]
    status: resolved
    answer: "No"
    decided: 2026-11-03
  - id: beginner-match
    text: "The Worm Battlegrounds lobby shows 3 public matches at a time, open to everyone, so a player in their first matches can land against level-80 players with Legendary weapons and 5 loadout slots. RIVALS keeps a Beginner 2v2 and a practice range for that reason. Keep one of the 3 public matches for players below level 10 (bots fill its empty spots as usual)?"
    options: [Yes, Later, No]
  - id: tutorial-ringout
    text: "Worm Battlegrounds' tutorial match is a 1v1 against a bot where two hits knock it out. Research on Roblox games says a player should see one memorable moment in their first 5 minutes, and a worm flying into water is this game's. Make the tutorial's second hit throw the bot into the water, with a slow-motion splash?"
    options: [Yes, Later, No]
  - id: party-bonus
    text: "Worm Battlegrounds parties hold up to 4 friends. Fish It! and Fix My Phone! pay +10% for each friend in the server, and Roblox's recommendations count days played with friends. Give each player +10% coins for every party friend in the same public match, up to +30%?"
    options: [Yes, Later, No]
  - id: group-reward
    text: "Many Roblox games give a one-time reward for joining their Roblox group (Break and Steal an Egg gives a free Legendary egg), which also grows the group that update news reaches. Give Worm Battlegrounds players one free skin crate, once, for joining the game's group?"
    options: [Yes, Later, No]
---

The lobby is the first thing a player sees. Behind its panels is a **3D stage**: the player's worm stands on a podium
in its equipped skin, among Picnic Plains trees, with hills and clouds behind. It follows the layout of Roworld's
lobby (a panel at the bottom for playing, the party at the left, crates and skins in the corner), drawn in Worm
Battlegrounds' own art.

## On screen

| Where | What |
|---|---|
| Top centre | The game's name, "WORM BATTLEGROUNDS", in gold |
| Top left | The **Party** tab and panel (below) |
| Top right | The **coins and diamonds** bar, with a green **+** that opens the shop; under it the **Crates** and **Skins** buttons |
| Bottom left | The **Loadout** bar: the emote row, then the Bazooka and the slots (below) |
| Bottom, just right of the centre | The **play panel**: Play solo and the public matches (below) |

The **Crates** button has a red badge: **FREE** while a free crate waits (the tutorial crate, or a VIP's daily skin
crate), otherwise how many crates the player's coins can open (350 coins and a 100-coin crate show **3**), **9+** past
nine, and nothing when the coins don't cover one. Opening a window (Crates, Skins, the shop…) blurs the stage behind
it.

## First time playing

A new player starts with **0 coins** and goes straight into a match, not the lobby:

1. **Tutorial match:** a 1v1 against the tutorial bot on Picnic Plains. The bot never hits the player and falls to
   two Bazooka hits. Either side may play first; the hints follow the player's own turns: walk, jump, "Point the
   crosshair at the bot, then hold to charge and let go to fire", the bot's turn, then "Two hits knock it out.
   Finish it!". The match ends with **100 coins** and goes back to the lobby (no rematch). Leaving it early still
   counts as playing it; closing the game mid-tutorial doesn't, so the tutorial starts again on the next join.
2. **The tutorial crate:** back in the lobby, the Crates button reads **FREE**. The tutorial crate costs the 100
   coins and always gives the **Grenade and the Shotgun**, the two starter weapons.
3. **Equip:** a hint and an arrow point to the loadout until both are in it. Then the tutorial is done for good.

## Bottom: play

Like Roworld's lobby, one panel at the bottom:

- **"Welcome, Name"** at the top.
- **Play solo**, the big yellow button, with **Custom** beside it. Play solo opens the setup in the same spot: **Easy,
  Medium or Hard** bots, a line about each, what the match pays ("Only a win pays coins") and **Start**; **Back**
  returns. It's a **1v1 against a bot**. The bot hits its shots about **30%** of the time on Easy, **60%** on Medium
  and **85%** on Hard, where it also picks stronger weapons. Only a win pays: 20, 35 or 60 coins by difficulty (see
  [[Currencies & crates]]).
- **In a party** the button reads **Play with party**: the party leader picks **No bots**, Easy, Medium or Hard and
  starts a friends-only deathmatch, everyone for themselves. With bots, there's one bot per party member; with no bots
  only the party plays, for half the coins. Other members are told only the leader can start it.
- **Public matches** under it: **four cards, one per mode**, always there: **Deathmatch** (4 players), **Duos** (4),
  **Trios** (6) and **Quads** (8). Each card shows its mode, the players who joined (`1 / 6`), its timer and
  **Join**.
  - A card's **30-second timer** starts when its first player joins. When it runs out, the match starts with whoever
    joined, and **bots fill every empty seat**, so one player can play Trios with two bot teammates.
  - When a match starts, a fresh card of the same mode replaces it, on a random map (Picnic Plains or Desert for
    now). See [[Match modes & maps]].

## Custom lobby

**Custom** opens a window to make a **custom lobby** and play friends privately, for example a **1v1 duel**: pick the
**map**, **Deathmatch or Teams** and the **number of players** (2 to 8), invite players in this server or friends,
and start once there are 2 or more. Custom matches pay **no coins**, so they can't be farmed, and have no bots: only
the players who joined play.

## After joining a match

Joining a public match swaps the play panel for the match's waiting room, like Roworld's:

- **The match:** its mode and map ("DEATHMATCH • PICNIC PLAINS").
- **The countdown:** "MATCH STARTS IN 0:29", counting down from the 30-second timer.
- **The players:** how many have joined and how many fit (`1 / 4 players`), then every player's name.
- **Vote to start**, with the votes so far and how many are needed (`VOTE TO START 0 / 1`). When **two thirds** of
  the players vote, the match starts before the timer runs out.
- **Leave match**, which goes back to the play panel.

When the match starts, a card slides down over the screen ("Heading to Picnic Plains…") and stays up through the trip
to the match server. After the match the same card says "Back to the lobby…".

A player who dropped out of a running match and comes back within 60 seconds is asked **"Rejoin your match?"** in the
lobby ("Back to your match…" on the card).

## Left: party and loadout

- **Party:** up to **4** players. A tab, **"PARTY 1/4"**, opens and folds the panel: open at first on PC and console,
  folded on phones and tablets. The panel lists every member (avatar, name, level, a crown on the leader, and Kick for
  the leader). **Invite players** opens a window of everyone in this server who isn't in a party, each with
  **Invite** (it turns to **Sent**), and **Invite friends** for friends who aren't here. An invited player gets a
  **Party invite** window with the inviter's picture: **Join party** or **No thanks**; the invite runs out after 30
  seconds. When the leader leaves, the next member leads. A party joins public matches together and plays on the same
  team in team modes; a party bigger than a team can't join that mode. See [[Match modes & maps]].
- **Loadout:** a slim dark bar like the match's loadout bar: the Bazooka and the 3 to 5 slots in one row (two rows on
  phones). An empty slot shows a **+**; the next locked slot shows only its price ("2500 coins"). See
  [[Loadout & inventory]].
- **Emotes:** the row of emotes the player owns, above the slots. See [[Emotes]].

## Top right: crates and skins

The **Crates** button opens the crates window, two crates to a row:

- **Weapon crate:** 100 coins (free to play), drops weapons.
- **Premium crate:** 250 diamonds (Robux), drops weapons with better odds for the rarer ones.
- **Utility crate:** 100 coins, or 200 diamonds for better odds; drops utilities.
- **Skin crate:** 100 coins or 50 diamonds (same odds), drops skins for your worms. Each crate also comes as a
  10-pack: 10 for the price of 9.

The **Skins** button opens the skins window, where the player equips a worm skin. See [[Currencies & crates]].

## History

:::changelog
- 2026-11-03: The first lobby: Play solo and three public match rows in the middle, party and loadout on the left, crates on the right; custom lobbies, parties of 4, rejoin, voice chat; the tutorial.
- 2026-11-04: The GUI kit's look; the tutorial hints follow the player's own shots.
- 2026-11-05:
  - The lobby is a 3D stage with the player's worm; one Play button and a Modes window; crates and skins move to the top-right corner, with the Crates badge.
  - The coin and diamond counts show the player's amounts, on one line.
  - The Party panel lists its members and folds to a tab on phones.
  - Leaving the tutorial match early still counts it as played.
- 2026-11-06:
  - The play panel like Roworld's: Play solo up front, one public match per mode, bots filling every empty seat.
  - Play with party: friends-only matches, with or without bots.
  - Party invites open windows: a list of players to invite, and an invite to answer.
  - A card slides over the screen between the lobby and a match.
:::

::navbox{from="game"}
