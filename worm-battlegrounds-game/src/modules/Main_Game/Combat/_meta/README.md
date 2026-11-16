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
gravity) when a hit is softer than `REST_SPEED`, homing (once locked, a stall for `LockPauseSteps`, then a dive that speeds up from `HomingSpeed` to `HomingMaxSpeed` by `HomingAccel` and turns at most `HomingTurn` radians a second, growing by `HomingTurnGrowth`: the row's fields, 2026-11-16), a thrown bomb's tumble (the
`Tumble` option: it leaves the hand turning with its sideways speed, `AIR_SPIN`, until the ground rolls it), and water
or lava: a shot flies on through a pond, slowed (`SINK_ENTRY_KEEP` as it splashes in, then `SINK_GRAVITY` and
`SINK_KEEP`), bursts on what it touches under it or when its fuse runs out, and is gone without a blast after sinking
`SINK_SECONDS` without touching anything. The open sea (wherever Arena's `GetHazard` would knock a snail out) takes a
shot at once, gone without a blast as it splashes in (the owner, 2026-11-15: the turn waited while it sank;
`Projectiles.IsGone`). The black hole grenade (the `Roller` kind) is thrown and opens on the first thing it touches, or where it is when its owner presses again (`Detonate`, even in the air): it holds still for its row's `HoleTime` (its state sent to every client, `Projectiles.SendState`, so its model and trail stay there on every screen; since 2026-11-16 every screen also draws its vortex and plays its sounds, `Combat_HoleOpened`), draws the snails within `PullRadius` in (the shooter's teammates aside) at `BLACK_HOLE_DRAG_SPEED`, sliding along the ground or drifting through the air (`I.Snails.Drag`, whose drift every client draws from the snail's `Drag*` attributes), each held stuck within `BLACK_HOLE_STICK` of its middle, then bursts with no knockback (its row's `Knockback` `None`, the owner, 2026-11-13: "does not knock people out but sticks to them") and lets them go (`I.Snails.Release`). Shots fly in
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
teammates instead of climbing them into the air; a variety grenade's four minis each hatch a worm where they burst (the owner, 2026-11-16), which digs
down through the terrain as a server part, squeaking as it dives in and crunching as it bites, and drowns in water or lava; clients glide both after their parts. A weapon with a
`Retreat` (Dynamite) is placed at the snail's feet and leaves its player moving it, with full stamina, for that many
seconds (`I.SnailControl.Retreat`) before the fuse blows it. A thrown or launched shot (`Aim` `Arc` or `Target`) leaves
its player moving the snail with the stamina it has left until the shot bursts (the owner, 2026-11-15: "throw it and
run away"): a blast (`Blast.Explode`), a hit on that snail (`Blast.Hit`) or an open black hole drawing it takes it back
first, and Match at the shot's end; guns and swings end the move at once. Guns fire their row's `Volleys` (the
Shotgun's two, `VolleyInterval` 1 s apart, 5 pellets of 4 damage each). Blasts play the studio's explosion effect for their size (`I.Vfx`) and throw chunks of the
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

An admin can give a player an aimbot for the match they're in (the `aimbot` command, level 255), quiet enough that
nobody watching their screen sees it: on their turn an arced weapon shows the tutorial's prediction line, where the
shot at the power held will fly and land (MatchHud's `Aim`), and each enemy snail some aim with the weapon held would
hurt gets a faint fill on its team outline (`AIMBOT_FILL_*`). The aim stays the player's: nothing snaps it. The server
finds those snails and sends them to that player alone, so the solver never reaches clients: for an arc weapon it
ranks the arcs from `GetArcs` by where they first touch, then runs the nearest `AIMBOT_SIMULATED` through the bots'
full prediction (`I.Bots.GetShotHits`: bounces, fuses, bomblets, crawls, pulls and blast reach); a gun or a swing is
tried straight at the snail, a homing shot fired up toward its side.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Combat` |
| Runs on | Server, Client, Global · Match map |
| Exposes | `I.Combat` (server), `I.G_Combat` (both) |
| Uses | `I.Match`, `I.Snails`, `I.Arena`, `I.G_Arsenal`, `I.Replicator`, `I.CameraShake`, `I.Haptic`, `I.Sound`, `I.Vfx`, `I.SnailRig`, `I.MatchCamera` (client: `Freeze`, `PunchIn`), `I.Bots` (server: the aimbot's `GetShotHits`), `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Remotes, Topics, the `I` table; starts the handlers |
| `Scripts/Server/Fire.lua` | Selecting, aiming, firing, utilities. A player's fire, utility and detonate need `I.Match.IsActivePlayer` (never while a bot plays their dropped snail's turn: `I.Match.IsAutopilot`), and selecting is refused while one does. |
| `Scripts/Server/Arcs.lua` | The exact arc solver (`GetArcs`) and arc prediction (`PredictArc`), for bots and the aimbot |
| `Scripts/Server/Aimbot.lua` | The aimbot, while the server has the player's `Aimbot` attribute on: on their turn, the enemy snails the weapon held can hurt (arcs from `GetArcs` at `AIMBOT_POWERS`, the `AIMBOT_SIMULATED` nearest run through `I.Bots.GetShotHits`; a gun's or a swing's straight aim; a homing shot's launch), found again every `AIMBOT_REFRESH` seconds once something moved and sent to that player (`Combat_AimbotTargets`) |
| `Scripts/Server/Uses.lua` | Uses and cooldowns per participant, the `Combat` Replicator folder |
| `Scripts/Helpers/Ballistics.lua` | `Combat_Ballistics`, the shot simulation both sides run: `New`, `Step`, `Load`, `GetState`, `GetCFrame`, `GetSnail`, `MakePart` (the placeholder ball) |
| `Scripts/Server/Projectiles.lua` | Simulated shots (`Launch`, `Fly`, `Land`, `GetOptions`, `GetStart`, `IsGone`), crawling shots' parts (`Spawn`), raycasts (`Cast`, and `CastTerrain` for crawlers), a crawler's step (`GetCrawlStep`), lost shots |
| `Scripts/Server/Blast.lua` | Explosions: tells clients first (`Combat_Explosion`), hurts every snail in reach at once (`Combat_Hit`) while the crater is cut, then throws them once it is (so a thrown snail flies the new ground; a `None` knockback throws nobody); never hurts or throws the shooter's teammates, always the shooter. `Hit` for one snail (guns, swings, the spear) |
| `Scripts/Server/Behaviors/*.lua` | One file per `Kind` (Rocket, Bouncer, Crawler, Homing, Roller, Hitscan, Melee), and `Snail.lua`, the variety grenade's worms (`Run`; `PlaySound`, a match sound for everyone where it happens, which Bouncer plays a row's `BurstSound` with). A variety grenade's minis (`Bomblets.Hatch`) each start a worm down one of `SNAIL_DIRECTIONS` at random where they burst; a row's `Snails` without `Hatch` dig out of the bomb's own burst |
| `Global.lua` | Launch velocity and wind, shared with the aim dots, the aimbot and bots |
| `Client.lua` | Starts the client handlers; `I.Combat` on the client (`SetAim`) |
| `Scripts/Client/Effects.lua` | Blasts (the `BLAST_VFX` effect for the blast's size, scaled by its radius, and chunks of the ground that bounce on the terrain in the `Chip` collision group, then fade), tracers (a gun's `MUZZLE_VFX` flash where it fires, `Flash_Bullet` and `Explosion_Gun` where each bullet lands; One Punch plays `Punch` at the snail it hits), the blast sound (`Explosion_Big` from `BIG_BLAST_SOUND_RADIUS`, else `Explosion_Small`), sparks off every snail a blow hurts (`HIT_VFX`, bigger for a harder blow), the camera shake (`_shake`: a jolt, then a rumble; for blasts, hits on snails and gunshots) and the haptics (`Combat_BlastBig`, `Combat_BlastSmall`, `Combat_Hurt` in `src/global_data/Haptic/Preset.lua`), and the hit stop (`_onHit`, `_hitStop`: particles' `TimeScale` 0 and `Debris` chunks anchored, then put back with their speed) |
| `Scripts/Client/Flight.lua` | Shots in flight drawn as their weapon's model (`GetProjectileModel`) over the hidden placeholder part: rockets and missiles along their flight, thrown and rolled weapons turning with the part, the spider bomb upright facing its crawl, worms (`Projectiles/Worm`, hatched by the variety grenade's minis) head first along their tunnel, swaying (`WORM_SWAY`). Models are drawn `PROJECTILE_DRAW_SCALE` times their size (a placed Dynamite at its own; a part's `DrawScale` attribute, set by Shots, wins); models of parts the server moves glide after them (`CRAWL_GLIDE`). A bomb's bomblets with `Mini` are named after their bomb and drawn as small copies of it, with its trail; other bomblets and weapons without a model keep the placeholder. A weapon in `PROJECTILE_TRAILS` draws its trail (a Vfx effect) on an invisible carrier part that follows the shot without turning (its attachments along Z, so the ribbon keeps its width), its exhaust's emitters streaming (a missile's smoke puffs and thruster), and a rocket's carrier rides `TRAIL_TAIL` behind it; all left to fade where the shot ends. `MakeTrailCarrier(effect, position, name)` makes such a carrier on its own (Vortex's arms) |
| `Scripts/Client/Shots.lua` | Each simulated shot's copy on this client: a local placeholder part in `Workspace.Ume.Combat`, `PROJECTILE_DRAW_SCALE` (or its `PROJECTILE_DRAW_SCALES`) times its size and marked `Simulated`, its `LAUNCH_VFX` played as it starts (Flight draws on it, the camera follows it), stepped to the server's clock as `I.Match.GetDrawTime` draws it and corrected by its states; a bounce on the way plays `Shot_Bounce`, and a lobbed shot whistles as it comes down (`_whistle`: `Shot_Whistle` from its part, volume 0.5, kept in the shot's `Whistle` and played once, `Whistled`); a homing shot's lock and dive (`_home`, its `Locked` and `Diving`): `HOMING_LOCK_VFX` and `Homing_Lock` as it locks on, then `Homing_Boost`, the `HOMING_DIVE_TRAIL` trail and `HOMING_DIVE_SPARKS`' emitters streaming on it as it dives |
| `Scripts/Client/Held.lua` | The active snail's held weapon: a copy of its model in `Workspace.Ume.Combat`, in the snail's hands in the weapon's pose (`I.SnailRig.Hold`), pitched to the aim this screen draws (MatchHud's crosshair, at once, and after the shot is sent its angle, until the next turn) or else to the snail's replicated aim. On its player's screen a snail standing still turns to face its aim. When the shot is away, a gun with a `HoldPose` plays its shot (`I.SnailRig.Shoot`, at least `Pellets` × `BurstInterval`), again for each of its `Volleys`, before it goes. Once a shot is away (`Match_PhaseChanged` to `Flight`) the active snail's emote ends (`I.SnailRig.StopEmote`) |
| `Scripts/Client/Aimbot.lua` | Marks the snails the server says the player can hit: a faint fill (`AIMBOT_FILL_COLOR`, `AIMBOT_FILL_TRANSPARENCY`) on each one's `TeamOutline` Highlight (Snails' tags), taken off the next time the list changes |
| `Scripts/Client/Vortex.lua` | An open black hole on this screen (`Combat_HoleOpened`, `Combat_Vortex`): `VORTEX_ARMS` carriers of `VORTEX_TRAIL` (`Flight.MakeTrailCarrier`) orbit its middle, closing in from `VORTEX_RADIUS` to `VORTEX_END_RADIUS` and spinning faster (`VORTEX_SPIN`, `VORTEX_SPIN_GROWTH`), since the still hole draws no trail of its own; `BlackHole_Open`, the looped `BlackHole_Hum`, `BlackHole_Collapse` `VORTEX_COLLAPSE` seconds before it bursts and `BlackHole_Burst`; the arms go a second after the burst, once their trails faded |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `combat` and `aimbot` commands, and the `Combat_ItemIds` dictionary (every weapon and utility id, from both of `I.G_Arsenal.GetAll()`'s tables) |
| `Settings.lua` | `Combat_Settings` |
| `ServerSettings.lua` | `Combat_ServerSettings`: the aimbot's solver, under a server name so clients never get it |

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
| `GetArcs(origin, aimAt, itemId, windAcceleration, powers)` | `{ Vector2 }` | The angles (X) and powers (Y) whose arcs pass through `aimAt` in open air: a low and a high arc for each share of power in `powers` that reaches it, corrected for the muzzle. Bots and the aimbot use it |
| `PredictArc(origin, velocity, windAcceleration, seconds, step?)` | `{ Vector3 }` | Points along the flight |
| `GetShotStart(origin, direction, shooter)` | `Vector3` | Where a shot leaves a snail's ball (`origin`) along `direction`: `MUZZLE_GAP` past the ball, or short of the terrain or snail in the way (a raycast that ignores `shooter`), so a shot aimed into the ground starts on it. `Fire` and the bots' predictions use it |
| `GetCrawlStep(position, side, distance)` | `Vector3` | Where a crawling spider bomb goes next, one step of `distance` toward `side` (-1, 1, or 0 to stay): up a wall, along the ground or falling, by terrain alone. The spider bomb's crawl and the bots' predictions use it |

### Client: `I.Combat`

| Function | Returns | What it does |
| --- | --- | --- |
| `SetAim(angle?)` | | Points the held weapon along the aim this screen draws, at once (MatchHud's crosshair, every frame it draws); nil hands it back to the snail's replicated aim |

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
- `Combat_Tracer @ (itemId: string, origin: Vector3, points: { Vector3 }, struck: { Vector3 }?)`: to everyone; a gun's `struck` holds the bullets that hit a snail or the terrain (MatchCamera glides only to those), a swing sends none
- `Combat_AimbotTargets @ (targets: { Model })`: to a player whose aimbot is on, the enemy snails they can hit, when that changes (empty to clear it)
- `Combat_HoleOpened @ (center: Vector3, seconds: number)`: to everyone, when a black hole opens (its `HoleTime`), for its vortex and sounds
- `Combat_Shot @ (id: number, kind: string, name: string, start: number, position: Vector3, velocity: Vector3, options: Combat_ShotOptions)`: to everyone, when a simulated shot leaves (`start` is the server time of its step 0)
- `Combat_ShotState @ (id: number, state: Combat_BodyState)` (unreliable): to everyone, every `STATE_INTERVAL` while it flies
- `Combat_ShotEnd @ (id: number, position: Vector3)`: to everyone, when it's over

### Client

**Receive: RemoteEvents**

- `Combat_Explosion`: drawn, shaken and felt by `Effects`
- `Combat_Hit`: throws sparks off the snail (`HIT_VFX`) and shakes the camera by the damage; a hit of `HITSTOP_DAMAGE` or more, or a knockout, stops the world for a beat (`Effects`); a hit on the player's own snail vibrates
- `Combat_Tracer`: drawn by `Effects`, and a gun's kicks the camera
- `Combat_AimbotTargets`: marked by `Aimbot`
- `Combat_HoleOpened`: drawn and heard by `Vortex`
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
| `WIND_ACCEL`, `WIND_ACCEL_GROWTH` | `3.5`, `0.375` | Wind's push per point of wind, in studs per second squared, plus the growth for every point of its strength: `wind × (3.5 + 0.375 × |wind|)`, so 8.5 at 2, 34.5 at 6, 96 at 12 and 220 at 20 (gravity is 196.2). At 12 a shot steeper than about 64° into the wind is swept back the other way; at 20, steeper than about 42°. Halved and quartered from 7 and 1.5 on 2026-11-15, when the wind's scale doubled to ±20 (the owner: the strength of 10 is now 20's). `WIND_ACCEL` was raised from 3 on 2026-11-13 (the testers found the wind too weak), and the growth added the same day (the owner) |
| `MUZZLE_GAP`, `SHOOTER_GRACE` | `0.8`, `0.25` | How far past the snail's ball a shot starts (closer when something is in the way: `GetShotStart`), and how long it ignores its shooter |
| `CHARGE_SECONDS` | `1.3` | How long a held press (the mouse button, FIRE on touch, RT) takes to fill the power from none to full at one even rate, firing by itself at full (MatchHud); bots charge their shot as fast (Bots) |
| `MAX_PROJECTILE_TIME` | `20` | A shot still moving after this is removed |
| `PROJECTILE_TIME_SCALE` | `0.5` | Shots fly at this share of real speed (half speed) along the same paths: the simulation's own time per step, the spider bomb's throw slowed the same way, and a thrown bomb's fuse stretched to match |
| `PROJECTILE_STEP`, `PROJECTILE_MAX_CONTACTS`, `PROJECTILE_SKIN` | `1/60`, `4`, `0.02` | The simulation's fixed step, the most touches it resolves in one, and how far off a surface it leaves a shot |
| `BOUNCE_FRICTION`, `REST_SPEED` | `0.8`, `8` | A bounce keeps this share of the speed along the surface; a hit softer than this (into it, studs per second) rests and rolls instead |
| `AIR_SPIN`, `AIR_SPIN_MAX` | `0.35`, `30` | A thrown bomb (`Tumble`) leaves the hand turning this many radians a second of its flight per stud a second it flies sideways, at most `AIR_SPIN_MAX`, until the ground rolls it |
| `ROLL_DRAG`, `STOP_SPEED`, `REST_NORMAL_Y` | `12`, `1.5`, `0.9` | A rolling shot's slowing, and the speed it stops under on ground at least this flat |
| `SINK_ENTRY_KEEP`, `SINK_GRAVITY`, `SINK_KEEP`, `SINK_SECONDS` | `0.5`, `0.3`, `0.12`, `4` | A shot flies on through a pond (the open sea takes it at once): it keeps this share of its speed as it splashes in, then falls at this share of gravity and keeps this share of its speed each second of its flight while under; it bursts on what it touches there, and is gone without a blast after this many real seconds under |
| `STATE_INTERVAL`, `CORRECTION_TOLERANCE`, `HISTORY_SECONDS`, `CORRECTION_SMOOTH`, `MAX_CATCH_UP` | `0.1`, `0.15`, `2`, `0.1`, `240` | How often the server sends a shot's state, how far off a client's copy may be before it rewinds, how much it keeps to rewind to, how fast a correction eases out, and the most steps a client takes in one frame |
| `UPWARD_BIAS`, `KNOCKBACK_EDGE` | `0.5`, `0.5` | Knockback's lift, and its share at a blast's edge |
| `BULLET_CARVE`, `BULLET_KNOCK_SHARE` | `0.75`, `0.25` | Gun bullets' crater size and knockback share |
| `BOMBLET_SPEED`, `BOMBLET_GHOST` | `{ 20, 40 }`, `0.1` | Bomblets' speeds (the cluster bomb's and the variety grenade's minis, which feel their bomb's wind), and how long they fly through everything to leave the crater |
| `SNAIL_SPEED`, `SNAIL_BITE`, `SNAIL_LIFETIME` | `6`, `0.3`, `6` | A row's `Snails` worms (the variety grenade's, hatched by its minis since 2026-11-16): digging speed, how often they eat a tunnel, how long they dig |
| `SNAIL_DIG_SOUND_EVERY` | `2` | A worm squeaks (`Variety_Squeak`) as it dives in, and crunches (`Variety_Dig`) every this many bites |
| `SNAIL_DIRECTIONS` | four, fanned out downward | The ways a variety grenade's worms dig off; a mini's worm takes one at random |
| `CONTACT_DISTANCE`, `BLACK_HOLE_DRAG_SPEED`, `BLACK_HOLE_STICK`, `MELEE_BOX` | `2.5`, `16`, `2.5`, `4` | Contact bursts, an open black hole's draw (studs per second; 10 until 2026-11-16) and how near its middle a snail sticks, melee reach |
| `VORTEX_TRAIL`, `VORTEX_ARMS` | `"Trail_BlackHole"`, `3` | An open black hole's vortex on every screen: this many carriers of the trail orbit its middle |
| `VORTEX_RADIUS`, `VORTEX_END_RADIUS` | `7`, `0.6` | They orbit this far out at first, closing in to the second as it nears its burst |
| `VORTEX_SPIN`, `VORTEX_SPIN_GROWTH` | `1.2`, `1.4` | Turns a second, faster by the second each second |
| `VORTEX_COLLAPSE` | `0.9` | `BlackHole_Collapse` plays this many seconds before the burst, as the hum stops |
| `CRAWL_STEP_UP`, `CRAWL_STEP_DOWN`, `CRAWL_STOP` | `1.25`, `3`, `0.25` | A crawling spider bomb walks up ledges this high (taller ones it climbs), steps down this far (deeper and it falls), and waits this close across to its target |
| `HELD_TURN_SPEED` | `14` | How quickly the held weapon turns to another player's new aim |
| `PROJECTILE_COLORS`, `PROJECTILE_SIZE` | | Placeholder projectile looks (hidden under a model when the weapon has one); the simulation's ball is half the size across |
| `PROJECTILE_DRAW_SCALE` | `2` | Flying shots are drawn this many times their size (models and placeholders, a placed Dynamite aside); hits still use `PROJECTILE_SIZE` |
| `PROJECTILE_DRAW_SCALES` | `{ HomingMissile = 3.5 }` | A weapon's shot drawn at its own scale instead (the homing missile's model is thin) |
| `PROJECTILE_TRAILS` | Bazooka, HomingMissile: `Trail_Smoke`; BlackHoleGrenade: `Trail_BlackHole`; VarietyGrenade: `Trail_Variety`; ClusterBomb: `Trail_Smoke` (their mini bomblets draw the same); since 2026-11-16 Grenade, SpiderBomb: `Trail_Fog`; Worm (the variety grenade's worms): `Trail_Variety` | The trail a weapon's shot draws behind it while it flies, by item id |
| `TRAIL_SCALE` | `1` | Widens every shot's trail |
| `TRAIL_TAIL` | `2` | A rocket's trail and exhaust start this many studs behind its middle, at its drawn tail |
| `WORM_SWAY`, `WORM_SWAY_SPEED` | `0.35`, `2` | How far (radians) and how fast (swings a second) a worm's model sways as it digs |
| `CRAWL_GLIDE` | `18` | How quickly a server-moved model (spider bomb, worm) glides after its part |
| `BLAST_VFX`, `BLAST_VFX_RADIUS` | `{ { 0, "Explosion" }, { 6, "Explosion_Fire" }, { 9, "Explosion_Big" } }`, `6.5` | The effect a blast plays: the last row whose radius it reaches; it's scaled by its radius over `BLAST_VFX_RADIUS` |
| `MUZZLE_VFX` | `{ Uzi = "Flash_SMG", Minigun = "Flash_SMG", Shotgun = "Flash_Sniper" }` | The flash a gun plays where its shot leaves |
| `LAUNCH_VFX`, `LAUNCH_VFX_SCALE` | Bazooka and HomingMissile: `Flash_Sniper`, `Explosion_Gun`; `1.5` | The blast out of a launcher where its shot starts, pointing along it (Shots, on every screen) |
| `PUNCH_VFX_SCALE` | `0.5` | One Punch's `Punch` effect's size |
| `HOMING_LOCK_VFX`, `HOMING_LOCK_VFX_SCALE` | `"Flash_Sniper"`, `2.5` | The flash a homing shot plays as it locks on |
| `HOMING_DIVE_TRAIL`, `HOMING_DIVE_SPARKS` | `"Trail_Jet"`, `"Aura_Speed"` | From its dive a homing shot draws the first trail and streams the emitters of the second's attachments (the Speed aura's lightning) |
| `HIT_VFX`, `HIT_VFX_SCALE`, `HIT_VFX_DAMAGE_SCALE`, `HIT_VFX_MAX_SCALE` | `"Hit_Sparks"`, `1.5`, `0.03`, `4` | A snail a blow hurts throws out these sparks (the studio's damage sparks), at the scale grown by the third for each point of damage, up to the fourth |
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
| `AIMBOT_FILL_COLOR`, `AIMBOT_FILL_TRANSPARENCY` | white, `0.82` | The fill the aimbot gives the team outline of each snail its player can hit |

### Server settings (`ServerSettings.lua`)

| Key | Default | What |
| --- | --- | --- |
| `AIMBOT_REFRESH` | `0.2` | How often the aimbot looks again while its snail or a target moves, in seconds |
| `AIMBOT_POWERS` | `0.1` to `1` by `0.05` | The shares of power it tries for arc weapons, a low and a high arc each |
| `AIMBOT_ARC_SECONDS`, `AIMBOT_ARC_STEP` | `5`, `1 / 30` | How long an arc is followed looking for what it first touches, and its step |
| `AIMBOT_SIMULATED` | `4` | How many of the arcs that first touch nearest a snail run the bots' full prediction |

## In the place

Creates `Workspace.Ume.Combat` for projectiles (placeholder balls: each client's own copies of simulated shots, and the server's crawling shots), the clients' aim dots, their `Debris` and `Tracer` parts, and the effects `I.Vfx` plays (prefabs in `Assets/Vfx`: the Vfx library's README).

