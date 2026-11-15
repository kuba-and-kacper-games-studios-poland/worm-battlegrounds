---
title: "The drop always runs its whole 15 s (was 10 s, ending once everyone placed)"
date: 2026-11-15
status: open
kind: changed
pages: ["Match"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
---

**What changed.** The owner: "everyone can place their marker to where they land, but make it so the timer does not
end when everyone places, it's 15s to place always and it doesn't skip if everyone placed their marker, so they can
change their position in that time". Match's `DROP_SECONDS` went from 10 to 15, and the drop no longer ends early when
every player has placed: a player can move their spot until the time is up (a new pick overwrites the old, `PickDrop`).
Only the tutorial's drop still ends once its player placed (its own `TUTORIAL_DROP_SECONDS`, 40).

**Where.** `DROP_SECONDS` in `Match/Settings.lua`; the drop loop in `Phases` (`_isEveryonePlaced` now only ends the
tutorial's drop).

**How to check.** In a match, place a spot at once: the drop timer keeps running to 0; place again and the snail lands
on the second spot.

**For the wiki.** Match: the drop lasts 15 seconds, always, and the spot can be changed until it ends.
