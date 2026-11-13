# Console

The game's gamepad: the one place every pad button is chosen. Its settings hold the scheme (`ACTIONS`: each action's
buttons, hint text and priority), and modules bind or read their pad buttons through it (`I.Console.Bind`,
`IsAction`, `IsHeld`) instead of naming `Enum.KeyCode.Button*` themselves; keyboard, mouse and touch input stay with
the modules. It draws the pad hints in the game's guis (every gui element tagged `Console_Hint` shows only on Console,
its icons swapped to the player's pad, Xbox or PlayStation, and drawn from the scheme when it names an action), and it
runs the gui selection on Console (where the selection starts, rests and goes back to, and B backing out). The `0_`
prefix loads it before the other Main modules; its hints and selection start in `Start`, once they have assigned `I`.

| | |
| --- | --- |
| Folder | `src/modules/Main/0_Console` |
| Runs on | Client |
| Exposes | `I.Console` (client) |
| Uses | `I.Platform`, `I.Topic`, `I.WidgetManager`, `I.UserInterface`, `I.Utils` (`IsGuiShown`), `ContextActionService`, `GuiService`, `UserInputService`, `CollectionService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The entry: starts the handlers, `I.Console` |
| `Scripts/Client/Binds.lua` | The scheme's actions: binding a module's callback to an action's buttons, and reading them |
| `Scripts/Client/Hints.lua` | The `Console_Hint` hints, their icons and texts, the pad's kind, button names |
| `Scripts/Client/Selection.lua` | The gui selection on Console: View, widgets, focus, home, B backing out |
| `Settings.lua` | The hint tag and style, the scheme, the selection's guis, the buttons' names, both pads' icons |
| `_meta/_types.lua` | `Console_Action` (an `ACTIONS` row), `Console_ActionCallback` |

## Scheme

Roblox reserves Start (Menu, Options) for its own menu, so the game never binds it: pausing, settings and leaving the
game are in Roblox's menu, and leaving a match is the HUD's **Leave game** (reached with View). The left stick and the
D-pad move Roblox's gui selection while there is one, A presses the selected button and B clears the selection; this
module turns that B into "back" (Selection, below). Hold RT to charge and let go to fire (the power runs while it's
held); a press that only charges never fires by itself.

### In a match

| Action | Xbox | PlayStation | `ACTIONS` row | Bound or read by |
| --- | --- | --- | --- | --- |
| Walk | Left stick, D-pad ← → | Left stick, D-pad ← → | `Move`, `WalkLeft`, `WalkRight` | SnailControl |
| Jump; hold to fly the jetpack | A | Cross | `Jump` | SnailControl |
| Aim | Right stick | Right stick | `Aim` | MatchHud (Aim), MatchCamera |
| Charge and fire | Hold RT, let go | Hold R2, let go | `Fire` | MatchHud (Aim) |
| Cancel the aim | B | Circle | `CancelAim` | MatchHud (Aim) |
| Previous, next weapon slot | LB, RB | L1, R1 | `WeaponPrevious`, `WeaponNext` | MatchHud (LoadoutBar): a weapon is picked at once, a utility only gets the cursor |
| Use the utility the cursor is on | Y | Triangle | `UseUtility` | MatchHud (LoadoutBar) |
| Emote wheel | X, then the selection; B closes it | Square | `Emotes` (Gui) | `MatchHud`'s `U_EmoteButton`; Cosmetics focuses the wheel |
| Move the camera | Hold LT, right stick | Hold L2, right stick | `CameraPan` | MatchCamera |
| Zoom in, out | D-pad ↑, ↓ (held) | D-pad ↑, ↓ | `ZoomIn`, `ZoomOut` | MatchCamera |
| Pick the landing spot, drop | Left stick, A | Left stick, Cross | `Move`, `PlaceDrop` | Match (DropPicker) |
| HUD buttons (Leave game, the music button, slots) | View, then the selection | Touchpad | `Navigate` | Console |
| Pause, settings, leave the game | Menu (Roblox's) | Options (Roblox's) | | Roblox |

The turn order is always on the screen (`MatchHud`'s turn list), so no button opens a scoreboard. MatchHud's Aim reads
`Fire`, `Aim`, `CancelAim` and `CameraPan` from `Enum.KeyCode` itself for now; moving those reads to `I.Console` is
planned with the hold-to-charge rework of its aim.

### In the lobby and menus

| Action | Xbox | PlayStation | `ACTIONS` row | Where |
| --- | --- | --- | --- | --- |
| Move the selection | Left stick, D-pad | Left stick, D-pad | | Roblox |
| Press the selected button | A | Cross | `Confirm` (Gui) | Roblox; A dialogs' A buttons |
| Back, close | B | Circle | `Back` (Gui) | Close buttons (`Utils_ButtonKey`), the setup's Back, dialogs' red answers (the confirmation's DECLINE, `PartyInvited`'s NO THANKS); with a selection, Selection backs out |
| Decline (a dialog) | X | Square | `Decline` (Gui) | Nothing since 2026-11-13, when `PartyInvited`'s NO THANKS moved to B |
| Previous, next tab | LB, RB | L1, R1 | `TabPrevious`, `TabNext` | Crates (while its widget is open) |
| Solo vs bots (Play with party) | A (the selection rests on it) | Cross | | MatchBoard (`SetHome`) |
| Custom lobby | X | Square | `Custom` (Gui) | `MatchBoard`'s `S_Custom` |
| Style (skins) | LB | L1 | `Style` (Gui) | `Lobby`'s `S_Style` |
| Crates | RB | R1 | `Crates` (Gui) | `Lobby`'s `S_Weapons` |
| Invite to the party | Y | Triangle | `Invite` (Gui) | `Party`'s invite slots |
| Loadout slots, emotes, public matches, kick, leave the party | Selection and A | Selection and Cross | | Their guis' buttons |
| Selection on or off | View | Touchpad | `Navigate` | Console |
| Scroll a list | Right stick | Right stick | | Roblox |

### Why these buttons

From what Roblox reserves and how popular Roblox and console games map pads (2026-11-10):

| Convention | Seen in | Here |
| --- | --- | --- |
| Start opens Roblox's menu and can't be bound; Select toggles gui selection unless `AutoSelectGuiEnabled` is off; L1/R1 belong to the Backpack while it's on | Roblox's input docs | Start unbound; View drives the selection the game's way; the Backpack is off, so the shoulders are the game's |
| A confirms, B goes back, shoulders switch tabs, the same on every screen | Xbox accessibility guideline 112, Fortnite, Roblox's console guidelines | A, B, LB / RB tabs everywhere |
| Triggers are the main action: hold to aim or charge, RT fires | Rivals, Fortnite, Worms Rumble, Roblox's own tool button (R2) | Hold RT to charge, let go to fire |
| A jumps; the left stick moves | Every Roblox game, Worms W.M.D. | A jumps, held flies the jetpack |
| LB / RB cycle the weapons, Y opens or uses gear | Rivals, Blox Fruits, Fortnite; Worms Rumble's Triangle | LB / RB step the loadout, Y uses a utility |
| Aim never shares an input with walking | Worms W.M.D. players' complaints about D-pad aiming | Right stick aims, left stick and D-pad ← → walk |
| Emotes on a face or D-pad button, scoreboard on another | Fortnite (D-pad ↓), Rivals (D-pad ←) | D-pad ← → walk in a match, so emotes are X and ↑ ↓ zoom |
| Every menu reachable with the D-pad, A and B; text at least 26 px at 1080p | Roblox's console guidelines, XAG 101 | Selection starts where the player is; hints use 48 px glyphs |

## API

### Client: `I.Console`

| Function | Returns | What it does |
| --- | --- | --- |
| `Bind(action: string, callback: Console_ActionCallback)` | | Binds the action's buttons (its `ACTIONS` row) with ContextActionService at its `Priority` (`DEFAULT_PRIORITY`), as `Console_<action>`. The callback gets the action's name, the input's state and the input, and returns a `ContextActionResult` (nil sinks). Binding again replaces it; a `Gui` row warns and binds nothing |
| `Unbind(action: string)` | | Unbinds it; nothing when it isn't bound |
| `Focus(container: GuiObject, onBack: (() -> ())?)` | | On Console, keeps the selection in the container while it shows and no widget is open (its A button first, else its first selectable button); B there calls `onBack`, or keeps the selection without one. One focus at a time; focusing the same container again does nothing |
| `Unfocus(container: GuiObject)` | | Ends that container's focus; the selection goes back where the player is |
| `SetHome(button: GuiObject)` | | The button the selection rests on, on Console, while no widget, focus or earlier selection wants it (the lobby's Solo vs bots) |
| `RefreshHints()` | | Shows every `Console_Hint` element on Console and hides it elsewhere, with its icons for the player's pad. It runs on its own when a hint is added, the platform changes or another kind of pad is used |
| `GetAction(action: string)` | `Console_Action?` | The action's `ACTIONS` row; warns when there is none |
| `IsAction(action: string, keyCode: Enum.KeyCode)` | `boolean` | Whether the key is one of the action's buttons, for input read from UserInputService's events |
| `IsHeld(action: string)` | `boolean` | Whether one of the action's buttons is held on the first pad |
| `GetIcon(keyCode: Enum.KeyCode, style: string?)` | `string?` | The button's icon for the player's pad, in an icon style of `GAMEPAD_ICONS` (`Color`, `White`, `Bold`, `BoldWhite`, `ColorThick`, `WhiteBorder`; `Color` by default) |
| `GetButtonName(action: string)` | `string` | What a text calls the action's first button on the player's pad (`BUTTON_NAMES`: "RT" or "R2", "the right stick") |
| `IsPlayStationPad()` | `boolean` | Whether the player's pad is a PlayStation one (Roblox then names `ButtonA` `ButtonCross`) |

### Selection

On Console (`I.Platform.Current`), the selection goes, in order: into the open widget when it has a button no key
presses (its A button first; a widget whose every button has a key, such as Results or a confirmation, is left to its
keys, so A and B do what their badges say), into the focus, back to what was selected before the first widget opened,
onto the home button. With nowhere to go it is cleared (a match). It moves when a widget opens or closes, a module
focuses or sets home, the platform changes, or the selected button goes away (a list redrawn). View (`Navigate`, with
Roblox's `AutoSelectGuiEnabled` off) clears it, or starts it there, or in the first shown gui of `NAVIGATION_GUIS`.

Roblox clears a selection on B before scripts see the press. When a selection ends while B is down or was pressed in
the last `BACK_WINDOW` seconds, the module backs out: in a widget, its B button closes it when that button is
WidgetManager's (else the B button is selected, so A presses it); in a focus, its `onBack` runs; anywhere else the
selection comes back. While there is a selection, a key other than A still presses its `Utils_ButtonKey` button
(Utils' ButtonPress), so the shortcuts work beside the selection.

## Usage

```lua
-- Client: a module binds its pad buttons through the scheme while its controls are live
I.Console.Bind("WeaponNext", Module._onStep)
I.Console.Unbind("WeaponNext")

