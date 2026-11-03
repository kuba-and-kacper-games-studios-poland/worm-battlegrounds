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
  - id: premium-power
    text: "Worm Battlegrounds' premium crate costs 250 diamonds (bought with Robux) and drops only Rare, Epic and Legendary weapons, which are stronger in matches against other players. Research on Roblox PvP games (RIVALS, Jujutsu Shenanigans, Blade Ball) finds the line players draw is money that changes who wins; all 11 crate weapons can also be won from the 100-coin weapon crate. What should the premium crate sell?"
    options: ["Keep it: Rare, Epic and Legendary weapons with better odds", "Weapons only from coin crates; the premium crate sells cosmetics instead (skins, weapon skins, emotes)", "Keep it, and say on the game page that every weapon can also be won with coins"]
  - id: shiny-boosts
    text: "In Worm Battlegrounds, 10 copies of an item make it shiny: shiny weapons deal +5% damage and shiny utilities get a small boost (a Bandage heals 45 instead of 40). Diamond crates, bought with Robux, collect copies faster, so paying players reach those boosts first in matches against other players. Should shiny items keep a gameplay boost?"
    options: ["Keep the boosts", "Shiny is a look only, for weapons and utilities like for skins", "Shiny adds a cosmetic extra (a trail or an explosion color) instead of a boost"]
  - id: restricted-regions
    text: "Worm Battlegrounds' diamond crates (premium, utility and skin) are paid random items. Roblox requires a check (PolicyService) for players where these are restricted, as in Belgium, the Netherlands, the UK, Australia and Brazil (where under-18s can't open them), or the game can be removed. What do those players get instead of the diamond crates?"
    options: ["The diamond crates are hidden; the coin crates stay", "They buy one chosen item directly for diamonds, at its average crate cost", "They see the crates with a message that buying isn't available in their region"]
  - id: bot-coins
    text: "In Worm Battlegrounds, bots fill the empty spots of a public match when its 30-second timer ends, and they count as players for coins. A player alone in a public 8-player lobby can beat 7 bots and earn 150 coins for 1st place, more than a Hard win against AI pays (60). How should bot-filled public matches pay?"
    options: ["Bots in public matches play at Hard, so 1st place stays earned", "Places pay as if only the real players were there (1 player and 7 bots pays like a 2-player match)", "Keep it as it is"]
suggestions:
  - id: diamond-bonus
    text: "Every Worm Battlegrounds diamond pack gives the same diamonds per Robux except the Vault (+11%). In Roblox games the largest currency pack gives a median 27% more per Robux than the smallest, and RIVALS, Blox Fruits and Murder Mystery 2 give 48–73%. Make the bonus grow with the pack: Handful 250 for 99, Pouch 525 for 199, Bag 1,100 for 399, Chest 1,750 for 599, Vault 3,000 for 899 (about +5%, +9%, +16%, +32%)?"
    options: [Yes, Later, No]
  - id: honest-labels
    text: "Worm Battlegrounds' Vault shows a crossed-out 999 Robux beside its 899 price, and every crate's 10-pack says '10% off' forever. Since April 2026 Roblox bans crossed-out prices that were never charged and discounts that never end. Show these as bonuses instead ('+11% diamonds' on the Vault, '10 crates for the price of 9' on 10-packs)?"
    options: [Yes, No]
  - id: starter-pack
    text: "Most Roblox games sell a one-time starter pack (median 79 Robux; PvP games 49–67), shown once after the tutorial with a real time window. Worm Battlegrounds has none. Add one for 99 Robux, offered once per account for 72 hours after the tutorial crate: an exclusive starter worm skin plus 500 diamonds, with every item listed?"
    options: [Yes, Later, No]
  - id: gift-copies
    text: "294 of 491 top Roblox games let players buy an item as a gift for someone else, at the same price. Let Worm Battlegrounds players buy the game passes (Slot 4, Slot 5, Double Coins, VIP) and diamond packs as gifts for a player in their party or match?"
    options: [Yes, Later, No]
  - id: rewarded-ad
    text: "Roblox's rewarded video ads let a player choose to watch a short ad for a small fixed reward, and pay the game for it; one game's earnings rose 40%+. They only show to players 13 and older, and the game needs 2,000 visitors a month. Where should Worm Battlegrounds offer one?"
    options: ["On the results screen: watch to double that match's coins, up to 3 times a day", "In the loadout: watch to try one weapon you don't own for one match", "No ads"]
  - id: cosmetics
    text: "Roblox PvP games earn most from looks that don't change who wins: weapon skins, kill effects and victory effects (100–199 Robux), emotes. Worm Battlegrounds sells worm skins and coin emotes only. Which cosmetics should its shop add? Pick every one."
    multiple: true
    options: ["Weapon skins (a gold Bazooka, a candy Grenade)", "Gravestones left where a worm is knocked out", "Explosion colors and projectile trails", "Victory dances on the results screen", "Emotes sold for Robux beside the coin ones"]
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
