---
title: "CharacterPark parks avatars at 0, -60, 0; the Game module is now Match"
date: 2026-11-03
status: merged
merged: 2026-11-06
kind: added
pages: ["Lobby & meta modules", "Architecture", "Roadmap"]
files:
  - worm-battlegrounds-game/src/modules/Utils/CharacterPark/
  - worm-battlegrounds-game/src/modules/Main_Game/Match/
---

**What changed.** Two P0 pieces:

- **`CharacterPark`** (Utils, server) anchors each player's avatar as soon as it spawns and moves it to
  `PARK_POSITION` 0, −60, 0, below the arena and out of the camera's view. The wiki planned `BaseSpawn` instead,
  which no map has yet, and it doesn't hide the avatar. It sits at −60 because the framework's `Fall_Controller`
  brings back anything below y −100 (`MIN_POSITION`).
- **The template's `Game` module is renamed `Match`** (`Main_Game/Match`, `I.Match`, `Match_Settings`). It's an empty
  shell until P3.

**Where.** `Utils/CharacterPark/Server.lua` and `Settings.lua`; `Main_Game/Match/`.

**How to check.** In a Studio test the avatar's `HumanoidRootPart` is anchored at 0, −60, 0 and stays there.

**For the wiki.** Lobby & meta modules → CharacterPark and Architecture → Players' own characters: the fixed park spot
until maps have a `BaseSpawn`. Roadmap: P0's CharacterPark and rename tasks. The framework change CharacterPark works
around is unchanged: a per-map switch for ume's `INITIAL_CHARACTER_AUTO_LOAD`.
