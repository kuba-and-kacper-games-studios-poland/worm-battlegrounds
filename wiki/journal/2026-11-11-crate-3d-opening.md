---
title: "Crates in 3D: on the pedestal, tap to open, hatches then walls, a golden crate; card and black hole fixes"
date: 2026-11-11
status: open
kind: changed
pages: ["Crates", "Sounds"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Stage3D.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Result.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Reveal.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Showcase.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Reel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Drops.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/_meta/_types.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - art/crates/make_models.py
  - art/crates/bake_models.py
---

**What changed.** The start of a crate opening is now 3D. Supersedes the intro part of `2026-11-11-crate-opening`
("the crate comes to the middle, rattles (0.68 s) and bursts", `SHAKE_SECONDS`, Quick open "skips the rattle"); its
reels, packs, reveals, legendary drops, themes, premium look and buttons still hold.

- **The crates drop in.** After the shop makes way, the bought crates fall onto the screen as 3D models over the
  crate's glow and turning rays, back ones first, each landing with a thud and a puff: one in the middle for x1, one
  in front and two behind for x3, a pyramid of 1, 2, 3 and 4 for x10. Each crate is its own model in the game's model
  look (chunky bevelled parts with the stud pattern): Weapon, Premium, Utility, Skin, and Starter for the tutorial
  crate.
- **Tap to open.** They bob while TAP TO OPEN (TAP TO OPEN ALL for packs) beats at the bottom, their hatches lifting
  on the beat. One tap anywhere (or A or Space on a pad or keyboard) opens them all, the front one first.
- **The opening.** Each crate rattles with its hatches straining (0.52 s), the two hatches on top spring open (0.3 s,
  129°), then the four walls fall outward (0.38 s, 93°) with the hatches riding on the side walls, and a ball of light
  in the crate's colour rises and swells into a white flash, which hands over to the reels.
- **The golden crate.** When a legendary lands as the gold ★ card, the reels give way to the same crate lit gold, on
  gold rays with sparkles, under TAP TO OPEN and LEGENDARY CRATE. Tapping opens it the same way; then the golden
  reel picks which legendary (when the crate holds more than one), or the legendary's card rises out of the crate.
  Then its own drop plays as before.
- **Quick open** drops the crates faster (0.36 s instead of 0.62 s), opens them with no tap at 55 % of the time and
  without the rattle sound; the golden crate opens with no tap too.
- **The crate on the pedestal is 3D too.** The GACHA shop's showcase shows the selected crate's model, swaying
  slowly from side to side and bobbing, lit like the opening; changing tabs pops the next crate's model on. Buying
  makes it leap up off the pedestal and fade (0.32 s) as the bought crates drop onto the stage.
- **Cards.** A card that shows no name (the big reveal card, a pack's cards, the ten-pack's columns) has its picture
  in the middle of the card and a little bigger, instead of high up with empty space under it. On the reels, names now
  sit in a box inside the card's slanted edges, so long ones ("Black hole grenade", "Variety grenade") wrap onto two
  lines instead of running past the edge; short ones stay at a set size (10 % of the card's height).
- **Black hole grenade's drop fixed.** It played behind a near-black tint, so the reels being swallowed couldn't be
  seen. Now, as in the draft, the hole opens over the reels with its disk already turning, the whole opening (reels,
  line, title) shrinks into it with purple, cyan and white streaks spiralling in, then it implodes in a white flash
  with rings, and the disk keeps turning behind the card.
- **Ten-packs run light.** Opening ten crates was heavy (about 25 ms more per frame, in every step of the 3D part).
  The crates now sit in a WorldModel inside the viewport, and a ten-pack shares one set of effects from its front
  crate with no per-crate balls of light (the stage's glow swells instead). Measured in a Studio playtest against the
  same session's frame time with nothing open: waiting for the tap +24–26 ms → +0.2 ms, the drop +24–25 ms → +7.8 ms,
  the opening +25–27 ms → +3.9 ms. The crates still bob while they wait.
- **Sounds.** The landing uses `Crate_Settle`, the tap `Button_Click`, the rattle `Crate_Shake`, the hatches
  `Crate_Unlock`, the flash `Crate_Land`, the golden crate's landing `Crate_GoldHit`. No new sounds.

**Where.** `Crates_Settings` → Stage: `STAGE_LAYOUTS` (positions by pack size), `STAGE_DROP_SECONDS` 0.62,
`STAGE_QUICK_DROP_SECONDS` 0.36, `STAGE_RATTLE_SECONDS` 0.52, `STAGE_HATCH_SECONDS` 0.3, `STAGE_WALL_SECONDS` 0.38,
`STAGE_HATCH_DEGREES` 129, `STAGE_WALL_DEGREES` 93, `STAGE_QUICK_SPEED` 0.55, `STAGE_GOLD_AMBIENT`,
`STAGE_GOLD_LIGHT`; the showcase's `SHOWCASE_*` (camera, sway, `SHOWCASE_LIFT_TWEENINFO`) and the cards' `CARD_NAME_TEXT` 0.1, and `STAGE_LIGHT_COUNT` 10 (the light ten-pack). `SHAKE_SECONDS`, `SHAKE_DEGREES` and `INTRO_SCALE` are gone, and so is the crate rows' `Picture` (the showcase draws the model). A crate row names its model in the new
`Model` field (`"PREFAB | Crate_Weapon"`; the tutorial crate `"PREFAB | Crate_Starter"`). `Stage3D.lua` plays the
3D part; `Result.lua` was split out of `Reveal.lua` (the result's cards and summary) with no change in behaviour. The
gui gained `U_Stage` (`S_Glow`, `S_Rays`, `S_Viewport`, `S_Tap`, `S_TapSub`, `S_Hit`). The models live in the place at
`Workspace.Ume.ReplicatedStorage_Assets.Crates` as `PREFAB | Crate_<Name>`. Uploaded to The Snail Studio group, model
asset ids: Weapon 73323979176816, Premium 119024943700934, Utility 117489702367144, Skin 105165043939816, Starter
102933455772099 (their textures: `art/crates/README.md` → Uploading). No remote, Topic or saved data changed.

**How to check.** In game, buy a Weapon x1: the crate drops in, TAP TO OPEN shows, a tap rattles it, the hatches open,
then the walls, and the light flashes into the reel. x3 shows three crates (one in front), x10 ten in a pyramid, and
one tap opens them all. With QUICK OPEN on, the crates open by themselves. The GACHA shop's pedestal shows the selected crate's model, swaying; the reveal card's picture sits in its middle; a reel card's long name stays inside the card. A legendary (0.5 % to 1 %; checked in a
Studio playtest by forcing the result) brings the golden crate.

**For the wiki.** Crates: the opening's first step (the 3D crates, tap to open, the layouts for x1, x3 and x10), the
golden crate before a legendary's reveal, Quick open opening them without a tap. Sounds: which crate sounds the 3D
opening uses. Still unsure: the models and the `Crates` gui's export are in the place only once the owner saves it.
