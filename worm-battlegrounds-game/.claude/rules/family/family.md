# Where this code comes from

*Framework rule: the same file is in both folders, from ume and ume-gui. Read only (Rules, below).*

This repo is a game made from ume's new-project template: `<name>-game/` started as a copy of **ume** (the framework)
and `<name>-gui/` as a copy of **ume-gui** (UmeGui, the gui engine). They are two UmeSync projects in one category,
syncing into the place at the repo root. The game's own names (its folders, place and UmeSync category) are in
`../AGENTS.md`. The rest of the ume family are tools the game uses:

| Tool | For the game |
| --- | --- |
| **UmeSync** (ume-sync) | Syncs both folders into Studio, one way; its MCP tools connect, check, stamp and extract |
| **The Ume Roblox plugin** (ume-rbx) | In Studio: the Sync tool, the Gui tool (previews and exports the guis), TagList+ |
| **ume-lsp**, **ume-vscode** | The language server and the editor extension (snippets, the author stamp, the extracts) |

## Boundaries

- Never change another repo from here. When a change belongs in one (a framework fix, a shared control), name it and
  ask.
- Framework-owned folders (the code folder's `AGENTS.md` → Map, the gui folder's `gui/repo.md` → Who owns what) are
  replaced by newer ume and ume-gui versions (Updating, below), so a change there is lost.

## Rules

| Path | Owner | Agents |
| --- | --- | --- |
| `.claude/rules/family/`, `.claude/rules/luau/` (both folders), `.claude/rules/ume/` (the code folder), `.claude/rules/gui/` (the gui folder) | the framework | read only |
| The template's skills: `audit-and-fix`, `network-and-events`, `readme`, `refactor-to-framework` (the code folder), `readme` (the gui folder) | the framework | read only |
| `AGENTS.md`, `CLAUDE.md` (both folders) | the framework | read only |
| The repo root's `AGENTS.md` and `CLAUDE.md` (`../`) | the game | change to fit the game: its names, versions, folders, skills |
| `.claude/rules/game/` (the code folder; `game/practices.md` covers both folders) | the game | create and change |
| Any other skill | the game | create and change |

- **Framework rules are read only.** They stay exactly as the template created them: never edit, move or delete one,
  not even to fix a mistake or fit it to the game. Newer framework versions replace them (Updating, below).
- **The game's own rules go in `.claude/rules/game/`:** a decision in `game/practices.md`, or a rule file of its own.
  A game rule may narrow or override a framework rule; it names the rule it overrides, and the game's rule wins.
- **When a framework rule is wrong or missing something,** write what the game needs in `game/`, and name the
  framework change to the user so it reaches ume or ume-gui.
- Framework files never name a game: they say "the code folder" and "the gui folder" (`<name>-game/`, `<name>-gui/`),
  and `<Game>` for the gui folder's own folders. The game's names live in the repo root's `AGENTS.md` and `CLAUDE.md`.

## Agent files

- Rules are `.claude/rules/**/*.md`. One without `paths:` frontmatter always loads; one with it loads when a matching
  file is read.
- A rule is the only full statement of its constraint, and each fact lives in one rule; other files link to it
  instead of copying it.
- `luau/`, `family/` and the `readme` skill are the same files in both folders.
- Clones, scripts, test places, builds and screenshots go in the session's scratchpad, never in the repo.

## Updating ume or ume-gui

The folders don't track ume or ume-gui. Their versions now: `_umeVersion` in the code folder's
`src/core/game_instance/Start/configs/general.lua`, and the gui folder's `src/engine/Version.model.json`.

1. Take the newest tag from GitHub (`git ls-remote --tags --refs --sort=-v:refname https://github.com/ume-roblox/ume
   "v*"`, the same for `ume-gui`; the first line is the newest), never from a doc or a sibling checkout.
2. Copy the framework-owned folders and files (Boundaries, above) from that tag over the game's, then run
   `./scripts/Sync.ps1 Libs` in the gui folder. Each folder's `AGENTS.md`, `CLAUDE.md` and `.claude/rules/family/`
   come from the tag's `.game/` folder: the ones at the tag's root are for working on ume or ume-gui itself.
3. Never copy over the game's own: `.claude/rules/game/`, `docs/game/`, its guis, its theme and its own skills.
4. Write the versions you took in `../AGENTS.md`, with what changed for the game.
