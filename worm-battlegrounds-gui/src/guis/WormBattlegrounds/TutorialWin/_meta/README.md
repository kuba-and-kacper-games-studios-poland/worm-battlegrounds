# TutorialWin

The tutorial match's end, in place of the Results screen (the owner, 2026-11-24): a small card with **YOU WON!** (or
**NICE TRY!** when the player's snail went out) and one button, **CONTINUE**, which takes the player back to the
lobby, where the tutorial goes on to picking a weapon.

**Look.** The confirmation dialog's parts (`WidgetManager_Confirmation`), kept simple: one rounded dark panel in the
screens' fill (25, 25, 35) with a dark outer line and the grey line inside it (130, 130, 130), the title in the turn
callout's gold (255, 205, 60) in black-outlined Londrina Solid Heavy Italic (the title outline, ScaledSize 0.06),
capitals (`TextCase_Upper`), and the crate shop's slanted button (Gacha `1020_5`) tinted FIRE's yellow for CONTINUE,
the one yellow button on the screen. No close button. Laid out by fractions of the card with an aspect-ratio
constraint (2.2).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TutorialWin"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop, Mobile and Console: on Mobile the card is 70% of the screen's width and 34% of its height at most (`Utils_PlatformSize`), against 50% and 26%; on Console the A badge shows on CONTINUE (`Console_Hint`) |
| Export | A ScreenGui named `TutorialWin` in StarterGui: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Widget` and a `MouseLockFix` (a modal ImageButton that frees the mouse from shift lock while it shows) go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame | The card, in WidgetManager's shape (`Bg_Bottom` the panel, `Bg_Top` the title, `Content` the button); WidgetManager tweens it in and out |
| `U_Widget` › `S_Title` | TextLabel | "You won!" or "Nice try!" (Tutorial's `WIN_TITLE`, `LOST_TITLE`), up to 100 px |
| `U_Widget` › `S_Continue` | ImageButton | CONTINUE: Tutorial sends `Match_Leave`; its guide's arrow points up at it from below |
| `U_Widget` › `S_ContinueHint` | ImageLabel | The A (Cross) badge on the button's top right corner, on Console only |

## Driven by

The game's `Tutorial` module (`Scripts/Client/MatchHints.lua`) finds it as `I.UserInterface.UI["TutorialWin"]`, writes
`S_Title` and opens it once with `I.WidgetManager.Open("TutorialWin")` when the tutorial match ends (with `Match_Win`
for a win), and closes it when the player is out of the tutorial match. It wires CONTINUE with `I.Interact.OnPress`.
MatchHud's Results never opens in the tutorial match.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `TutorialWin`, disabled. A restyled
   copy keeps its `Name`, `U_Widget`, every `S_` Id and the button's `Utils_ButtonKey` tag.
2. Modules: `Main_Game/Tutorial` opens it and answers CONTINUE; `Main/WidgetManager` opens and closes it (its
   settings set the blur, dim and field of view while it is open); `Roblox/Interact` and `Utils/Utils` press the keyed
   button; `Main/0_Console` shows the gamepad badge.

### Input

| What | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| Continue to the lobby | Click **CONTINUE** | Tap | A / Cross | `Utils_ButtonKey` on `S_Continue`; Tutorial connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Opening | `U_Widget` | WidgetManager tweens its position in, blurs and dims the background and widens the field of view |
| The panel | `Bg_Bottom` | Fill `Color3.fromRGB(25, 25, 35)`, `UICorner` `UDim.new(0.08, 0)`; a 2 px outer `UIStroke` in the fill's colour and a 3 px inner one (`UIStroke_Inner`) `Color3.fromRGB(130, 130, 130)`, both scaled with the screen (`Utils_UIStroke`) |
| The title | `S_Title` | `Color3.fromRGB(255, 205, 60)`, black `UIStroke` ScaledSize 0.06 |
| CONTINUE | `S_Continue` › `Background` | `Main` `Color3.fromRGB(255, 196, 46)`, `Stroke` `Color3.fromRGB(240, 150, 30)`, `Stroke2` `Color3.fromRGB(25, 25, 35)`; white `ButtonText` with a black ScaledSize 0.07 outline |
| Hover, press | `S_Continue` (`Utils_ButtonScale`, `Bouncy`) | Scale 1.04, 0.92, with the `Button_Hover` and `Button_Click` sounds (`Utils_ButtonSound`) |
| Gamepad badge | `S_ContinueHint` | Console only, swapped to the player's pad |
