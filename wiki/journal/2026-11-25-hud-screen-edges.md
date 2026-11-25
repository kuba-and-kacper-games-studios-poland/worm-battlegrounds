---
title: "Match HUD reaches the screen's edges on phones"
date: 2026-11-25
status: open
kind: fixed
pages: ["Match HUD"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/BattleIntro.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main/WidgetManager/Scripts/Dim.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/PotionVignette/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TeleportGui/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LobbyGui/init.lua
---

**What changed.** On a phone with a notch, the whole match HUD sat inside the safe area: a gap on both sides, with the
team panels, walk buttons, JUMP, EMOTES and the red tension band all pulled in toward the middle. The owner's words
were "we need it to be on the edges". The HUD's ScreenGui now ignores the safe area (`ScreenInsets` `None`; it used
to be `CoreUISafeInsets` on phones and `DeviceSafeInsets` elsewhere). On phones and tablets the module pads only its
top, by Roblox's top-bar height (`GuiService.TopbarInset`), so the top row and the timer stay below the bar's buttons.
Consoles keep their TV safe area (`DeviceSafeInsets`).

**Where.** The gui's `Screen.ScreenInsets` and a new root `UIPadding`, `U_Inset`, in MatchHud's `init.lua`.
`_refreshInsets` in the MatchHud module's `Client.lua` sets both and follows `Platform_Changed` and the top bar.
BattleIntro's `_coverScreen` counts the padding when it stretches the intro over the device.

**How to check.** On a real phone, in a match: the walk buttons, JUMP, EMOTES and the team panels sit near the screen's
edges, the tension band runs along the edges, and the turn timer is at the top under Roblox's top bar. Studio's
phone emulator reports itself to the game as a PC, so it never shows the phone layout (the timer at the top, the
smaller sizes, the top padding). It does show the side gap gone.

**For the wiki.** Match HUD: on phones the HUD uses the whole screen.

**After the owner's iPhone 13 mini test (same day).** The edges looked right on a real phone. Two follow-ups:

- **The round intro's dark cover reaches the whole screen.** BattleIntro's `_coverScreen` used to size it to the
  camera's `ViewportSize`, which on that iPhone leaves out the notch sides, so the dark edges stopped short of both
  sides. It now covers the gui's own area, which is the whole screen when `ScreenInsets` is `None` (every device but
  consoles).
- **Bigger walk buttons and JUMP on phones** (the owner: "the guis might be too small? or maybe the steering guis"):
  `U_Touch` is 0.1794 × 0.154 (was 0.138 × 0.1185) and `U_TouchJump` is 0.7033 × 0.7267 of its block (was 0.541 ×
  0.559), 1.3 times each. The phone's room under the health and stamina bars (`TouchRoom`) is 0.33 of the bars'
  height (was 0.257), so the bars stay over the arrows. Checked in Studio with the phone layout set by hand: a 13 px
  gap.
- Not changed: on that iPhone the notch covers part of the turn list on the left (the owner: "specific to that
  phone").

**Second phone test (same day).** The intro's dark edges still left a light strip at both sides of the phone. Its four
edges and flash now run `INTRO_COVER_BLEED` (0.08 of the screen's width) past every screen edge, solid out there, with
the fade on screen unchanged (`INTRO_VIGNETTE_DEPTH` 0.26 of the width at the sides, 0.34 of the height top and bottom),
set by BattleIntro's `_coverScreen`. Every other full-screen gui now reaches a phone's notch sides too: `PotionVignette`
(also the bought-diamonds gem vignette), `TeleportGui` (the loading card), `LobbyGui` (the transit card) with
`ClipToDeviceSafeArea` off, and WidgetManager's dim (`Scripts/Dim.lua`: `ScreenInsets` `None`, `ClipToDeviceSafeArea`
off). Checked in Studio only; Studio can't show a notch.

**Third phone test (same day).** The intro's vignette reached the edges ("the vignette is good now"); the red band
of a turn's last seconds (`U_Tension`) still stopped under Roblox's top bar on phones. Turn now places it over the whole
screen each frame it shows, its frame `TENSION_SIZE` (0.99 × 0.985) of the screen and reaching up past the top padding,
so its glow runs along all four edges. Checked in Studio with the phone padding forced: the frame's top sits 8 px under
the screen's top, the 14 px glow outside it.
