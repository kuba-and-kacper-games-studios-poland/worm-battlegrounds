---
title: "Play solo's drop timer 15 → 7 seconds"
date: 2026-11-25
status: open
kind: changed
pages: ["Match", "Play solo"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
---

**What changed.** In a solo match (the player against bots) the drop, where the player picks where their snail lands,
lasts 7 seconds instead of 15 (the owner: "so its more dynamic (since we playing with bots we dont need to wait for
anyone)"). It still runs its whole time once placed, so the spot can be moved. Public, party, custom and local matches
keep 15; the tutorial's ends once its player placed.

**Where.** Match's `SOLO_DROP_SECONDS` (7), picked in `Phases._drop` when the metadata's `Kind` is `Solo`; the drop timer
on screen follows the match folder's `DropEndsAt`, so it shows 0:07.

**How to check.** Press PLAY SOLO, pick a difficulty: the drop's timer starts at 0:07. Not run in Studio (a solo match
starts from the lobby's teleport).

**For the wiki.** Play solo: a shorter drop, 7 seconds.
