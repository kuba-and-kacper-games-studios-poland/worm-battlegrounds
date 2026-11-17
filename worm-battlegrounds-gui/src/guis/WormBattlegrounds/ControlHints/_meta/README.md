# ControlHints

The match's controls while a new player waits for the match and picks where to land: a short list at the bottom
left of the screen, a button and its label on each line for the device in use, and a tip over it that changes every
few seconds.

| Device | What the list shows |
| --- | --- |
| Desktop (and VR) | A D Walk · Space Jump / Fly · the mouse's left button Shoot · its right button Camera · 1 2 3 Weapons · its wheel Zoom |
| Mobile | `<` `>` Walk · JUMP Jump / Fly · a fingertip Aim · FIRE Shoot · two fingertips Camera |
| Console | Left stick Walk · A Jump / Fly · Right stick Aim · RT Shoot · LB RB Weapons · LT and the right stick Camera |

**Look.** `Primitive` nodes in MatchHud's pad-hint look (`U_PadControls`), rebuilt the same day after the owner
found the first strip "very off" (a dark panel across the bottom middle, over the notifications and the waiting
room): no panel, a column at the bottom left (AnchorPoint 0, 1 at 1.2 % across, 96.8 % down, 0.22 of the screen wide,
square), one line per control: its glyphs right-aligned in the first 36 %, then the label, upper case, white Heavy
Italic Londrina (`rbxassetid://12187365977`) with a black `ScaledSize` outline. Key caps, touch pills and the mouse
are the HUD's dark slots (fill 25, 25, 35 at 0.1, the grey 130 line, `Utils_UIStroke`) with white letters; the
mouse's pressed part, FIRE's letters and the fingertips are gold (255, 210, 63); the pad's buttons are the Console
module's icons. The tip sits over the list, left-aligned, Bold Italic. No new pictures.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/ControlHints"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | Desktop, Mobile, Console (each shows its own list) |
| Export | A ScreenGui named `ControlHints`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_ControlHints` | Frame, bottom left (AnchorPoint 0, 1), a `UIListLayout` from the bottom | The lists and the tip |
| `U_ControlHints` › `S_Tip` | TextLabel | The tip, turned through MatchHud's `HINT_TIPS` |

The lists (`Desktop`, `Touch`, `Pad`) aren't reached by code: each carries `Utils_HideOnPlatform` with its
device's `Utils_<Device>Visibility`, and every pad button image a `Console_Hint` with its `Console_Action` (`Move`,
`Jump`, `Aim`, `Fire`, `WeaponPrevious`, `WeaponNext`, `CameraPan`), so the Console module draws it in the player's
pad's icons.

## Driven by

The game's `MatchHud` module (its `Hints` client handler) turns the ScreenGui on while the player is in the match's
waiting phase or drop, in their first `HINTS_MATCHES` matches (their `MatchesPlayed` statistic) and never in the
tutorial match, and turns the tip every `HINT_TIP_SECONDS`. At the bottom left it stays clear of the waiting room and
the notifications at the bottom middle.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `ControlHints`, `Enabled` off. It's new on
2026-11-17: MatchHud and Match find it by name (`HINTS_GUI_NAME`), so it must be in the place before either starts.
A restyled copy keeps its `Name` and `S_Tip`.

### Input

None: it only shows. The list follows the device in use live (`Utils_HideOnPlatform` follows `Platform_Changed`, so
picking up a pad switches to the pad's list).

### Looks

| State | Element | Value |
| --- | --- | --- |
| Tip changing | `S_Tip` | `TextTransparency` and its `UIStroke`'s `Transparency` fade to 1 and back (MatchHud's `HINT_TIP_TWEENINFO`, 0.35 s quad out), the next tip set between |