-- Client: input read from UserInputService
if I.Console.IsAction("PlaceDrop", input.KeyCode) then Module._place() end
if I.Console.IsHeld("CameraPan") then ... end

-- Client: a pick list that holds the selection, and closes on B
I.Console.Focus(wheel, function()
	wheel.Visible = false
end)

-- Client: a gamepad icon for a gui built at runtime, and a button named in a text
icon.Image = I.Console.GetIcon(Enum.KeyCode.ButtonX)
label.Text = `Hold {I.Console.GetButtonName("Fire")} to charge`
```

A gui shows a shortcut's hint with a `Console_Hint` element whose `Console_Action` attribute names the action (an
image of any gamepad icon in `GAMEPAD_ICONS`, and any text, which shows the action's `Hint`). A button the action
presses carries the action's first button as its `Utils_GamepadKey` (Interact binds those); the module warns once when
they differ. The `WormBattlegroundsBrawl` theme's Button draws such a badge from a node's `Hint` param, its preview
icon from the node's own `Utils_ButtonKey` tag.

## Network

The module uses no remotes and no Topics of its own: everything it does is on the client.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `HINT_TAG` | `"Console_Hint"` | The tag of the gui elements shown only on Console |
| `HINT_HIDDEN_ATTRIBUTE` | `"Console_HintHidden"` | A hint with this attribute set to `true` stays hidden on Console too; the module shows or hides it again when the attribute changes |
| `HINT_ACTION_ATTRIBUTE` | `"Console_Action"` | A hint with this attribute shows that action: its first button in `HINT_STYLE` in every gamepad icon image in it, its `Hint` in every text |
| `HINT_STYLE` | `"Color"` | The icon style an action's hint shows. The game's own glyphs (`art/console_glyphs`) become a `Glyph` style of both pads once the owner approves and uploads them; then this is `"Glyph"`, the one change that swaps them in |
| `DEFAULT_PRIORITY` | `Enum.ContextActionPriority.High.Value` | The priority of an action that names none |
| `ACTIONS` | The scheme above | Each action: `Keys` (its buttons; hints show the first), `Hint` (its hint text), `Priority` (optional), `Gui` (pressed by gui buttons, so not bound here) |
| `BACK_WINDOW` | `0.25` | How long after B a selection that ends counts as B backing out |
| `NAVIGATION_GUIS` | `MatchBoard`, `Lobby`, `Loadout`, `Party`, `MatchHud`, `TopBar` | Where View starts the selection when no widget, focus or home shows, the first enabled |
| `BUTTON_NAMES` | Xbox ("A", "RT", "View"), PlayStation ("Cross", "R2", "the touchpad") | What texts call each button, by pad and `Enum.KeyCode` name |
| `GAMEPAD_ICONS` | `Xbox` and `PlayStation`, each in `Color`, `White`, `Bold` and `BoldWhite`, with `ColorThick` (`ButtonA`, `ButtonB`, `ButtonX`) and `WhiteBorder` (`ButtonB`) | Gamepad icon images by pad, icon style and `Enum.KeyCode` name: a copy of the System theme's `Gamepad.lua` in ume-gui. Update it when that file changes |

## In the place

| Instance | What the module does with it |
| --- | --- |
| Gui elements tagged `Console_Hint` | Sets `Visible` to whether the platform is Console and the element's `Console_HintHidden` isn't `true` (modules set it on hints with nothing to show). Every image in or under the element that shows a gamepad icon of `GAMEPAD_ICONS` (UmeGui exports them with the Xbox icons) gets the same button and style on the player's pad, or with `Console_Action` the action's first button in `HINT_STYLE`; with `Console_Action` every text in it shows the action's `Hint`. A hint can stack images, as the WidgetManager close button's border and B do. The game's guis have them on their pad shortcuts (MatchHud, Lobby, MatchBoard, Party, Crates, Skins, LoadoutPicker, and every theme button with a `Hint`); UmeGui's System BackpackPlus and WidgetManager guis have their own (`S_CloseHint`, `S_AcceptHint`, `S_DeclineHint`) |
| `GuiService.SelectedObject` | Set and cleared on Console as Selection says; `GuiService.AutoSelectGuiEnabled` is turned off at start |
