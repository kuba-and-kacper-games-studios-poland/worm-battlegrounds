---
title: "Party cards show only the avatar, crown and Kick: no names, badges or level"
date: 2026-11-24
status: open
kind: removed
pages: ["Party", "Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Party/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Client.lua
---

**What changed.** The PARTY column's member cards no longer show the display name, @username, badges or the level
badge. A card is the avatar in its prestige frame, the leader's crown and Kick. A custom lobby's second column no
longer turns its cards compact (there's nothing left to hide). The names and levels now stand over each snail on the
lobby stage (see 2026-11-24-stage-nameplates-and-invite-bubbles).

**Where.** `PREFAB | Member` in the Party gui lost `S_Name`, `S_Username`, `S_Badges` and `S_Level` (and the
`LevelBadge` art); `Party/Client.lua` `_refresh` no longer writes them or calls `I.PlayerBadges.Show`.

**How to check.** In a party: the cards show avatars only, and each snail on the stage has its name and level over it.

**For the wiki.** Party: the card's contents; badges no longer show in the lobby (they still show on the SnailTag,
the turn list and Results).
