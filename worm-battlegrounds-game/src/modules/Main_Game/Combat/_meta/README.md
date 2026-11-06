# Combat

Shooting. The active worm's client picks an item, aims and fires; the server checks it's their turn and they can use
it, then runs the weapon's behaviour (rockets, bouncers, crawlers, homing missiles, rollers, hitscan guns, melee),
carves craters with Arena, damages and knocks back worms, and tells Match when the shot is fired and when everything
has settled. Utilities heal or change how the worm moves. Uses and cooldowns are counted per match. Every client
puts the active worm's weapon in its hands during its turn, on the camera's side, turned to its aim, and draws each
shot in flight as its weapon's model. Blasts draw a flash, a fireball, fire, sparks, smoke and flying chunks of the
ground they hit, which bounce on the terrain and lie there a moment; they shake the camera and vibrate phones and pads
by their size and how close they are to the view, and a hit on the player's own worm vibrates too.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Combat` |
| Runs on | Server, Client, Global · Match map |
| Exposes | `I.Combat` (server), `I.G_Combat` (both) |
| Uses | `I.Match`, `I.Worms`, `I.Arena`, `I.G_Arsenal`, `I.Replicator`, `I.CameraShake`, `I.Haptic` |

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
| `Client.lua` | Starts the client handlers; `I.Combat` on the client (`SetAim`, `GetMuzzle`) |
| `Scripts/Client/Effects.lua` | Blasts (flash, fireball, light, fire, sparks and smoke particles, chunks of the ground that bounce on the terrain in the `Chip` collision group, then fade), tracers with a flash where they land, the camera shake and the haptics (`Combat_BlastBig`, `Combat_BlastSmall`, `Combat_Hurt` in `src/global_data/Haptic/Preset.lua`). Placeholders until the studio's effects exist |
| `Scripts/Client/Flight.lua` | Shots in flight drawn as their weapon's model (`GetProjectileModel`) over the hidden placeholder part: rockets and missiles along their flight, thrown and rolled weapons turning with the part, the spider bomb upright facing its crawl, the Variety grenade's snails (`Projectiles/Snail`) upright with their face to the camera. Bomblets and weapons without a model keep the placeholder |
| `Scripts/Client/Held.lua` | The active worm's held weapon: a copy of its model in `Workspace.Ume.Combat`, on the camera's side, turned to the aim this screen draws (MatchHud's crosshair, at once) or else to the worm's replicated aim |
| `Settings.lua` | `Combat_Settings` |

## API

### Server: `I.Combat`

| Function | Returns | What it does |
| --- | --- | --- |
| `Fire(participantId, itemId, angle, power, target?)` | `boolean` | Fires an item for a participant (players through the remote, bots directly) |
| `UseUtility(participantId, itemId)` | `boolean` | Uses a utility |
| `ShowAim(participantId, itemId?, angle, power)` | | Shows a worm's aim to every player (`AimAngle`, `AimPower`, `AimTime`; `HeldItem` when `itemId` is given). The aim remote and bots use it |
| `Detonate(participantId)` | | Sets off a rolling Black Hole Grenade early |
| `Explode(center, radius, itemId, sourceId?, shiny?, damageMax, damageEdge, knockback)` | | A blast |
| `Hit(participantId, damage, velocityChange, itemId, sourceId?, position)` | | Damages and pushes one worm |
| `CanUse(participantId, itemId)` | `boolean` | Uses left and no cooldown |
| `GetUses(participantId, itemId)` | `number` | Uses left (−1 unlimited) |
| `IsIdle()` | `boolean` | No shot is still moving |

### Client: `I.Combat`

| Function | Returns | What it does |
| --- | --- | --- |
| `SetAim(angle?)` | | Points the held weapon along the aim this screen draws, at once (MatchHud's crosshair, every frame it draws); nil hands it back to the worm's replicated aim |
| `GetMuzzle()` | `Vector3?` | Where the held weapon's shot leaves it: its `Muzzle` attachment (Arsenal's README), nil when nothing is held |

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
- `Combat_Aim @ (player: Player, angle: number, power: number)` (unreliable): the active player's aim while they aim, shown to everyone through `ShowAim`

**Send: RemoteEvents**

- `Combat_Explosion @ (position: Vector3, radius: number, itemId: string, shiny: boolean)`: to everyone
- `Combat_Hit @ (participantId: string, damage: number, position: Vector3)`: to everyone
- `Combat_Tracer @ (itemId: string, origin: Vector3, points: { Vector3 })`: to everyone

### Client

**Receive: RemoteEvents**

- `Combat_Explosion`: drawn, shaken and felt by `Effects`
- `Combat_Hit`: a hit on the player's own worm vibrates
- `Combat_Tracer`: drawn by `Effects`

## Data

| Where | Key | What |
| --- | --- | --- |
| Replicator `Combat` | `Slots`, `Uses_<item>`, `Cooldown_<item>` | The player's items (comma-separated), uses left and turns of cooldown left |
| Worm attributes | `HeldItem`, `AimAngle`, `AimPower`, `Facing` | What other clients draw |
| Worm attribute | `AimTime` | The server time of the latest aim update (0 once the shot is fired): clients draw a worm's aim line and turn its held weapon while it keeps changing |
| Worm attribute | `DamageTaken` | Damage multiplier (the tutorial bot's 3) |
| Projectile parts | `Projectile` | Marks a part MatchCamera may follow |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `WIND_ACCEL` | `3` | Wind's push at full strength |
| `MUZZLE_GAP`, `SHOOTER_GRACE` | `0.8`, `0.25` | Where a shot starts, and how long it ignores its shooter |
| `CHARGE_SECONDS` | `1.6` | How long a held fire button takes to charge a shot from none to full power, and back down again; MatchHud and Bots read it |
| `MAX_PROJECTILE_TIME` | `12` | A shot still moving after this is removed |
| `UPWARD_BIAS`, `KNOCKBACK_EDGE` | `0.5`, `0.5` | Knockback's lift, and its share at a blast's edge |
| `BULLET_CARVE`, `BULLET_KNOCK_SHARE` | `0.75`, `0.25` | Gun bullets' crater size and knockback share |
| `BOMBLET_SPEED` | `{ 20, 40 }` | Cluster bomblets' speeds |
| `SNAIL_SPEED`, `SNAIL_BITE`, `SNAIL_LIFETIME` | `6`, `0.3`, `6` | Spider Bomb snails |
| `CONTACT_DISTANCE`, `ROLL_HOP_SPEED`, `MELEE_BOX` | `2.5`, `22`, `4` | Contact bursts, rollers, melee reach |
| `HELD_FORWARD`, `HELD_HEIGHT`, `HELD_DEPTH` | `0.8`, `-0.3`, `1.5` | Where the active worm holds its weapon, from its ball's centre: along its aim, up, and toward the camera |
| `HELD_TURN_SPEED` | `14` | How quickly the held weapon turns to a new aim |
| `PROJECTILE_COLORS`, `PROJECTILE_SIZE` | | Placeholder projectile looks (the server's parts; hidden on clients under a model) |
| `PROJECTILE_STAND_INS` | `{ Bazooka = "HomingMissile" }` | Shots drawn as another weapon's projectile model until their own exists (placeholder) |
| `BLAST_TEXTURES` | Roblox's `smoke_main`, `fire_main`, `sparkles_main` | The blast particles' pictures (placeholder) |
| `FEEL_FULL_RADIUS`, `FEEL_RANGE` | `10`, `90` | A blast this big is felt at full strength; it's felt less the farther from the middle of the view, and not past `FEEL_RANGE` studs |
| `SHAKE_MAGNITUDE`, `SHAKE_SETTLE` | `4`, `0.45` | A full-strength blast's camera shake, and how long it takes to settle |
| `HAPTIC_BIG`, `HAPTIC_SMALL` | `0.6`, `0.15` | The strengths from which a blast plays `Combat_BlastBig` or `Combat_BlastSmall` |
| `DEBRIS_MAX`, `DEBRIS_SPEED` | `16`, `{ 25, 50 }` | The most chunks of ground a blast throws, and their speed |
| `DEBRIS_SIZE`, `DEBRIS_LIFETIME` | `{ 0.3, 1 }`, `2.5` | A chunk's smallest and biggest side, in studs, and how long it lies before fading |

## In the place

Creates `Workspace.Ume.Combat` for projectiles (placeholder balls), the clients' aim dots and their blast effects (`Blast`, `BlastPuff`, `Debris`, `Tracer` parts).
