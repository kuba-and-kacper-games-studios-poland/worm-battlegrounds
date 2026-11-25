---
title: "PLAY SOLO: pick the difficulty only, on a random map"
date: 2026-11-25
status: open
kind: changed
pages: ["Lobby", "Play solo", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchSetup/init.lua
  - art/ui_glyphs/glyphs.py
---

**What changed.** The owner: "when clicking play solo we want it to select random map and also we only have
difficulty choice (do icons for easy medium and hard - and the reward and PLAY)". PLAY SOLO's window now shows only
DIFFICULTY, as three cards (Easy, Medium, Hard), each with its icon: a smiling face, a frowning face, a skull. Under
them is the win reward for the picked difficulty (10, 18 or 30 diamonds, unchanged), then PLAY. The map list and the
bots row are gone for solo, and a solo match always plays a random map from the rotation. PLAY WITH PARTY and LOCAL
keep their map list and bot buttons (the owner's pick). The window's yellow button reads PLAY instead of START in every
form.

Then, the same day ("make win reward bigger... eye catching and easy to understand"; "play with colors for
difficulties subtly"): the reward sits on a dark rounded plate with a gold outline, "WIN REWARD" at 30 px beside the
diamond and the amount in gold at 46 px; each difficulty card has a faint wash in its colour rising from the bottom,
its icon tinted toward it, and the picked card's outline and name in it (Easy green, Medium amber, Hard red). PLAY is 1.3 times bigger, with the play icon (PLAY SOLO's own) before
the word ("bigger play button with play icon").

**Where.** MatchBoard's `DIFFICULTY_ICONS` (image ids 88105304367362, 94010149349376, 103240032909077: the decals
"Snail Glyph Easy/Medium/Hard", 74795022723480, 96532229887321, 94462966575720, uploaded to The Snail Studio group);
`DIFFICULTY_COLORS`, `DIFFICULTY_GLYPH_TINT`; Setup's `_buildDifficulties` and `_refresh`, `MatchBoard_PlaySolo` sent with `"Random"`; the MatchSetup gui's
`S_DifficultyRow`, `S_DifficultyList`, `PREFAB | Difficulty`, `S_MapRow`, `S_BotsRow`; the glyphs in
`art/ui_glyphs` (`easy`, `medium`, `hard`).

**How to check.** In the lobby press PLAY SOLO: the window shows the three difficulty cards with Medium outlined, the
reward and PLAY; picking Hard shows 30 diamonds; PLAY starts a match. Checked in Studio on 2026-11-25.

**For the wiki.** Play solo: the difficulty cards with their icons, the random map and the rewards per difficulty;
a History line.
