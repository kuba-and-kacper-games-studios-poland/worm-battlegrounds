# DropMarker

A snail's landing spot in the drop phase: a map pin in its colour, its player's picture (or the bot picture) in its
round head and their name over it, its tip on a small target on the spot: the aim crosshair's ring in its colour and
a dot (2026-11-17, the owner: "add some kind of circle or target… but make it subtle"). The player's own follows their
pointer until they place it.

**Look.** `Primitive` nodes in SnailTag's look (2026-11-17, the polish pass; before, the GUI kit's label and chevron):
the name in the heavy Bold Italic font (`rbxassetid://12187365977`) with a dark `ScaledSize` outline, a round head
(`UICorner` 0.5, a dark (20, 14, 10) 4 px `UIStroke`) over a square turned 45° for the point, both in the player's
colour, over the target. 150 × 222 at design scale, scaled with the screen like the hud. No pictures but the design's player icon in
the gui (code puts the player's headshot there).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/DropMarker"` |
| Kind | Billboard |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `DropMarker` (a template), moved into its `PREFAB \| DropMarker` holder as `U_DropMarker` (Integration → Setup) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Marker` | Frame | 150 × 222, the billboard's design size: the pin in the top 190, its tip at 190 down, the target centred there. Has `S_ScreenScale` (set with the billboard's size, below) |
| `U_Marker` › `S_Target` | Frame, 0.42 of the width, square, centred on the tip (0.5, 0.8559), under the pin | The landing target: `RingOutline` (a dark `ScaledSize` line, 0.12) under `Ring` › `S_RingLine` (0.08, set to the snail's colour) and `S_Dot` (the snail's colour, a dark 2 px outline) on the spot; `S_TargetScale` (UIScale) pops it in when placed |
| `U_Marker` › `S_Drop` | Frame, the pin (the top 190 of the 222), anchored at its bottom middle (the pin's tip) | Dropped onto its spot: its `Position` tweened from Match's `DROP_PIN_FALL` of its height above to (0.5, 0.8559) when a spot is placed or moved |
| `S_Drop` › `S_Name` | TextLabel | The player's name, in their colour |
| `S_Drop` › `S_Head`, `S_Point` | Frame | `BackgroundColor3` = the player's colour |
| `S_Head` › `S_Avatar` | ImageLabel (round, `Crop`) | The player's headshot (`rbxthumb://type=AvatarHeadShot`), MatchHud's `BOT_AVATAR` for a bot |

## Driven by

The game's `Match` module (`DropPicker`) clones one per participant with a spot during the drop, on an invisible part
at the spot: the player's own follows their pointer until they place it, and a pin is faded (Match's `DROP_PIN_FADE`:
its name, head, point, picture and outlines) where a snail doesn't fit or until its spot is placed.

## Integration

### Setup

Export it with the Gui tool (a BillboardGui named `DropMarker` in StarterGui), then move it into its holder in place of the old one: `Workspace.Ume.ReplicatedStorage_Assets/Match/PREFAB | DropMarker` › `RootPart` › `Attachment`, renamed `U_DropMarker` (StarterGui would draw it at 0, 0, 0 in Studio). Its module clones it onto parts; the clone's `SizeOffset` (0, `S_Drop`'s Y position − 0.5: 0.3559), so the pin's tip and the target's middle stand on the part, and `AlwaysOnTop` are set by that code, and the game's ScreenScale module sizes the clone to the screen: it sets `S_ScreenScale` to the screen's scale (height / 1080, width / 1920 on screens narrower than 16:9, ×1.3 on Mobile screens shorter than 500 px, never under 0.6 on other devices; no device scale) and the billboard's `Size` to the root's design size times it. The Gui tool previews it at 150 × 222 (`Preview`). The Gui tool's export is a BillboardGui; one exported from a script (`UmeGui.Export`) is a ScreenGui, so its `U_Marker` goes into the holder's BillboardGui (150 × 222, `LightInfluence` 0, `ZIndexBehavior` Sibling) instead.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Faded (doesn't fit, or not placed yet) | `S_Name`, `S_Head`, `S_Point`, `S_Avatar`, `S_Dot` and every `UIStroke` (the target's ring too) | Text, background, image and outline transparency `DROP_PIN_FADE` (0.6), else 0 |
| Placed (target) | `S_TargetScale` | `Scale` from Match's `DROP_TARGET_POP` (1.6) to 1, `DROP_TARGET_TWEENINFO` (0.35 s back out) |
| Placed or moved | `S_Drop` | `Position` from (0.5, 0.8559 × (1 − `DROP_PIN_FALL`)) to (0.5, 0.8559), Match's `DROP_PIN_TWEENINFO` (0.4 s bounce out) |
| Player's colour | `S_Name` (`TextColor3`), `S_Head`, `S_Point`, `S_Dot` (`BackgroundColor3`), `S_RingLine` (`Color`) | The participant's `Color`: their team's, or their own in a free-for-all |
