---
title: "Mirage Mesa, Lakeside Showdown and Training Meadow lose their scenery backdrops (kept only behind ponds)"
date: 2026-11-15
status: open
kind: removed
pages: ["Mirage Mesa", "Lakeside Showdown", "Training Meadow", "Architecture"]
files: []
---

**What changed.** The owner: "on MirageMesa remove the backdrop and leave it only on water, on LakesideShowdown also
remove the backdrop and leave on water, on TutorialMeadow remove backdrop, we'll be only now making the backdrops
only for caves, water etc." The wall behind each map is gone: Mirage Mesa's red mesa (70 parts), Lakeside Showdown's
forest treeline (54) and Training Meadow's low hills (53). Mirage Mesa keeps one backdrop block behind its oasis
(x −30 to 0, Y 16 to 23) and Lakeside Showdown one behind its lake (x −39 to 38, Y 11 to 21), so their pond water
has something behind it; Training Meadow has none. Land, props and liquids are unchanged.

**Where.** In the dev place: the arena templates `Arenas.MirageMesa`, `LakesideShowdown`, `TutorialMeadow`, exported
from MapLab; the ones before are `MapLab._Iterations.MirageMesa_arena_1`, `LakesideShowdown_arena_3`,
`TutorialMeadow_arena_2`. MapLab: each map's `map.json` `backdrop.only` (a new option in the map kit's `maplab.py`).

**How to check.** MapLab: all three PASS with 0 errors and 0 warnings. Studio playtest: each loads with its land,
props and liquids, 1, 1 and 0 backdrop parts, 6 landing spots, no errors.

**For the wiki.** Those maps' pages: no scenery behind them. Architecture: backdrops only for caves and behind
ponds. Picnic Plains and Volcano Isle still have scenery backdrops.
