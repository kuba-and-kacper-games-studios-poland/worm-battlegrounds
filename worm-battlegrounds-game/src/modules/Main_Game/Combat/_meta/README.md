# Combat

Shooting. The active snail's client picks an item, aims and fires; the server checks it's their turn and they can use
it, then runs the weapon's behaviour (rockets, bouncers, crawlers, homing missiles, rollers, hitscan guns, melee),
carves craters with Arena, damages and knocks back snails, and tells Match when the shot is fired and when everything
has settled. Utilities heal or change how the snail moves. Uses and cooldowns are counted per match, and a weapon with a
`Cooldown` starts the match on it, so strong weapons wait that many of the player's own turns first; a utility's
cooldown starts when it's used. Every client
puts the active snail's weapon in its hands during its turn, on the camera's side, turned to its aim, and draws each
shot in flight as its weapon's model, `PROJECTILE_DRAW_SCALE` times its size.

Flying shots (rockets, bouncers, bomblets, homing missiles, the black hole grenade) move by the game's own simulation,
`Scripts/Helpers/Ballistics.lua`, the same on the server and on every client, in fixed steps on the server's clock:
gravity and wind with exact arcs, a ball that touches the terrain and snails (a spherecast per step), bounces that keep
the row's `Elasticity` into the surface and `BOUNCE_FRICTION` along it, resting and rolling (down off ledges under
gravity) when a hit is softer than `REST_SPEED`, homing, a thrown bomb's tumble (the
`Tumble` option: it leaves the hand turning with its sideways speed, `AIR_SPIN`, until the ground rolls it), and water
or lava (any liquid, a pond too): a shot flies on through them, slowed (`SINK_ENTRY_KEEP` as it splashes in, then
`SINK_GRAVITY` and `SINK_KEEP`), bursts on what it touches under them or when its fuse runs out, and is gone without a
blast after sinking `SINK_SECONDS` without touching anything. The black hole grenade (the `Roller` kind) is thrown and opens on the first thing it touches, or where it is when its owner presses again (`Detonate`, even in the air): it holds still for its row's `HoleTime` (its state sent to every client, `Projectiles.SendState`, so its model and trail stay there on every screen), throws the snails within `PullRadius` toward it (`BLACK_HOLE_PULL_SPEED`, the shooter's teammates aside), then bursts. Shots fly in
slow motion, `PROJECTILE_TIME_SCALE` of real speed along the same paths, so players can follow them; a thrown bomb's
`Fuse` counts its own slowed flight time (it bursts at the same point of its path), a placed one's (Dynamite) real
seconds. A thrown bomb with a fuse (the Grenade) bursts as soon as it comes to rest on the ground, before its fuse
runs out; a placed one waits for its fuse. A shot leaves `MUZZLE_GAP` past the snail's ball, or short of the terrain or snail in the way when that's
closer (`GetShotStart`, a raycast), so one aimed into the ground starts on it, never inside it. The server is the
authority: it launches each shot
(`Combat_Shot`), sends its state every `STATE_INTERVAL` (`Combat_ShotState`) and ends it (`Combat_ShotEnd`), and its
fuses, contact bursts, pierces and detonations decide the blast. Each client simulates its own copy from the launch,
catching up to the server's clock and easing out from the launch spot, draws it between steps at any frame rate, and,
when the server's state at a step differs from its own, goes back to that step, steps again to now and eases the jump
out. The spider bomb is thrown on the simulation too, then crawls as a server part (`Projectiles.Spawn`), walking up
and down the stud grid's 1-stud steps (`CRAWL_STEP_UP`) and climbing taller walls (never past a ceiling, never up
an overhang it fits under), and bursts if it crawls into liquid. It finds its way by terrain alone
(`Projectiles.CastTerrain`): snails are neither walls nor ground to it, so it crawls through the shooter and
teammates instead of climbing them into the air; a variety grenade's four worms dig
down through the terrain as server parts and drown in water or lava; clients glide both after their parts. A weapon with a
`Retreat` (Dynamite) is placed at the snail's feet and leaves its player moving it, with full stamina, for that many
seconds (`I.SnailControl.Retreat`) before the fuse blows it. Blasts play the studio's explosion effect for their size (`I.Vfx`) and throw chunks of the
ground they hit, which bounce on the terrain and lie there a moment; they shake the camera (a sharp jolt, `SHAKE_KICK`,
then a rumble, `SHAKE_MAGNITUDE`) and vibrate phones and pads by their size and how close they are to the view. A hit
on a snail adds its own shake by its damage (full at `HIT_SHAKE_DAMAGE`, plus `KNOCKOUT_SHAKE` on a knockout), a gunshot
kicks the view a little (`GUN_SHAKE`), and a hit on the player's own snail vibrates too. A blow of
`HITSTOP_DAMAGE` or more stops the world for a beat on every screen (`HITSTOP_SECONDS`): the particles in
`Workspace.Ume.Combat` freeze, the thrown chunks of ground hang in the air and the camera holds (`I.MatchCamera.Freeze`);
a knockout blow stops it for `HITSTOP_KNOCKOUT`, the camera punches in on the snail (`I.MatchCamera.PunchIn`) and
the knockout's ding plays (`Match_Knockout`). A
stop already running isn't stretched. A lobbed shot (`WHISTLE_KINDS`) whistles once from its part as it first comes
down faster than `WHISTLE_FALL_SPEED`, and hushes as it lands, rests, sinks, rises again or ends.

