# AGENTS.md — Worm Battlegrounds

Guide for AI agents working in this repo. Worm Battlegrounds is a Roblox game. The repo holds its two projects, made by ume's
new-project template from ume v2.0.0 and ume-gui v4.1.0 (copies without their history), and the place they
sync into.

| Folder | What | Rules |
| --- | --- | --- |
| `worm-battlegrounds-game/` | The game's code, on the ume framework | its `AGENTS.md` and `.claude/rules/` |
| `worm-battlegrounds-gui/` | The game's guis, on UmeGui, styled by the `WormBattlegroundsBrawl` theme (the GUI kit, over `WormBattlegrounds`) | its `AGENTS.md` and `.claude/rules/` |
| `worm-battlegrounds.rbxl` | The place both projects sync into | |
| `wiki/` | The game's Shiori wiki: the design, the player's guide under `pages/game/` | `wiki/AGENTS.md`, only when asked to change it |
| `bot-gym/` | The PC bot gym: the Bots module's gym run outside Roblox in Lune, on every core, and its parity check against Studio | `bot-gym/README.md` |

The folders' `AGENTS.md`, `CLAUDE.md` and rules are the framework's and name no game: they say `<name>-game`,
`<name>-gui` and `<Game>`. Here `<name>` is `worm-battlegrounds` and `<Game>` is `WormBattlegrounds`. This file and `CLAUDE.md` are the
game's: change them to fit it (its names, a folder or skill it adds, a wiki).

The game's own decisions (how it uses ume and ume-gui, and its gui look) are in
`worm-battlegrounds-game/.claude/rules/game/practices.md`. They cover both folders and win over the framework's defaults.

## Skills the game adds

| Skill | Use when |
| --- | --- |
| `brawl-gui` (`worm-battlegrounds-gui/.claude/skills/brawl-gui/SKILL.md`) | Asked to make or restyle a gui in the game's GUI kit look (Brawl Stars style, the `WormBattlegroundsBrawl` theme), in the gui or as a design option |
| `train-bots` (`worm-battlegrounds-game/.claude/skills/train-bots/SKILL.md`) | Asked to train, retrain or recalibrate the bots (self-play on the PC with `bot-gym/`, checked in Studio), or to teach them something the game added. Only when asked |

## Working here

- Work in one folder at a time: follow its rules and run its commands from inside it.
- Framework-owned folders and files are replaced when the game takes a newer ume or ume-gui, so a change there is
  lost. Which they are, and how to update: `family/family.md` (Boundaries, Updating) in either folder. The rest is the
  game's own.
- Don't change the wiki unless asked: write what changed in `wiki/journal/`, one entry per change (`wiki/JOURNAL.md`).

## Studio

| UmeSync project | Path | Category | Place |
| --- | --- | --- | --- |
| `worm-battlegrounds-game` | `worm-battlegrounds-game/` | Worm Battlegrounds | `worm-battlegrounds.rbxl` |
| `worm-battlegrounds-gui` | `worm-battlegrounds-gui/` | Worm Battlegrounds | `worm-battlegrounds.rbxl` |

Connecting and checking: `.claude/rules/luau/studio.md` in either folder. When the projects aren't in UmeSync yet,
ask, then create the category with `create_category` and add both folders with `add_project` (`category`: Worm Battlegrounds).
