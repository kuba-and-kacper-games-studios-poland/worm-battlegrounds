---
title: "Currencies & crates"
summary: "Coins earned in game, diamonds bought with Robux, and three crates for weapons and worm skins."
icon: tag
status: planned
order: 7
type: "System"
tags: [game, economy]
infobox:
  Free currency: "Coins (earned in game)"
  Premium currency: "Diamonds (bought with Robux)"
  Crates: "Coin · Diamond · Skin"
questions:
  - id: coin-earning
    text: "Worm Battlegrounds players earn coins in game to open coin crates and upgrade loadout slots. How do they earn them?"
    multiple: true
    options: ["Playing a match", "Winning a match", "Each kill", "Daily rewards"]
    status: resolved
    answer: "By the place the player finishes in each match"
    decided: 2026-11-03
  - id: coins-per-place
    text: "Worm Battlegrounds gives coins for the place a player finishes in a match. How many coins for each place, 1st to 8th? One line, like '1st 100, 2nd 70, 3rd 50…'. Should team matches give every player on a team their team's place?"
    status: resolved
    answer: "Deathmatch 1st 150; team matches 1st 100 each; the last 2 places get a little, only after 2 rounds or when knocked out (not when leaving); solo vs AI pays only a win, at 30%"
    decided: 2026-11-03
  - id: skin-crate-currency
    text: "Worm Battlegrounds has a skin crate for worm skins, beside the coin and diamond crates. What does it cost?"
    options: ["Coins", "Diamonds", "Either"]
    status: resolved
    answer: "Coins"
    decided: 2026-11-03
  - id: diamond-crate-better
    text: "Worm Battlegrounds' coin crate and diamond crate both drop weapons. What does the diamond crate give that the coin crate doesn't?"
    options: ["Better odds for rarer weapons", "Weapons only it drops", "The same weapons, just faster to get"]
    status: resolved
    answer: "Better odds for rarer weapons"
    decided: 2026-11-03
  - id: utilities-source
    text: "Worm Battlegrounds' crates drop the 11 crate weapons and worm skins. Where do players get the 6 utilities (Jetpack, Speed potion, Parachute, Bandage, Medkit, Low gravity)?"
    options: ["Everyone owns all 6 from the start", "They drop from the weapon crates too", "They're bought one by one with coins"]
    status: resolved
    answer: "From a utility crate: 100 coins, or 200 diamonds for better odds"
    decided: 2026-11-03
  - id: duplicates
    text: "When a Worm Battlegrounds crate drops a weapon the player already owns, turn it into coins, so a duplicate is never a wasted opening?"
    options: [Yes, Later, No]
    status: resolved
    answer: "Ten copies of a weapon turn it into its shiny version"
    decided: 2026-11-03
  - id: odds
    text: "Show each Worm Battlegrounds crate's drop odds when opening it? Roblox requires showing the odds for paid random items, so the diamond crate needs it."
    options: [Yes, No]
  - id: pity
    text: "Give the Worm Battlegrounds diamond crate a guarantee (a rare weapon at least every 10 openings) so players who pay always get something good?"
    options: [Yes, Later, No]
    status: resolved
    answer: "No"
    decided: 2026-11-03
---

Worm Battlegrounds has two currencies and three crates, all on the right side of the [[Lobby]].

## Currencies

| Currency | Get it by | Spend it on |
|---|---|---|
| Coins | The place you finish in a match (free to play) | The weapon crate, the utility and skin crates, loadout slots 4 and 5, emotes |
| Diamonds | Buying with Robux | The premium crate |

## Coins from a match

Coins come from the **place the player finishes** in a match: the better the place, the more coins. A player who
leaves early (Leave game, see [[Match screen]]) is placed **last among the players still alive** when they leave.

**Anti-farming:** the last 2 places get their coins only if the player **played at least 2 rounds, or was
knocked out by another player** (even on the first turn). **Leaving** before 2 rounds pays nothing.

### Deathmatch

Deathmatches run with 2, 4, 6 or 8 players: 2, 4 and 6 on the 5 basic maps, 8 on The Big Mashup. The fewer
players there are to knock out, the less each place pays.

| Players | 1st | 2nd | 3rd | 4th | 5th | 6th | 7th | 8th |
|---|---|---|---|---|---|---|---|---|
| 8 | **150** | 100 | 70 | 50 | 35 | 25 | 20 | 15 |
| 6 | **125** | 75 | 50 | 30 | 20 | 15 | — | — |
| 4 | **100** | 50 | 25 | 15 | — | — | — | — |
| 2 | **50** | 15 | — | — | — | — | — | — |

Every place pays at least **15**. The last 2 places are paid only under the anti-farming rule above.

### Team matches

Every player on a team gets the team's place. Winning a team match pays **100** (75 in a 2v2), less than a big
deathmatch win.

