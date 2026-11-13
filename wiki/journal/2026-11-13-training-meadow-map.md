---
title: "Training Meadow: the tutorial's own map (200 × 80, one island), replacing Picnic Plains in the tutorial"
date: 2026-11-13
status: open
kind: added
pages: ["Match modes & maps", "Training Meadow", "Lobby & meta modules", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
---

**What changed.** A new map, Training Meadow (id `TutorialMeadow`), made in MapLab for the tutorial match only. One
small grassy island in a calm sea, the map 200 studs wide and 80 tall (Bounds 200 × 80 × 11), the sea from Y −8 to
6.5: a tall hill in the west (top about Y 28) with an oak and a pine, a lower, broader hill in the east (about Y 24)
with a pine and a birch, and between them a meadow (x −34 to 34 from the middle, Y 18 to 19) where the tutorial
starts the player and the bot about 30 studs apart, with nothing between them. A bush on each side of the meadow and
a rock on the east slope. Dark bedrock under Y 8 (`Arena_Indestructible`). No ledges, no ponds. 191 land parts, 53
backdrop parts (low hills), 7 props. Picnic Plains' colours and its mood: the `Plains` lighting preset and Picnic
Plains' music.

- Lobby's `TUTORIAL_MAP`: `"PicnicPlains"` → `"TutorialMeadow"`.
- MatchBoard's `MAPS` has a `TutorialMeadow` row (name "Training Meadow", sizes `{ 2 }`), not in `MAP_POOL`, so no
  public row or custom lobby ever picks it. Its picture (the teleport card) is Picnic Plains' until Training Meadow
  has its own uploaded (a `shortcut:` comment marks it).
- Atmosphere's `PROFILES.TutorialMeadow` copies Picnic Plains' row.

**Where.** The template is `Workspace.Ume.ServerStorage_Assets.Arenas.TutorialMeadow` (slot 5, X 1600; played at X
0 like every map). Its files are the game home's `assets/models/maps/tutorial_meadow/` (drawn by
`source/generate.py`, its card `asset.yaml`).

**How to check.** A new player's first join (or Workspace's `StudioTutorial` in Studio) plays the tutorial on it;
the teleport card reads "Heading to Training Meadow…". It isn't in the board's maps or the custom lobby's map picker.
Checked in Studio: the template exports (442 parts) and the meadow is grass at Y 18 to 19. Not yet played through as
the tutorial.

**For the wiki.** Match modes & maps: Training Meadow, the tutorial's map, not in rotation (a page of its own,
`Training Meadow`, if maps have pages). Architecture: the arena templates now run to slot 5 (X 1600).
Supersedes the tutorial map line of `2026-11-13-guided-tutorial` (Picnic Plains until the export).
