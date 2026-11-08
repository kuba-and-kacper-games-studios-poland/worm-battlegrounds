---
title: "Admin commands for testing: give weapons, skip turns, set wind and round, win; five more admins"
date: 2026-11-08
status: open
kind: added
pages: ["Architecture", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Uses.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Control.lua
  - worm-battlegrounds-game/src/global_data/AdminPanel/Permissions.lua
---

**What changed.** Admins (level 255) can steer a match from the command bar (Ctrl + [, or `/cmd` in chat) to test
it. Commands act on the admin's own snail unless they name a participant id (`P_<userId>`, bots `B_<n>`):

| Command | What |
| --- | --- |
| `combat give <itemId> [id]` | Adds any weapon or utility to the loadout mid-match, with full uses (autocompletes item ids) |
| `combat refill [id]` | Fills every use and clears every cooldown |
| `snailcontrol refill [id]` | Fills the stamina bar |
| `match skip` | Ends the turn playing now |
| `match time <seconds>` | Every turn lasts this long until the server closes (`0` goes back to 15 s) |
| `match wind <n>` | This turn's wind (−10 to 10) |
| `match round <n>` | The round; `11` starts sudden death on the next turn |
| `match win [id]` | Knocks out every other team, so the match ends |

They join the earlier `arena`, `snails` and `snailcontrol turn/end` commands. Five accounts from the studio's
testers got admin level 255 in `Permissions.lua` (`CustomLevels`).

**Where.** The command scripts are each module's `Scripts/AdminPanel/CommandBar/Server.lua`. New server API:
`I.Combat.Give`, `I.Combat.Refill`, `I.Match.SkipTurn`, `I.Match.SetTurnSeconds`, `I.Match.SetWind`,
`I.Match.SetRound`, `I.SnailControl.Refill`. The turn's deadline is `turnDeadline` in `Turns.lua`.

**How to check.** Studio match (2026-11-08): `combat give Minigun` put it in `Slots` with 3 uses; `match wind 25` set
10; `match time 60` made `TurnEndsAt` 60 s away, and the next turn too; `match round 11` started sudden death next
turn; `match skip` ended the turn in 0.2 s; `match win` ended the match in 0.5 s.

**For the wiki.** Architecture (or a testing page): the commands, who can run them and how to open the bar. Admin
tools aren't for players' pages.
