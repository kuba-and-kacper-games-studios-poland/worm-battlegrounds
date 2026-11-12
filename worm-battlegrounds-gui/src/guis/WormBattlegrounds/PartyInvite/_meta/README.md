# PartyInvite

**Invite players**: everyone in this server who isn't in a party, each with **Invite** (it turns to **Sent**), and **Invite friends** (Roblox's game invite). With nobody to invite it says so.

**Look.** The studio's `InvitePlayers` design (2026-11-12), ported 1:1 as `Primitive` nodes (its pictures, fonts and screen-fraction layout, the code folder's `practices.md` → "The studio's screens are 1:1 `Primitive` ports"). A dark slanted panel with INVITE PLAYERS and a red ✕ in its header, a scrolling list of player rows (avatar, name, @username, a dark Invite) and a yellow INVITE FRIENDS under it. The design has no empty-list text, so `S_Empty` uses its member name's font, centred over the list.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/PartyInvite"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and aspect-ratio constraints, no `S_ScreenScale` |
| Export | A ScreenGui named `PartyInvite`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (full screen, WidgetManager's shape: `Content` holding the panel) and `MouseLockFix` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Close` | ImageButton | Closes the window (its tags) |
| `U_Players` | ScrollingFrame with a UIListLayout | Holds one `Invitable` per player |
| `U_Widget` › `S_Empty` | TextLabel | Shows when nobody can be invited |
| `U_Widget` › `S_InviteFriends` | ImageButton | Opens Roblox's game invite |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Invitable` | `U_Players` | `S_Avatar`, `S_Name`, `S_Username`, `S_Invite` (ImageButton with its `S_Text`) |

## Driven by

The game's `Party` module (`Invites` handler) fills it on `WidgetManager_Opened` with `PartyInvite`; the Party panel's **Invite players** opens it.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `PartyInvite`, `Enabled` off. WidgetManager opens it (`I.WidgetManager.Open("PartyInvite")`). A restyled copy keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `S_Close` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Invite friends | Click | Tap | A (Cross) | `S_InviteFriends` tags (`Utils_ButtonKey`); Party connects it |
| Invite | Click | Tap | Select and A | Party connects each row's `S_Invite` |

Close and Invite friends show their pad button in a `PadHint` badge on Console (`Console_Hint`, `Console_Action` `Back`, `Confirm`).

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Sent | `Invitable` › `S_Invite` › `Background.Stroke`, `S_Text` | `Look_SentStrokeColor` (130, 130, 130) and `Look_SentTextColor` (153, 153, 153), text "Sent"; otherwise `Look_StrokeColor` and `Look_TextColor`. Party's `Invites` |
