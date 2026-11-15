---
title: "Props turn see-through (70 %) while a snail is inside them"
date: 2026-11-15
status: open
kind: added
pages: ["Arena", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/PropSeeThrough.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** The owner: props overlapped the snails, and "maybe we can add like dithering or something like that
so the prop gets transparent when snail is inside of it". Roblox draws no dithering, so a tree, bush, rock or cactus a
snail stands inside fades to 70 % see-through on every screen while it's there, and back when it leaves (about a
fifth of a second each way). "Inside" is the snail's ball within the prop's box on the play plane, with a stud's
margin. Knocked-out ghosts don't count. Props still stand behind the snails as before (`PROP_BEHIND_GAP`).

**Where.** `Arena/Scripts/Client/PropSeeThrough.lua`, started from Arena's `Client.lua`; it sets the prop parts'
`LocalTransparencyModifier` on each client and leaves alone parts the client's carver has hidden. Settings in
Arena's `Settings.lua`: `PROP_SEE_THROUGH` (0.7), `PROP_SEE_THROUGH_MARGIN` (1 stud), `PROP_SEE_THROUGH_SPEED` (5 a
second), `PROP_SEE_THROUGH_REFRESH` (0.5 s, how often the props' boxes are read again). No remotes.

**How to check.** In a match, walk a snail into a tree: the tree fades, the other trees don't, and it comes back when
the snail walks out. Tested in Studio on Rolling Plains with a stand-in snail in a big oak: the oak's 124 parts went
to 0.70, the other trees stayed at 0, and it was back to 0 within 0.2 s after the stand-in moved away. Not yet seen in
a real match.

**For the wiki.** Arena (props): they turn see-through when a snail is inside them.
