# WidgetManager_Message

System's `WidgetManager_Message` made the game's own: the dialog that tells the player something ("You can't open that
crate right now. Check your coins and diamonds."), with a title, the message and one **OK**.

**Look.** The approved confirmation's (`WormBattlegrounds/WidgetManager_Confirmation`, 2026-11-11): one rounded dark
panel in the screens' fill (25, 25, 35) with a dark outer line and the grey line inside it (130, 130, 130), **HEY!** and
the message in white Londrina Solid (Heavy Italic, a scaled black outline), and the crate shop's slanted button (Gacha
`1020_5`) tinted green for OK, centred. No close button: OK closes it. Laid out by fractions of the card with an
aspect-ratio constraint (1.9). Before, it was System's blue-bannered card; that export is kept in
`ServerStorage.!dump` as `WidgetManager_Message_before_2026-11-11`.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/WidgetManager_Message"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop, Mobile and Console: on Mobile the card is 90% of the screen's width and 46% of its height at most (`Utils_PlatformSize`), against 80% and 34%; on Console the A badge shows (`Console_Hint`) |
| Export | A ScreenGui named `WidgetManager_Message` in StarterGui: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Widget` and a `MouseLockFix` (a modal ImageButton that frees the mouse from shift lock while it shows) go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame | The card, in WidgetManager's shape (`Bg_Bottom` the panel, `Bg_Top` the title, `Content` the rest); WidgetManager tweens it in and out |
| `U_Widget` › `S_MessageText` | TextLabel | The message, up to 40 px |
| `U_Widget` › `S_AcceptButton` | ImageButton | OK: closes the message and shows the next one |
| `U_Widget` › `S_AcceptHint` | ImageLabel | An A (Cross) badge on OK's top right corner, on Console only |

## Driven by

ume's WidgetManager (`src/modules/Main/WidgetManager/Scripts/MessageWidget.lua`) finds this gui as
`I.UserInterface.UI["WidgetManager_Message"]` and the `S_` elements above, for `I.WidgetManager.ShowMessage`; it wires
OK with `I.Interact.OnPress`, so its key dismisses it as a click does. `Client.lua` opens it like any widget, through
its `U_Widget`.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**) over the copy in StarterGui: a ScreenGui named
   `WidgetManager_Message`, disabled. It keeps System's `Name`, `U_Widget`, every `S_` Id and OK's `Utils_ButtonKey` tag.
2. ume modules: `Main/WidgetManager` opens it (`I.WidgetManager.ShowMessage(message)`) and answers OK through
   `I.Interact.OnPress`; `Roblox/Interact` and `Utils/Utils` press the keyed button; `Main/0_Console` shows the gamepad
   badge. WidgetManager's settings set the blur, dim and field of view while it is open.

### Input

| What | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| OK and close | Click **OK** | Tap | A / Cross | `Utils_ButtonKey` on `S_AcceptButton` |

No keyboard key yet; a keyboard key is the same tag's `Utils_KeyboardKey`.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Opening | `U_Widget` | WidgetManager tweens its position in, blurs and dims the background and widens the field of view |
| The panel | `Bg_Bottom` | Fill `Color3.fromRGB(25, 25, 35)`, `UICorner` `UDim.new(0.06, 0)`; a 2 px outer `UIStroke` in the fill's colour and a 3 px inner one (`UIStroke_Inner`) `Color3.fromRGB(130, 130, 130)`, both scaled with the screen (`Utils_UIStroke`) |
| OK | `S_AcceptButton` › `Background` | `Main` `Color3.fromRGB(90, 220, 110)`, `Stroke` `Color3.fromRGB(77, 199, 97)`, `Stroke2` `Color3.fromRGB(25, 25, 35)` (the crate shop's green button) |
| Hover, press | `S_AcceptButton` (`Utils_ButtonScale`, `Bouncy`) | Scale 1.04, 0.92, with the `Button_Hover` and `Button_Click` sounds (`Utils_ButtonSound`) |
| Gamepad badge | `S_AcceptHint` | Console only, swapped to the player's pad (`ColorThick` A) |
