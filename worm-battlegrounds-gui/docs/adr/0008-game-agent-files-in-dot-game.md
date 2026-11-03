# 0008: A game's agent files ship in `.game/`

**Status:** Accepted, ume-gui 4.1.0
**Date:** 2026-11-03
**Deciders:** Nari

## Context

A game's gui folder is a copy of ume-gui, made by new-project's `setup.ps1`, `.claude/` included. ume-gui's
`AGENTS.md`, `CLAUDE.md` and `.claude/rules/family/` are written for maintaining ume-gui (the same `family/` is in
every framework repo), so a game's gui folder got the maintainers' instructions. My Tree Farm rewrote them for a game:
which folders are the framework's and read only, where the game's own rules go, and how to update. ume made the same
choice for its own folder (its ADR 0010).

## Decision

**ume-gui keeps a game's set beside its own, in `.game/`:** `AGENTS.md`, `CLAUDE.md` and `.claude/rules/family/`.
`setup.ps1` swaps the set in when it makes a game, then removes `.game/`. A game's update copies the set again, with
the engine. The `gui/` and `luau/` rules and the skills stay one copy, worded to work in a game's gui folder and in
ume-gui itself (`gui/repo.md` says which folders each may change).

## Options considered

| | A: `.game/` beside the maintainers' files (chosen) | B: the game set in new-project | C: one set for both |
| --- | --- | --- | --- |
| Versioned with the framework | Yes, with ume-gui's tags | With new-project only | Yes |
| Maintainers' rules | Unchanged | Unchanged | Rewritten to fit games too |
| A game's update | Copies the set from the new ume-gui | Needs new-project as well | Copies everything |
