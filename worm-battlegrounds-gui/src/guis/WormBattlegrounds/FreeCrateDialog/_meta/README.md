# FreeCrateDialog

**The free crate's dialog**, opened by the lobby's **FREE WEAPONS** tile and the crates screen's **FREE CRATE** badge
(`FreeCrate`). It's mostly pictures: **FREE WEAPONS** in gold, the Weapon crate turning on a lit green stage with the
crates screen's sunburst wheeling behind it and twinkles round it, two picture tiles, **LIKE** (a thumbs-up, "the
game's page"; only asked, since no game can check it) and **JOIN** (the group's own picture, "The Snail Studio"), each
ticked green once done, and **CLAIM**, grey with a lock until the player is in the group, then gold, pulsing, with a
light sweeping across it. A WidgetManager widget since 2026-11-17 (it was `FreeCrate`'s `U_Dialog`): it opens with
WidgetManager's tween and sound, the stage blurred and dimmed behind it like every lobby window, and the lobby's top row
and board hide while it shows (Lobby's `PANEL_WIDGETS`), so the FREE WEAPONS tile no longer peeks out from under it.

**Look.** The confirmation dialog's rounded dark panel (25, 25, 35) with a dark outer line and the grey line inside it
(130, 130, 130). CLAIM is the crate shop's slanted button. The close button is the game's red X, inside the panel's
top-right corner with a gap. The panel's aspect ratio is 0.86, 80% of the screen's width and 68% of its height at most
(90% and 86% on Mobile, `Utils_PlatformSize`).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/FreeCrateDialog"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop, Mobile and Console: the Mobile size above |
| Export | A ScreenGui named `FreeCrateDialog`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (full screen, WidgetManager's shape: `Content` holding `U_Dialog`) and `MouseLockFix` |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Dialog` | Frame, centred | The dialog |
| `U_Dialog` › `S_Pop` | UIScale | Pops the dialog in as it opens |
| `U_Dialog` › `S_Rays` | ImageLabel: the crates screen's sunburst picture (`rbxassetid://109967588890262`, as `Crates` › `S_Rays`), tinted (220, 255, 170), centred behind the crate | Turned by code |
| `U_Dialog` › `S_CrateView` | ViewportFrame | The Weapon crate's 3D model (`Assets/Crates`, its row's `Model`) in a WorldModel, turning and bobbing |
| `U_Dialog` › `S_Sparkles` | Frame | The twinkles (`I.UIEmitter`, the crates' star picture) |
| `U_Dialog` › `S_Like`, `S_LikeDone`, `S_LikePop` | ImageButton, Frame, UIScale | LIKE, its green tick, the thumb's pop |
| `U_Dialog` › `S_Join`, `S_JoinDone`, `S_JoinTitle`, `S_GroupIcon` | ImageButton, Frame, TextLabel, ImageLabel | JOIN (prompts the join), its tick, "JOIN" or "JOINED", the group's picture (`rbxthumb` GroupIcon) |
| `U_Dialog` › `S_ClaimButton` | ImageButton | CLAIM. Its `Look_*` attributes hold its lit (gold) and locked (grey) colours |
| `U_Dialog` › `S_ClaimText`, `S_ClaimShine`, `S_ClaimPulse` | TextLabel, UIGradient, UIScale | "🔒 CLAIM" or "CLAIM", the sweeping light, the pulse |
| `U_Dialog` › `S_CloseButton` | ImageButton | Closes the dialog |

## Driven by

The game's `Crates` module (its `GroupReward` handler) opens it with `I.WidgetManager.Open("FreeCrateDialog")` (Crates'
`GROUP_DIALOG_GUI_NAME`) and draws it on `WidgetManager_Opened`: the pop, the twinkles, the rays, crate, shines and
pulse. Opened from the crates screen's badge, it opens that screen again when it's closed. It wires the buttons with
`I.Interact.OnPress`, prompts the join with `I.Group.PromptJoin`, and on CLAIM plays `Free_Claim`, shakes the crate
and opens the crates screen in its place, where the crate opens like a bought one, paid with `"GroupReward"`. Claimed,
it closes.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**) over the copy in StarterGui. A restyled copy keeps its `Name`,
its Ids, the `Main` and `Stroke` pictures under `S_ClaimButton` › `Background` (the code tints them), the four `Look_*`
attributes on `S_ClaimButton`, and the buttons' `Utils_ButtonKey` tags. The Crates module needs its settings
`GROUP_CRATE` (`"Weapon"`), `GROUP_NAME` (`"SnailStudio"`, 566704940 in `src/global_data/Group/Groups.lua`),
`GROUP_DIALOG_GUI_NAME`, `GROUP_JOIN_FIRST` and the dialog's `GROUP_*` motion settings.

### Input

| Action | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| Like (only a tick) | Click **LIKE** | Tap | Select it and press A / Cross | Crates (`I.Interact.OnPress`) |
| Join the group | Click **JOIN** | Tap | Select it and press A / Cross | Crates |
| Claim the crate | Click **CLAIM** | Tap | A / Cross | `Utils_ButtonKey` on `S_ClaimButton`; Crates connects it |
| Close | Click **X** | Tap | B / Circle | `Utils_ButtonKey` on `S_CloseButton`; Crates connects it (`I.WidgetManager.Close`) |

### Looks

| Look | Value | Set by |
| --- | --- | --- |
| CLAIM lit / locked | gold 255, 196, 40 and 230, 150, 20 / grey 110, 110, 120 and 90, 90, 100 | `Look_*` on `S_ClaimButton` |
| Rays and crate turn | `GROUP_RAYS_SPEED` 18, `GROUP_CRATE_SPIN` 40 degrees a second | Crates' Settings |
| Shine | `GROUP_SHINE_SECONDS` 0.8, then `GROUP_SHINE_PAUSE` 1.8 | Crates' Settings |
| Twinkles | `GROUP_SPARKLE_RATE` 7 a second | Crates' Settings |
| Pop and pulse | `GROUP_POP_TWEENINFO`, `GROUP_PULSE_TWEENINFO` | Crates' Settings |
