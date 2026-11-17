# LevelPlate

**The lobby's level plate** at the top centre of the screen: the player's level in a diamond painted in their prestige
frame's colours, **LEVEL n**, **into / for XP**, a gold bar, and **Next unlock: … at level n**. Over the lobby, the
**XP replay** after a match: the lobby dims, the plate grows in the middle, the match's XP lines pop in under it, and a
level-up shows **LEVEL UP!** in gold over it and what the level opened on a card under the lines. The owner asked for
it on 2026-11-17 ("some bar to indicate the level… when we come back to lobby we want to see the progress bar filling").

**Look.** The game's screens (the code folder's `practices.md` → Guis): Primitive nodes on the currency slots' dark
slanted plate (the Gacha frame's `Main`, `Stroke2` and `Stroke` pictures, since the owner's second look on
2026-11-17: "polish the level gui too, it needs to fit the game more"), the diamond standing on its left end as the
coin does on a currency slot. Londrina Solid Heavy Italic with scaled black outlines, white text: LEVEL in the
plate's top half, the XP written over the bar in its bottom half, the next unlock under the plate (gold-white, as the
turn timer's banner under its plate). The bar is a dark slot (13, 13, 20) with the grey 130 line and a gold to
orange fill (255, 226, 122 → 255, 138, 0), a glow (the crates' glow picture) riding its end while it fills. The
reward card is the confirmation dialog's dark panel. Laid out by screen fractions: the plate is 0.125 of the screen
wide with an aspect ratio of 2.6 (the plate's 3.61 over the top 72 %).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/LevelPlate"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `LevelPlate`: `Enabled` off, `DisplayOrder` 3, `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Replay` and `U_Plate` go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Plate` | Frame (top centre) | Moves to the middle and back during the replay |
| `U_Plate` › `S_Pop` | UIScale | Grows the plate during the replay |
| `U_Plate` › `S_Diamond` › `S_TierGradient` | UIGradient | The prestige tier's colours (`I.G_Progression.ApplyFrame`) |
| `U_Plate` › `S_LevelNum`, `S_Title`, `S_Xp`, `S_Next` | TextLabel | The level, "Level n", "into / for XP" ("Max level"), the next unlock |
| `U_Plate` › `S_Fill`, `S_Head` | Frame, ImageLabel | The bar's fill (scale X) and the glow at its end |
| `U_Replay` | Frame, hidden | The replay's layer |
| `U_Replay` › `S_Dim` | Frame | The lobby's dimming |
| `U_Replay` › `S_Lines` | Frame with a UIListLayout | Holds the XP line clones |
| `U_Replay` › `S_LevelUpScale`, `S_RewardScale` | UIScale | Pop LEVEL UP! and the reward card |
| `U_Replay` › `S_RewardText` | TextLabel | "New frame: Silver", "Unlocked: Dance emote" |
| `U_Replay` › `S_Particles` | Frame | The sparks and stars (`I.UIEmitter`) |

## Prefabs

| Prefab | What |
| --- | --- |
| `PREFAB \| XpLine` | One XP line: `S_Label` ("Victory") on the left, `S_Amount` ("+50", gold) on the right, `S_Scale` to pop it in |

## Driven by

The game's `Progression` module (its `Client.lua`) finds it as `I.UserInterface.UI["LevelPlate"]`. The Lobby module turns
it on with the lobby's other screens (Lobby's `LOBBY_GUIS`).

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**) over the copy in StarterGui. A restyled copy keeps its `Name`,
its Ids and the `PREFAB | XpLine` prefab.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Skip the replay | Click | Tap | A | Progression (`UserInputService.InputBegan`) |

### Looks

| Look | Value | Set by |
| --- | --- | --- |
| Frame colours | `FRAME_TIERS` | Progression's Settings, through `I.G_Progression.ApplyFrame` |
| Plate positions and scale | `PLATE_POSITION`, `REPLAY_POSITION`, `REPLAY_SCALE` | Progression's Settings |
| Tweens | `PLATE_TWEENINFO`, `PLATE_BACK_TWEENINFO` | Progression's Settings |
| Dimming | `REPLAY_DIM` | Progression's Settings |
