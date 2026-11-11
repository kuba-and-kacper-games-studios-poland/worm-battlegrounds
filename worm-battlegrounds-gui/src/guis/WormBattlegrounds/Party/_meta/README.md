# Party

The lobby's **PARTY** column at the left: a card per party member (avatar, name, level, the leader's crown, Kick),
then a **+** card per free place that opens the invite box, and the red Leave button by the title.

**Look.** Ported 1:1 from the studio's `LobbyInventory` gui (its `Left` frame, 2026-11-09) as `Primitive` nodes: its
dark slanted cards (a member's outlined orange, a + card grey), pictures and fonts, laid out in screen fractions with
aspect-ratio constraints, so it scales with the screen by itself (no `S_ScreenScale`). Changed from the design: the
cards are shorter (`0.2059` of the list since the gui maker's polish, no aspect constraint on the + card), so a full party of 4 fits above
ACTIVE LOBBIES; added: the name, level, crown and Kick on a member card, and Leave (a copy of the design's red close),
with button tags (`Utils_ButtonScale`, `Utils_ButtonSound`). The gui maker reworked the member card (2026-11-11): the name and
"@username" at its right, left-aligned, and the level on a badge under the avatar.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Party"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Party`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Party` | Frame | The column (the design's `Left`) |
| `U_Party` › `S_Leave` | ImageButton (red X) | Leaves the party; shown only in a party |
| `U_Members` | Frame (vertical list) | Holds the `Member` cards, then the `Invite` cards |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Member` | `U_Members` | A Frame: `S_Avatar`, `S_Name` (with a `UITextSizeConstraint`), `S_Badges` (Frame: PlayerBadges clones its hidden `PREFAB \| Badge`, an ImageLabel with an `S_Glyph` TextLabel for Roblox's verified and Premium glyphs, once per badge and lays them out after the name, whose `UITextSizeConstraint` it lowers so the name stays on one line), `S_Level` (the level on the `LevelBadge` under the avatar; capitals by `TextCase_Upper`), `S_Username` ("@name", under the name), `S_Crown` (leader), `S_Kick` (ImageButton, the leader sees it on others). Party names it by user id; Cosmetics puts a played emote's label beside it |
| `PREFAB \| Invite` | `U_Members` | An ImageButton with a +: opens `PartyInvite` |

## Driven by

The game's `Party` module (`Client.lua`); `Cosmetics` (`Scripts/Client/Emotes.lua`) shows played emotes beside a member.

## Preview

`Preview.lua` fills the column for a leader.

| Setting | What it does |
| --- | --- |
| `S_Members` (Slider, 1 to 4) | Members (the first leads), then + cards up to 4, and Leave in a party |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Party`, `Enabled` off. The Lobby module
turns it on outside matches (and off while a full-screen widget is open). It keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Invite (open `PartyInvite`) | Click | Tap | Y (Triangle), or select and A | Party (`I.Interact.OnPress`); `PREFAB \| Invite` tags (`Utils_ButtonKey`), its `PadHint` badge (`Console_Action` `Invite`) on Console |
| Kick, Leave | Click | Tap | Select and A | Party (`I.Interact.OnPress`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | + cards, Kick, Leave | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Member | `Member` › `Background` › `Stroke` | Orange (the design's); + cards grey |
