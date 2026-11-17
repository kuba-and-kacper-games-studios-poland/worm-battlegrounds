---
title: "FREE WEAPONS tile in the lobby and a picture-first free crate dialog"
date: 2026-11-17
status: open
kind: changed
pages: ["Crates", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/GroupReward.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FreeCrate/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Reveal.lua
---

**What changed.** The free crate for joining The Snail Studio now has a gold FREE WEAPONS tile in the lobby, left of
STYLE, WEAPONS and SKINS, with a sweeping light, a bobbing crate and a red 1, until it's claimed. The dialog is mostly
pictures: the Weapon crate turning on a lit stage with light rays and twinkles, LIKE and JOIN as two picture tiles
(JOIN with the group's own picture, ticked once the player is in), and CLAIM, locked and grey until then, gold, pulsing
and shining after. CLAIM shakes the crate with a claim sound and opens it on the crates screen (from the lobby it opens
that screen first). The X sits inside the corner. The WEAPONS button's badge says 1 instead of FREE for VIP's daily
crate, so there aren't two FREEs side by side.

**Where.** Crates' `GROUP_*` settings, `BADGE_FREE` "1"; sound `Free_Claim` (stand-in until approved).

**For the wiki.** Crates: the free crate's two ways in.

**Fixed in testing (2026-11-17).** The lobby tile asked the Group module for membership before its data arrived
(an error at lobby start); `GroupReward._refresh` now waits for the Crates data, which connects after the Group's.

**Sound uploaded (same day).** `Free_Claim` "Snail Gift Claim" 85804626362349 replaces the stand-in.

**Fixed after the owner's third look (same day).** "FREE CRATE still appears even at the unboxing menu": the badge on the crates screen now hides while a crate opens there and comes back with the shop (Crates' Reveal calls `GroupReward.SetOpening` beside `Showcase.SetOpening`). Checked in Studio: bought one Weapon crate with the free crate unclaimed; the badge was hidden from TAP TO OPEN to the result, and back after CONTINUE.

**Fixed after the owner's fourth look (same day).** "The backlit on the weapon crate is broken": the dialog's light rays met at a point above the crate and swung round the panel as they turned (eight hand-made beams, each turning about its own middle). The stage now shows the crates screen's sunburst picture (`S_Rays`, `rbxassetid://109967588890262`, tinted 220, 255, 170), centred behind the crate and turning there (`GROUP_RAYS_SPEED` 18 degrees a second). Checked in Studio: the rays spread from behind the crate.
