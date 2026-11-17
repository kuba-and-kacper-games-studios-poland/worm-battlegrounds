---
title: "Emote wheel: a ring of every emote, hold T or X to open, the HUD button shows the Wave"
date: 2026-11-17
status: open
kind: changed
pages: ["Emotes", "Match screen", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/Preview.lua
---

**What changed.** The match's emote wheel is a real ring of dark slices, one per emote (9 today), in a fixed order (by
the level that unlocks it, then its price: Wave, Thumbs up, Laugh, Dance, Flex, Taunt, Cry, Backflip, Victory
Trumpet). Emotes not owned yet are greyed with a lock and their unlock level ("Lv 10"); pointing at one says "Unlocks
at level 10", or "Get it in the emote shop" once the level is reached. The slice pointed at lights in the player's
team colour and grows, its name in the middle. Hold T (PC) or X (pad) to open it round the middle of the screen,
point with the mouse or the left stick, let go to play; a quick tap plays the last emote again (the Wave at first).
On touch, and with a click, the HUD's emote button opens it and a tap or click picks. It spins in with a whoosh and
ticks as it's pointed round; it stays shut while the snail is hit or thrown. The HUD's button shows the Wave's picture
and its key (a T key cap on PC, X on a pad) instead of an empty slot. Before, the wheel only showed owned emotes as
cards on a circle, PC had no key, and X opened it for the selection.

**Where.** Cosmetics' `WHEEL_*` settings (`WHEEL_KEY` T, `WHEEL_TAP_SECONDS` 0.25, `WHEEL_BUTTON_EMOTE` Emote_Wave,
`WHEEL_SLICE_GAP` 2°, `WHEEL_HOVER_SCALE` 1.06); MatchHud's `U_EmoteWheel` and `PREFAB | WheelSlice` (replaces `PREFAB |
WheelEmote`), `U_EmoteButton` › `S_Icon`, `KeyHint`. The CAS action `Cosmetics_EmoteWheel`; X is the Console module's
`Emotes`. `EMOTE_COOLDOWN` 5 and `EMOTE_SECONDS` 3 are unchanged; `Cosmetics_PlayEmote` too. Sounds `Emote_WheelOpen`,
`Emote_WheelHover` (stand-ins until the 17 Nov sound set is approved).

**How to check.** In a match on your snail's turn: hold T, point at Wave, let go: the snail waves; tap T: it waves
again. A locked emote shows the lock and its level.

**For the wiki.** Emotes: the wheel, its keys per device, locked emotes. Controls: T / X held.

**Checked in Studio (2026-11-17).** The wheel draws 9 slices, locked ones greyed with "Lv N" and "Get it in the emote
shop" in the middle. The T key cap (and the pad's X) moved to the button's top right corner, where it no longer covers
EMOTES. Once in the first test the wheel showed with no key pressed; a watcher saw it not happen again in three more
matches, so its cause is still unknown.

**Sounds uploaded (same day).** `Emote_WheelOpen` "Snail Wheel Open" 112250812308627 and `Emote_WheelHover` "Snail
Wheel Tick" 101996198618237 replace the stand-ins.
