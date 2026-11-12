# MatchBoard

The lobby's way into matches, along the bottom: **ACTIVE LOBBIES**, a scrolling row of public matches, one lobby card
per mode (map picture, mode, "3/6 players", map name, timer, **Join** or **Join teams**), and at the right the yellow
**SOLO VS BOTS** (**Play with party** in a party) with a blue **CUSTOM** over it. In the board's place it shows the
setup for a solo or party match (the bots' difficulty, what a win pays, **Start**) or, after joining a public match,
the waiting room: the countdown, the mode, map and players, **Vote to start** and **Leave**.

**Look.** The board is ported 1:1 from the studio's `LobbyInventory` gui (its `BottomLeft` and `BottomRight` frames,
2026-11-09) as `Primitive` nodes in `U_Play`, laid out in screen fractions with aspect-ratio constraints (no
`S_ScreenScale`). CUSTOM, which the design lacks, is a copy of SOLO VS BOTS, smaller and blue. The setup is the
studio's `PlaySolo` design and the waiting room its `MatchWaiting` design (2026-11-12), ported 1:1 the same way: dark
slanted panels at the bottom, the setup centred (AnchorPoint 0.5, 1 at 50 % across, 97.8 % down, the owner's pick,
2026-11-12) and the waiting room hanging from the bottom left beside Party (AnchorPoint 0, 1 at 10.5 % across). The picked difficulty wears a white outline, the rest grey. The texts code writes into the
buttons (SOLO VS BOTS, JOIN) carry `TextCase_Upper`.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchBoard"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and aspect-ratio constraints, no `S_ScreenScale` |
| Export | A ScreenGui named `MatchBoard`: `Enabled` off, `DisplayOrder` -1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Play` | Frame, full screen | The board (`BottomLeft`, `BottomRight`); hidden while the setup or the waiting room shows |
| `U_Play` › `S_Solo` | ImageButton (yellow: the gui maker's painted button, `Background` › `Main` alone, 2026-11-11) | Opens the setup; its `Name1` reads "Solo vs bots", or "Play with party" in a party, or "Waiting for host" for a party member (greyed out) |
| `U_Play` › `S_Custom` | ImageButton (blue, painted as Solo's) | Opens `CustomLobby` (its tags). For a party member it's greyed out and reads "Host picks" (its `Interact_Function` set to `""`), until they're in their leader's lobby: then "Party lobby", and it opens it |
| `U_Rows` | ScrollingFrame (horizontal) | Holds one `Row` per public match |
| `U_Setup` | Frame | The solo or party setup, hidden until Solo vs bots |
| `U_Setup` › `S_Title` | TextLabel | "Play solo" or "Play with party" |
| `U_Setup` › `S_Back` | ImageButton | Back to the board |
| `U_Setup` › `S_None`, `S_Easy`, `S_Medium`, `S_Hard` | ImageButton | The bots; the picked one is outlined white. `S_None` (No bots) shows only in a party |
| `U_Setup` › `S_RewardText` | TextLabel | "Win reward", or how a party match pays |
| `U_Setup` › `S_RewardAmount` | Frame (a coin and `S_Reward`) | What a solo win pays; hidden for a party |
| `U_Setup` › `S_Start` | ImageButton | Starts the match |
| `U_WaitingRoom` | Frame | The waiting room, hidden until the player joins |
| `U_WaitingRoom` › `S_Countdown` | TextLabel | "Match starts in 0:29" |
| `U_WaitingRoom` › `S_Info` | TextLabel | "Trios  \|  Desert  \|  5 / 8 players" |
| `U_Players` | ScrollingFrame with a UIListLayout | Holds one `PlayerName` per joined player |
| `U_WaitingRoom` › `S_Vote` | ImageButton | Votes to start; its `S_Text` shows the votes ("Vote to start 4/6") |
| `U_WaitingRoom` › `S_Leave` | ImageButton | Leaves the match, back to `U_Play` |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Row` | `U_Rows` | A lobby card (the gui maker's layout, 2026-11-11: a small map picture at the left, the texts beside it, the player count orange): `S_MapIcon` (the map's picture; the design's until the map has a `Thumbnail`), `S_Mode`, `S_Players` ("3/6 players"), `S_Map` (the map's name), `S_Timer`, `S_Join` (ImageButton; its `Name1` reads Join or Join teams, or "Host picks" greyed out for a party member) |
| `PREFAB \| PlayerName` | `U_Players` | `S_Avatar`, `S_Name`, `S_Username` |

## Driven by

The game's `MatchBoard` module (`Board` and `Setup` handlers): the cards, Solo vs bots, the setup and swapping the panels. The `Lobby` module turns the ScreenGui on outside matches (and off while a full-screen widget is open).

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview`) fills the four lobby cards, the setup's texts and example players.

| Setting | What it does |
| --- | --- |
| `S_Panel` (Dropdown) | Shows the board, the setup or the waiting room |
| `S_Party` (Toggle) | Play with party: the button and title, and No bots |
| `S_Players` (Slider, 1 to 8) | Players in the waiting room |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchBoard`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Custom | Click | Tap | X (Square), or select and A | `S_Custom` tags (`Interact_Button` → WidgetManager `Toggle`, `Utils_ButtonKey`) |
| Solo vs bots, Join, a difficulty | Click | Tap | Select and A (the selection rests on Solo vs bots; it stays in the setup and the waiting room while they show) | MatchBoard connects them; Console (`SetHome`, `Focus`) |
| Start, Vote | Click | Tap | A (Cross) | `S_Start`, `S_Vote` tags (`Utils_ButtonKey`); MatchBoard connects them |
| Back, Leave | Click | Tap | B (Circle) | `S_Back`, `S_Leave` tags (`Utils_ButtonKey`); MatchBoard connects them (with a selection, B backs out through the Console module's focus) |

On Console `S_Custom`, `S_Back`, `S_Start`, `S_Vote` and `S_Leave` show their button in a badge (`PadHint`, `Console_Action` `Custom`, `Back`, `Confirm`). Every pad hint is a `Console_Hint` the game's Console module shows only on Console; one with a `Console_Action` attribute shows that action's button from the module's scheme, for the player's pad.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Picked difficulty | `S_None` … `S_Hard` › `Background.Stroke` | `Look_SelectedStrokeColor` (white) when picked, else `Look_StrokeColor` (130, 130, 130); MatchBoard's `Setup` |
| Locked (a party member: their leader picks) | `S_Solo`, `S_Custom`, a `Row`'s `S_Join` | `Background` › `Main` and `Stroke` `ImageColor3`, and `Name1` `TextColor3`, take MatchBoard's `LOCKED_MAIN_COLOR`, `LOCKED_STROKE_COLOR`, `LOCKED_TEXT_COLOR`; hover and press scales 1. The design's look is kept on the button (`Look_MainColor`, `Look_StrokeColor`, `Look_TextColor`, `Look_HoverScale`, `Look_ClickScale`) and put back when it unlocks |
