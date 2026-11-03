# AGENTS.md — the code folder

The game's code (`<name>-game`), on ume, a lightweight Luau framework for Roblox games (copied from ume by
new-project's setup). `../AGENTS.md` names the game, gives the versions and maps the repo; the guis this code drives
are in the gui folder (`../<name>-gui`).

Modules (one folder each, with `Server.lua` / `Client.lua` / `Global.lua` entry scripts) start in a fixed order on both
sides and expose their APIs on the framework instance `I` (`I.Currency.Add(...)`). The framework ships its own modules
(Network, Topic, Component, AdminPanel, player data, the Replicator, Roblox API wrappers) and libraries (`I.Number`,
`I.BN`, `I.Validate`, …).

## Read first

- `.claude/rules/ume/overview.md`: which rule owns what, the guide to read before writing each kind of file, the checks.
- `.claude/rules/game/`: the game's own rules, `practices.md` first (`family/family.md` → Rules).
- The `_meta/README.md` of any module or library you use or change.

## Commands

```sh
rokit install                                                 # selene and stylua at the versions in rokit.toml
selene src                                                    # lint, after every Lua edit (rokit run selene src if not on PATH)
stylua --check <files>                                        # formatting of the files you changed
ume-sync build default.project.json -o <scratchpad>/game.rbxl # after structural changes (ume/tooling.md)
```

## Map

| Path | In the place | What |
| --- | --- | --- |
| `src/core/game_mode/{server,client}` | `ServerScriptService.GameMode`, `StarterPlayerScripts.GameMode` | The scripts that start the framework |
| `src/core/game_instance` | `ServerScriptService.Instance` | The loader: `Start/` (configs, start tasks), `Failed/` |
| `src/modules/{Main,Main_Controllers,Main_Game,Utils}` | `Instance.Modules` | The game's modules |
| `src/modules_ume/{Ume,Ume_Data,Roblox}` | `Instance.Modules_Ume` | The framework's modules |
| `src/libs/{Internal,External}` | `Instance.Libs` | Libraries, assigned onto `I` at startup |
| `src/global_data` | `Instance.GlobalData` | Tunables the framework's modules read |
| `src/other/TagListPlus.model.json` | `ServerStorage.TagListPlus` | The components' tag registry, generated (`ume/tooling.md`) |
| `<unit>/_meta/` | hidden at runtime | `README.md` (the unit's docs), `_types.lua` (its classes) |
| `docs/` | | ume's `architecture/`, `guides/` (templates) and `reference/`; the game's own docs in `game/` (`lessons.md`). Index: `docs/README.md` |
| `ume.yaml` | | Settings for ume's tools: where the extracts write, the author nickname |

`src/core`, `src/modules_ume`, `src/libs` and `docs/` (not `docs/game/`) are the framework's: replaced when the game
takes a newer ume (`family/family.md` → Updating), changed only when the user asks.

## Skills

Playbooks in `.claude/skills/<name>/SKILL.md`; any agent can read them. The template's:

| Skill | Use when |
| --- | --- |
| `audit-and-fix` | The user asks to audit a module or folder for bugs, leaks, performance, security and data safety, then fix them |
| `refactor-to-framework` | The user asks to bring a script, module or folder onto these rules |
| `network-and-events` | The user asks to align a module's remotes and Topics with `ume/events.md` |
| `readme` | A module or library needs its `_meta/README.md` written or refreshed |

The first three run only when the user invokes or names them; naming a module isn't enough. Skills the game adds are
listed in `../AGENTS.md`.

## Studio

This folder is the game's code project in UmeSync (its name: `../AGENTS.md` → Studio). Connecting and checking:
`.claude/rules/luau/studio.md`.
