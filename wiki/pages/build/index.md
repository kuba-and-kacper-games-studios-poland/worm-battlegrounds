---
title: "Implementation plan"
summary: "How Worm Battlegrounds gets built on ume: the modules, guis, data and networking, and the order to build them in. Written so one agent can build the whole game from it."
icon: toolbox
status: active
order: 2
type: "Plan"
tags: [build]
suggestions:
  - id: playtest-after-combat
    text: "Worm Battlegrounds' roadmap builds a full match (every weapon, bots, results) before the lobby, economy and shop. Stop the build after that point for a team playtest, and tune blast sizes, knockback, stamina and the turn time before building the lobby on top of them?"
    options: [Yes, No]
  - id: greybox-first
    text: "The agent building Worm Battlegrounds can't make the studded art (maps, worm skins, weapon models, icons, animations, sounds); it builds grey placeholders. Should the team make art for Picnic Plains, the Classic worm and the Bazooka first, so the first playtest already looks like the game?"
    options: [Yes, "No, greybox is fine for the first playtest"]
  - id: ume-change
    text: "ume always spawns each player's Roblox avatar once (its INITIAL_CHARACTER_AUTO_LOAD setting), but Worm Battlegrounds has no avatars, so the game parks them out of sight with a small CharacterPark module. Ask ume for a per-map switch that skips the first spawn, so the game can drop CharacterPark?"
    options: [Yes, No]
---

This section is the **build plan** for Worm Battlegrounds: every module, gui, saved key and remote the game needs on
the ume framework, and the order to build them. The game pages ([[The game]] and the pages under it) stay the source
of truth for **what** the game does and its numbers; this section says **how** it's built and **in what order**.

Phases P0 to P12 are built (2026-11-03 to 2026-11-06), with placeholder ids, models and art, and the pages below
describe the game as built. Each module's `_meta/README.md` in the code folder is the source of truth for its API and
settings; P13 (content and launch checks) is what's left.

:::cards
- :icon[checklist] [Roadmap](/roadmap) — the build order: 14 phases, each with its tasks and how to check it's done
- :icon[books] [Architecture](architecture) — servers and maps, travel between them, physics, replication, the place
- :icon[target] [Match modules](match-modules) — arena, worms, movement, combat, turns, bots, camera, match screen, rewards
- :icon[home] [Lobby & meta modules](meta-modules) — lobby, match rows, party, loadout, crates, cosmetics, levels, shop, tutorial
- :icon[frame] [Guis](guis) — every gui, its kind, its module and how it opens
- :icon[tag] [Data & networking](data) — saved keys, data rows, global data, remotes, Topics, replicated values
:::

## How to build from this plan

One agent builds the game, phase by phase, in the order of the [[Roadmap]]:

