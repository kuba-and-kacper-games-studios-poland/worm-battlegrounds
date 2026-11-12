---
title: "12 more bot names (12 → 24)"
date: 2026-11-12
status: open
kind: added
version: ""
commit: ""
pages: ["Bots", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
---

**What changed.** Bots now draw from 24 names instead of 12. The names added, in the owner's spelling and case:
Fleaper, Shide, MB, gaspro, RedBicycle12, Tommy, Travis, REKTWASAKI, Lats, George, ozyboii, GloriousMorning. The 12
names already there stay: Bax, Ninja, Pickles, Bricky, Snailzilla, Noodle, Sprocket, Gizmo, Turbo, Biscuit, Rascal,
Studs.

**Where.** `BOT_NAMES` in the Bots module's `ServerSettings.lua`. `Module._getName` in `Bots/Server.lua` still picks
them at random, with no repeats in a match. Once every name is taken it falls back to `Bot <10–99>`, which now
happens only past 24 bots.

**How to check.** `BOT_NAMES` has 24 entries. In a match full of bots, any of the new names can show on a bot's
SnailTag.

**For the wiki.** Wherever bot names are listed or counted: there are 24 now, and the 12 new ones are above. No page
lists them yet. Match modules → Bots names `BOT_NAMES` without its contents.

**Unsure.** Nobody has checked yet whether the longest name, GloriousMorning (15 characters), fits on the SnailTag and
the turn list without shrinking.
