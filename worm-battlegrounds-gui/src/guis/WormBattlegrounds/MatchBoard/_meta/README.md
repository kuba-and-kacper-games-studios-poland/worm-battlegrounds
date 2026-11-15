# MatchBoard

The lobby's way into matches, along the bottom: **ACTIVE LOBBIES**, a scrolling row of public matches, one minimal
lobby card per mode (the mode and map over the map's big picture, **Join**), and at the right the yellow
**SOLO VS BOTS** (**Play with party** in a party) with a blue **CUSTOM** over it. In the board's place it shows the
setup for a solo or party match (the bots' difficulty, what a win pays, **Start**). A public match's waiting room is
its own gui on the match server, `MatchWaiting`.

**Look.** The board is ported 1:1 from the studio's `LobbyInventory` gui (its `BottomLeft` and `BottomRight` frames,
2026-11-09) as `Primitive` nodes in `U_Play`, laid out in screen fractions with aspect-ratio constraints (no
`S_ScreenScale`). CUSTOM, which the design lacks, is a copy of SOLO VS BOTS, smaller and blue. The setup is the
studio's `PlaySolo` design (2026-11-12), ported 1:1 the same way: a dark slanted panel centred at the bottom
(AnchorPoint 0.5, 1 at 50 % across, 97.8 % down, the owner's pick, 2026-11-12). The picked difficulty wears a white
outline, the rest grey. The lobby card is minimal (the owner, 2026-11-15): the map's picture covers the whole card
and fades out to the right before Join (a `UIGradient` on `S_MapIcon`), the mode big and the map's name under it over
the picture, with no player count; since 2026-11-16 the timer is back at the top right, over Join (the owner: "show the
timer back"), counting down to the card's next map. The texts code writes into the
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
| `U_Play` | Frame, full screen | The board (`BottomLeft`, `BottomRight`); hidden while the setup shows |
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

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Row` | `U_Rows` | A lobby card (the gui maker's card, 2026-11-11, made minimal 2026-11-15): `S_MapIcon` (the map's picture over the card's whole fill, `Background` › `Main`, stretched: the pictures are cut to the card's slanted shape, so it lines up with the frame; fading out to the right; empty for a map with no `Thumbnail`), `S_Mode` (big, over the picture), `S_Map` (the map's name under it), `Timer` › `S_Timer` (the clock icon and "0:30": the seconds until the card's next map, over Join), `S_Join` (ImageButton; its `Name1` reads Join, or "Host picks" greyed out for a party member) |

## Driven by

The game's `MatchBoard` module (`Board` and `Setup` handlers): the cards, Solo vs bots, the setup and swapping the panels. The `Lobby` module turns the ScreenGui on outside matches (and off while a full-screen widget is open).

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview`) fills the four lobby cards (modes and maps) and the setup's texts.

| Setting | What it does |
| --- | --- |
| `S_Panel` (Dropdown) | Shows the board or the setup |
| `S_Party` (Toggle) | Play with party: the button and title, and No bots |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchBoard`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Custom | Click | Tap | X (Square), or select and A | `S_Custom` tags (`Interact_Button` → WidgetManager `Toggle`, `Utils_ButtonKey`) |
| Solo vs bots, Join, a difficulty | Click | Tap | Select and A (the selection rests on Solo vs bots; it stays in the setup while it shows) | MatchBoard connects them; Console (`SetHome`, `Focus`) |
| Start | Click | Tap | A (Cross) | `S_Start` tags (`Utils_ButtonKey`); MatchBoard connects it |
| Back | Click | Tap | B (Circle) | `S_Back` tags (`Utils_ButtonKey`); MatchBoard connects it (with a selection, B backs out through the Console module's focus) |

On Console `S_Custom`, `S_Back` and `S_Start` show their button in a badge (`PadHint`, `Console_Action` `Custom`, `Back`, `Confirm`). Every pad hint is a `Console_Hint` the game's Console module shows only on Console; one with a `Console_Action` attribute shows that action's button from the module's scheme, for the player's pad.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Picked difficulty | `S_None` … `S_Hard` › `Background.Stroke` | `Look_SelectedStrokeColor` (white) when picked, else `Look_StrokeColor` (130, 130, 130); MatchBoard's `Setup` |
| Locked (a party member: their leader picks) | `S_Solo`, `S_Custom`, a `Row`'s `S_Join` | `Background` › `Main` and `Stroke` `ImageColor3`, and `Name1` `TextColor3`, take MatchBoard's `LOCKED_MAIN_COLOR`, `LOCKED_STROKE_COLOR`, `LOCKED_TEXT_COLOR`; hover and press scales 1. The design's look is kept on the button (`Look_MainColor`, `Look_StrokeColor`, `Look_TextColor`, `Look_HoverScale`, `Look_ClickScale`) and put back when it unlocks |
