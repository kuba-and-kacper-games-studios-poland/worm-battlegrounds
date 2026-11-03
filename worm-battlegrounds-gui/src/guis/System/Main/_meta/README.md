# Main

The game's main hud: an empty screen under every other gui, where a game adds its own corners and buttons in its copy. It has no elements of its own. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/Main"` |
| Modes | Night only |
| Devices | Desktop |
| Export | An empty ScreenGui named `Main` in StarterGui: `DisplayOrder` -999, `ScreenInsets` `DeviceSafeInsets`, tagged `UserInterface_PreventHiding` so it shows from the start. Its root is a Folder, so what a game adds goes straight into the ScreenGui |

## Driven by

Nothing in ume reads it yet: `I.UserInterface.UI["Main"]` finds it, and a game fills its copy with its own hud.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): an empty ScreenGui named `Main`, tagged `UserInterface_PreventHiding`. Build the game's hud inside its copy.

### Input

None of its own.

### Looks

None of its own: a game's copy defines them, and its README lists them.
