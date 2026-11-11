# WidgetManager_Confirmation

System's `WidgetManager_Confirmation` made the game's own: the dialog that asks the player to confirm something
("Open slot 4 for 2500 coins?"), with a title, the question, and **ACCEPT** and **DECLINE**.

**Look.** The game's screens (MatchBoard, Loadout, the crate shop), kept simple at the owner's ask (2026-11-11: "dont
make it too complicated"): one rounded dark panel in the screens' fill (25, 25, 35) with a dark outer line and the
grey line inside it (130, 130, 130), **ARE YOU SURE?** and the question in white Londrina Solid (Heavy Italic, a
scaled black outline), and the crate shop's slanted button (Gacha `1020_5`) tinted green for ACCEPT and red for
DECLINE. No close button: DECLINE closes it. Laid out by fractions of the card with an aspect-ratio constraint (1.9).
Before, it was System's blue-bannered card; that export is kept in `ServerStorage.!dump` as
`WidgetManager_Confirmation_before_2026-11-11`.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/WidgetManager_Confirmation"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop, Mobile and Console: on Mobile the card is 90% of the screen's width and 46% of its height at most (`Utils_PlatformSize`), against 80% and 34%; on Console the gamepad badges show (`Console_Hint`) |
| Export | A ScreenGui named `WidgetManager_Confirmation` in StarterGui: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Widget` and a `MouseLockFix` (a modal ImageButton that frees the mouse from shift lock while it shows) go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame | The card, in WidgetManager's shape (`Bg_Bottom` the panel, `Bg_Top` the title, `Content` the rest); WidgetManager tweens it in and out |
| `U_Widget` › `S_MessageText` | TextLabel | The question, up to 40 px |
| `U_Widget` › `S_AcceptButton` | ImageButton | ACCEPT: runs the confirmation's `onAccept` |
| `U_Widget` › `S_DeclineButton` | ImageButton | DECLINE: runs its `onDecline` and closes the dialog |
| `U_Widget` › `S_AcceptHint`, `S_DeclineHint` | ImageLabel | A (Cross) and B (Circle) badges on the buttons' top right corners, on Console only |

## Driven by

ume's WidgetManager (`src/modules/Main/WidgetManager/Scripts/ConfirmationWidget.lua`) finds this gui as
`I.UserInterface.UI["WidgetManager_Confirmation"]` and the `S_` elements above, for
`I.WidgetManager.ShowConfirmation`; it wires ACCEPT and DECLINE with `I.Interact.OnPress`, so their keys answer it as
a click does. `Client.lua` opens it like any widget, through its `U_Widget`.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**) over the copy in StarterGui: a ScreenGui named
   `WidgetManager_Confirmation`, disabled. It keeps System's `Name`, `U_Widget`, every `S_` Id and the buttons'
   `Utils_ButtonKey` tags.
2. ume modules: `Main/WidgetManager` opens it (`I.WidgetManager.ShowConfirmation(message, onAccept, onDecline)`) and
   answers its buttons through `I.Interact.OnPress`; `Roblox/Interact` and `Utils/Utils` press the keyed buttons;
   `Main/0_Console` shows the gamepad badges. WidgetManager's settings set the blur, dim and field of view while it is
   open.

### Input

| What | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| Accept | Click **ACCEPT** | Tap | A / Cross | `Utils_ButtonKey` on `S_AcceptButton` |
| Decline and close | Click **DECLINE** | Tap | B / Circle | `Utils_ButtonKey` on `S_DeclineButton` |

No keyboard keys yet; a keyboard key is the same tag's `Utils_KeyboardKey`.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Opening | `U_Widget` | WidgetManager tweens its position in, blurs and dims the background and widens the field of view |
| The panel | `Bg_Bottom` | Fill `Color3.fromRGB(25, 25, 35)`, `UICorner` `UDim.new(0.06, 0)`; a 2 px outer `UIStroke` in the fill's colour and a 3 px inner one (`UIStroke_Inner`) `Color3.fromRGB(130, 130, 130)`, both scaled with the screen (`Utils_UIStroke`) |
| ACCEPT | `S_AcceptButton` › `Background` | `Main` `Color3.fromRGB(90, 220, 110)`, `Stroke` `Color3.fromRGB(77, 199, 97)`, `Stroke2` `Color3.fromRGB(25, 25, 35)` (the crate shop's green button) |
| DECLINE | `S_DeclineButton` › `Background` | `Main` `Color3.fromRGB(255, 77, 77)`, `Stroke` `Color3.fromRGB(230, 64, 64)` (the close button's red), `Stroke2` `Color3.fromRGB(25, 25, 35)` |
| Hover, press | The buttons (`Utils_ButtonScale`, `Bouncy`) | Scale 1.04, 0.92, with the `Button_Hover` and `Button_Click` sounds (`Utils_ButtonSound`) |
| Gamepad badges | `S_AcceptHint`, `S_DeclineHint` | Console only, swapped to the player's pad (`ColorThick` A and B) |
