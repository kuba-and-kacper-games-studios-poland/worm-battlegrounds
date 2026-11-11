---
title: "Full gamepad support: one control scheme in the Console module, pad hints in every gui, D-pad zoom, own glyph kit"
date: 2026-11-10
status: open
kind: added
pages: ["Controls & platforms", "Match screen", "Lobby", "Guis"]
files:
  - worm-battlegrounds-game/src/modules/Main/0_Console/Settings.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Client.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Binds.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Hints.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Selection.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/_meta/README.md
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/TouchControls.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Client/DropPicker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/MatchHints.lua
  - worm-battlegrounds-game/src/modules/Utils/Utils/Scripts/ButtonPress.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Controls/Button.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Controls/Widget.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Lobby/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Party/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - art/console_glyphs/make_glyphs.py
---

**What changed.** Every gamepad button the game uses is chosen in one place, the Console module's `ACTIONS` setting
(the scheme, with each action's buttons, hint text and priority), and the guis show pad hints for their shortcuts on
Console, in the player's pad's buttons (Xbox or PlayStation).

- **Match (unchanged feel):** left stick or D-pad ← → walk, A (Cross) jumps and held flies the jetpack, right stick
  aims, hold RT (R2) to charge and let go to fire, B (Circle) cancels the aim, hold LT (L2) with the right stick moves
  the camera, A places the drop.
- **Match (new):** D-pad ↑ / ↓ held zooms in / out (`PAD_ZOOM_RATE` 0.9 of the distance a second, MatchCamera); X
  (Square) opens the emote wheel, which then holds the selection, and B closes it; LB / RB (L1 / R1) step through the
  loadout but only rest on a utility (outlined, a Y badge on it) and Y (Triangle) uses it. Before, LB / RB used a
  utility as soon as they reached it and stayed stuck on it. View (the touchpad) starts or ends the gui selection, for
  the HUD's buttons (Leave game, Mute music).
- **Lobby and menus:** the selection rests on SOLO VS BOTS; X (Square) opens CUSTOM, LB (L1) STYLE, RB (R1) the
  crates, Y (Triangle) a party invite; in the crates window LB / RB switch the tabs; the solo setup holds the selection
  (Start first) and B goes back; A presses the selected button and B closes a window even while something is
  selected. A window whose every button has a key (Results, a party invite, a confirmation) has no selection, so A and B
  do what their badges say. Start (Menu / Options) stays Roblox's menu.
- **Hints:** a corner badge with the button on every keyed button (LB / RB / X / Y in the lobby, B on every close
  button, A / B / X in dialogs, X on EMOTES, LB / RB at the crates tabs and the loadout bar), and on the player's
  turn a strip of the match's controls at the bottom left (`MatchHud`'s `U_PadControls`). The tutorial match's first
  hints name the pad's buttons on Console (`PAD_HINTS`).
- **Glyphs:** the game's own Xbox and PlayStation button pictures were drawn (`art/console_glyphs`, 39 SVGs and PNGs,
  `preview.html`). They are not uploaded: the game shows the System theme's uploaded icons until the owner approves
  them; then `HINT_STYLE = "Glyph"` swaps them in.

**Where.** `ACTIONS`, `HINT_STYLE`, `BUTTON_NAMES`, `NAVIGATION_GUIS`, `BACK_WINDOW` in
`worm-battlegrounds-game/src/modules/Main/0_Console/Settings.lua`; `I.Console.Bind`, `Unbind`, `IsAction`, `IsHeld`,
`Focus`, `Unfocus`, `SetHome`, `GetButtonName`. Hints are `Console_Hint` elements with a `Console_Action` attribute;
the theme Button's `Hint` param draws them on theme buttons. No remotes.

**How to check.** On a pad in Studio (or Console in the Gui tool): the badges show only on Console and swap to
PlayStation symbols with a PlayStation pad; in the lobby SOLO VS BOTS is selected and LB, RB, X, Y open their
windows; in a match the strip shows on your turn, D-pad ↑ / ↓ zoom, RB passes a utility without using it and Y uses it.

**For the wiki.** Controls & platforms: the Console column (Zoom: D-pad ↑ / ↓; Pick an item: LB / RB, Y uses a
utility; emotes: X; menus: View), a lobby controls table (LB Style, RB Crates, X Custom, Y Invite, A select, B back),
and "button hints on every shortcut". Its open question `pad-zoom` (LT with the right stick's up and down) was
answered differently: D-pad ↑ / ↓. Still unsure: MatchHud's aim still reads RT, B and the sticks itself until its
hold-to-charge rework moves them into the scheme, and a homing missile's target can't be picked on a pad yet.
