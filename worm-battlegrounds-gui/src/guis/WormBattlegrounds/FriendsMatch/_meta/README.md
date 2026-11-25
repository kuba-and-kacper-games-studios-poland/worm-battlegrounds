# FriendsMatch

**PLAY WITH FRIENDS**: the window the lobby board's gear tile opens (2026-11-25, the owner: Local and Custom out of the
lobby, "one small square button with game settings gear" that opens "a gui where we can select local or custom"). It
asks "How do you want to play?" and offers **LOCAL** (friends on this screen) and **CUSTOM** (a room friends are
invited into), each opening its own setup.

**Look.** The custom lobby's window (`CustomLobby`'s create panel: its slanted dark panel pictures, header text and red
✕), in the middle of the screen at the panel's aspect ratio (1.1469). Under the title a grey line, "How do you want to
play?". LOCAL and CUSTOM are two big buttons, each the lobby's old LOCAL button drawn large (its fill, the eight ink
copies of its outline, its mask and inner line; aspect 2.543): LOCAL light blue (112, 192, 255), CUSTOM purple (176,
120, 255, the modes' colour), each with its `art/ui_glyphs` glyph on the left (`local`, `custom`), its name in the title
weight and one line under it ("Friends on this screen, taking turns", "Make a room: map, bots, then invite friends").
Like the custom lobby and the setup, it opens with the lobby's guis hidden and a darker dim (`WidgetManager_Dim` 0.3).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/FriendsMatch"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and aspect-ratio constraints, no `S_ScreenScale` |
| Export | A ScreenGui named `FriendsMatch`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (full screen, WidgetManager's shape: `Content` holding `U_Choose`), its `WidgetManager_Dim` attribute 0.3 |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Choose` | Frame (the panel, centred) | Nothing: its look |
| `U_Choose` › `S_Close` | ImageButton (the red ✕) | Closes the window (its tags: WidgetManager `CloseCurrent`, the pad's B) |
| `U_Choose` › `S_Local` | ImageButton (light blue) | LOCAL: MatchBoard's Board opens the setup in its local form; refused in a party ("Local play is for friends on this screen: leave your party first.") |
| `U_Choose` › `S_Custom` | ImageButton (purple) | CUSTOM: opens `CustomLobby` (its tags: WidgetManager `Toggle`). For a party member MatchBoard greys it out and its `Name1` reads "Host picks" (its `Interact_Function` set to `""`), until they're in their leader's lobby: then "Party lobby", and it opens it |

Each button's `Name1` is its title (code writes CUSTOM's), `Line` the line under it and `Icon` its glyph.

## Driven by

The game's `MatchBoard` module (`Board` handler): LOCAL, and CUSTOM's text and locked look. WidgetManager opens and
closes it (the board's `S_Friends`, its ✕), dimming the screen to its `WidgetManager_Dim`. The `Lobby` module hides the
lobby's guis while it's open (`FULL_SCREEN_WIDGETS`).

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `FriendsMatch`, `Enabled` off.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Local play | Click LOCAL | Tap | The cursor and A | MatchBoard's Board (`I.Interact.OnPress`) |
| Custom lobby | Click CUSTOM | Tap | The cursor and A | `S_Custom` tags (`Interact_Button` → WidgetManager `Toggle`) |
| Close | Click ✕ | Tap | B | `S_Close` tags (`CloseCurrent`, `Utils_ButtonKey` ButtonB) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Rest | `S_Local`, `S_Custom` | `Background` › `Main` `ImageColor3` (112, 192, 255), (176, 120, 255); `Stroke` (190, 225, 255), (222, 200, 255) |
| Hover, press | Both | `Utils_ButtonScale`: hover ×1.03, press ×0.95 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Locked (a party member: their leader picks) | `S_Custom` | MatchBoard's `LOCKED_MAIN_COLOR`, `LOCKED_STROKE_COLOR`, `LOCKED_TEXT_COLOR`; hover and press scales 1 (`Look_*` attributes keep the design's look) |
