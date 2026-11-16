# FreeCrate

**Free crate for joining the group**: a yellow **FREE CRATE** badge on the crates screen, with a red dot reading 1. It
opens a dialog with the Weapon crate in 3D and two steps: **1 LIKE THE GAME** ("Tap the thumbs up on the game's page",
only asked, since no game can check it) and **2 JOIN THE GROUP** (The Snail Studio) with **JOIN**, which reads
**JOINED ✓** once the player is in. Under them is **CLAIM CRATE**, grey until then and green after. The owner asked for
it on 2026-11-16.

**Look.** The game's screens, drawn as the confirmation dialog (`WidgetManager_Confirmation`, the code folder's
`practices.md` → "Dialogs in the new look stay simple"). It is one rounded dark panel (25, 25, 35) with a dark outer
line and the grey line inside it (130, 130, 130), and **FREE WEAPON CRATE** on top in white Londrina Solid (Heavy
Italic, a scaled black outline). Each step is a darker row (40, 40, 52, outlined 70, 70, 86) with a blue number
circle (64, 140, 230). The badge, JOIN and CLAIM are the crate shop's slanted button, tinted yellow, blue and green.
The close button is the game's red X. It is laid out by fractions of the screen with aspect-ratio constraints: the
dialog is 0.95, and the badge and CLAIM are 3.6.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/FreeCrate"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop, Mobile and Console: on Mobile the dialog is 90% of the screen's width and 80% of its height at most (`Utils_PlatformSize`), against 80% and 62% |
| Export | A ScreenGui named `FreeCrate`: `Enabled` off, `DisplayOrder` 2 (over the crates screen's 1), `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Button` and `U_Dialog` go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Button` | ImageButton (at the right edge, 0.975 × 0.42 of the screen) | The badge: opens the dialog |
| `U_Dialog` | Frame, hidden, centred | The dialog: shown by the badge, hidden by close, by CLAIM and when the crates screen closes |
| `U_Dialog` › `S_CrateView` | ViewportFrame | The Weapon crate's 3D model (`Assets/Crates`, its row's `Model`), still, turned a little toward the camera |
| `U_Dialog` › `S_JoinButton` | ImageButton | JOIN: prompts the player to join the group; hidden once they're in |
| `U_Dialog` › `S_Joined` | TextLabel, hidden | "JOINED ✓" in green, shown once they're in |
| `U_Dialog` › `S_ClaimButton` | ImageButton | CLAIM CRATE: opens the crate once they're in, else asks them to join first. Its `Look_*` attributes hold its lit and locked colours |
| `U_Dialog` › `S_CloseButton` | ImageButton | Hides the dialog |

## Driven by

The game's `Crates` module (its `GroupReward` handler) finds it as `I.UserInterface.UI["FreeCrate"]` (Crates'
`GROUP_GUI_NAME`). The handler turns it on while the crates screen shows and the player's free crate is unclaimed. It
wires the buttons with `I.Interact.OnPress`, prompts the join with `I.Group.PromptJoin`, and on CLAIM opens the crate
on the crates screen (`Crates_Open` paid with `"GroupReward"`).

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**) over the copy in StarterGui: a ScreenGui named `FreeCrate`,
`Enabled` off, `DisplayOrder` 2. A restyled copy keeps its `Name`, its Ids, the `Main` and `Stroke` pictures under
`S_ClaimButton` › `Background` (the code tints them), the four `Look_*` attributes on `S_ClaimButton`, and the buttons'
`Utils_ButtonKey` tags. The Crates module needs its settings `GROUP_CRATE` (`"Weapon"`), `GROUP_NAME` (`"SnailStudio"`,
566704940 in `src/global_data/Group/Groups.lua`), `GROUP_GUI_NAME` and `GROUP_JOIN_FIRST`.

### Input

| Action | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| Open the dialog | Click **FREE CRATE** | Tap | Select it and press A / Cross | Crates (`I.Interact.OnPress`) |
| Join the group | Click **JOIN** | Tap | Select it and press A / Cross | Crates |
| Claim the crate | Click **CLAIM CRATE** | Tap | A / Cross | `Utils_ButtonKey` on `S_ClaimButton`; Crates connects it |
| Close | Click **X** | Tap | B / Circle | `Utils_ButtonKey` on `S_CloseButton`; Crates connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| The badge | `U_Button` › `Background` | `Main` `Color3.fromRGB(255, 205, 50)`, `Stroke` `Color3.fromRGB(230, 165, 20)`, `Stroke2` `Color3.fromRGB(25, 25, 35)`; the `Dot` `Color3.fromRGB(235, 55, 55)` with a 2 px dark outline (`Utils_UIStroke`) |
| The panel | `Bg_Bottom` | Fill `Color3.fromRGB(25, 25, 35)`, `UICorner` `UDim.new(0.05, 0)`; a 2 px outer `UIStroke` in the fill's colour and a 3 px inner one (`UIStroke_Inner`) `Color3.fromRGB(130, 130, 130)`, both scaled with the screen (`Utils_UIStroke`) |
| JOIN | `S_JoinButton` › `Background` | `Main` `Color3.fromRGB(77, 160, 255)`, `Stroke` `Color3.fromRGB(64, 140, 230)`, `Stroke2` `Color3.fromRGB(25, 25, 35)` |
| CLAIM locked | `S_ClaimButton` › `Main`, `Stroke` | `Look_LockedMainColor` `Color3.fromRGB(110, 110, 120)`, `Look_LockedStrokeColor` `Color3.fromRGB(90, 90, 100)` (the export's colours) |
| CLAIM lit (in the group) | `S_ClaimButton` › `Main`, `Stroke` | `Look_MainColor` `Color3.fromRGB(90, 220, 110)`, `Look_StrokeColor` `Color3.fromRGB(77, 199, 97)` (the crate shop's green) |
| Joined | `S_Joined` | `TextColor3` `Color3.fromRGB(90, 220, 110)` |
| Hover, press | The buttons (`Utils_ButtonScale`, `Bouncy`) | The badge ×1.06 and ×0.92, JOIN and CLAIM ×1.04 and ×0.92, close ×1.08 and ×0.9, with `Button_Click` (`Button_Click-CloseWidget` on close) through `Utils_ButtonSound` |
