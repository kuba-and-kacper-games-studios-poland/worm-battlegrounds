# PartyInvite

**Invite players**: everyone in this server who isn't in a party, each with **Invite** (it turns to **Sent**), and **Invite friends** (Roblox's game invite). With nobody to invite it says so.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README): a `Small` Hazard plate window. A row is an avatar, the name and a small blue Invite, laid out as the custom lobby's invite list; a sent invite wears the kit's grey (`Kit_DisabledImage`).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/PartyInvite"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`) |
| Export | A ScreenGui named `PartyInvite`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Empty` | Label (`Dim`) | Shows when nobody can be invited |
| `U_Players` | Cells | Holds one `Invitable` per player |
| `U_Widget` › `S_InviteFriends` | Button | Opens Roblox's game invite |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Invitable` | `U_Players` | `S_Avatar`, `S_Name`, `S_Invite` (Button, `Small`) |

## Driven by

The game's `Party` module (`Invites` handler) fills it on `WidgetManager_Opened` with `PartyInvite`; the Party panel's **Invite players** opens it.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `PartyInvite`, `Enabled` off. WidgetManager opens it (`I.WidgetManager.Open("PartyInvite")`). A restyled copy keeps its `Name`, Ids and prefab names. Its `S_ScreenScale` follows the screen through the game's ScreenScale module, like every widget's (its `GUIS` list).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Invite, Invite friends | Click | Tap | Select and A | Party connects them |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Sent | `S_Invite` › `Face` | `Kit_DisabledImage` (grey), text "Sent" |
