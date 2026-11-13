# PartyInvited

**Party invite**: who asked the player to join their party, with their avatar, then **JOIN PARTY** or **NO THANKS**.

**Look.** The game's screens, drawn as the confirmation dialog (`WidgetManager_Confirmation`, the code folder's
`practices.md` → "Dialogs in the new look stay simple"). One rounded dark panel (25, 25, 35) with a dark outer line and
the grey line inside it (130, 130, 130). **PARTY INVITE** sits on top, then the inviter's head shot (plain, as in the
invite list) beside "Name invited you to their party!" in white Londrina Solid (Heavy Italic, a scaled black outline).
Under them are the crate shop's slanted button (Gacha `1020_5`), tinted green for JOIN PARTY and red for NO THANKS. There
is no close button: NO THANKS closes it. It is laid out by fractions of the card with an aspect-ratio constraint
(1.9). Before 2026-11-13 it was the GUI kit's Hazard plate `Small` window (`WormBattlegroundsBrawl`).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/PartyInvited"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop, Mobile and Console: on Mobile the card is 90% of the screen's width and 46% of its height at most (`Utils_PlatformSize`), against 80% and 34%; on Console the gamepad badges show (`Console_Hint`) |
| Export | A ScreenGui named `PartyInvited`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Widget` (WidgetManager's shape: `Bg_Bottom` the panel, `Bg_Top` the title, `Content` the rest) and a `MouseLockFix` go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Avatar` | ImageLabel | The inviter's head shot |
| `U_Widget` › `S_Text` | TextLabel | "Name invited you to their party!", up to 40 px |
| `U_Widget` › `S_Accept` | ImageButton | JOIN PARTY: joins the party |
| `U_Widget` › `S_Decline` | ImageButton | NO THANKS: says no |
| `U_Widget` › `S_AcceptHint`, `S_DeclineHint` | ImageLabel | A (Cross) and B (Circle) badges on the buttons' top right corners, on Console only |

## Driven by

The game's `Party` module (`Invites` handler) writes the inviter and opens it with `I.WidgetManager.Open("PartyInvited")`
when `Party_Invited` arrives, and closes it once answered. It wires `S_Accept` and `S_Decline` with
`I.Interact.OnPress`.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**) over the copy in StarterGui: a ScreenGui named `PartyInvited`,
`Enabled` off. A restyled copy keeps its `Name`, Ids and the buttons' `Utils_ButtonKey` tags.

### Input

| Action | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| Join party | Click **JOIN PARTY** | Tap | A / Cross | `Utils_ButtonKey` on `S_Accept`; Party connects it |
| No thanks, and close | Click **NO THANKS** | Tap | B / Circle | `Utils_ButtonKey` on `S_Decline`; Party connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Opening | `U_Widget` | WidgetManager tweens its position in, blurs and dims the background and widens the field of view |
| The panel | `Bg_Bottom` | Fill `Color3.fromRGB(25, 25, 35)`, `UICorner` `UDim.new(0.06, 0)`; a 2 px outer `UIStroke` in the fill's colour and a 3 px inner one (`UIStroke_Inner`) `Color3.fromRGB(130, 130, 130)`, both scaled with the screen (`Utils_UIStroke`) |
| JOIN PARTY | `S_Accept` › `Background` | `Main` `Color3.fromRGB(90, 220, 110)`, `Stroke` `Color3.fromRGB(77, 199, 97)`, `Stroke2` `Color3.fromRGB(25, 25, 35)` (the crate shop's green button) |
| NO THANKS | `S_Decline` › `Background` | `Main` `Color3.fromRGB(255, 77, 77)`, `Stroke` `Color3.fromRGB(230, 64, 64)` (the close button's red), `Stroke2` `Color3.fromRGB(25, 25, 35)` |
| Hover, press | The buttons (`Utils_ButtonScale`, `Bouncy`) | Scale 1.04, 0.92, with the `Button_Hover` and `Button_Click` sounds (`Utils_ButtonSound`) |
| Gamepad badges | `S_AcceptHint`, `S_DeclineHint` | Console only, swapped to the player's pad (`ColorThick` A and B) |