## Sounds

By name from `src/global_data/Sound/SoundsList.lua`, in the `SFX` group: when a weapon fires, the server plays `Fire_<itemId>` where the shot leaves, and when a utility is used, `Use_<itemId>` at the snail (`I.Sound.PlayForAll`, from `Fire.lua`); each client plays `Explosion_Big` / `Explosion_Small` at a blast, `Shot_Bounce` at a bounce and `Shot_Whistle` from a lobbed shot coming down. Since 2026-11-16: the server plays a row's `BurstSound` where the bomb bursts (`Variety_Burst`, `Cluster_Split`) and each worm's `Variety_Squeak` and `Variety_Dig` (`Snail.PlaySound`, pitch 0.92 to 1.08); each client plays `Homing_Lock` and `Homing_Boost` from a homing shot (`Shots`) and `BlackHole_Open`, `BlackHole_Hum` (looped), `BlackHole_Collapse` and `BlackHole_Burst` at an open hole (`Vortex`). These ten, and the thrown weapons' own `Fire_` sounds, are the sound kit's 16 Nov set, uploaded to The Snail Studio. A new weapon or utility needs its `Fire_` or `Use_` row there.

## Commands

`combat` (server, level 255). Each acts on the invoker's snail unless it names another (`snail?`: its name, spaces as
underscores, its player's username or its participant id, ignoring case; the start of one name is enough; autocompleted
from Match's `Match_Snails`):

| Subcommand | Arguments |
| --- | --- |
| `give` | `itemId` (any weapon or utility: the jetpack, the potions, the bandage, the medkit, the parachute; autocompleted from `Combat_ItemIds`), `snail?` |
| `refill` | `snail?` |

`aimbot` (server, level 255) `player`: turns that player's aimbot on or off (the `Aimbot` Player attribute) for
the match they're in; refused outside a match, and off again when they leave it (`InMatch` changes).
