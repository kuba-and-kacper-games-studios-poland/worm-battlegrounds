# 0010: A game's agent files ship in `.game/`

**Status:** Accepted, ume 2.0.0
**Date:** 2026-11-03
**Deciders:** Nari

## Context

A game is made from new-project, whose `setup.ps1` clones ume and ume-gui whole, `.claude/` included. ume's
`AGENTS.md`, `CLAUDE.md` and `.claude/rules/family/` are written for maintaining ume (the same `family/` is in every
framework repo), so a game got the maintainers' instructions. My Tree Farm rewrote them for a game: which files are
the framework's and read only, where the game's own rules go (`.claude/rules/game/`), and how to update. Those rules
had nowhere to live upstream without replacing the maintainers'.

## Decision

**ume keeps a game's set beside its own, in `.game/`:** `AGENTS.md`, `CLAUDE.md`, `.claude/rules/family/`, and the
starters `.claude/rules/game/practices.md` and `docs/game/lessons.md`. `setup.ps1` swaps the set in when it makes a
game, then removes `.game/`. A game's update copies the set again (`family/family.md` → Updating ume or ume-gui, in
the game's set), never the starters. ume-gui does the same with its own set.

The code rules (`luau/`, `ume/`) and the skills stay one copy, worded to work in a game, in ume itself and, for
`luau/` and the readme skill, in ume-rbx.

## Options considered

| | A: `.game/` beside the maintainers' files (chosen) | B: the game set in new-project | C: one set for both |
| --- | --- | --- | --- |
| Versioned with the framework | Yes, with ume's tags | With new-project only | Yes |
| Maintainers' rules | Unchanged | Unchanged | Rewritten to fit games too |
| A game's update | Copies the set from the new ume | Needs new-project as well | Copies everything |

## Consequences

- **Harder:** a change to how games work with ume edits `.game/` as well as ume's own files.
- **Easier:** a new game starts with rules written for a game, and updates keep them current.
