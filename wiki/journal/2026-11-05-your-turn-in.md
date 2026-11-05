---
title: "Turn panel says when your turn comes: \"You're next!\", \"Your turn in 3 turns\""
date: 2026-11-05
status: open
kind: added
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
---

**What changed.** The turn panel at the top used to show its "Your turn!" line only on the player's own turn. Now,
while other worms play, the same line tells the player when theirs comes: "You're next!" when they play right after
the current worm, else "Your turn in N turns", where N counts the turn playing now and every turn before theirs.
It counts down each turn, and worms knocked out or players who left drop out of the count. The line hides once the
player's own worm is out.

**Where.** The server writes the match attribute `TurnOrder` on `Workspace.Ume.Match` at the start of every turn:
the ids of the worms that can play (`P_<UserId>` for players, `B_<n>` for bots), comma-separated, in the order
their next turn comes (`Turns._getUpcoming`, which walks a copy of the team-by-team order). MatchHud's
`Turn._getTurnsLeft` finds the player's worm in it; the banner is `S_Banner`.

**How to check.** In an 8-worm solo match, the line read "Your turn in 7 turns" right after the player's turn, then
6, 4 (a bot was knocked out), 3, 2, "You're next!", "Your turn!" (checked in Studio).

**For the wiki.** Match screen: the turn panel's top line, what it says on the player's turn and on others' turns.
