---
title: "Turns are announced with a banner (avatar and whose turn), and the last 5 seconds of your turn tighten"
date: 2026-11-10
status: open
kind: added
pages: ["Match screen", "Guis", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Teams.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/global_data/Haptic/Preset.lua
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/_meta/README.md
---

**What changed.**

- **The turn banner:** as each turn starts, a dark band opens across the upper middle of the screen with the snail's
  avatar (the player's headshot, or the bots' picture) in a rounded square frame, whose turn it is in big slanted
  capitals, and a line under it. The band opens in 0.18 s while the content slides in from the left and settles from
  1.3 times its size (0.35 s); it stays 1 s, then the content slides on to the right as the band closes (0.22 s).
- **Your turn:** "Your turn!" in a gold gradient over orange lines and an orange avatar frame, "Aim and fire!" under
  it. It plays the turn sting (`Turn_Yours`) with a whoosh (`Turn_Whoosh`), and a phone or pad taps twice.
- **Anyone else's turn:** "Bax's turn" in white over lines and an avatar frame in that snail's team colour, "You're
  next!" or "Your turn in 3 turns" under it, at 0.8 of the size, with the softer turn chime (`Turn_Start`).
- **You're next:** when the player plays after this turn, a sting plays (`Turn_Next`, at half volume) and the
  "You're next!" line under the timer's banner flashes yellow and fades back over 1.2 s.
- **The end of your turn:** the timer turns orange from 8 seconds left and red from 5. From 5 it ticks every second
  (`Turn_Tick`), every half second from 3, its pitch rising from 1 to 1.3, and a red band pulses along the screen's
  sides, 1.5 times a second at first and twice as fast at the end.

The timer's own banner ("Your turn!" / "Bax's turn") and the wait line still show as before; the callout comes on top.

**Supersedes** the earlier version of this entry from the same day: two callouts on the timer's trapezoid frame
pictures (`U_TurnCallout`, orange, and `U_TurnCalloutOther`, dark with `S_Name` and a team-coloured outline) that
punched in from 2.2 times their size. The owner turned that down: "the ui your turn looks bad, polish it up, make it
look professional", and "add the player avatar/bot icon". Still true from it: the sounds, the haptic, the "You're
next" flash and the end-of-turn tightening.

**Where.** `Turn._onTurnStarted` (on Match's `Match_TurnStarted`) fills the banner: the avatar through
`Teams.SetAvatar` (headshot, or `BOT_AVATAR`), the title, the line, the title's gradient and the accent colour.
`Turn._popCallout(scale)` plays it; `Turn._tick(deltaTime?)` runs the last seconds. MatchHud settings:
`CALLOUT_START_SCALE` 1.3, `CALLOUT_SLIDE` 0.06 (share of the screen), `CALLOUT_HOLD` 1, `CALLOUT_OTHER_SCALE` 0.8,
`CALLOUT_BAND_TWEENINFO` (0.18 s Quad Out), `CALLOUT_IN_TWEENINFO` (0.35 s Back Out), `CALLOUT_OUT_TWEENINFO` (0.22 s
Quart In), `CALLOUT_ACCENT_COLOR` (255, 140, 20), `CALLOUT_MINE_GRADIENT` (255, 232, 110) to (255, 140, 20),
`CALLOUT_OTHER_GRADIENT` (255, 255, 255) to (200, 215, 235); `NEXT_FLASH_COLOR` (255, 220, 60), `NEXT_FLASH_TWEENINFO`
(1.2 s), `TIMER_WARN_FROM` 8, `TIMER_WARN_COLOR` (255, 170, 40), `TIMER_DANGER_COLOR` (255, 70, 50), `TICK_FAST_FROM`
3, `TENSION_PULSE_RATE` 1.5; `TICK_SOUND_FROM` stays 5. Haptic preset `Match_YourTurn` (two taps, in
`Haptic/Preset.lua`). Sounds in `SoundsList.lua`, checked to load in Studio: `Turn_Whoosh` 9126046540
(ProSoundEffects "Synth Air Whoosh") and `Turn_Next` 1840076509 (APM "Through the Roof (sting)"). In the MatchHud gui,
one `Primitive` block `U_TurnCallout` (Position 0.5, 0.34, 1 × 0.14 of the screen, ZIndex 10; `U_TurnCalloutOther` is
gone): `S_Band` ((14, 14, 22) at 0.2 transparency, its edges faded by a UIGradient) with `S_LineTop` and
`S_LineBottom`, and `S_Content` (UIScale `S_Pop`) holding `S_Avatar` (UICorner, UIStroke `S_AvatarStroke`), `S_Title`
(the timer's font, Heavy Italic, `TextCase_Upper`, UIGradient `S_TitleGradient`, a dark UIStroke) and `S_Sub`; and
`U_Tension` (a screen-sized frame whose UIStroke `S_Glow` is red, 14 px, with a UIGradient). The gui was exported again
into StarterGui on 2026-11-10 with the banner (`UmeGui.Export`); the copy from before that day is in
`ServerStorage.!dump` as `MatchHud_before_2026-11-10`.

**How to check.** In a Studio match against bots: on your turn the dark band opens with your avatar and a gold "Your
turn!" with a whoosh; on a bot's turn it shows the bot picture, "<name>'s turn" in white over lines in its colour, and
how many turns until yours. Wait out your turn: orange timer at 8, red with ticks at 5, faster ticks at 3, and the red
band pulsing. The place must be saved for the new StarterGui export to stay. Not checked in Studio by the docs pass.

**For the wiki.** Match screen: the turn banner (avatar, whose turn, the line under it), the "You're next" sting and
flash, and the last seconds' timer colours, ticks and red band. Guis: MatchHud's `U_TurnCallout` and `U_Tension`.
Match modules: MatchHud's `CALLOUT_*` settings and the `Match_YourTurn` haptic.

**From.** The owner, 2026-11-10: "the ui your turn looks bad, polish it up, make it look professional"; "add the
player avatar/bot icon".