An admin can give a player an aim guide for the match they're in (the `aimbot` command, level 255): on their turn,
their screen draws, for every enemy snail, the path of the shot that lands on it with the weapon held (dots, green when
it hits, orange for the nearest miss) and the angle and power to set, as the HUD writes them. The server solves the
guide and sends it to that player alone, so the solver never reaches clients. A right click locks the aim on to the
guide nearest the mouse, eased, and a left click fires it (MatchHud's `Aim`, which reads the guides through
`GetAimGuides`).

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Combat` |
| Runs on | Server, Client, Global · Match map |
| Exposes | `I.Combat` (server), `I.G_Combat` (both) |
| Uses | `I.Match`, `I.Snails`, `I.Arena`, `I.G_Arsenal`, `I.Replicator`, `I.CameraShake`, `I.Haptic`, `I.Sound`, `I.Vfx`, `I.SnailRig`, `I.MatchCamera` (client: `Freeze`, `PunchIn`), `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Remotes, Topics, the `I` table; starts the handlers |
| `Scripts/Server/Fire.lua` | Selecting, aiming, firing, utilities. A player's fire, utility and detonate need `I.Match.IsActivePlayer` (never while a bot plays their dropped snail's turn: `I.Match.IsAutopilot`), and selecting is refused while one does. In the tutorial match a player's shot flies the aim guide's path onto the bot (`Aimbot.GetShot`), whatever their aim and charge, so it can't miss |
| `Scripts/Server/Arcs.lua` | The exact arc solver (`GetArcs`) and arc prediction (`PredictArc`), for bots and the aim guide |
| `Scripts/Server/Aimbot.lua` | The aim guide, while the server has the player's `Aimbot` attribute on: on their turn, for each enemy snail, the arc (from `GetArcs` at `AIMBOT_POWERS`, the one whose path lands nearest it), a gun's straight line, or a homing shot's launch, solved again every `AIMBOT_REFRESH` seconds once something moved and sent to that player (`Combat_AimbotGuide`); `GetShot` solves one shot at an enemy for `Fire`'s tutorial shots |
| `Scripts/Server/Uses.lua` | Uses and cooldowns per participant, the `Combat` Replicator folder |
| `Scripts/Helpers/Ballistics.lua` | `Combat_Ballistics`, the shot simulation both sides run: `New`, `Step`, `Load`, `GetState`, `GetCFrame`, `GetSnail`, `MakePart` (the placeholder ball) |
| `Scripts/Server/Projectiles.lua` | Simulated shots (`Launch`, `Fly`, `Land`, `GetOptions`, `GetStart`, `IsGone`), crawling shots' parts (`Spawn`), raycasts (`Cast`, and `CastTerrain` for crawlers), a crawler's step (`GetCrawlStep`), lost shots |
| `Scripts/Server/Blast.lua` | Explosions: tells clients first (`Combat_Explosion`, so the blast shows before the crater's cut), then craters, damage, knockback (never on the shooter's teammates; always on the shooter); each hit tells clients with whether it knocked the snail out (`Combat_Hit`) |
| `Scripts/Server/Behaviors/*.lua` | One file per `Kind` (Rocket, Bouncer, Crawler, Homing, Roller, Hitscan, Melee), and `Snail.lua`, the variety grenade's worms |
| `Global.lua` | Launch velocity and wind, shared with the aim dots, the aim guide and bots |
| `Client.lua` | Starts the client handlers; `I.Combat` on the client (`SetAim`, `GetAimGuides`) |
| `Scripts/Client/Effects.lua` | Blasts (the `BLAST_VFX` effect for the blast's size, scaled by its radius, and chunks of the ground that bounce on the terrain in the `Chip` collision group, then fade), tracers (a gun's `MUZZLE_VFX` flash where it fires, `Flash_Bullet` and `Explosion_Gun` where each bullet lands; One Punch plays `Punch` at the snail it hits), the blast sound (`Explosion_Big` from `BIG_BLAST_SOUND_RADIUS`, else `Explosion_Small`), the camera shake (`_shake`: a jolt, then a rumble; for blasts, hits on snails and gunshots) and the haptics (`Combat_BlastBig`, `Combat_BlastSmall`, `Combat_Hurt` in `src/global_data/Haptic/Preset.lua`), and the hit stop (`_onHit`, `_hitStop`: particles' `TimeScale` 0 and `Debris` chunks anchored, then put back with their speed) |
| `Scripts/Client/Flight.lua` | Shots in flight drawn as their weapon's model (`GetProjectileModel`) over the hidden placeholder part: rockets and missiles along their flight, thrown and rolled weapons turning with the part, the spider bomb upright facing its crawl, worms (`Projectiles/Worm`, unused since the variety grenade bursts into minis) head first along their tunnel, swaying (`WORM_SWAY`). Models are drawn `PROJECTILE_DRAW_SCALE` times their size (a placed Dynamite at its own; a part's `DrawScale` attribute, set by Shots, wins); models of parts the server moves glide after them (`CRAWL_GLIDE`). A bomb's bomblets with `Mini` are named after their bomb and drawn as small copies of it, with its trail; other bomblets and weapons without a model keep the placeholder. A weapon in `PROJECTILE_TRAILS` draws its trail (a Vfx effect) on an invisible carrier part that follows the shot without turning (its attachments along Z, so the ribbon keeps its width), its exhaust's emitters streaming (a missile's smoke puffs and thruster), and a rocket's carrier rides `TRAIL_TAIL` behind it; all left to fade where the shot ends |
| `Scripts/Client/Shots.lua` | Each simulated shot's copy on this client: a local placeholder part in `Workspace.Ume.Combat`, `PROJECTILE_DRAW_SCALE` (or its `PROJECTILE_DRAW_SCALES`) times its size and marked `Simulated`, its `LAUNCH_VFX` played as it starts (Flight draws on it, the camera follows it), stepped to the server's clock and corrected by its states; a bounce on the way plays `Shot_Bounce`, and a lobbed shot whistles as it comes down (`_whistle`: `Shot_Whistle` from its part, volume 0.5, kept in the shot's `Whistle` and played once, `Whistled`) |
| `Scripts/Client/Held.lua` | The active snail's held weapon: a copy of its model in `Workspace.Ume.Combat`, in the snail's hands in the weapon's pose (`I.SnailRig.Hold`), pitched to the aim this screen draws (MatchHud's crosshair, at once, and after the shot is sent its angle, until the next turn) or else to the snail's replicated aim. On its player's screen a snail standing still turns to face its aim. When the shot is away, a gun with a `HoldPose` plays its shot (`I.SnailRig.Shoot`, at least `Pellets` × `BurstInterval`) before it goes. Once a shot is away (`Match_PhaseChanged` to `Flight`) the active snail's emote ends (`I.SnailRig.StopEmote`) |
| `Scripts/Client/Aimbot.lua` | Draws the aim guide the server sends (dots and a label in `Workspace.Ume.Combat.Aimbot`) and keeps it for `GetAimGuides` |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `combat` and `aimbot` commands, and the `Combat_ItemIds` dictionary (every weapon and utility id, from both of `I.G_Arsenal.GetAll()`'s tables) |
| `Settings.lua` | `Combat_Settings` |
| `ServerSettings.lua` | `Combat_ServerSettings`: the aim guide's solver, under a server name so clients never get it |

## API

### Server: `I.Combat`

| Function | Returns | What it does |
| --- | --- | --- |
| `Fire(participantId, itemId, angle, power, target?)` | `boolean` | Fires an item for a participant (players through the remote, bots directly) |
| `UseUtility(participantId, itemId)` | `boolean` | Uses a utility |
| `ShowAim(participantId, itemId?, angle, power)` | | Shows a snail's aim to every player (`AimAngle`, `AimPower`, `AimTime`; `HeldItem` when `itemId` is given), and turns a bot's snail, or one a bot plays for a dropped player, to face it (`Facing`). The aim remote and bots use it |
| `Detonate(participantId)` | | Sets off a rolling Black Hole Grenade early |
| `Explode(center, radius, itemId, sourceId?, shiny?, damageMax, damageEdge, knockback)` | | A blast |
| `Hit(participantId, damage, velocityChange, itemId, sourceId?, position)` | `number` | Damages and pushes one snail, and tells every client (`Combat_Hit`); nothing for the shooter's teammate (same `Team`; the shooter itself always takes it); the damage when it hit a snail other than the shooter's, else 0 |
| `Give(participantId, itemId)` | `boolean` | Adds a weapon or a utility (either of `I.G_Arsenal.GetAll()`'s tables) to the participant's loadout for the rest of the match, with its full uses and no cooldown (or fills it again); `false` when they aren't in the match or the item doesn't exist. For testing |
| `Refill(participantId)` | `boolean` | Fills every item the participant has and clears its cooldowns; `false` when they aren't in the match. For testing |
| `CanUse(participantId, itemId)` | `boolean` | Uses left and no cooldown |
| `GetUses(participantId, itemId)` | `number` | Uses left (−1 unlimited) |
| `IsIdle()` | `boolean` | No shot is still moving |
| `GetArcs(origin, aimAt, itemId, windAcceleration, powers)` | `{ Vector2 }` | The angles (X) and powers (Y) whose arcs pass through `aimAt` in open air: a low and a high arc for each share of power in `powers` that reaches it, corrected for the muzzle. Bots and the aim guide use it |
| `PredictArc(origin, velocity, windAcceleration, seconds, step?)` | `{ Vector3 }` | Points along the flight |
| `GetShotStart(origin, direction, shooter)` | `Vector3` | Where a shot leaves a snail's ball (`origin`) along `direction`: `MUZZLE_GAP` past the ball, or short of the terrain or snail in the way (a raycast that ignores `shooter`), so a shot aimed into the ground starts on it. `Fire` and the bots' predictions use it |
| `GetCrawlStep(position, side, distance)` | `Vector3` | Where a crawling spider bomb goes next, one step of `distance` toward `side` (-1, 1, or 0 to stay): up a wall, along the ground or falling, by terrain alone. The spider bomb's crawl and the bots' predictions use it |

### Client: `I.Combat`

| Function | Returns | What it does |
| --- | --- | --- |
| `SetAim(angle?)` | | Points the held weapon along the aim this screen draws, at once (MatchHud's crosshair, every frame it draws); nil hands it back to the snail's replicated aim |
| `GetAimGuides()` | `{ Combat_AimGuide }` | The aim guides showing now (`Angle`, `Power`, `Target`, `Hit`, `Points`): empty unless the player's aimbot is on and it's their turn |

### Global: `I.G_Combat`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetLaunchVelocity(itemId, angle, power)` | `Vector3` | The launch velocity |
| `GetWindAcceleration(itemId, wind)` | `number` | Wind's push on that item |
| `NewBody(position, velocity, options)` | `Combat_Body` | Ballistics' `New`: a shot body, for code that simulates shots ahead (Bots) |
| `StepBody(body, world)` | `RaycastResult?` | Ballistics' `Step`: one fixed step of a body |
| `GetBodySnail(result)` | `Model?` | Ballistics' `GetSnail`: the snail a cast hit |

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
- `Combat_Hit @ (participantId: string, damage: number, position: Vector3, knockout: boolean)`: to everyone; `knockout` when the blow took the snail's `Health` from above 0 to 0
- `Combat_Tracer @ (itemId: string, origin: Vector3, points: { Vector3 })`: to everyone
- `Combat_AimbotGuide @ (guides: { Combat_AimGuide })`: to a player whose aimbot is on, when their guide changes (empty to clear it)
- `Combat_Shot @ (id: number, kind: string, name: string, start: number, position: Vector3, velocity: Vector3, options: Combat_ShotOptions)`: to everyone, when a simulated shot leaves (`start` is the server time of its step 0)
- `Combat_ShotState @ (id: number, state: Combat_BodyState)` (unreliable): to everyone, every `STATE_INTERVAL` while it flies
- `Combat_ShotEnd @ (id: number, position: Vector3)`: to everyone, when it's over

### Client

**Receive: RemoteEvents**

- `Combat_Explosion`: drawn, shaken and felt by `Effects`
- `Combat_Hit`: shakes the camera by the damage; a hit of `HITSTOP_DAMAGE` or more, or a knockout, stops the world for a beat (`Effects`); a hit on the player's own snail vibrates
- `Combat_Tracer`: drawn by `Effects`, and a gun's kicks the camera
- `Combat_AimbotGuide`: drawn by `Aimbot`
- `Combat_Shot`, `Combat_ShotState` (unreliable), `Combat_ShotEnd`: simulated, corrected and removed by `Shots`

## Data

| Where | Key | What |
| --- | --- | --- |
| Replicator `Combat` | `Slots`, `Uses_<item>`, `Cooldown_<item>` | The player's items (comma-separated), uses left and turns of cooldown left |
| Snail attributes | `HeldItem`, `AimAngle`, `AimPower`, `Facing` | What other clients draw |
| Snail attribute | `AimTime` | The server time of the latest aim update (0 once the shot is fired): clients draw a snail's aim line and turn its held weapon while it keeps changing |
| Projectile parts | `Projectile` | Marks a part MatchCamera may follow |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `WIND_ACCEL`, `WIND_ACCEL_GROWTH` | `7`, `1.5` | Wind's push per point of wind, in studs per second squared, plus the growth for every point of its strength: `wind × (7 + 1.5 × |wind|)`, so 8.5 at 1, 34.5 at 3, 96 at 6 and 220 at 10 (gravity is 196.2). At 6 a shot steeper than about 64° into the wind is swept back the other way; at 10, steeper than about 42°. `WIND_ACCEL` was raised from 3 on 2026-11-13 (the testers found the wind too weak), and the growth added the same day (the owner) |
| `MUZZLE_GAP`, `SHOOTER_GRACE` | `0.8`, `0.25` | How far past the snail's ball a shot starts (closer when something is in the way: `GetShotStart`), and how long it ignores its shooter |
| `CHARGE_SECONDS` | `1.3` | How long a held press (the mouse button, FIRE on touch, RT) takes to fill the power from none to full at one even rate, firing by itself at full (MatchHud); bots charge their shot as fast (Bots) |
| `MAX_PROJECTILE_TIME` | `20` | A shot still moving after this is removed |
| `PROJECTILE_TIME_SCALE` | `0.5` | Shots fly at this share of real speed (half speed) along the same paths: the simulation's own time per step, the spider bomb's throw slowed the same way, and a thrown bomb's fuse stretched to match |
| `PROJECTILE_STEP`, `PROJECTILE_MAX_CONTACTS`, `PROJECTILE_SKIN` | `1/60`, `4`, `0.02` | The simulation's fixed step, the most touches it resolves in one, and how far off a surface it leaves a shot |
| `BOUNCE_FRICTION`, `REST_SPEED` | `0.8`, `8` | A bounce keeps this share of the speed along the surface; a hit softer than this (into it, studs per second) rests and rolls instead |
| `AIR_SPIN`, `AIR_SPIN_MAX` | `0.35`, `30` | A thrown bomb (`Tumble`) leaves the hand turning this many radians a second of its flight per stud a second it flies sideways, at most `AIR_SPIN_MAX`, until the ground rolls it |
| `ROLL_DRAG`, `STOP_SPEED`, `REST_NORMAL_Y` | `12`, `1.5`, `0.9` | A rolling shot's slowing, and the speed it stops under on ground at least this flat |
| `SINK_ENTRY_KEEP`, `SINK_GRAVITY`, `SINK_KEEP`, `SINK_SECONDS` | `0.5`, `0.3`, `0.12`, `4` | A shot flies on through liquid: it keeps this share of its speed as it splashes in, then falls at this share of gravity and keeps this share of its speed each second of its flight while under; it bursts on what it touches there, and is gone without a blast after this many real seconds under |
| `STATE_INTERVAL`, `CORRECTION_TOLERANCE`, `HISTORY_SECONDS`, `CORRECTION_SMOOTH`, `MAX_CATCH_UP` | `0.1`, `0.15`, `2`, `0.1`, `240` | How often the server sends a shot's state, how far off a client's copy may be before it rewinds, how much it keeps to rewind to, how fast a correction eases out, and the most steps a client takes in one frame |
| `UPWARD_BIAS`, `KNOCKBACK_EDGE` | `0.5`, `0.5` | Knockback's lift, and its share at a blast's edge |
| `BULLET_CARVE`, `BULLET_KNOCK_SHARE` | `0.75`, `0.25` | Gun bullets' crater size and knockback share |
| `BOMBLET_SPEED`, `BOMBLET_GHOST` | `{ 20, 40 }`, `0.1` | Bomblets' speeds (the cluster bomb's and the variety grenade's minis), and how long they fly through everything to leave the crater |
| `SNAIL_SPEED`, `SNAIL_BITE`, `SNAIL_LIFETIME` | `6`, `0.3`, `6` | A row's `Snails` worms (no weapon has them since 2026-11-13): digging speed, how often they eat a tunnel, how long they dig |
| `CONTACT_DISTANCE`, `BLACK_HOLE_PULL_SPEED`, `MELEE_BOX` | `2.5`, `45`, `4` | Contact bursts, an open black hole's pull (studs per second at its middle, half at `PullRadius`), melee reach |
| `CRAWL_STEP_UP`, `CRAWL_STEP_DOWN`, `CRAWL_STOP` | `1.25`, `3`, `0.25` | A crawling spider bomb walks up ledges this high (taller ones it climbs), steps down this far (deeper and it falls), and waits this close across to its target |
| `HELD_TURN_SPEED` | `14` | How quickly the held weapon turns to another player's new aim |
| `PROJECTILE_COLORS`, `PROJECTILE_SIZE` | | Placeholder projectile looks (hidden under a model when the weapon has one); the simulation's ball is half the size across |
| `PROJECTILE_DRAW_SCALE` | `2` | Flying shots are drawn this many times their size (models and placeholders, a placed Dynamite aside); hits still use `PROJECTILE_SIZE` |
| `PROJECTILE_DRAW_SCALES` | `{ HomingMissile = 3.5 }` | A weapon's shot drawn at its own scale instead (the homing missile's model is thin) |
| `PROJECTILE_TRAILS` | Bazooka, HomingMissile: `Trail_Smoke`; BlackHoleGrenade: `Trail_BlackHole`; VarietyGrenade: `Trail_Variety`; ClusterBomb: `Trail_Smoke` (their mini bomblets draw the same) | The trail a weapon's shot draws behind it while it flies, by item id |
| `TRAIL_SCALE` | `1` | Widens every shot's trail |
| `TRAIL_TAIL` | `2` | A rocket's trail and exhaust start this many studs behind its middle, at its drawn tail |
| `WORM_SWAY`, `WORM_SWAY_SPEED` | `0.35`, `2` | How far (radians) and how fast (swings a second) a worm's model sways as it digs |
| `CRAWL_GLIDE` | `18` | How quickly a server-moved model (spider bomb, worm) glides after its part |
| `BLAST_VFX`, `BLAST_VFX_RADIUS` | `{ { 0, "Explosion" }, { 6, "Explosion_Fire" }, { 9, "Explosion_Big" } }`, `6.5` | The effect a blast plays: the last row whose radius it reaches; it's scaled by its radius over `BLAST_VFX_RADIUS` |
| `MUZZLE_VFX` | `{ Uzi = "Flash_SMG", Minigun = "Flash_SMG", Shotgun = "Flash_Sniper" }` | The flash a gun plays where its shot leaves |
| `LAUNCH_VFX`, `LAUNCH_VFX_SCALE` | Bazooka and HomingMissile: `Flash_Sniper`, `Explosion_Gun`; `1.5` | The blast out of a launcher where its shot starts, pointing along it (Shots, on every screen) |
| `PUNCH_VFX_SCALE` | `0.5` | One Punch's `Punch` effect's size |
| `FEEL_FULL_RADIUS`, `FEEL_RANGE` | `10`, `90` | A blast this big is felt at full strength; it's felt less the farther from the middle of the view, and not past `FEEL_RANGE` studs |
| `SHAKE_KICK`, `SHAKE_KICK_SETTLE` | `10`, `0.18` | A full-strength blow's jolt (CameraShake's Magnitude, roughness 35), and how long it takes to fade, in seconds |
| `SHAKE_MAGNITUDE`, `SHAKE_SETTLE` | `6.5`, `0.7` | The rumble after the jolt (roughness 12), and how long it takes to settle |
| `HIT_SHAKE_DAMAGE`, `KNOCKOUT_SHAKE`, `GUN_SHAKE` | `60`, `0.8`, `0.15` | A hit on a snail shakes at full strength for this much damage, plus the second on a knockout; each gunshot kicks the view at the third (all less away from the middle of the view, as blasts) |
| `HAPTIC_BIG`, `HAPTIC_SMALL` | `0.6`, `0.15` | The strengths from which a blast plays `Combat_BlastBig` or `Combat_BlastSmall` |
| `HITSTOP_DAMAGE`, `HITSTOP_SECONDS`, `HITSTOP_KNOCKOUT` | `30`, `0.07`, `0.16` | A hit of this much damage or more stops the blast's effects and the camera for this many seconds on every screen; a knockout blow for the last, with the camera's punch-in |
| `DEBRIS_MAX`, `DEBRIS_SPEED` | `16`, `{ 25, 50 }` | The most chunks of ground a blast throws, and their speed |
| `DEBRIS_SIZE`, `DEBRIS_LIFETIME` | `{ 0.3, 1 }`, `2.5` | A chunk's smallest and biggest side, in studs, and how long it lies before fading |
| `SOUND_ROLLOFF_MIN`, `SOUND_ROLLOFF_MAX` | `150`, `600` | Match sounds play at full volume within this many studs of the camera and fade out by the second (Snails' sounds use them too) |
| `BIG_BLAST_SOUND_RADIUS` | `6` | Blasts this big or bigger play `Explosion_Big`, smaller ones `Explosion_Small` |
| `BOUNCE_SOUND_SPEED`, `BOUNCE_SOUND_GAP` | `15`, `0.12` | A bounce that changes a shot's speed by this much plays `Shot_Bounce`, at most once per gap in seconds |
| `WHISTLE_KINDS`, `WHISTLE_FALL_SPEED` | `{ Bouncer = true, Rocket = true, Crawler = true }`, `25` | Shots of these kinds whistle (`Shot_Whistle`) once as they first come down faster than this, in studs a second of their flight |
| `AIMBOT_HIT_COLOR`, `AIMBOT_MISS_COLOR` | green, orange | The aim guide's colours: a path that lands on its target, and the best miss |

### Server settings (`ServerSettings.lua`)

| Key | Default | What |
| --- | --- | --- |
| `AIMBOT_REFRESH` | `0.2` | How often the aim guide solves again while its snail or a target moves, in seconds |
| `AIMBOT_POWERS` | `0.1` to `1` by `0.05` | The shares of power the guide tries for arc weapons, a low and a high arc each |
| `AIMBOT_ARC_SECONDS`, `AIMBOT_ARC_STEP` | `5`, `1 / 30` | How long a guided arc is followed looking for what it hits, and its step |
| `AIMBOT_HIT_MARGIN` | `2.5` | A path landing this close to its target counts as a hit |

## In the place

Creates `Workspace.Ume.Combat` for projectiles (placeholder balls: each client's own copies of simulated shots, and the server's crawling shots), the clients' aim dots, their `Debris` and `Tracer` parts, the aim guide's `Aimbot` folder, and the effects `I.Vfx` plays (prefabs in `Assets/Vfx`: the Vfx library's README).

## Sounds

By name from `src/global_data/Sound/SoundsList.lua`, in the `SFX` group: when a weapon fires, the server plays `Fire_<itemId>` where the shot leaves, and when a utility is used, `Use_<itemId>` at the snail (`I.Sound.PlayForAll`, from `Fire.lua`); each client plays `Explosion_Big` / `Explosion_Small` at a blast, `Shot_Bounce` at a bounce and `Shot_Whistle` from a lobbed shot coming down. A new weapon or utility needs its `Fire_` or `Use_` row there.

## Commands

`combat` (server, level 255). Each acts on the invoker's snail unless it names a participant id:

| Subcommand | Arguments |
| --- | --- |
| `give` | `itemId` (any weapon or utility: the jetpack, the potions, the bandage, the medkit, the parachute; autocompleted from `Combat_ItemIds`), `participantId?` |
| `refill` | `participantId?` |

`aimbot` (server, level 255) `player`: turns that player's aim guide on or off (the `Aimbot` Player attribute) for
the match they're in; refused outside a match, and off again when they leave it (`InMatch` changes).