| Teams in the match | 1st | 2nd | 3rd | 4th |
|---|---|---|---|---|
| 4 teams | **100** | 60 | 30 | 15 |
| 3 teams | **100** | 50 | 15 | — |
| 2 teams: 3v3 or 4v4 | **100** | 15 | — | — |
| 2 teams: 2v2 | **75** | 15 | — | — |

### Custom lobbies

Private matches with friends (see [[Lobby#Custom lobby]]) pay **no coins**.

### Solo against AI

Play solo is **1v1 against AI** only. Only a **win** pays, by difficulty:

| Difficulty | Easy | Medium | Hard |
|---|---|---|---|
| Coins for a win | 20 | 35 | **60** |

:::callout{tone="warning"}
A Hard win pays more than 2nd place in a 4-player match, on purpose. So the **Hard AI must be truly hard**: it
aims well, uses wind and picks good weapons. Otherwise players farm it instead of playing public matches.
:::

The numbers below 1st place are a proposal.

## Starter weapons

Every player gets **3 weapons** they always keep: the **Bazooka** (the basic weapon, which takes no slot), and the
**Grenade** and **Shotgun**, which come from the tutorial crate in the first-time flow (see [[Lobby#First time playing]]).
New players start with **0 coins**. They never drop from crates. The other **11 weapons**
come only from the weapon crates.

## Crates

| Crate | 1 crate | 10 crates (10% off) | Drops |
|---|---|---|---|
| **Weapon crate** | **100 coins** | **900 coins** | One of the 11 crate weapons |
| **Premium crate** | **250 diamonds** | **2,250 diamonds** | Rare, Epic or Legendary weapons only: never an Uncommon |
| **Utility crate** | **100 coins**, or **200 diamonds** for better odds | **900 coins** or **1,800 diamonds** | One of the 6 utilities |
| **Skin crate** | **100 coins**, or **50 diamonds** (same odds) | **900 coins** or **450 diamonds** | One of the 9 worm skins |

The premium crate has no guaranteed drop (no pity system). Roblox requires showing the odds of paid random items,
so every crate shows its drop chances before opening.

### Drop chances

| Weapon | Rarity | Weapon crate | Premium crate |
|---|---|---|---|
| Uzi | :badge[Uncommon]{tone="good"} | 14.75% | — |
| Baseball bat | :badge[Uncommon]{tone="good"} | 14.75% | — |
| Dynamite | :badge[Uncommon]{tone="good"} | 14.75% | — |
| Spartan spear | :badge[Uncommon]{tone="good"} | 14.75% | — |
| Cluster bomb | :badge[Rare]{tone="accent"} | 10% | 26% |
| Spider bomb | :badge[Rare]{tone="accent"} | 10% | 26% |
| Minigun | :badge[Rare]{tone="accent"} | 10% | 26% |
| Homing missile | :badge[Epic]{tone="warn"} | 5% | 10% |
| One Punch | :badge[Epic]{tone="warn"} | 5% | 10% |
| Variety grenade | :badge[Legendary]{tone="bad"} | 0.5% | 1% |
| Black hole grenade | :badge[Legendary]{tone="bad"} | 0.5% | 1% |

| By rarity | Weapon crate | Premium crate |
|---|---|---|
| Uncommon | 59% | — |
| Rare | 30% | **78%** |
| Epic | 10% | **20%** |
| Legendary | **1%** | **2%** |

The premium crate holds only the 7 Rare, Epic and Legendary weapons. Uncommon weapons come only from the weapon
crate.

### What a Legendary costs

| Way | Crates on average | Cost |
|---|---|---|
| Premium crates, in 10-packs, with Vault diamonds | 50 | 11,250 diamonds ≈ **4,050 Robux** |
| Premium crates, one at a time, with 99-Robux packs | 50 | 12,500 diamonds ≈ **4,950 Robux** |
| Weapon crates, in 10-packs | 100 | 9,000 coins ≈ 180 matches at 50 coins |

That's for **either** Legendary. One **specific** Legendary costs twice as much (see below).

### What each weapon costs

The average cost to get one specific weapon, opening crates until it drops. Some players get it sooner, some later.

| Weapon | Rarity | Weapon crates | Coins (10-packs) | ≈ Matches | Premium crates | Robux (Vault + 10-packs) | Robux (99 packs, single crates) |
|---|---|---|---|---|---|---|---|
| Uzi, Baseball bat, Dynamite, Spartan spear | Uncommon | 7 | 610 | 12 | — | — | — |
| Cluster bomb, Spider bomb, Minigun | Rare | 10 | 900 | 18 | 4 | ~310 | ~380 |
| Homing missile, One Punch | Epic | 20 | 1,800 | 36 | 10 | ~810 | ~990 |
| Variety grenade, Black hole grenade | Legendary | 200 | 18,000 | **360** | 100 | **~8,100** | **~9,900** |

Matches assume about 50 coins a match.

### Utility crate

One crate for the 6 utilities, bought with coins or, for better odds, with diamonds. The Low gravity potion is the best utility
and the rarest.

| Utility | Rarity | With coins (100) | With diamonds (200) |
|---|---|---|---|
| Parachute | :badge[Uncommon]{tone="good"} | 27.5% | 15% |
| Bandage | :badge[Uncommon]{tone="good"} | 27.5% | 15% |
| Jetpack | :badge[Rare]{tone="accent"} | 15% | 20% |
| Speed potion | :badge[Rare]{tone="accent"} | 15% | 20% |
| Medkit | :badge[Epic]{tone="warn"} | 10% | 20% |
| Low gravity potion | :badge[Legendary]{tone="bad"} | **5%** | **10%** |

On average, the Low gravity potion takes 20 coin crates (1,800 coins in 10-packs, about 36 matches) or 10 diamond crates
(1,800 diamonds, about 650 Robux with Vault diamonds).

### Skin crate

![The 10 worm skins at launch](/assets/worm-skins.png "The 10 worm skins: Classic, Soldier, Pirate, Ninja, Cowboy, Knight, Robot, Devil, Skeleton, Clown")

All skins are built from **studded bricks**, like the rest of the game. Every player starts with the **Classic** worm. The other 9 skins drop from the skin crate, which costs 100 coins or
50 diamonds with the **same odds** either way. The **Skeleton** is the best and the rarest.

| Skin | Rarity | Chance |
|---|---|---|
| Soldier | :badge[Uncommon]{tone="good"} | 20% |
| Pirate | :badge[Uncommon]{tone="good"} | 20% |
| Cowboy | :badge[Uncommon]{tone="good"} | 20% |
| Ninja | :badge[Rare]{tone="accent"} | 10% |
| Knight | :badge[Rare]{tone="accent"} | 10% |
| Clown | :badge[Rare]{tone="accent"} | 10% |
| Robot | :badge[Epic]{tone="warn"} | 2% |
| Devil | :badge[Epic]{tone="warn"} | 7% |
| **Skeleton** | :badge[Legendary]{tone="bad"} | **1%** |

What each skin costs on average, opening crates until it drops (10-packs, about 50 coins a match, Robux with Vault
diamonds):

| Skin | Chance | Crates | Coins | ≈ Matches | Diamonds | ≈ Robux |
|---|---|---|---|---|---|---|
| Soldier, Pirate, Cowboy | 20% each | 5 | 450 | 9 | 225 | 80 |
| Ninja, Knight, Clown | 10% each | 10 | 900 | 18 | 450 | 160 |
| Devil | 7% | 14 | 1,290 | 26 | 640 | 230 |
| Robot | 2% | 50 | 4,500 | 90 | 2,250 | 810 |
| **Skeleton** | **1%** | 100 | 9,000 | **180** | 4,500 | **1,620** |

## Diamonds

Diamonds are bought with Robux as developer products, which can be bought again and again. Every pack is full
price except the biggest, the **Vault, which is 10% off**.

| Pack | Diamonds | Robux | Premium crates |
|---|---|---|---|
| Handful | 250 | **99** | 1 |
| Pouch | 500 | 199 | 2 |
| Bag | 1,000 | 399 | 4 |
| Chest | 1,500 | 599 | 6 |
| Vault (10% off) | **2,500** | **899** ~~999~~ | A 10-pack, plus 250 left |

## Game passes

Game passes are bought once and kept forever.

| Game pass | Robux | What it gives |
|---|---|---|
| **Slot 4** | 149 | Opens loadout slot 4 (or unlock it with **2,500 coins**) |
| **Slot 5** | 299 | Opens loadout slot 5, after slot 4 (or unlock it with **6,000 coins**) |
| **Double Coins** | 349 | Every coin reward from matches is doubled |
| **VIP** | 199 | A gold name and VIP tag in chat, an exclusive VIP worm skin, and one free skin crate every day |

All prices are a proposal. Either Legendary costs about 4,050–4,950 Robux; a specific one about 8,100–9,900.

## Duplicates and shiny items

A crate can drop something the player already owns: a weapon, a utility or a skin. Each one adds a copy, and
**10 copies** of the same item turn it into its **shiny** version.

| Shiny | What changes |
|---|---|
| Weapons | A shiny look and **+5% damage** |
| Utilities | A shiny look and a small boost of their own (below) |
| Skins | A shiny look only |

| Shiny utility | Boost |
|---|---|
| Bandage | Heals 45 instead of 40 |
| Medkit | Heals 110 instead of 100 |
| Jetpack | Flies 20% longer |
| Speed potion | 10% faster |
| Parachute | Falls 20% slower |
| Low gravity potion | 10% stronger: higher jumps, slower falls |

The Grenade and Shotgun never drop from crates, so they can't become shiny.

::navbox{from="game"}
