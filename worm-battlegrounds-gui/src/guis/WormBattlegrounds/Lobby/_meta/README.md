# Lobby

The lobby's own screen, under every other gui and see-through, so the Lobby module's 3D stage (the player's snail) shows behind it: the game's name at the top, the **Crates** and **Skins** buttons in the top-right corner, and the tutorial's arrow layer.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). The name is a `Hero` label in gold, a placeholder until the owner's logo exists (then a picture). Crates and Skins are square `Item` slots under the currency bar; a red `Badge` pill sits on the Crates button's top-right corner. Each group is a frame with its own `S_ScreenScale` (0.75 on Desktop, smaller on Mobile: the logo 0.4, so on a 667 × 375 phone it sits between the Party tab and the currency bar; the corner buttons 0.8, at 16.5 % down so they clear the bar).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Lobby"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR larger (`Utils_PlatformScale`) |
| Export | A ScreenGui named `Lobby`: `Enabled` off, `DisplayOrder` -1000, `ScreenInsets` `None` (edge to edge) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Logo` | Frame | The game's name, top centre. Has `S_ScreenScale` |
| `U_Menu` | Frame | The corner buttons, top right. Has `S_ScreenScale` |
| `U_OpenCrates` | Item (`Square`) | Opens `Crates` (its tags) |
| `U_OpenCrates` › `S_Badge` | Box (`Badge`, `Fixed`) | The red badge on its corner, hidden until Crates shows it |
| `U_OpenCrates` › `S_Count` | Label (`Strong`) | The badge's text: FREE, a count, or 9+ |
| `U_Skins` | Item (`Square`) | Opens `Skins` (its tags); Cosmetics writes the equipped skin's picture and name (`S_Icon`, `S_Info`) |
| `U_Pointer` | Frame | Full-screen layer for the tutorial |
| `U_Pointer` › `S_Arrow` | Picture (`Glyph`) | Tutorial shows it and moves it over the button the player should press |

## Driven by

The game's `Lobby` module turns the ScreenGui on outside matches; `Tutorial` drives `S_Arrow`; `Cosmetics` fills `U_Skins`; `Crates` fills the Crates button's badge.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Lobby`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Its frames are laid out for a 1920 × 1080 screen and sized by the game's ScreenScale module (`Lobby` is in its `GUIS` list). The logo picture replaces the `U_Logo` label once it's drawn and approved.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Crates / Skins | Click | Tap | Select and A | `U_OpenCrates`, `U_Skins` tags (`Interact_Button` → WidgetManager `Toggle`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
