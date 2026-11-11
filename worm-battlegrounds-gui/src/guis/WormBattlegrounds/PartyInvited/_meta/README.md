# PartyInvited

**Party invite**: who asked the player to join their party, with their avatar, then **Join party** or **No thanks**. Closing it lets the invite run out.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README): a `Small` Hazard plate window, the inviter's large avatar beside the line, Join party the one yellow and No thanks red.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/PartyInvited"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`) |
| Export | A ScreenGui named `PartyInvited`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Avatar` | Picture (`AvatarLarge`) | The inviter's head shot |
| `U_Widget` › `S_Text` | Label (`Strong`) | "Name invited you to their party!" |
| `U_Widget` › `S_Accept` | Button (`Primary`, `Large`) | Joins the party |
| `U_Widget` › `S_Decline` | Button (`Danger`, `Large`) | Says no |

## Driven by

The game's `Party` module (`Invites` handler) writes the inviter and opens it with `I.WidgetManager.Open("PartyInvited")` when `Party_Invited` arrives, and closes it once answered.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `PartyInvited`, `Enabled` off. A restyled copy keeps its `Name`, Ids and prefab names. Its `S_ScreenScale` follows the screen through the game's ScreenScale module, like every widget's (its `GUIS` list).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Join party | Click | Tap | A (Cross) | `S_Accept` tags (`Utils_ButtonKey`); Party connects it |
| No thanks | Click | Tap | X (Square) | `S_Decline` tags (`Utils_ButtonKey`); Party connects it |

Every button shows its pad button in a badge on Console (the theme Button's `Hint`: `Confirm`, `Decline`, and the close's `Back`).

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
