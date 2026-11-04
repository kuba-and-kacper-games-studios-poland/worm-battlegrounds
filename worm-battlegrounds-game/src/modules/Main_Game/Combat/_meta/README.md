# Combat

Shooting. The active worm's client picks an item, aims and fires; the server checks it's their turn and they can use
it, then runs the weapon's behaviour (rockets, bouncers, crawlers, homing missiles, rollers, hitscan guns, melee),
carves craters with Arena, damages and knocks back worms, and tells Match when the shot is fired and when everything
has settled. Utilities heal or change how the worm moves. Uses and cooldowns are counted per match.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Combat` |
| Runs on | Server, Client, Global · Match map |
| Exposes | `I.Combat` (server), `I.G_Combat` (both) |
| Uses | `I.Match`, `I.Worms`, `I.Arena`, `I.G_Arsenal`, `I.Replicator` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Remotes, Topics, the `I` table; starts the handlers |
| `Scripts/Server/Fire.lua` | Selecting, aiming, firing, utilities |
| `Scripts/Server/Uses.lua` | Uses and cooldowns per participant, the `Combat` Replicator folder |
| `Scripts/Server/Projectiles.lua` | Projectile parts, raycasts, lost shots |
| `Scripts/Server/Blast.lua` | Explosions: craters, damage, knockback |
| `Scripts/Server/Behaviors/*.lua` | One file per `Kind` (Rocket, Bouncer, Crawler, Homing, Roller, Hitscan, Melee) and the Spider Bomb's snails |
| `Global.lua` | Launch velocity, wind and arc prediction, shared with the aim dots and bots |
| `Client.lua` | Explosion and tracer effects (placeholders) |
| `Settings.lua` | `Combat_Settings` |

## API

### Server: `I.Combat`

| Function | Returns | What it does |
| --- | --- | --- |
| `Fire(participantId, itemId, angle, power, target?)` | `boolean` | Fires an item for a participant (players through the remote, bots directly) |
| `UseUtility(participantId, itemId)` | `boolean` | Uses a utility |
| `Detonate(participantId)` | | Sets off a rolling Black Hole Grenade early |
| `Explode(center, radius, itemId, sourceId?, shiny?, damageMax, damageEdge, knockback)` | | A blast |
| `Hit(participantId, damage, velocityChange, itemId, sourceId?, position)` | | Damages and pushes one worm |
| `CanUse(participantId, itemId)` | `boolean` | Uses left and no cooldown |
| `GetUses(participantId, itemId)` | `number` | Uses left (−1 unlimited) |
| `IsIdle()` | `boolean` | No shot is still moving |

### Global: `I.G_Combat`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetLaunchVelocity(itemId, angle, power)` | `Vector3` | The launch velocity |
| `GetWindAcceleration(itemId, wind)` | `number` | Wind's push on that item |
| `PredictArc(origin, velocity, windAcceleration, seconds, step?)` | `{ Vector3 }` | Points along the flight |

## Network

### Server

**Topics**

- `Combat_ShotFired @ (participantId: string, itemId: string)`: a shot left; Match stops the turn timer
- `Combat_ShotResolved @ (participantId: string, damage: number)`: everything from the shot settled

**Receive: RemoteEvents**

- `Combat_Select @ (player: Player, itemId: string)`
- `Combat_Fire @ (player: Player, itemId: string, angle: number, power: number, target: Vector3?)`: power 0 to 1, the
  target for homing weapons. Rate limit 2 per second.
- `Combat_UseUtility @ (player: Player, itemId: string)`
- `Combat_Detonate @ (player: Player)`
- `Combat_Aim @ (player: Player, angle: number, power: number)` (unreliable)

**Send: RemoteEvents**

- `Combat_Explosion @ (position: Vector3, radius: number, itemId: string, shiny: boolean)`: to everyone
- `Combat_Hit @ (participantId: string, damage: number, position: Vector3)`: to everyone
- `Combat_Tracer @ (itemId: string, origin: Vector3, points: { Vector3 })`: to everyone

## Data

| Where | Key | What |
| --- | --- | --- |
| Replicator `Combat` | `Slots`, `Uses_<item>`, `Cooldown_<item>` | The player's items (comma-separated), uses left and turns of cooldown left |
| Worm attributes | `HeldItem`, `AimAngle`, `AimPower`, `Facing` | What other clients draw |
| Worm attribute | `DamageTaken` | Damage multiplier (the tutorial bot's 3) |
| Projectile parts | `Projectile` | Marks a part MatchCamera may follow |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `WIND_ACCEL` | `3` | Wind's push at full strength |
| `MUZZLE_GAP`, `SHOOTER_GRACE` | `0.8`, `0.25` | Where a shot starts, and how long it ignores its shooter |
| `MAX_PROJECTILE_TIME` | `12` | A shot still moving after this is removed |
| `UPWARD_BIAS`, `KNOCKBACK_EDGE` | `0.5`, `0.5` | Knockback's lift, and its share at a blast's edge |
| `BULLET_CARVE`, `BULLET_KNOCK_SHARE` | `0.75`, `0.25` | Gun bullets' crater size and knockback share |
| `BOMBLET_SPEED` | `{ 20, 40 }` | Cluster bomblets' speeds |
| `SNAIL_SPEED`, `SNAIL_BITE`, `SNAIL_LIFETIME` | `6`, `0.3`, `6` | Spider Bomb snails |
| `CONTACT_DISTANCE`, `ROLL_HOP_SPEED`, `MELEE_BOX` | `2.5`, `22`, `4` | Contact bursts, rollers, melee reach |
| `PROJECTILE_COLORS`, `PROJECTILE_SIZE` | | Placeholder projectile looks |

## In the place

Creates `Workspace.Ume.Combat` for projectiles (placeholder balls) and the clients' aim dots.
