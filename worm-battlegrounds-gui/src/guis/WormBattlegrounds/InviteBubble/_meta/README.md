# InviteBubble

The "+" bubble that floats over each free pod on the lobby's stage: pressing it opens the party invite, or the custom
lobby's window while the player is in one (the owner, 2026-11-24: "like this but even more realistic and faded and
smaller", of the party column's + card).

**Look.** A copy of the Party gui's `PREFAB | Invite` card, as `Primitive` nodes: its dark slanted card (`Main` 25,
25, 35), dark outer line (`Stroke2` 25, 25, 35) and grey inner line (`Stroke` 130, 130, 130), all three pictures 0.35
see-through, and a grey "+" (154, 154, 154, 0.2 see-through) in Londrina ExtraBold Italic in the middle. 150 × 110 at
design size, the party card's.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/InviteBubble"` |
| Kind | Billboard |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same: it's sized in studs, in the world) |
| Export | A BillboardGui named `InviteBubble` (a template), moved into its `PREFAB \| InviteBubble` holder as `U_InviteBubble` (Integration → Setup) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Invite` | ImageButton, the whole billboard (no picture of its own) | Pressed, opens `PartyInvite`, or `CustomLobby` while the player is in a custom lobby (`I.Interact.OnPress`) |

## Driven by

The game's `Lobby` module (`Scripts/Client/Stage.lua`, `_refreshInvites`): each client clones one bubble per free pod
and shows it while the player may invite (no party, its leader, or in a custom lobby) and isn't in a match.

## Preview

The Gui tool previews it at 150 × 110 (`Preview`). It has no `Preview.lua`.

## Integration

### Setup

Export it with the Gui tool (a BillboardGui named `InviteBubble` in StarterGui), then move it into its holder in place
of the old one (or move the export's children into the holder's BillboardGui): `Workspace.Ume.ReplicatedStorage_Assets/Lobby/PREFAB | InviteBubble`
› `RootPart` › `Attachment`, renamed `U_InviteBubble` (Lobby's `INVITE_NAME`), its `Size` 1.7 × 1.25 studs (scale
1.7, 1.25). A restyled copy keeps the `U_Invite` Id. Lobby clones only the BillboardGui into the player's `PlayerGui`
(a BillboardGui in the Workspace can't be pressed) and sets its `Adornee` (the pod's `Snail` marker),
`StudsOffsetWorldSpace` (`INVITE_HEIGHT` up) and `Enabled`. Like the Nameplate it's sized in studs, not scaled with the
screen. The windows it opens are Party's `INVITE_GUI_NAME` and `CUSTOM_GUI_NAME`.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Invite (open `PartyInvite`, or `CustomLobby` in a custom lobby) | Click | Tap | No button of its own (no `Utils_ButtonKey`); the + card in the Party column has Y | Lobby's Stage (`I.Interact.OnPress`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Rest | `Background` › `Main`, `Stroke2`, `Stroke`; the "+" | `ImageTransparency` 0.35; "+" (154, 154, 154), `TextTransparency` 0.2 |
| Hover, press | `U_Invite` | `Utils_ButtonScale` (`Bouncy`, hover ×1.08, press ×0.92) with `Button_Hover` and `Button_Click` (`UI`) |
