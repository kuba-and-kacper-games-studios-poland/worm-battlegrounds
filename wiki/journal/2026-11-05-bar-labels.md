---
title: "Stamina and power bars say what they are: \"Stamina 70%\", \"Power 60%\""
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
---

**What changed.** The stamina and power bars showed only a percentage ("100%", "62%"), so players couldn't tell
them apart. They now read "Stamina 100%" and "Power 62%".

**Where.** `Turn._tick` and `Aim._step` keep the bar's own label from the gui (`U_Stamina` / `U_Power` › `Status`,
"Stamina" / "Power") and write it before the share.

**How to check.** On the player's turn the bar above the loadout reads "Stamina 100%" and drops as the worm walks;
while aiming the bottom-right bar reads "Power N%". Checked in a Studio match.

**For the wiki.** Match screen → Stamina bar, and the power bar while aiming: name the label they show.
