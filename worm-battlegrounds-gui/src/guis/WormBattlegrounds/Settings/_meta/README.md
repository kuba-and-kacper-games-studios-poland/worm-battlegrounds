# Settings

System's `Settings` made the game's own: the settings window of ume's Settings module, with the player's settings in
groups, each a row in its group's colour. A volume sits between two buttons that step it; a switch is a button that
reads On or Off. It is laid out for a 1080 px tall screen and scaled by its `S_ScreenScale`.

**Look.** The approved confirmation's panel (`WormBattlegrounds/WidgetManager_Confirmation`, 2026-11-11) in place of
System's blue banner: one dark panel in the screens' fill (25, 25, 35) with 22 px corners, a dark outer line and the
grey line inside it (130, 130, 130), **SETTINGS** in white Londrina Solid (Heavy Italic, a scaled black outline) at
the top, and the red close (the Party card's kick button, LobbyInventory `1037_195`, as the EMOTES panel's) in the top
right corner. The rows, switches and steppers are System's, unchanged. `Primitive` nodes only, so no theme changes it.
Before, it was System's blue-bannered window; that export is kept in `ServerStorage.!dump` as
`Settings_before_2026-11-11`.

| | |
| --- | --- |
| Path | `"WormBattlegrounds/Settings"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop, Mobile: the Mobile preview adds the touch boost (`S_ScreenScale` ×1.3 on screens shorter than 500 px). On Console the close button's X hides and B shows in its place |
| Export | A ScreenGui named `Settings` in StarterGui: `Enabled` off, `DisplayOrder` 5, `ScreenInsets` `CoreUISafeInsets`. Its root is a Folder: `U_Widget` and a `MouseLockFix` go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame | The window, 720 × 660 at 1080, in WidgetManager's shape (`Bg_Bottom` the panel, `Bg_Top` the title and the close, `Content` the list, 84 px under the top); WidgetManager tweens it in and out. Its close button (`CloseButton`, 60 × 54) is tagged `Interact_Button` to call `WidgetManager.CloseCurrent` |
| `U_Widget` › `S_ScreenScale` | UIScale | Scales the window for the screen: a driver sets it to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px |
| `U_Widget` › `S_CloseHint` | ImageLabel | B (Circle) in the close button's X place, on Console only |
| `U_List` | ScrollingFrame | The settings, in groups (`PREFAB \| Header`, `PREFAB \| Setting`, `PREFAB \| Stepper`), 652 px rows centred in it, 14 px apart; the scroll bar runs in the margin beside them |

## Prefabs

### `PREFAB | Header`

In `U_List`. A group's name over its settings, 652 × 44.

| Element | Class | What it is |
| --- | --- | --- |
| `S_Text` | TextLabel | The group's name, Work Sans ExtraBold 30 in the group's gradient (its `UIGradient`, light to dark downwards) with a 3 px black outline; a driver colours it |

### `PREFAB | Setting`

In `U_List`. One switch, 652 × 90: its name, what it does (when that isn't plain from the name), and an On/Off button.

| Element | Class | What it is |
| --- | --- | --- |
| `S_Name` | TextLabel | The setting's name, Work Sans ExtraBold 28 with a 2.5 px black outline |
| `S_Detail` | TextLabel | What it does, Source Sans Pro Heavy 24 in grey; empty when the name says it all, and then a driver centres `S_Name` in the row |
| `S_Switch` | ImageButton | Turns it on and off: System's WidgetManager_Message OK button, 124 × 58, its gradient on `Background_Front` and `Background_Back`, its word in `ButtonText` |

### `PREFAB | Stepper`

In `U_List`. A volume, 652 × 90: its name, what it does, and the value between two buttons.

| Element | Class | What it is |
| --- | --- | --- |
| `S_Name` | TextLabel | The setting's name, 360 wide (the stepper takes the rest of the row) |
| `S_Detail` | TextLabel | What it does; empty when the name says it all, and then a driver centres `S_Name` in the row |
| `S_Left` | ImageButton | Steps the value down: a 56 × 56 System button reading `<` |
| `S_Value` | TextLabel | The value, Work Sans ExtraBold 28, in a 112 × 50 dark box (`ValueBox`: black at 0.45, a 3 px outline in the group's colour) |
| `S_Right` | ImageButton | Steps the value up: the same, reading `>` |

## Driven by

ume's Settings module (`src/modules/Main/Settings/Scripts/Client/SettingsGui.lua`) finds this gui as
`I.UserInterface.UI["Settings"]`. It fills `U_List` with a `PREFAB | Header` per group and a row per setting, in the
group's colours (the heading's `UIGradient`, the row's `UIStroke` and its `Tint`, a stepper's `ValueBox` outline),
hides the three prefabs, and sets `S_ScreenScale` when the window opens and when the screen changes size. On every
open and every change it colours each `S_Switch` (`SWITCH_LOOKS`: green with On, red with Off) and each stepper
(`S_Value` reads `50%`, or Off at 0; the chevron at the end the volume has reached turns grey and stops taking
presses, `CHEVRON_LOOKS`). The top bar's gear button (ume's TopBar_Controller) opens and closes it.

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_Settings_Preview`, System's preview) lists ume's Sound group (Master at 100%, Music and Sound Effects
at 50%) and an example Gameplay group a game would add (Show tips on, Camera shake off), each group in its colours
(Sound purple, Gameplay green), a name with no detail line centred in its row; clicking a switch flips it, and a
chevron steps the volume by 10 between Off (0) and 100%.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**) over the copy in StarterGui: a ScreenGui named
   `Settings`. ume's UserInterface module moves it into each player's `PlayerGui` and keeps it as
   `I.UserInterface.UI["Settings"]`.
