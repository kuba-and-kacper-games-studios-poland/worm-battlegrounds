# Party

The lobby's top-left panel: up to 4 players who join matches together, with invites and **Leave party**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). At the top left, 500 wide: a slate `Tab` button ("Party 2/4", a chevron) over a `Panel` box as tall as its members and buttons, so it grows with the party. The tab shows selected (the kit's blue, the chevron turned up) while the panel is open. Party's code opens it on PC and console and folds it on phones and tablets, where the open panel covers the Loadout card; a press opens or folds it. Invite players and Invite friends share a row in blue (the lobby's yellows are Play and a free crate); Leave party is red.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Party"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile at 0.85 (a full party fits under the tab on a 667 × 375 phone), Console and VR at full size (`Utils_PlatformScale`) |
| Export | A ScreenGui named `Party`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Party` | Frame | Holds the tab and the panel, auto height. Has `S_ScreenScale` |
| `U_Party` › `S_Tab` | Button (`Tab`) | Party writes the count ("Party 2/4"), swaps its skin from its `Face`'s `Kit_Image` / `Kit_SelectedImage`, turns its `Icon` 180° while open, and opens or folds the panel on a press |
| `U_Party` › `S_Panel` | Box (`Panel`) | Shown while open |
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
| `S_Members` (Slider, 1 to 4) | How many members, and the count on the tab |
| `S_Open` (Toggle) | The panel open (the tab selected) or folded |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Party`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open or fold the panel | Click the tab | Tap the tab | Select and A | Party connects `S_Tab` |
| Invite, Leave, Kick | Click | Tap | Select and A | Party connects the buttons |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Open, folded | `S_Tab` | Open: the `Tab` style's selected skin (blue), `Icon` rotation 180; folded: the slate skin, rotation 0 |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
