# Worms

The worm bodies. Each participant's worm is an invisible ball held on the arena's plane and upright, wearing a skin
model, with its state in attributes others read: health, team colour, alive or ghost. The server spawns worms, hurts,
heals and throws them, knocks them out in liquid or out of bounds, charges fall damage when they land, and turns
knocked-out worms into floating ghosts. Clients put a WormTag over every worm (name in team colour, health number
and bar, the turn marker on the active worm) and pop a damage number when its health drops. Worm state travels as
attributes on the worm model, so the module creates no remotes.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Worms` |
| Runs on | Server, Client |
| Exposes | `I.Worms` (server: bodies and health; client: lookups) |
| Uses | `I.Arena` (plane, hazards), `I.Create`, `I.Dirs.Assets` (skins), `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The entry: `I.Worms`, starting the hazard checks |
| `Client.lua` | The entry: `I.Worms` lookups, starting the tags |
| `Settings.lua` | `Worms_Settings`: health, falls, the body, ghosts, tags |
| `Scripts/Server/Bodies.lua` | `Workspace.Ume.Worms`, building a worm (ball, constraints, skin, attributes), ownership, lookups; moves the WormTag and DamagePop templates out of the gui loader's folder |
| `Scripts/Server/Health.lua` | Damage, heal, knockback, kill credit, knockouts and ghosts, the `Worms_Died` Topic |
| `Scripts/Server/Hazards.lua` | Each frame: liquid and bounds along each worm's path since the last frame, fall tracking and fall damage |
| `Scripts/Client/Tags.lua` | WormTag billboards (team colour, gold for VIP, the level) and DamagePop numbers (when the player's `DamageNumbers` setting is on) |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `worms` command |
| `_meta/_types.lua` | `Worms_Participant`, who a worm belongs to |

## API

### Server: `I.Worms`

| Function | Returns | What it does |
| --- | --- | --- |
| `Spawn(participant: Worms_Participant, position: Vector3)` | `Model?` | Builds the participant's worm at a position on the loaded arena's plane, server-owned, and focuses the player's streaming on it. Nil and a warning with no arena loaded or no `DEFAULT_SKIN` in `Assets.Skins` |
| `Damage(participantId, amount: number, sourceId: string?, itemId: string?)` | | Takes rounded health, never below 0, and remembers the source for kill credit. A worm at 0 stays in play: the Match module knocks it out once the shot settles |
| `Heal(participantId, amount: number)` | | Gives rounded health, never above `MaxHealth` |
| `Knockback(participantId, impulse: Vector3, sourceId: string?, itemId: string?)` | | Applies an impulse and remembers the source. The server must own the worm (WormControl takes it back from its player first) |
| `Kill(participantId, cause: string, sourceId: string?)` | | Knocks the worm out: a see-through ghost in the `Ghost` group that floats up, then `Worms_Died` |
| `SetOwner(participantId, player: Player?)` | | Gives the worm's physics to a player's client, or back to the server with nil |
| `Clear()` | | Removes every worm |
| `Get(participantId)` | `Model?` | The participant's worm |
| `GetAll()` | `{ Model }` | Every worm, ghosts included |
| `GetAlive()` | `{ Model }` | Every worm still in play |

### Client: `I.Worms`

| Function | Returns | What it does |
| --- | --- | --- |
| `Get(participantId)` | `Model?` | The participant's worm |
| `GetMine()` | `Model?` | The local player's worm (`P_<UserId>`) |

## Usage

```lua
-- Server: a player's worm on the drop zone
--- @type Worms_Participant
local participant = { Id = `P_{player.UserId}`, UserId = player.UserId, DisplayName = player.DisplayName, Team = 1, Color = teamColor, IsBot = false }
I.Worms.Spawn(participant, dropPosition)
I.Worms.Damage(participant.Id, 45, attackerId, "Bazooka")
```

## Network

No remotes: clients read the worm models' attributes.

### Server

**Topics**

- `Worms_Died @ (participantId: string, cause: string, killerId: string?, itemId: string?)`: a worm was knocked out.
  `cause` is `"Water"`, `"Lava"`, `"Bounds"` or the caller's; the killer falls back on whoever last hurt or pushed it.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MAX_HEALTH` | `200` | Starting health, and the most healing reaches |
| `SAFE_FALL_HEIGHT` | `10` | A fall costs 1 health per stud above this |
| `MAX_FALL_DAMAGE` | `40` | The most one fall costs |
| `ROOT_SIZE` | `2.6` | The ball's size, in studs across |
| `ROOT_FRICTION` | `1` | The ball's grip: worms hold still on slopes up to about 45° |
| `DEFAULT_SKIN` | `"Classic"` | The model in `Assets.Skins` every worm wears until Cosmetics picks one |
| `GROUND_GAP` | `0.4` | How far below the ball the ground may be for a worm to stand on it |
| `GHOST_RISE`, `GHOST_RISE_TIME`, `GHOST_TRANSPARENCY` | `4`, `1.5`, `0.6` | A ghost floats this many studs up over this many seconds, this see-through |
| `TAG_OFFSET` | `1.8` | How far above a worm's center its tag's bottom sits |
| `VIP_NAME_COLOR` | `(255, 206, 46)` | A VIP player's name colour on their worm's tag |
| `POP_RISE`, `POP_TWEENINFO` | `3`, 1 s quad out | How far a damage number rises while it fades, and how |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.Worms` | Created at start. One Model per participant, named by its id (`P_<UserId>`, `B_<n>`), streamed to every client |
| `<worm>.Root` | The invisible ball (`Worm` collision group): `Center` attachment, `Plane` (PlaneConstraint), `Upright` (AlignOrientation, facing ±X), `Walk` (LinearVelocity along X, off; WormControl's owner client turns it on), the client's WormTag |
| `<worm>.Skin` | The skin's parts, welded to the ball, massless and non-colliding |
| `<worm>` attributes | `ParticipantId`, `UserId`, `DisplayName`, `Team`, `Color`, `IsBot`, `Health`, `MaxHealth`, `Alive`, `Ghost`, `Facing` (−1 or 1), `Shiny`, `Vip`, `Level` (0 for bots, hidden on the tag), `DamageTaken` (damage multiplier, 1 but for the tutorial bot); WormControl adds `CanMove` and `Stamina`; Match sets `Active` (the tag's turn marker) |
| `Assets.Skins.<SkinId>` | A skin: a Model whose pivot sits at the ball's center, facing its pivot's front (−Z). The placeholder `Classic` (pink balls with eyes) is staged under `ReplicatedStorage.Ume.Assets.PlaceLoader.Default.Skins` |
| `ReplicatedStorage.Ume.Worms` | The WormTag and DamagePop billboards (exported guis), moved here at start so the gui loader leaves them alone |

## Commands

`worms` (server, level 255). Each acts on the invoker's worm unless it names a participant id:

| Subcommand | Arguments |
| --- | --- |
| `damage` | `amount`, `participantId?` |
| `heal` | `amount`, `participantId?` |
| `kill` | `participantId?` |
| `push` | `x`, `y` (a speed change, in studs per second), `participantId?` |