2. It keeps System's `Name`, `U_Widget`, every `U_` and `S_` Id, the prefab names, and in each button
   `Background_Front`, `Background_Back` (each with a `UIGradient`) and `ButtonText`, which the module colours and writes.
3. ume modules: `Main/Settings` fills and drives it; `Main/WidgetManager` opens it; `Main_Controllers/TopBar_Controller`
   adds the gear button that toggles it.

### Input

| What | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click the X | Tap | B / Circle | `Utils_ButtonKey` and `Interact_Button` on `CloseButton` |
| Flip a setting | Click its switch (`S_Switch`) | Tap | None yet | ume's Settings module (`I.Interact.OnPress`) |
| Step a volume | Click a chevron (`S_Left`, `S_Right`) | Tap | None yet | ume's Settings module (`I.Interact.OnPress`) |
| Scroll | Mouse wheel or drag | Swipe | None yet | `U_List` (a ScrollingFrame) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Rest | The panel (`Bg_Bottom`), the header (`Bg_Top`) | Fill `Color3.fromRGB(25, 25, 35)`, `UICorner` 22 px; a 2 px outer `UIStroke` in the fill's colour and a 3 px inner one (`UIStroke_Inner`) `Color3.fromRGB(130, 130, 130)`; `TitleText` SETTINGS; the close's `Main` `Color3.fromRGB(255, 77, 77)` and `Stroke` `Color3.fromRGB(230, 64, 64)` |
| Rest | `PREFAB \| Setting`, `PREFAB \| Stepper` | Dark rows (a `UIGradient` from `Color3.fromRGB(42, 42, 42)` to `Color3.fromRGB(13, 13, 13)` at 0.4) outlined 3 px at 0.5 in the group's colour, with a `Tint` of that colour fading down (0.78, its gradient 0.2 to 0.9) |
| On, off | `S_Switch` | `System/_Primitives_ButtonsColors`' Accept (`Color3.fromRGB(50, 195, 24)` to `Color3.fromRGB(154, 255, 23)`) with On; Cancel (`Color3.fromRGB(186, 0, 0)` to `Color3.fromRGB(255, 62, 62)`) with Off. Pressable either way |
| Can step, at the end | `S_Left`, `S_Right` | Blue (`Color3.fromRGB(0, 195, 255)` to `Color3.fromRGB(0, 251, 255)`); Gray (`Color3.fromRGB(130, 143, 162)` to `Color3.fromRGB(205, 220, 252)`) and not `Active` at the end the volume has reached |
| Hover, press | Every button (`Utils_ButtonScale`, `Utils_ButtonSound`) | Scale 1.04, 0.95 (the close 1.04, 0.92, `Bouncy`); `Button_Hover` and `Button_Click` play. The buttons' text boxes are their design size tall with a `MaxTextSize` of 100, so the text follows the scale |
| Screen size | `S_ScreenScale` | Screen height / 1080; ×1.3 on Mobile screens shorter than 500 px. Strokes inside it carry no `Utils_UIStroke`, since the UIScale already scales them |
