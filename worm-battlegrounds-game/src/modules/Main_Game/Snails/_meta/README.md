# Snails

The snail bodies. Each participant's snail is an invisible ball held on the arena's plane and upright, wearing a skin
model, with its state in attributes others read: health, team colour, alive or ghost. The server spawns snails, hurts,
heals and throws them, knocks them out in liquid or out of bounds, charges fall damage when they land, and turns
knocked-out snails into floating ghosts. Clients put a SnailTag over every snail (name, health number and bar in team
colour, the turn marker on the active snail with the turn's seconds for everyone but its own player) and an outline in
its team's colour around it, pop a damage number when its health drops, draw the gear a snail wears while it works (an open parachute, a
jetpack for the turn), and break a snail's shell into chips once its health drops below `SHELL_BREAK_HEALTH`. Snail state travels as
attributes on the snail model, so the module creates no remotes.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Snails` |
| Runs on | Server, Client |
| Exposes | `I.Snails` (server: bodies and health; client: lookups) |
| Uses | `I.Arena` (plane, hazards), `I.Create`, `I.Dirs.Assets` (skins), `I.G_Arsenal` (gear models), `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The entry: `I.Snails`, starting the hazard checks |
| `Client.lua` | The entry: `I.Snails` lookups, starting the tags and the gear |
| `Settings.lua` | `Snails_Settings`: health, falls, the body, ghosts, tags, gear |
| `Scripts/Server/Bodies.lua` | `Workspace.Ume.Snails`, building a snail (ball, constraints, skin, attributes), ownership, lookups |
| `Scripts/Server/Health.lua` | Damage, heal, knockback, kill credit, knockouts and ghosts, the `Snails_Died` Topic |
| `Scripts/Server/Hazards.lua` | Each frame: liquid and bounds along each snail's path since the last frame, fall tracking and fall damage |
| `Scripts/Client/Tags.lua` | SnailTag billboards (team colour, gold for VIP, the level, the health number and bar in team colour, the active snail's marker and turn timer), the `TeamOutline` Highlight, and DamagePop numbers (when the player's `DamageNumbers` setting is on), each sized with the screen by `I.ScreenScale.AddBillboard` |
| `Scripts/Client/Shell.lua` | The shell break: hides the skin's `SHELL_PART` on this screen while the snail's health is under `SHELL_BREAK_HEALTH` and throws chips in its colours when it breaks; healing back up shows it again |
| `Scripts/Client/Gear.lua` | The gear a snail wears: a copy of each `GEAR` utility's Arsenal model while its attribute is set and the snail is in play, moved onto its ball every frame |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `snails` command |
| `_meta/_types.lua` | `Snails_Participant`, who a snail belongs to; `Snails_Gear`, a `GEAR` row |

## API

### Server: `I.Snails`

| Function | Returns | What it does |
| --- | --- | --- |
| `Spawn(participant: Snails_Participant, position: Vector3)` | `Model?` | Builds the participant's snail at a position on the loaded arena's plane, server-owned, and focuses the player's streaming on it. Nil and a warning with no arena loaded or no `DEFAULT_SKIN` in `Assets.Skins` |
| `Damage(participantId, amount: number, sourceId: string?, itemId: string?)` | | Takes rounded health, never below 0, and remembers the source for kill credit. A snail at 0 stays in play: the Match module knocks it out once the shot settles |
| `Heal(participantId, amount: number)` | | Gives rounded health, never above `MaxHealth` |
| `Knockback(participantId, impulse: Vector3, sourceId: string?, itemId: string?)` | | Applies an impulse and remembers the source. The server must own the snail (SnailControl takes it back from its player first) |
| `Kill(participantId, cause: string, sourceId: string?)` | | Knocks the snail out: a see-through ghost in the `Ghost` group that floats up, then `Snails_Died` |
| `SetOwner(participantId, player: Player?)` | | Gives the snail's physics to a player's client, or back to the server with nil |
| `Clear()` | | Removes every snail |
| `Get(participantId)` | `Model?` | The participant's snail |
| `GetAll()` | `{ Model }` | Every snail, ghosts included |
| `GetAlive()` | `{ Model }` | Every snail still in play |

### Client: `I.Snails`

| Function | Returns | What it does |
| --- | --- | --- |
| `Get(participantId)` | `Model?` | The participant's snail |
| `GetMine()` | `Model?` | The local player's snail (`P_<UserId>`) |

## Usage

```lua
-- Server: a player's snail on the drop zone
--- @type Snails_Participant
local participant = { Id = `P_{player.UserId}`, UserId = player.UserId, DisplayName = player.DisplayName, Team = 1, Color = teamColor, IsBot = false }
I.Snails.Spawn(participant, dropPosition)
I.Snails.Damage(participant.Id, 45, attackerId, "Bazooka")
```

## Network

No remotes: clients read the snail models' attributes.

### Server

**Topics**

- `Snails_Died @ (participantId: string, cause: string, killerId: string?, itemId: string?)`: a snail was knocked out.
  `cause` is `"Water"`, `"Lava"`, `"Bounds"` or the caller's; the killer falls back on whoever last hurt or pushed it.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MAX_HEALTH` | `200` | Starting health, and the most healing reaches |
