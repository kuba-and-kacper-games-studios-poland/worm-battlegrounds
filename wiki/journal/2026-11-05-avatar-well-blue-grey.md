---
title: "Avatar pictures sit on blue-grey instead of light blue"
date: 2026-11-05
status: dropped
kind: changed
pages: ["Lobby", "Architecture"]
files:
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Tokens.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Styles/Picture.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/_meta/README.md
---

**What changed.** The square behind a player's avatar picture (the lobby's Party panel, top left) was light blue;
it's a muted blue-grey now, the owner's ask. The same square sits behind avatars in match results, the custom lobby
and the match board, behind emote pictures in the emote shop, and in the tag over a worm's head, so all of them
changed together.

**Where.** The `WormBattlegroundsBrawl` theme's palette token `Well`, `143, 211, 255` → `125, 142, 165` (`#7d8ea5`),
used by the `Picture` styles `Avatar` and `AvatarLarge`. The six guis that use them were exported again into
StarterGui (`Party`, `Results`, `CustomLobby`, `MatchBoard`, `EmoteShop`, `WormTag`), keeping their copies' extra
attributes (`Results` keeps `PreventClosing`).

**How to check.** In the lobby, the Party panel's member picture has a blue-grey square behind it (`S_Avatar`
`BackgroundColor3` `7d8ea5`), checked in a Studio playtest.

**For the wiki.** Lobby: the Party panel's look, if a page shows it. Nothing else to change.

**Dropped.** The owner asked to revert it the same day: `Well` is back to `143, 211, 255` (`#8fd3ff`) and the six guis were exported again with it. Nothing for the wiki.
