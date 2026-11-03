# AGENTS.md — {{Title}}

Guide for AI agents working in this repo. {{Title}} is a Roblox game. The repo holds its two projects, made by ume's
new-project template from ume {{UmeRef}} and ume-gui {{UmeGuiRef}} (copies without their history), and the place they
sync into.

| Folder | What | Rules |
| --- | --- | --- |
| `{{Name}}-game/` | The game's code, on the ume framework | its `AGENTS.md` and `.claude/rules/` |
| `{{Name}}-gui/` | The game's guis, on UmeGui, styled by the `{{Theme}}` theme | its `AGENTS.md` and `.claude/rules/` |
| `{{Name}}.rbxl` | The place both projects sync into | |

The folders' `AGENTS.md`, `CLAUDE.md` and rules are the framework's and name no game: they say `<name>-game`,
`<name>-gui` and `<Game>`. Here `<name>` is `{{Name}}` and `<Game>` is `{{Theme}}`. This file and `CLAUDE.md` are the
game's: change them to fit it (its names, a folder or skill it adds, a wiki).

The game's own decisions (how it uses ume and ume-gui, and its gui look) are in
`{{Name}}-game/.claude/rules/game/practices.md`. They cover both folders and win over the framework's defaults.

## Working here

- Work in one folder at a time: follow its rules and run its commands from inside it.
- Framework-owned folders and files are replaced when the game takes a newer ume or ume-gui, so a change there is
  lost. Which they are, and how to update: `family/family.md` (Boundaries, Updating) in either folder. The rest is the
  game's own.

## Studio

| UmeSync project | Path | Category | Place |
| --- | --- | --- | --- |
| `{{Name}}-game` | `{{Name}}-game/` | {{Title}} | `{{Name}}.rbxl` |
| `{{Name}}-gui` | `{{Name}}-gui/` | {{Title}} | `{{Name}}.rbxl` |

Connecting and checking: `.claude/rules/luau/studio.md` in either folder. When the projects aren't in UmeSync yet,
ask, then create the category with `create_category` and add both folders with `add_project` (`category`: {{Title}}).
