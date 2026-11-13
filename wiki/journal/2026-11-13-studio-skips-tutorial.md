---
title: "Studio playtests skip the whole tutorial unless StudioTutorial is on"
date: 2026-11-13
status: open
kind: changed
pages: ["Architecture", "Lobby & meta modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Server.lua
---

**What changed.** In Studio with Workspace's `StudioTutorial` off (or unset), a playtest skipped only the tutorial
match: the lobby marked it played (`I.Tutorial.CompleteMatch`, 100 coins), so the free crate and the loadout guide
still played. Now it skips all of it: the lobby calls the new `I.Tutorial.Skip(player)`, which marks `MatchDone`,
`CrateOpened` and `Done` with no coins and no crate, so no guide shows. With `StudioTutorial` true nothing changes: the
Studio map plays the whole tutorial, and the Lobby map alone (which can't start the match) still goes straight to the
crate. Live servers never read the attribute.

**Where.** Lobby's join handler (the Tutorial phase) and `STUDIO_TUTORIAL_ATTRIBUTE`; Tutorial's `Skip`.

**How to check.** In Studio, set `StudioTutorial` false and play: the lobby opens with no spotlight and no crate
guide. Set it true: the tutorial match starts.

**For the wiki.** Architecture (how Studio tests the places): `StudioTutorial` now turns the whole tutorial on or off
in Studio. Supersedes the Studio line of `2026-11-05-match-start-fix` (the match only).
