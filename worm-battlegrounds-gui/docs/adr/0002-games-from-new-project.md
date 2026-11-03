# 0002: Games from new-project, and ume-rbx copies UmeGui on demand

**Status:** Accepted
**Date:** 2026-10-16
**Deciders:** Nari
**Supersedes:** the game layout and ume-rbx's committed copy in [0001](0001-umegui-in-its-own-repo.md)

> **Update, 2026-10-16:** [0003](0003-plugin-widgets-in-ume-gui.md) moves the plugin's widgets into ume-gui
> (`src/guis/Plugin`): ume-rbx now copies them with the engine and the System theme, and every game gets them.

## Context

ADR 0001 made a game two repos: `<game>`, made with GitHub's "Use this template" on ume, and `<game>-gui`, a clone of
ume-gui that pulls engine updates from `upstream`. In practice:

- Nothing renamed what came with the template. anime-rng, made from ume, still names its project `ume`.
- Every game meant two GitHub repos, two remotes and a merge from upstream to keep in step.
- New games are rare, and they seldom need the framework's later changes enough to merge them.

ADR 0001 also had ume-rbx commit a pinned copy of the engine (`vendor/ume-gui`). Every engine change a plugin widget
needed took a tag in ume-gui, `Sync.ps1 Gui` in ume-rbx and a commit of the copied files, which showed up as large
diffs of generated files.

## Decision

**A game is one repo made from new-project.** `ume-roblox/new-project` is a template holding a README and
`setup.ps1`. Setup copies the newest ume tag into `<game>-game/` and the newest ume-gui tag into `<game>-gui/`, without
their git history, names both projects after the game, moves `ume.rbxl` to the repo root as `<game>.rbxl`, adds the
game's theme and regenerates the Libs mirror. Nothing else is created: no GitHub repos, no remotes. In UmeSync the two
folders stay two projects (one folder per project, as UmeSync works today), grouped in a category named after the game.

A game doesn't track ume or ume-gui afterwards. To take a newer engine, it copies ume-gui's folders over its own
(`gui/repo.md`).

**ume-rbx copies UmeGui on demand.** `vendor/` is gitignored. While the plugin is developed, `Sync.ps1 Gui -Local`
copies `../ume-gui`'s current engine and System theme into `vendor/ume-gui`, and `-Watch` keeps copying as files
change, so UmeSync syncs them as part of ume-rbx. `Release.ps1` copies the newest ume-gui tag into `vendor/` before it
builds, so every release bundles a tagged UmeGui. ume-rbx reads `gui/format.md` from `../ume-gui` instead of a copy.

## Options considered

| | A: one repo from new-project (chosen) | B: two repos, as in 0001 | C: one repo, framework kept as git upstream |
| --- | --- | --- | --- |
| Repos per game | 1 | 2 | 1 |
| Named after the game at creation | Yes (setup) | By hand | Yes |
| Takes framework updates | By copying folders | `git pull upstream` | `git pull upstream`, two histories in one repo |
| Setup | One script | Template + clone + remotes | Script with subtree merges |

For ume-rbx:

| | Copy on demand, gitignored (chosen) | Committed copy, as in 0001 | Point the project at `../ume-gui` |
| --- | --- | --- | --- |
| Engine edits reach the plugin | `-Watch`, or `-Local` once | Tag, copy, commit | Only if UmeSync watched folders outside a project, which it doesn't |
| Releases reproducible | Yes: copied from a tag at release | Yes | Only with a release copy |
| Generated files in git | None | `vendor/ume-gui` | None |

## Consequences

- **Easier:** a new game is one template and one command; every name matches the game. Plugin work on the engine needs
  no tag or commit until release. ume-rbx's history no longer carries generated engine files.
- **Harder:** a game takes engine and framework fixes by copying folders, not by merging. ume-rbx can't build or sync
  until `vendor/` is filled once (`Sync.ps1 Gui` or `-Local`), and development needs `../ume-gui` next to it.
- **Unchanged:** the host API contract (0001), the ownership of folders inside a game's gui folder, and UmeSync.
