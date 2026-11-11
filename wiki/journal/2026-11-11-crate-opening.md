---
title: "Crate opening rebuilt as a CS:GO-style reel, with themed crates and legendary drops"
date: 2026-11-11
status: open
kind: changed
pages: ["Crates", "Lobby", "Shop", "Sounds"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Reveal.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Reel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Showcase.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Drops.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/_meta/_types.lua
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Lobby/init.lua
  - art/crates/
  - art/sfx/make_crates.py
---

**What changed.** Opening a crate no longer shows the `CrateOpen` window: it plays on the GACHA screen itself, laid
out like CS2's case opening. Supersedes the reveal part of `2026-11-09-crates-screen` (the screen, tabs, odds and
prices it describes still hold).

- **The opening.** The shop slides away, the crate comes to the middle, rattles (0.68 s) and bursts in its colour.
  Then a reel of item cards rolls right to left under a fixed gold line and slows onto the result, on CS2's own curve
  (`cubic-bezier(0.075, 0.82, 0.165, 1)`) for 6 s; the line stops anywhere from 10 % to 90 % across the winning card,
  then glides to its centre. A tick plays as each card passes the line. Legendaries never appear as filler.
- **Packs.** x3 rolls three stacked reels (5 s, each 0.62 s after the last); x10 rolls ten vertical columns under a
  horizontal line (3.9 s, 0.28 s apart). The rarest result always stops last. The winners fly to a row of three or a
  5 × 2 grid and are named one by one, with NEW and BEST tags and a summary by rarity ("1 Legendary, 3 Epic, 1 new").
- **Rare results.** From epic up, a heartbeat starts 2.6 s before the reel lands, letterbox bars slide in and the
  screen darkens on each beat. Each rarity has its own reveal: rays (none for common), a burst and a sound.
- **Legendaries.** A legendary lands as a gold ★ "???" card; when the crate holds more than one legendary, a golden
  reel of them rolls (3.2 s) to pick which. Then its own drop plays: **Black hole grenade** pulls the reels into a
  black hole that implodes, leaving a spinning accretion disk behind the card; **Variety grenade** bursts into
  confetti and smileys with rainbow rays; **Skeleton** skin rises in a green glow with bones and ghost flames; **Low
  gravity potion** floats up in violet with rising bubbles. Any other legendary gets the plain legendary reveal.
- **Buttons.** SKIP (A or Space) brings every reel in at once. QUICK OPEN (a toggle by the buy buttons) shortens the
  rolls to 1.7 s (x1), 1.3 s (x3) and 1.1 s (x10) and skips the rattle. After a result: OPEN AGAIN (the same pack in
  the same currency, hidden for VIP's free crate and the tutorial crate) and CONTINUE (B).
- **Themed crates.** Each crate has a drawn 3D picture and a colour: its glow, rays, beam, pedestal ring, ambient
  particles and its reel's lines. Weapon amber with embers, Utility mint with bubbles, Skin pink with sparkles,
  Tutorial green with sparkles. The crate stands on a pedestal under a name plate and a STANDARD or PREMIUM tag, and
  bobs while the screen is open.
- **Premium feels premium.** The Premium crate (paid in diamonds) is cyan and gold with glints, a turning halo, a
  PREMIUM tag, a gold tab, a violet backdrop and a shimmer sound when picked; its reel's line is pale gold. Buy
  buttons and OPEN AGAIN turn blue with a diamond when paying in diamonds, green with a coin for coins.
- **Lobby menu.** STYLE, WEAPONS and SKINS now carry drawn icons (a snail shell with a paintbrush, the weapon crate,
  the skin crate).
- **Sounds.** 21 new sounds (`Crate_*`, `Reveal_*`, `Legend_*`, `Card_Flip`, `Results_Open` in `SoundsList.lua`):
  crisp clicks for the ticks and the landing, the Great Strategy instruments for the melodies, uploaded to The Snail
  Studio group.

**Where.** `Crates_Settings` holds every number above (`ROLL_SECONDS`, `ROLL_STAGGER`, `QUICK_ROLL_*`, `ROLL_CURVE`,
`LAND_SPREAD`, `STRIP_CARDS` 38, `WIN_CARD` 33, `TEASE_FROM_RARITY` "Epic", `TEASE_SECONDS`, `GOLDEN_SECONDS`,
`SHAKE_SECONDS`, `LEGENDARY_DROPS`). A crate row's look is its new `Glow`, `Accent`, `Ambient` and `Premium` fields
(`Data/Crates/<Id>.lua`). New pictures, by image id: crates Weapon 100039001608184, Premium 112183136204952, Utility
111692496235544, Skin 130190991872708, Starter 136889158399800; the STYLE icon 130223906536662 (the rest:
`art/crates/README.md` → Uploading). No remote, Topic or saved data changed: `Crates_Open` is the same call.

**How to check.** In game, buy a Weapon x1: the reel rolls about 6 s and ticks; x3 shows three bands, x10 ten
columns. Toggle QUICK OPEN and the x1 roll takes under 2 s. The PREMIUM tab shows the violet backdrop and gold tab.
The legendary drops are rare (0.5 % to 1 %); they were checked in a Studio playtest by forcing the result.

**For the wiki.** Crates: the opening (reels, packs, skip, quick open, open again), each rarity's reveal, the four
legendary drops, each crate's look and the premium crate's. Shop: diamond prices tint the buttons blue. Lobby: the menu
icons. Sounds: the crate sounds. Still unsure: the old `CrateOpen` gui is kept but unused until the owner says to
remove it.
