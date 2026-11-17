---
title: "Blasts on props: no more \"Could not carve\" warnings from a client's own cut"
date: 2026-11-17
status: open
kind: fixed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Helpers/Cutter.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** The owner's Output showed `[Arena::Cutter]: Could not carve (Workspace.Ume.Arena.Decor.Trees.Bigoak.Trunk)!
- (CSG: One of the primitives was of unknown type (error -4)) (x4)` on the client. Each client cuts a blast's hole in
the props itself as a guess the server's pieces replace a moment later; a cut it can't make (most likely a trunk
piece the server had just cut, its shape not on that screen yet: the four failures match the four server-cut pieces)
now tries once more after `CUT_RETRY_SECONDS` (0.15) and is then left to the server's pieces without a warning. The
server still warns when its own cut fails. Nothing players see changes, except that a prop whose client cut fails
shows its hole when the server's pieces arrive instead of at once.

**Where.** Arena's `Cutter.Subtract` (shared by both sides), `CUT_RETRY_SECONDS` in Arena's Settings.

**How to check.** Blast the same tree several times in a match: no `Could not carve` lines from the client. The cause
wasn't reproduced in Studio (clients cut the server's tree pieces fine in every test, even the moment they arrived),
so a live server is where to watch for it.

**For the wiki.** Nothing for players; Architecture's blasts section may mention that a client's cut is a guess the
server corrects.
