# MatchBoard

The lobby's way into matches, along the bottom: **PUBLIC MATCHES**, a scrolling row of public matches, one lobby card
per mode (the mode with its icon over the map's big picture, the map's name and the players seated on a band, the
timer, the orange **JOIN**), and at the right the yellow **PLAY SOLO** (**Play with party** in a party) with a square
gear tile over it (since 2026-11-25, in LOCAL's and CUSTOM's place: the owner, "one small square button with game
settings gear"), which opens **PLAY WITH FRIENDS** (`FriendsMatch`: LOCAL and CUSTOM). The setup for a solo, party or
local match is its own widget, `MatchSetup` (since 2026-11-17), and a public match's waiting room is its own gui on the
match server, `MatchWaiting`.

**Look.** Since 2026-11-24 the board is the studio's `LobbyRework` design (in Studio's `Workspace.NewGuis`), ported
1:1 as `Primitive` nodes in `U_Play` over the 2026-11-09 `LobbyInventory` port (its `BottomLeft` and `BottomRight`
frames), laid out in screen fractions with aspect-ratio constraints (no `S_ScreenScale`). Every node has an explicit
`LayoutOrder`: UmeGui renumbers the nodes that have none, which reorders a design's layers. The header reads PUBLIC
MATCHES (was ACTIVE LOBBIES). PLAY SOLO is the design's, in gold (255, 215, 110; inner line 255, 240, 201), its icon
left of its text: the game's white ink-outlined glyph `play` by default (code sets it from `MODE_ICONS`). The design's
outer outline pictures (`Stroke2`) were cut off at their edges, so its outline is its fill picture again in ink (0, 0,
0), eight copies nudged 3 design pixels each way round it under the fill (a `Stroke2` Frame of eight ImageLabels); a
stretched copy would bend the slanted shapes. Since 2026-11-25 PLAY SOLO is centred on the PUBLIC MATCHES bar, 128 px
tall on a 1080 p screen (0.62 of `BottomRight`; the owner: "make it bigger, so it is aligned with the bottom lobby
matches gui", then "its too big, make it a bit more slick" at the bar's full height): its pictures stretch to that
shape (`ScaleType` Stretch), its ink outline 4 px round it (was 3), its text up to 46 px and its icon square (`Fit`). The gear tile (`S_Friends`) is the Loadout's EMOTES tile (its dark slanted card, `Main`
drawn three times as the dark tiles are) at the right above PLAY SOLO, its bottom level with the PUBLIC MATCHES
title's (the owner: "move the settings gear logically higher"), with the top bar's settings
gear (`rbxassetid://123765846716976`) in the glyphs' look: white over eight ink copies nudged round it. The lobby card
(the owner, 2026-11-15, minimal; 2026-11-24, the design's): the map's picture covers the whole card and fades out to
the right before Join (a `UIGradient` on `S_MapIcon`), the mode big at the top left with its icon, a dark band along
the bottom left with the map's name and, since 2026-11-24, the players seated in the match a Join would put the player
in (a capacity icon and `2/4`), the timer at the top right, and JOIN in orange (255, 178, 74). The texts code writes
into the buttons (PLAY SOLO, JOIN) and the mode carry `TextCase_Upper`.

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
| `U_Play` | Frame, full screen | The board: `BottomBar`, a right-aligned row holding `BottomLeft` (PUBLIC MATCHES) and `BottomRight` (the gear tile over PLAY SOLO) a fixed gap apart, so the gap holds on screens wider than 16:9; slides away as one while the setup or the custom lobby shows |
| `U_Play` › `S_Solo` | ImageButton (gold: the design's `Background` › `Main`, `Stroke2`, `Mask`, `Stroke`) | Opens the setup (`MatchSetup`); its `Name1` reads "Play solo", or "Play with party" in a party, or "Waiting for host" for a party member (greyed out) |
| `U_Play` › `S_Friends` | ImageButton (the gear tile) | Opens `FriendsMatch` (its tags: `Interact_Button` → WidgetManager `Toggle`, the pad's X) |
| `U_Play` › `S_SoloIcon` | ImageLabel, left in `S_Solo` | The mode icon: `MODE_ICONS` Bots, or Party in a party (both the `play` glyph since 2026-11-24) |
| `U_Rows` | ScrollingFrame (horizontal) | Holds one `Row` per public match |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Row` | `U_Rows` | A lobby card (the design's `LobbyRework` card since 2026-11-24): `S_MapIcon` (the map's picture over the card's whole fill, stretched: the pictures are cut to the card's slanted shape, so it lines up with the frame; fading out to the right; empty for a map with no `Thumbnail`), `ModeIcon` › `S_ModeIcon` (the mode's icon at the top left, from `MODE_ICONS`: the `deathmatch`, `duo` and `trio` glyphs; the design's own picture in the gui is only a placeholder), `S_Mode` (big, beside it), `Map` › `S_Map` (the map's name, on the dark `Band` along the bottom left), `Map` › `Players` › `S_Players` (beside the capacity icon on the band: the players seated in the mode's filling match on every server and the match's size, "2/4", or "0/4" while none fills), `Timer` › `S_Timer` (the clock icon and "0:30": the seconds until the filling match starts, or until the card's next map), `S_Join` (orange ImageButton; its `Name1` reads Join, or "Host picks" greyed out for a party member; behind it `S_Glow`, its picture stretched 1.12 × 1.25 in pale yellow (255, 246, 190), a bright rim hidden until the Tutorial's public matches hint pulses it: 2026-11-25) |

## Driven by

The game's `MatchBoard` module (`Board` handler): the cards (from each card's `Configuration`, its `Live*` attributes the server writes every `CARD_REFRESH_SECONDS`), Play solo (LOCAL and CUSTOM are in `FriendsMatch`) and sliding the board away while the setup or the custom lobby shows. The `Lobby` module turns the ScreenGui on outside matches (and off while a full-screen widget or the weapon picker is open).

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview`) fills four lobby cards (modes and maps).

| Setting | What it does |
| --- | --- |
| `S_Party` (Toggle) | Play with party on the yellow button |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchBoard`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open PLAY WITH FRIENDS | Click the gear | Tap | X (Square), or select and A | `S_Friends` tags (`Interact_Button` → WidgetManager `Toggle`, `Utils_ButtonKey`) |
| Play solo, Join | Click | Tap | Select and A (the selection rests on Play solo) | MatchBoard connects them; Console (`SetHome`) |

On Console `S_Friends` shows its button in a badge (`PadHint`, `Console_Action` `Custom`). Every pad hint is a `Console_Hint` the game's Console module shows only on Console; one with a `Console_Action` attribute shows that action's button from the module's scheme, for the player's pad.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Rest | `S_Solo`; a `Row`'s `S_Join` | `Background` › `Main` `ImageColor3` (255, 215, 110), (255, 178, 74); `Stroke2` (eight ink copies of `Main`, 3 design px out) (0, 0, 0); `Stroke` the inner light line |
| Hover, press | Buttons | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Locked (a party member: their leader picks) | `S_Solo`, a `Row`'s `S_Join` (and `FriendsMatch`'s `S_Custom`) | `Background` › `Main` and `Stroke` `ImageColor3`, and `Name1` `TextColor3`, take MatchBoard's `LOCKED_MAIN_COLOR`, `LOCKED_STROKE_COLOR`, `LOCKED_TEXT_COLOR`; hover and press scales 1. The design's look is kept on the button (`Look_MainColor`, `Look_StrokeColor`, `Look_TextColor`, `Look_HoverScale`, `Look_ClickScale`) and put back when it unlocks |
