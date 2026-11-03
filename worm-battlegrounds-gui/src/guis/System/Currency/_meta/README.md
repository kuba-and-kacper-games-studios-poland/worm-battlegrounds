# Currency

The layer currency orbs fly across: an empty frame over the middle of the screen that ume's Currency slots emit their orbs into. It is a `Primitive` node, a plain Roblox instance, so no theme changes it. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/Currency"` |
| Modes | Night only |
| Devices | Desktop |
| Export | A ScreenGui named `Currency` in StarterGui: `Enabled` off, `DisplayOrder` -999, `ScreenInsets` `DeviceSafeInsets`, tagged `UserInterface_PreventHiding` (the UserInterface server enables it at start) |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_OrbsContainer` | Frame | Transparent, 80% of the screen, centred; a Currency slot with `SpawnOrbs` on puts its `UIEmitter` here |

## Driven by

ume's Currency module (`src/modules/Main/2_Currency/Components/Slot.lua`) finds this gui as `I.UserInterface.UI["Currency"]` and `U_OrbsContainer` inside it, only for slots with `SpawnOrbs` on.

## Preview

`Preview.lua` (`UmeGui_Guis_System_Currency_Preview`) simulates the orbs in the Gui tool. **Simulate orbs** bursts them over `U_OrbsContainer` with the look and flight ume's Currency slot gives them (the example Coins icon, the same sizes, speeds, drag and attraction), then flies them into the mouse's position, following it while they fly. An orb that comes within 48 px of the mouse shrinks out over 0.12 s, as orbs do at their slot in game. The preview follows the mouse with a transparent frame over the whole preview (`__MouseTracker`, never exported) and its `MouseMoved`, since `UserInputService` only follows it while the 3D view has focus; until the mouse has moved over the preview, the orbs fly to the orb area's centre. It runs UmeGui's mirror of ume's `UIEmitter`.

| Setting | What it does |
| --- | --- |
| `S_Orbs` (Slider, 1 to 30) | How many orbs one simulation bursts |
| `S_Simulate` (Button) | Bursts them |

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `Currency`, tagged `UserInterface_PreventHiding`. A restyled copy keeps its `Name` and `U_OrbsContainer`.
2. ume module: `Main/2_Currency`. A currency display in the game's own hud is a `Currency_Slot` (a `TextLabel` with `Currency_Name`, optional `Currency_CustomFormat`); with `Currency_SpawnOrbs` on, a gain bursts orbs here that fly into that label. The orbs' image is the currency's `IconId` in Currency's `CURRENCIES`.
3. Sounds: `Currency_OrbCollect` in the game's sound list, played as each orb arrives.

### Input

None: the orbs only show a gain.

### Looks

| State | Element | Value |
| --- | --- | --- |
| A gain | Orbs (a `UIEmitter` in `U_OrbsContainer`) | 3 to 5 orbs (more for big gains), 7.5% to 12.5% of the area, burst outward at 420 to 620 px/s and pulled into the slot, 1.35 to 1.75 s |
| An orb arriving | The slot | A short scale boost (up to 0.5 over its size, decaying) and `Currency_OrbCollect` at 0.5 volume; the slot's number counts up |
