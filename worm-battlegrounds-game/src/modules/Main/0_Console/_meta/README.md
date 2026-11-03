# Console

Every gamepad control of the game, in one place. It binds the gamepad buttons other modules are driven by: for BackpackPlus the bumpers equip the previous or next toolbar Tool, D-pad up opens the backpack view and B (Circle on PlayStation) closes it, and while it is open D-pad up and down select the category above or below (`I.BackpackPlus.CycleCategory`); while it is closed D-pad down unequips the equipped Tool. Gui buttons with a key of their own (`Utils_ButtonKey`, such as WidgetManager's A, X and B) aren't bound here: Interact presses them, at a higher priority than these binds, so B closes an open widget before the backpack. It also draws the gamepad hints in the game's guis: every gui element tagged `Console_Hint` shows only while the player is on Console, with its gamepad icons swapped to the player's pad, Xbox or PlayStation. The `0_` prefix loads it before the other Main modules; its binds and hints start in `Start`, once they have assigned `I`.

| | |
| --- | --- |
| Folder | `src/modules/Main/0_Console` |
| Runs on | Client |
| Exposes | `I.Console` (client) |
| Uses | `I.BackpackPlus`, `I.Platform`, `I.Topic`, `I.S.ContextActionService`, `I.S.CollectionService`, `I.S.UserInputService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The gamepad binds, the `Console_Hint` hints and their icons, `I.Console` |
| `Settings.lua` | The buttons each bind uses, the hint tag, and both pads' gamepad icons |

## API

### Client: `I.Console`

| Function | Returns | What it does |
| --- | --- | --- |
| `RefreshHints()` | | Shows every `Console_Hint` element on Console and hides it elsewhere, with its icons for the player's pad. It runs on its own when a hint is added, the platform changes or another kind of pad is used |
| `GetIcon(keyCode: Enum.KeyCode, style: string?)` | `string?` | The button's icon for the player's pad, in an icon style of `GAMEPAD_ICONS` (`Color`, `White`, `Bold`, `BoldWhite`, `ColorThick`, `WhiteBorder`; `Color` by default) |
| `IsPlayStationPad()` | `boolean` | Whether the player's pad is a PlayStation one (Roblox then names `ButtonA` `ButtonCross`) |

## Usage

```lua
-- Client: a gamepad icon for a gui built at runtime
icon.Image = I.Console.GetIcon(Enum.KeyCode.ButtonX)
```

## Network

The module uses no remotes and no Topics of its own: everything it does is on the client.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `BACKPACK_PREVIOUS` | `Enum.KeyCode.ButtonL1` | Equips the Tool on the previous occupied BackpackPlus toolbar slot (`I.BackpackPlus.CycleToolbar(-1)`) |
| `BACKPACK_NEXT` | `Enum.KeyCode.ButtonR1` | Equips the Tool on the next one (`CycleToolbar(1)`) |
| `BACKPACK_OPEN` | `Enum.KeyCode.DPadUp` | Opens the backpack view while it is closed and not locked; passes the input on otherwise. TopBar_Controller gives the top bar's backpack button this key, which takes it first while the top bar shows (and toggles the backpack) |
| `BACKPACK_CLOSE` | `Enum.KeyCode.ButtonB` | Closes the backpack view while it is open; passes the input on otherwise |
| `BACKPACK_CATEGORY_PREVIOUS`, `BACKPACK_CATEGORY_NEXT` | `Enum.KeyCode.DPadUp`, `Enum.KeyCode.DPadDown` | While the backpack view is open, select the category above or below. Bound just above `Enum.ContextActionPriority.High`, so D-pad up moves the category instead of pressing the top bar's backpack button. The categories wrap: down from the last goes to the first, up from the first to the last |
| `BACKPACK_UNEQUIP` | `Enum.KeyCode.DPadDown` | While the backpack view is closed, unequips the equipped Tool (`I.BackpackPlus.Unequip`); passes the input on with nothing equipped |
| `HINT_HIDDEN_ATTRIBUTE` | `"Console_HintHidden"` | A hint with this attribute set to `true` stays hidden on Console too; the module shows or hides it again when the attribute changes |
| `HINT_TAG` | `"Console_Hint"` | The tag of the gui elements shown only on Console |
| `GAMEPAD_ICONS` | `Xbox` and `PlayStation`, each in `Color`, `White`, `Bold` and `BoldWhite`, with `ColorThick` (`ButtonA`, `ButtonB`, `ButtonX`) and `WhiteBorder` (`ButtonB`) | Gamepad icon images by pad, icon style and `Enum.KeyCode` name: a copy of the System theme's `Gamepad.lua` in ume-gui. Update it when that file changes |

## In the place

| Instance | What the module does with it |
| --- | --- |
| Gui elements tagged `Console_Hint` | Sets `Visible` to whether the platform is Console and the element's `Console_HintHidden` isn't `true` (modules set it on hints with nothing to show). Every image in or under the element that shows a gamepad icon of `GAMEPAD_ICONS` (UmeGui exports them with the Xbox icons) gets the same button and style on the player's pad (a hint can stack images, as the WidgetManager close button's border and B do). UmeGui's System BackpackPlus gui has six: `S_PreviousHint` and `S_NextHint` beside the toolbar, `S_CloseHint` on the backpack view, `S_CategoryUpHint` and `S_CategoryDownHint` above the first and below the last category button, and `S_UnequipHint` on every slot. Its WidgetManager guis have `S_CloseHint` in place of the close button, and `S_AcceptHint` (and `S_DeclineHint` on the confirmation) on their buttons |
| ContextActionService actions | `Console_BackpackPrevious`, `Console_BackpackNext`, `Console_BackpackOpen`, `Console_BackpackUnequip`, `Console_BackpackClose` at the default priority, and `Console_BackpackCategoryPrevious`, `Console_BackpackCategoryNext` at `Enum.ContextActionPriority.High` + 1, bound to the buttons in Settings, with no touch buttons |
