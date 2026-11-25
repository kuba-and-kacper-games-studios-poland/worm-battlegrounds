---
title: "MapLab's workbench (_Labs) removed from the place: 151,260 → 14,628 Workspace parts"
date: 2026-11-25
status: open
kind: removed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/.claude/rules/game/practices.md
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
  - worm-battlegrounds-game/docs/game/lessons.md
---

**What changed.** `Workspace._Labs` (MapLab's build area: `Maps` with the nine working copies, `_Study` props,
`_Kit` ModuleScripts and `_Iterations`, the 120 old map versions) was deleted from the place. It held 136,632 of the
Workspace's 151,260 parts and no game code used it. It was only hidden (`HideOnPlay`), so every lobby and match
server still loaded it and walked its 141,000 instances at start. The owner saved `_Labs` to a file first; it goes
back into Studio only to build a map, and comes out before the place is saved.

**Where.** The place (`Workspace._Labs` is gone; the arena templates in `Workspace.Ume.ServerStorage_Assets/Arenas`
are unchanged). practices.md → Maps and placeholders → "The Workspace holds only the game" no longer lists `_Labs`.
The Arena README says the replaced templates (`<MapId>_arena_<n>`) are in the saved `_Labs` file.

**How to check.** In Studio, `workspace:FindFirstChild("_Labs")` is nil and the Workspace has about 14,600 parts.
Players see no change; servers start lighter once the place is saved and published.

**For the wiki.** Architecture → In the place: remove the `Workspace._Labs.MapLab` line and say MapLab's workbench
lives in a saved file outside the place. Older journal entries naming `Workspace._Labs.MapLab._Iterations.<…>` mean
that file now.
