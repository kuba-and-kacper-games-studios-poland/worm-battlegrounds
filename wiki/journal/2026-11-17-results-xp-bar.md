---
title: "Results: a level bar filling with the match's XP"
date: 2026-11-17
status: open
kind: added
pages: ["Levels & XP", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Results.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Results/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Results/Preview.lua
---

**What changed.** The Results screen has the lobby's level bar, small, under the coins line: the level in a diamond
in the player's prestige frame colours, "LEVEL n", a dark bar with the gold to orange fill and "into / for XP". Shortly
after the screen opens it fills from where the player was before the match: each XP line (match played, victory,
knockouts) adds to the "+N XP" total with a chime and fills the bar with ticks rising in pitch; a level reached plays
the level-up fanfare, pops the diamond in the new level's frame and shows "Level up! Level n", and the bar starts
again. The lobby's replay stays the big moment.

**Where.** MatchHud's Results handler (`_playXp`), `RESULTS_XP_DELAY` 0.6, `RESULTS_XP_LINE_GAP` 0.25,
`RESULTS_XP_FILL_SECONDS` 0.8, `RESULTS_XP_TICKS` 10, `RESULTS_XP_TICK_PITCH` 0.9 to 1.5; the Results gui's
`U_Earned` › `S_XpRow`. It reads `Match_Results`' `earned.XpLines`, `XpBefore`, `XpAfter` (MatchRewards, the level
plate's entry); results without them hide the bar and show "+N XP" and the level-up line at once, as before. Sounds
`Xp_Line`, `Xp_Tick`, `Level_Up`.

**How to check.** Win a solo match with knockouts: on Results the bar counts up three lines; at the level's end it
pops and says "Level up!".

**For the wiki.** Levels & XP: the bar on Results. Supersedes nothing; the level plate entry
(`2026-11-17-level-plate-and-xp`) covers the XP lines.
