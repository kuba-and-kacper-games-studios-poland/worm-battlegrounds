---
title: "Admin command: progression add_level"
date: 2026-11-11
status: open
kind: added
pages: ["Levels", "Admin panel"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Scripts/AdminPanel/CommandBar/Server.lua
---

**What changed.** Admins (permission level 255) can raise a player's level from the command bar (Ctrl + [, or `/cmd`):
`progression add_level <player> <levels>`. The command gives the player the XP those levels take, capped at level 100
(`MAX_LEVEL`), so each level's reward (the Prisoner, FBI Agent and Wizard skins at 25, 50 and 100), the
`Progression_LevelUp` Topic, the Level leaderstat and the "Level up!" toast all come as they do after a match. Levels
must be a whole number above 0; a player already at level 100 gets "already at the highest level".

**Where.** `I.Progression.AddLevels(player, levels)` in `Progression/Server.lua` (new, server only); the
`progression` command (`Progression_Server`, subcommand `add_level`) in `Scripts/AdminPanel/CommandBar/Server.lua`.

**How to check.** In Studio, open the command bar and run `progression add_level <your name> 5`: the output says the
new level, the player list's Level goes up 5, and a toast shows. Running it with 30 from level 1 gives the Prisoner skin.

**For the wiki.** Admin panel: the `progression add_level` command. Levels: none for players (an admin tool).
