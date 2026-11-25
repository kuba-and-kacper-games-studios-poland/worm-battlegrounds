---
title: "The lobby's XP replay becomes a rank-up: crest, tier looks, slick bar, reward card, XP tiles"
date: 2026-11-25
status: open
kind: changed
pages: ["Levels & XP", "Lobby", "Results"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Nameplate/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Results/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
---

**What changed.** The XP replay after a match (the owner: "too much ugly text… needs to feel like leveling up in a high
end competition", "based on level it gets better") now takes the whole lobby: the panels and the stage's nameplates
hide, the lobby darkens (0.62), and a stage pops up in the middle:

- a **rank crest**: the level in a dark middle inside a rim in the prestige tier's colours, a light sweeping it, on
  turning rays and a glow in the tier's colour; a row of seven pips (one per tier, lit up to the player's) and the
  tier's name under it;
- **each tier looks richer**: Rookie has no rays, then the rays strengthen, a second ray layer joins from Silver, and a
  level-up throws more stars, up to Mythic's turning rainbow (twice the stars);
- a **thin, sharp XP bar** (the owner: "too bubbly", "more square… slick"), cut in five by faint ticks, its fill in the
  tier's own colours (Bronze, Silver, Gold… shining from Gold, the colours turning at Mythic), "into / for XP" over its
  right end;
- the **next reward as a card** at the bar's end: a weapon look's, skin's or emote's picture, or the player's own face
  in the frame the level opens, "Lv 30" under it and a NEXT tag, which turns UNLOCKED! (gold) and pops when the bar
  reaches it;
- the match's XP as **tiles** (picture, "+50" in gold, what it was for): a gamepad for a match played, a crown for a
  victory, a crosshair for knockouts.

A level-up punches the crest into the new level and slams LEVEL UP! across it; a new rank also flashes the screen white
and pops the tier's name. The old floating texts ("Next unlock: …", "NEW FRAME: SILVER", the XP lines) are gone.

The level now always fits its badge (the owner: "the lvl 100 overlaps the border"): the stage nameplate's badge pads
its number in (two and three digits shrink inside), and the crest, the weapon unlock's diamond and the match results'
diamond have a text box inside the turned square. The results row's diamond is bigger (1.5 times the row) and its bar
is the same thin, sharp bar.

**Where.** LevelPlate gui: `U_Plate` now inside `U_Replay` (`S_Rays`, `S_RaysBack`, `S_Glow`, `S_Badge` with
`S_TierGradient` and `S_LevelNum`, `S_LevelUp`, `S_Pips`, `S_TierName`, `S_Track` with `S_Fill`/`S_FillGradient`,
`S_Head`, `S_Xp`, `S_Next` card, `S_Lines`), `S_Flash`, the `PREFAB | XpLine` tile; `S_Reward`/`S_RewardText` and
`S_Diamond` removed. Progression's Settings: `REPLAY_SCALE` 1.8 → 1, `REPLAY_DIM` 0.45 → 0.62, new
`REPLAY_TIER_LOOKS`, `PIP_OFF_COLOR`, `CREST_PUNCH` 1.22, `RANK_FLASH` 0.35, `LEVEL_UP_TWEENINFO`,
`RANK_FLASH_TWEENINFO`, `REWARD_COLOR`, `REWARD_TAG_NEXT`, `REWARD_TAG_UNLOCKED`, `REWARD_POP` 1.35, `TRACK_X` 0.45,
`XP_ICONS` (Played 86467359142321, Win 103399252005394, Knockouts 88744460498201). Lobby: `I.Lobby.SetTakeover(on)`,
`TAKEOVER_GUIS` (Currency, LevelPlate). Nameplate: `S_Level`'s UIPadding 0.17 a side. Results: `S_XpRow`'s badge and
bar.

**How to check.** In a lobby play test, `I.Progression.SetReplay` a replay from level 24 to 25 (a Server script):
the lobby's panels hide, the crest punches to 25 with a white flash, GOLD pops, the card turns UNLOCKED!, the tiles pop
in; the lobby comes back after. A level-100 nameplate shows "100" inside its badge.

**For the wiki.** Levels & XP: the replay's new look (crest, tiers growing richer, the reward card, the tiles), a
screenshot of a Gold level-up; Lobby: the replay hides the lobby while it plays; Results: the level row.

Supersedes the plate look in 2026-11-17-level-plate-and-xp and 2026-11-24-level-plate-hidden; the replay's flow (the
diamonds first, a tap skips, the weapon unlock) still holds.
