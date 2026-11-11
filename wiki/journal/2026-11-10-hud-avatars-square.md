---
title: "Match HUD avatars are square, inside their outline"
date: 2026-11-10
status: open
kind: fixed
pages: ["Match screen", "Guis"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/_meta/README.md
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Teams.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
---

**What changed.** In the team panels and the turn list, player headshots and the bots' picture were different
shapes and drew over the slot's outline. Now every avatar is the same square, standing on the bottom of the slot,
under its outline.

**Where.** In MatchHud's `PREFAB | TeamPlayer` and `PREFAB | TurnEntry`, `S_Avatar` moved inside `Background`,
between `Main` (ZIndex 1) and the outlines: `S_Avatar` 2, then the strokes 3 and 4 (and `S_Mask` 5 in TurnEntry);
`AnchorPoint` 0.5, 1 at `Main`'s bottom, `ScaleType` Fit, with a `UIAspectRatioConstraint` of 1. The code finds it
with `FindFirstChild("S_Avatar", true)` (`Teams._buildTeam`, `Turn._refreshTurnList`).

**How to check.** MatchHud was exported again into StarterGui on 2026-11-10 (`UmeGui.Export`, with the turn
callouts of `2026-11-10-your-turn-callout`; the old copy is in `ServerStorage.!dump` as
`MatchHud_before_2026-11-10`), so the place carries the new layout once it's saved. In a match against bots, every avatar in
both team panels and the turn list is square and framed by its outline.

**For the wiki.** Match screen: nothing to change unless it describes the avatars' look.
