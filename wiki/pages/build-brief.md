---
title: "Build brief"
summary: "Worm Battlegrounds on one page: what to build, in what order, and where each detail lives. Start here before building."
icon: toolbox
status: active
order: 1
type: "Brief"
---

Everything a developer needs before building Worm Battlegrounds. Each part links to the page with the full detail; the
numbers on those pages are the source of truth.

## Name

The game is called **Worm Battlegrounds**. It avoids "Worms", which is Team17's trademark, and uses the common
Roblox "Battlegrounds" naming. Before launch, check that no popular Roblox game uses the same name.

Don't copy Team17's own content: their art, worm designs, sounds, voice lines or exact weapon names (like "Super
Sheep" or "Holy Hand Grenade"). That's why the walking bomb is a Black hole grenade, not a sheep.

## The game in one paragraph

A **2D turn-based artillery game for Roblox** in a studded-brick style, for PC, phone, tablet and console. Each
player controls **one worm (200 health)**. Players take **15-second turns**, team by team, to move, aim with a drag
(or the right stick) and shoot; the turn ends when they shoot. Explosions break the block terrain and throw worms
into water and lava. Matches have **2, 4, 6 or 8 players**, free-for-all or teams, on **6 maps**. Players earn
**coins** by finishing place and buy **crates** for weapons, utilities and skins; **diamonds** are bought with Robux.

## Places and servers

- **Lobby place:** the lobby screen, crates, loadout, party. See [[Lobby]].
- **Match place:** every match on its own reserved server; the lobby teleports players there and back. See
  [[Match modes & maps]].

## Screens

| Screen | Page |
|---|---|
| Tutorial match and first-time flow | [[Lobby#First time playing]] |
| Lobby: play solo, public matches, custom lobby, party, loadout, crates | [[Lobby]] |
| Waiting room: players, timer, vote to start, leave | [[Lobby#After joining a match]] |
| Drop phase: pick a landing spot in 15 seconds | [[Match modes & maps#Starting a match]] |
| Match screen: top bar, settings, turn and wind, health, stamina, loadout bar, kill feed | [[Match screen]] |
| Knocked out (spectate or leave) and the results screen with Rematch | [[Match screen#End of match]] |
| Crate opening and the shop | [[Currencies & crates]] |

## Content at launch

| What | How many | Page |
|---|---|---|
| Maps | 5 + 1 HUGE | [[Match modes & maps#Maps]] |
| Weapons | Bazooka + 13 | [[Arsenal]] |
| Utilities | 6 | [[Arsenal#Utilities]] |
| Worm skins | Classic + 9 crate skins + 3 level skins | [[Currencies & crates#Skin crate]], [[Levels & XP]] |
| Crates | Weapon, Premium, Utility, Skin | [[Currencies & crates#Crates]] |
| Emotes | Wave free + 8 bought with coins, by level | [[Emotes]] |
| Game passes | Slot 4, Slot 5, Double Coins, VIP | [[Currencies & crates#Game passes]] |
| Diamond packs | 5 | [[Currencies & crates#Diamonds]] |

## What to save for each player

- Coins, diamonds, level and XP
- Owned weapons, utilities and skins, with their **copy counts** and which are **shiny** (10 copies)
- Loadout (3–5 slots) and how many slots are unlocked
- Equipped skin, and the emotes owned
- Game passes owned (Roblox keeps those; read them on join)
- Whether the tutorial is done

## Rules a build must keep

- Roblox requires showing the drop odds of paid random items: every crate shows its chances before opening.
- Chat must use Roblox's text filtering.
- Custom lobbies pay no coins; leaving before 2 rounds pays nothing (see [[Currencies & crates#Coins from a match]]).

## Not at launch

- Limited-time events, event items and weekly featured modes: none at launch; decided in later updates.
- A season pass or battle pass: **no**, not planned.
- A report-player button: Roblox's own report menu covers it.

## Left to the scripter

The open suggestions on the pages (an aim line while aiming, marking the last shot, the worm in the lobby, a
currency bar, loadout presets, and similar) are **up to the scripter**: build them if they fit, skip them if not.

## Suggested build order

The full plan, module by module on the ume framework, is the [[Implementation plan]]; its [[Roadmap]] splits these
steps into 14 phases.

1. **Core match:** a 2D studded map, one worm each, movement with stamina, jumping, turns, the Bazooka, block
   destruction, knockback, water.
2. **Aiming on every device:** mouse and touch drag, controller stick and power bar.
3. **The arsenal:** the 13 weapons and 6 utilities, uses and cooldowns.
4. **Match flow:** drop phase, team-by-team turns, sudden death, placement, AI bots.
5. **Lobby and match servers:** public matches, waiting room, vote to start, teleports, rejoin.
6. **Saving and economy:** coins, crates, inventory, shiny copies, loadout, levels.
7. **Monetization:** diamonds, premium crate, game passes.
8. **Tutorial and polish:** first-time flow, settings, the 6 maps, skins.

## Proposed numbers to tune in playtests

Blast sizes and knockback ([[Arsenal#Blast sizes and knockback]]), stamina distance ([[Match modes & maps#Movement and physics]]),
the XP curve ([[Levels & XP#XP and levels]]) and the shiny utility boosts ([[Currencies & crates#Duplicates and shiny items]]).