:::steps[For the building agent]
1. Open the session on the game's repo, `game/` (the folder with `worm-battlegrounds-game/`, `worm-battlegrounds-gui/` and the place). Read `game/AGENTS.md`, then both folders' `AGENTS.md` and every rule in their `.claude/rules/` before writing a line, and the code folder's `docs/guides/` for each kind of file you write.
2. Read this section and the game pages it links. When this plan and a game page disagree on what the game does, the game page wins; on how it's built, this plan wins; when a framework rule disagrees with this plan, the rule wins (and tell the owner).
3. Build one phase at a time, in order. Work in one folder at a time and run its checks: selene and StyLua (or ume-sync's `check`), `stamp_authorship` on new Luau files, `extract_components` after a `*.comp.json` change, each module's `_meta/README.md` written with the `readme` skill.
4. Check every phase in Studio through the Roblox Studio MCP (play tests, the command bar, the output, screen captures) against its "Done when" lines on the module pages. Don't start the next phase until they pass.
5. After each phase, write one journal entry per change players would notice in `game/wiki/journal/` (`game/wiki/JOURNAL.md`). Never change the wiki itself.
6. Stop at an **owner gate** (below) and say exactly what's needed. Never invent asset ids or product ids.
7. Never edit framework-owned files (`src/core` except `configs/`, `src/modules_ume`, `src/libs`, the gui folder's `src/engine` and `src/themes/System`, every `.claude/rules/` but `game/`). Record each game decision in `worm-battlegrounds-game/.claude/rules/game/practices.md`, its story in `docs/game/lessons.md`.
:::

**The prompt to start it with** (paste it into a session opened on `game/`):

```text
Build Worm Battlegrounds from the wiki's Implementation plan (wiki/pages/build/ and wiki/pages/roadmap.md),
phase by phase, starting at the first phase whose tasks aren't done. Follow "How to build from this plan" on
wiki/pages/build/index.md exactly. Check each phase in Studio before moving on, write journal entries instead of
changing the wiki, and stop at owner gates. Commit each finished phase on a local branch; don't push.
```

## Owner gates

What the agent can't make or decide, and when it's needed.

| Before phase | The owner provides |
|---|---|
| P0 | Both projects in UmeSync's "Worm Battlegrounds" category and connected to the open place; Studio with the Roblox Studio MCP running |
| P1 | The arena maps, made in MapLab and approved before they go in the game (shape on [[Architecture#In the place]]). Picnic Plains and Desert are in; 4 or 5 to go |
| P2 | Worm skin models (the Classic first) and their animations; until then the agent's placeholder worm |
| P9 | The published **lobby and match places** with API services on (DataStore, MemoryStore, teleports) to test lobby ↔ match travel; the lobby place's max players. Both places exist |
| P10 | Item icons, crate pictures, skin models and emote animations |
| P11 | The 5 developer products and 4 game passes created in the Creator Hub, their ids, and the Robux prices set there |
| P13 | Sounds and music (uploaded as `.ogg` after PrepKit), the lobby background, map thumbnails, lighting presets, the badge list if any; the go-ahead for `IsProductionReady` |

## Decisions this plan makes

Technical choices, with why. Each one goes into the game's `practices.md` in phase P0.

| Decision | Why |
|---|---|
| **Two places, one file** (the lobby place and the match place, Arena), booting the `Lobby` and `Match` maps, plus ume's transit `UmeLobby` and the Studio-only `Studio` map | One place file, one sync; the place id picks the map, so Roblox's analytics count the lobby and the matches apart (moved from one place to two on 2026-11-06) |
| **Every match on its own reserved server** (`I.Teleport` with metadata) | The design asks for it; a match server only ever holds one match, so its code never juggles several |
| **Rematch on the same server** | No teleport wait; the arena reloads from its template |
| **Public rows per lobby server first** | Simple and testable with Studio's local players; a MemoryStore board can replace it behind the same API |
| **Worms are not Roblox characters** | A turn game needs the server to decide positions. Avatars are parked (`CharacterPark`); worms are server-owned physics models |
| **Roblox physics, server-owned, on a `PlaneConstraint`** | Bouncing grenades, rolling black holes, falling blocks and knockback come from the engine and replicate smoothly; the active worm is owned by its player while walking for instant feel, checked by the server |
| **Terrain as authored parts, carved by CSG in 1-stud steps** (replaced the planned grid of greedy-meshed chunks) | Maps look hand-made (made in MapLab); craters still step like blocks on the grid; replicated by Roblox for free, rejoins included. Only water and lava are a grid |
| **Weapons, utilities, skins and emotes are Inventory items** | ume's Inventory already saves counts (copies toward shiny) and syncs them; combat numbers live beside them in `Arsenal` |
| **Roblox's own chat, voice button, teams and player list** | TextChatService filters chat (a Roblox rule); `I.Team` gives team chat and the player list grouping for free |
| **Fail-closed paid random items** | Diamond crates hide until `PolicyService` says they're allowed; Roblox can remove a game that gets this wrong |
| **No fake discounts** | "10 for 900", never "10% off" forever or crossed-out prices (banned since April 2026) |
| **Prices read live** | Robux prices come from the Creator Hub (`GetProductPrice`), never from code |

## Open questions: what the build does meanwhile

Questions and suggestions still open on the game pages, and what the plan builds until they're answered. An answer
later lands in that page's Incoming changes like any other.

| Open on | Item | Built meanwhile |
|---|---|---|
| [[Currencies & crates]] | Shiny gameplay boosts | Kept (+5% damage, the utility boosts), each one a single setting |
| [[Currencies & crates]] | Restricted regions | Diamond crates hidden, coin crates stay |
| [[Currencies & crates]] | Bot-filled public matches pay | Bots count as players (as the page says now) |
| [[Currencies & crates]] | Honest labels, diamond bonus ladder, premium crate's power | Labels without discounts; the pack amounts as written; the premium crate as written |
| [[Lobby]] | Middle solo difficulty's name, custom lobby teams, bots in custom lobbies, parties bigger than a team | Medium; two equal teams; no bots (only the players who joined); a party bigger than a team can't join that row |
| [[Arsenal]] | Speed potion and stamina | Stamina ×1.5 with the speed |
| [[Levels & XP]] | Which matches give XP | Public, solo, party and custom; not the tutorial |
| [[Emotes]] | Where emotes are bought | A + at the end of the lobby's emote row opens the emote shop |
| [[Match screen]] | Rematch map | The same map |
| [[Match screen]] | The turn timer on the active worm's tag | Only in the turn panel |
| [[Match modes & maps]] | Desert: a seventh map or a replacement | In the rotation with Picnic Plains |
| Every other open suggestion | Supply drops, quick chat, win streaks, mastery, starter pack… | Not built. Of the [[Build brief#Left to the scripter]] picks, the currency bar and the worm in the lobby are built; the short aim line was built, then replaced by the crosshair; the last-shot marker isn't |

## Not built at launch

As the [[Build brief#Not at launch]] says: no events, no season pass, no report button. Also left out of this plan,
because nothing in the design asks for them yet: badges, global leaderboards, the friends and group bonuses ume's
controllers offer, trading, daily rewards.

::navbox{from="build"}