| `SAFE_FALL_HEIGHT` | `10` | A fall costs 1 health per stud above this |
| `MAX_FALL_DAMAGE` | `40` | The most one fall costs |
| `ROOT_SIZE` | `2.6` | The ball's size, in studs across |
| `ROOT_FRICTION` | `1` | The ball's grip: snails hold still on slopes up to about 45° |
| `DEFAULT_SKIN` | `"Classic"` | The model in `Assets.Skins` every snail wears until Cosmetics picks one |
| `GROUND_GAP` | `0.4` | How far below the ball the ground may be for a snail to stand on it |
| `GHOST_RISE`, `GHOST_RISE_TIME`, `GHOST_TRANSPARENCY` | `4`, `1.5`, `0.6` | A ghost floats this many studs up over this many seconds, this see-through |
| `SHELL_BREAK_HEALTH` | `50` | A snail's shell breaks below this health, and shows again once healing brings it back up |
| `SHELL_PART` | `"Shell"` | The skin part that breaks; a skin without one never breaks |
| `SHELL_CHIPS`, `SHELL_CHIP_SIZE`, `SHELL_CHIP_SPEED`, `SHELL_CHIP_LIFETIME` | `12`, 0.3–0.6, 14–26, `1.5` | The break: how many chips, their size in studs, their speed in studs per second, and how long before they fade |
| `SHELL_CHIP_COLORS` | `(232, 210, 160)`, `(214, 180, 120)`, `(176, 108, 52)` | The chips' colours, the shell's tans and brown |
| `TAG_OFFSET` | `2.4` | How far above a snail's center its tag's bottom sits |
| `VIP_NAME_COLOR` | `(255, 206, 46)` | A VIP player's name colour on their snail's tag |

| `POP_RISE`, `POP_TWEENINFO` | `3`, 1 s quad out | How far a damage number rises while it fades, and how |
| `GEAR` | Parachute (`Parachute`, 4.9 up), Jetpack (`JetpackFuel`, 2.4 behind, 0.4 up, on the back of the shell) | The utilities a snail wears: the snail attribute that shows each, and its RootPart's offset in the ball's space (−Z ahead) |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.Snails` | Created at start. One Model per participant, named by its id (`P_<UserId>`, `B_<n>`), streamed to every client |
| `<snail>.Root` | The invisible ball (`Snail` collision group): `Center` attachment, `Plane` (PlaneConstraint), `Upright` (AlignOrientation, facing ±X), `Walk` (LinearVelocity along X, off; SnailControl's owner client turns it on), the client's SnailTag |
| `<snail>.TeamOutline` | A Highlight each client adds: the snail's outline in its team's colour (`Color`), off while it's a ghost |
| `<snail>.Skin` | The skin's parts, welded to the ball, massless and non-colliding |
| `<snail>.Parachute`, `<snail>.Jetpack` | Client only: the worn gear, copies of the Arsenal models, anchored and moved onto the ball every frame |
| `<snail>.ShellChip` | Client only: the chips of a shell that just broke, in Arena's `Chip` collision group, gone once they fade. The shell itself stays in the skin, hidden by its `LocalTransparencyModifier` |
| `<snail>` attributes | `ParticipantId`, `UserId`, `DisplayName`, `Team`, `Color`, `IsBot`, `Health`, `MaxHealth`, `Alive`, `Ghost`, `Facing` (−1 or 1), `Shiny`, `Vip`, `Level` (0 for bots, hidden on the tag), `DamageTaken` (damage multiplier, 1 but for the tutorial bot); SnailControl adds `CanMove` and `Stamina`; Match sets `Active` (the tag's turn marker) |
| `Assets.Skins.<SkinId>` | A skin: a Model whose pivot sits at the ball's center, facing its pivot's front (−Z). `Classic` is the snail (the owner's model, 2026-11-06): `Body` and `Shell` MeshParts scaled to 0.45, 4.1 studs tall with its foot on the ball's bottom, staged under `ReplicatedStorage.Ume.Assets.PlaceLoader.Default.Skins` |
| `Assets.Snails` | The SnailTag and DamagePop billboards' holders, authored in `Workspace.Ume.ReplicatedStorage_Assets/Snails/`: a Model `PREFAB \| SnailTag` (and `PREFAB \| DamagePop`) with an invisible 1 × 1 × 1 `RootPart`, an `Attachment` under it, and the exported BillboardGui under that, named `U_SnailTag` (`U_DamagePop`). Clients clone only the billboard (`FindFirstChild("U_SnailTag", true)`) and name the copy `SnailTag` |

## Commands

`snails` (server, level 255). Each acts on the invoker's snail unless it names a participant id:

| Subcommand | Arguments |
| --- | --- |
| `damage` | `amount`, `participantId?` |
| `heal` | `amount`, `participantId?` |
| `kill` | `participantId?` |
| `push` | `x`, `y` (a speed change, in studs per second), `participantId?` |
