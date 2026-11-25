# Nameplate

The nameplate over each snail on the lobby's stage: the player's level in a small badge, then their display name over
their @username. It replaces the names on the party cards and the level plate at the top of the lobby (the owner,
2026-11-24).

**Look.** The studio's `Nameplate` design (2026-11-24), as `Primitive` nodes: a row centred in the billboard, 600 × 110
at design size (aspect 5.45). The level stands in the rank crest (2026-11-25, the owner: "make sure this emblem is the same as the new gui
emblems"), the lobby level bar's and the XP replay's: a square turned 45° in the prestige tier's colours (Lobby's
`Stage` paints `S_LevelGradient` with `I.G_Progression.ApplyFrame`) round a dark middle (52, 54, 74 to 20, 20, 30), its
dark outlines `ScaledSize` fractions of their own frames so they scale with the billboard, 0.6 of the row high; the
level's box (0.42 × 0.36) sits inside the turned middle (0.56), so three digits fit, a hair left of the middle (0.49)
since the italic digits lean right (the owner: "1 is not centered"). Before, it was the design's gold rounded square. The level is Londrina Solid Heavy Italic in white with a black outline
(ScaledSize 0.133). The names stand right of the badge, as wide as they need (`AutomaticSize` X): the display name in
Londrina Bold Italic, white, over the @username in grey (200, 200, 205), both with black outlines (0.133 and 0.15).
Every node has an explicit `LayoutOrder`.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Nameplate"` |
| Kind | Billboard |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same: it's sized in studs, in the world) |
| Export | A BillboardGui named `Nameplate` (a template), moved into its `PREFAB \| Nameplate` holder as `U_Nameplate` (Integration → Setup) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Nameplate` | Frame, the whole billboard | The row (a horizontal UIListLayout, centred) |
| `U_Nameplate` › `S_Level` | TextLabel, in the `LevelNumber` crest | The player's level (`Level` Player attribute, 1 when unset) |
| `U_Nameplate` › `S_LevelGradient` | UIGradient on the crest's rim | The level's prestige tier colours (`I.G_Progression.ApplyFrame`) |
| `U_Nameplate` › `S_Name` | TextLabel, in `Names` | The player's display name |
| `U_Nameplate` › `S_Username` | TextLabel, in `Names` | `@` and the player's user name |

## Driven by

The game's `Lobby` module (`Scripts/Client/Stage.lua`, `_label`): each client clones the billboard over every snail
it stands on the stage, and writes the level again when the player's `Level` attribute changes.

## Preview

The Gui tool previews it at 600 × 110 (`Preview`), with its sample texts ("1", "DisplayName", "@username"). It has no
`Preview.lua`.

## Integration

### Setup

Export it with the Gui tool (a BillboardGui named `Nameplate` in StarterGui), then move it into its holder in place of
the old one (or move the export's children into the holder's BillboardGui): `Workspace.Ume.ReplicatedStorage_Assets/Lobby/PREFAB | Nameplate`
› `RootPart` › `Attachment`, renamed `U_Nameplate` (Lobby's `NAMEPLATE_NAME`), its `Size` 6 × 1.1 studs (scale 6, 1.1).
StarterGui would draw it at 0, 0, 0 in Studio. A restyled copy keeps the `S_Level`, `S_Name` and `S_Username` Ids. Lobby
clones only the BillboardGui and sets the rest: its `Size` times `NAMEPLATE_SCALE`, its `Adornee` (the snail's
`PrimaryPart`) and `StudsOffsetWorldSpace` (the snail's top, measured before it holds its weapon, plus
`NAMEPLATE_GAP`), and parents it to the snail's model, so it goes with the snail. Unlike the match's billboards
(SnailTag, DropMarker), it isn't scaled with the screen: it's sized in studs, so it grows and shrinks with the stage.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Rest | `LevelNumber` › `Background` › `Main`, `Stroke`, `Stroke2` | Gold (255, 215, 110), the light line (255, 240, 201), the ink outline (0, 0, 0) |
| Rest | `S_Name`, `S_Username` | White, and grey (200, 200, 205) |
