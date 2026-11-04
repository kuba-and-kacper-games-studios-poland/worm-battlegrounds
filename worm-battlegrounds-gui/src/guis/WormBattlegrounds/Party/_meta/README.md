# Party

The lobby's top-left panel: up to 4 players who join matches together, with invites and **Leave party**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). 500 × 380 at the top left (460 × 360 on phones and tablets); Invite players and Invite friends share a row in blue (the lobby's yellows are Play and a free crate); Leave party is red.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Party"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `Party`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Party` | Box (`Panel`, `Fixed`) | The panel. Has `S_ScreenScale` |
| `U_Members` | Cells | Holds one `Member` per party member |
| `U_Invite` | Button | Invites players in this server |
| `U_InviteFriends` | Button (`Primary`) | Opens Roblox's friend invite prompt |
| `U_Leave` | Button (`Danger`, `Small`) | Leaves the party |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Member` | `U_Members` | `S_Avatar`, `S_Name`, `S_Level` ("Level 12"), `S_Crown` (leader only), `S_Kick` (leader sees it on others) |

## Driven by

The game's `Party` module; `Cosmetics` shows played emotes beside a member's name.

## Preview

`Preview.lua` fills the party; the first member leads.

| Setting | What it does |
| --- | --- |
| `S_Members` (Slider, 1 to 4) | How many members |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Party`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Invite, Leave, Kick | Click | Tap | Select and A | Party connects the buttons |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
