# Snails

The snail bodies. Each participant's snail is an invisible ball held on the arena's plane and upright, wearing a skin
model, with its state in attributes others read: health, team colour, alive or ghost. The server spawns snails, hurts,
heals and throws them, knocks them out in the sea (Arena's `GetHazard`: a pond above it is safe) or out of bounds, charges fall damage when they land, and turns
knocked-out snails into ghosts that touch nothing. Each client draws the ghost: a pale glow, a puff and a rush of air,
then it floats up, bobbing and swaying, fades and vanishes (`GHOST_*`). Clients put a SnailTag over every snail (name, health number and bar in team
colour, the red turn arrow on the active snail with the turn's seconds for everyone but its own player; the arrow drops
in from above the screen and bobs, and once the snail moves, aims or shoots its tag and arrow hide until the turn ends,
as in Worms Armageddon) and an outline in
its team's colour around it, pop a damage number when its health drops, draw the gear a snail wears while it works (an open parachute, a
jetpack for the turn), and animate its rigged skin (idle, walking, hiding in its shell the moment it's hit or while it's thrown). Snail state travels as
attributes on the snail model, so the module creates no remotes.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Snails` |
| Runs on | Server, Client |
| Exposes | `I.Snails` (server: bodies and health; client: lookups) |
| Uses | `I.Arena` (plane, hazards), `I.Create`, `I.Dirs.Assets` (skins), `I.G_Arsenal` (gear models), `I.Sound`, `I.Vfx`, `I.SnailRig` (skin animations), `I.PlayerBadges` (badges after the tag's name), `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The entry: `I.Snails`, starting the hazard checks |
| `Client.lua` | The entry: `I.Snails` lookups, starting the tags, the gear, the sounds, the effects, the motion, the ghosts and the potions |
| `Settings.lua` | `Snails_Settings`: health, falls, the body, animations, ghosts, tags, gear |
| `Scripts/Server/Bodies.lua` | `Workspace.Ume.Snails`, building a snail (ball, constraints, the skin welded on by its RootPart, attributes), ownership, lookups |
| `Scripts/Server/Health.lua` | Damage, heal, knockback, kill credit, knockouts (`Alive` false and `Ghost` true before `Health` drops to 0, so a screen that hears the health change already sees a ghost; the ball anchored in the `Ghost` group; its player's `ReplicationFocus` back to their parked avatar, so the arena stays streamed in while they watch), the `Snails_Died` Topic |
| `Scripts/Server/Hazards.lua` | Each frame: liquid and bounds along each snail's path since the last frame, fall tracking and fall damage (counted from where the snail last rose, so a jetpack that catches a fall restarts it) |
| `Scripts/Server/Flight.lua` | Throws: a knocked snail flies the game's own simulation, not Roblox physics. Its ball is anchored and stepped along a Combat body (`Helpers/Flight`) on the server's clock, its speed written on the anchored ball so whatever reads it (settling, animations, sounds, the camera) sees it fly; a knock while it flies throws it again from where it is. It lands back on Roblox physics, server-owned, once it rests on the ground (`FLIGHT_LAND_KEEP` of its speed to slide on) or after `FLIGHT_MAX_SECONDS`; a snail knocked out mid-flight stays anchored as a ghost. Its `FlightFrom`, `FlightVelocity` and `FlightStart` attributes tell every client |
| `Scripts/Client/Tags.lua` | SnailTag billboards (the name in team colour, gold for VIP, its player's badges after it through `I.PlayerBadges.Show`; the level; the health number on the design's bar, whose outline and fill take the team colour and whose fill is cut at the health left by its `UIGradient`; the active snail's turn arrow, dropped in and bobbed each frame, and turn timer; the active snail's tag hides once it acts: `TAG_HIDE_MOVE` studs from where its turn started, `TAG_HIDE_AIM` while this screen's camera is still (the aim follows the pointer, which drifts while the camera flies to the snail) or a charged shot, or the Turn phase ending, and comes back when `Active` clears), the `TeamOutline` Highlight, and DamagePop numbers (the number and its shadow rise and fade, bigger and warmer for bigger hits, `POP_TIERS`, which punch in; when the player's `DamageNumbers` setting is on), each sized with the screen by `I.ScreenScale.AddBillboard` |
| `Scripts/Client/Ghost.lua` | A snail's ghost on this screen when its `Alive` turns false: a `Ghost` Highlight in `GHOST_COLOR`, the `Spawn` effect and `Snail_Ghost`, then its ball floats `GHOST_RISE` up over `GHOST_TIME`, bobbing and swaying, its skin fading out (`LocalTransparencyModifier`) from `GHOST_FADE_FROM` of the way, and it's hidden with a small `Spawn` puff. A snail already out when it streams in is hidden at once |
| `Scripts/Client/Effects.lua` | Every snail's particle effects on this client, in `Workspace.Ume.Combat` (`I.Vfx`): `Spawn` when it appears, `Fall` dust when it lands (the landing sound's thresholds), `Healing` when its health rises, `Splash_Water` or `Splash_Lava` when it's knocked out there (`Match_KnockedOut`), the `Trail_Snail` trail on its ball while it's alive and faster than `TRAIL_SPEED`, and under its jetpack, while the active snail flies it (climbing or hovering off the ground, not dropping faster than `JET_FALL_SPEED`, held `JETPACK_SOUND_HOLD`), the `Trail_Jet` jet and the `JET_EXHAUST_VFX` prefab's `Exhaust` emitters streaming down (`JET_TRAIL_OFFSET`) |
| `Scripts/Client/Sounds.lua` | Every snail's sounds on this client, from its ball's speed and its attributes: `Snail_Land` after a fall, and for the active snail `Snail_Step` while it walks, `Snail_Jump`, and `Snail_Jetpack` (looped) while its jetpack climbs; `Snail_Hurt` when it loses health; `Snail_Splash`, `Snail_Burn` or `Snail_KnockedOut` when it's knocked out in water, lava or otherwise (`Match_KnockedOut`) |
| `Scripts/Client/Motion.lua` | Each frame, every snail's skin animation (`I.SnailRig.SetMotion`) from its ball's speed: `Walk` while it moves along the ground faster than `WALK_ANIMATION_SPEED`, `Hidden` (into its shell) the moment Combat's `Combat_Hit` hurts it, or while it's thrown faster than `HIDE_SPEED` (not the active snail's own jumps and falls: bots never get `CanMove`, so it reads `Active`; a hidden snail stays hidden while it flies that fast), out again `HIDE_SECONDS` after the hit or its last fast moment once slower than `SHOW_SPEED` or, for the active snail, as soon as it walks, `Idle` otherwise. Combat's `Held` puts the weapon in its hands |
| `Scripts/Client/Potions.lua` | The potions on this client: each snail under the Speed or Low gravity potion (its `SpeedMultiplier` or `LowGravity` attribute) and in play streams its `POTION_AURAS` effect around its ball (the prefab's attachments copied onto it, emitters on; off and removed once their particles are gone when the potion ends), and while the player's own snail is under one on its turn (`Active`) the `PotionVignette` gui fades in, tinted `POTION_VIGNETTE_SPEED`, `_LOW_GRAVITY` or `_BOTH` |
| `Scripts/Client/Flight.lua` | Every thrown snail on this client: when its `FlightStart` changes it builds the same flight from the Flight attributes and, before each frame is drawn, puts the anchored ball where the flight is on the server's clock, so it flies smoothly on every screen; when the attributes clear, the server's landed ball takes over |
| `Scripts/Helpers/Flight.lua` | A throw's flight, the same on the server and every client: a Combat body (`I.G_Combat.NewBody`, `StepBody`) the ball's size, at `GRAVITY_SCALE` gravity, bouncing with `FLIGHT_BOUNCE`, hitting what a snail hits (the ball's collision group) and slowed in the drawn liquid; stepped at Ballistics' own step in real time (30 steps a frame at most), landed once it rests on the ground |
| `Scripts/Client/Gear.lua` | The gear a snail wears: a copy of each `GEAR` utility's Arsenal model while its attribute is set and the snail is in play, moved onto its ball every frame |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `snails` command |
| `_meta/_types.lua` | `Snails_Participant`, who a snail belongs to; `Snails_Gear`, a `GEAR` row; `Snails_SoundState`, what a snail's sounds remember between frames |

## API

### Server: `I.Snails`

| Function | Returns | What it does |
| --- | --- | --- |
| `Spawn(participant: Snails_Participant, position: Vector3)` | `Model?` | Builds the participant's snail at a position on the loaded arena's plane, server-owned, and focuses the player's streaming on it. Nil and a warning with no arena loaded or no `DEFAULT_SKIN` in `Assets.Skins` |
| `Damage(participantId, amount: number, sourceId: string?, itemId: string?)` | | Takes rounded health, never below 0, and remembers the source for kill credit. A snail at 0 stays in play: the Match module knocks it out once the shot settles |
| `Heal(participantId, amount: number)` | | Gives rounded health, never above `MaxHealth` |
| `Knockback(participantId, impulse: Vector3, sourceId: string?, itemId: string?)` | | Throws the snail on the game's own physics (`Flight`) at its speed plus the impulse divided by its mass, and remembers the source |
| `Kill(participantId, cause: string, sourceId: string?)` | | Knocks the snail out: a ghost in the `Ghost` group (each client draws it floating up and fading: `Ghost.lua`), then `Snails_Died` |
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

No remotes: clients read the snail models' attributes. The server also writes `LastAttacker` (the id of whoever last hurt or pushed the snail, never itself), which bots read to hold a grudge.

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
| `GRAVITY_SCALE` | `0.55` | The share of gravity snails feel: the ball's `Lift` always holds up the rest (more under the Low gravity potion), and throws fly with it |
| `FLIGHT_BOUNCE`, `FLIGHT_LAND_KEEP`, `FLIGHT_MAX_SECONDS` | `0.2`, `0.4`, `8` | A thrown snail bounces off a hard hit with this share of its speed into it, lands keeping this share of its speed to slide on, and lands anyway after this many seconds |
| `WALK_ANIMATION_SPEED` | `1.5` | A snail plays its walk while it moves along faster than this (studs a second), rising or falling slower than `STEP_SOUND_MAX_RISE`, on the ground (never in the air on a jetpack or a jump) |
| `HIDE_SPEED`, `SHOW_SPEED`, `HIDE_SECONDS` | `25`, `2`, `1` | A snail hides in its shell the moment it's hit, or while faster than the first (not the active snail jumping or falling on its own), and comes out at least the third (seconds) after the hit or after it last flew that fast, once slower than the second or, for the active snail, the moment it walks |
| `DEFAULT_SKIN` | `"Classic"` | The model in `Assets.Skins` every snail wears until Cosmetics picks one |
| `GROUND_GAP` | `0.4` | How far below the ball the ground may be for a snail to stand on it |
| `GHOST_RISE`, `GHOST_TIME` | `9`, `1.8` | A ghost floats this many studs up over this many seconds, then it's gone from sight; Match waits `GHOST_TIME` after a turn that knocked a snail out |
| `GHOST_BOB`, `GHOST_BOB_RATE`, `GHOST_SWAY` | `0.5`, `1.2`, `10` | As it rises it bobs this many studs side to side, this many times a second, swaying this many degrees with the bob |
| `GHOST_FADE_FROM`, `GHOST_COLOR` | `0.3`, `(205, 235, 255)` | It starts fading out this share of the way up; its glow's colour |
| `TAG_OFFSET` | `2.4` | How far above a snail's center its tag's bottom sits |
| `VIP_NAME_COLOR` | `(255, 206, 46)` | A VIP player's name colour on their snail's tag |
| `ARROW_DROP_FROM`, `ARROW_DROP_SECONDS` | `700`, `0.7` | The turn arrow drops onto the active snail's tag from this many design px above, bouncing in over these seconds |
| `ARROW_BOB_HEIGHT`, `ARROW_BOB_SPEED` | `7`, `6` | Then it bobs this many design px up and down, this many radians a second |
| `TAG_HIDE_MOVE`, `TAG_HIDE_AIM` | `0.75`, 4° | The active snail's tag and arrow hide once it moves this many studs from where its turn started, or turns its aim this far (or charges a shot, or shoots), until the turn ends |
| `TAG_HIDE_CAMERA_STILL` | `0.02` | The aim only counts while this screen's camera moves less than this many studs a frame; while it moves, the aim's start is taken again |
| `POP_RISE`, `POP_TWEENINFO` | `3`, 1 s quad out | How far a damage number rises while it fades, and how |
| `POP_TIERS` | `{ 0, 1, white }`, `{ 25, 1.3, (255, 220, 60) }`, `{ 45, 1.65, (255, 120, 40) }` | Rows of the damage they start at, the number's size (times its design size) and its colour; a hit takes the last row it reaches |
| `POP_PUNCH`, `POP_PUNCH_TWEENINFO` | `1.5`, 0.18 s back out | A number past the first row punches in from this many times its size, and how |
| `GEAR` | Parachute (`Parachute`, 4.9 up), Jetpack (`JetpackFuel`, 2.4 behind, 0.4 up, on the back of the shell) | The utilities a snail wears: the snail attribute that shows each, and its RootPart's offset in the ball's space (−Z ahead) |
| `STEP_SOUND_DISTANCE`, `STEP_SOUND_MAX_RISE` | `1.6`, `4` | The active snail squishes a step every this many studs walked, while its upward speed stays under the second |
| `JUMP_SOUND_SPEED`, `JUMP_SOUND_FROM` | `25`, `5` | It boings when it shoots up past the first from below the second (studs a second) |
| `LAND_SOUND_SPEED`, `LAND_SOUND_STOP` | `30`, `5` | Any snail thuds, and raises the `Fall` dust, when a fall faster than the first stops below the second |
| `JETPACK_SOUND_RISE`, `JETPACK_SOUND_HOLD` | `8`, `0.12` | The jetpack hums while the active snail wears one and climbs between this and `JUMP_SOUND_SPEED` for the hold, and stops a hold after |
| `TRAIL_SPEED` | `45` | A snail faster than this (studs a second) draws its trail |
| `JET_TRAIL_OFFSET` | `(0, -0.6, 2.4)` | Where the jetpack's jet comes out, from the snail's ball: under the worn jetpack |
| `JET_EXHAUST_VFX`, `JET_GROUND_GAP`, `JET_FALL_SPEED` | `"Trail_Smoke"`, `0.6`, `6` | The prefab whose `Exhaust` emitters stream down from the jet (so a hover shows it), and when it's on: nothing within the gap under the ball, not dropping faster than the speed |
| `HEAL_VFX_SCALE` | `2` | The `Healing` effect's size, so it shows at the match camera's distance |
| `POTION_AURAS` | `SpeedMultiplier` → `Aura_Speed`, `LowGravity` → `Aura_LowGravity` | The Vfx prefab that streams around a snail while each potion's attribute is set |
| `POTION_VIGNETTE_SPEED`, `POTION_VIGNETTE_LOW_GRAVITY`, `POTION_VIGNETTE_BOTH` | `(70, 200, 255)`, `(165, 95, 255)`, `(255, 95, 205)` | The vignette's colour on the player's own turn under the Speed potion, the Low gravity potion, or both |
| `POTION_VIGNETTE_TWEENINFO` | 0.4 s sine out | How the vignette fades in, changes colour and fades out |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.Snails` | Created at start. One Model per participant, named by its id (`P_<UserId>`, `B_<n>`), streamed to every client |
| `<snail>.Root` | The invisible ball (`Snail` collision group): `Center` attachment, `Plane` (PlaneConstraint), `Upright` (AlignOrientation, facing ±X), `Walk` (LinearVelocity along X, off; SnailControl's owner client turns it on), `Chute` (SnailControl's parachute), `Lift` (VectorForce, always on: holds up the `1 − GRAVITY_SCALE` of the weight snails don't feel, more under the Low gravity potion), the client's SnailTag. Anchored while it flies a throw (`Flight`) |
| `<snail>.TeamOutline` | A Highlight each client adds: the snail's outline in its team's colour (`Color`), off while it's a ghost |
| `<snail>.Skin` | The skin: its RootPart welded to the ball, the rest hanging from it by its Motor6Ds and bones, massless and non-colliding. Each client animates it (`Motion`, and Combat's `Held` for the weapon) |
| `<snail>.Parachute`, `<snail>.Jetpack` | Client only: the worn gear, copies of the Arsenal models, anchored and moved onto the ball every frame |
| `<snail>.Root.Aura` | Client only: a potion's aura, the `Aura_*` prefab's attachment with its emitters streaming, while the potion lasts |
| `<snail>` attributes | `ParticipantId`, `UserId`, `DisplayName`, `Team`, `Color`, `IsBot`, `Health` and `MaxHealth` (the participant's `MaxHealth`, else `MAX_HEALTH`: the tutorial bot's 10), `Alive`, `Ghost`, `Facing` (−1 or 1), `Shiny`, `Vip`, `Level` (0 for bots, hidden on the tag); SnailControl adds `CanMove` and `Stamina`; Match sets `Active` (the tag's turn arrow; clearing it brings a hidden tag back); Flight writes `FlightFrom`, `FlightVelocity` and `FlightStart` (server time) while it's thrown |
| `Assets.Skins.<SkinId>` | A skin: a Model whose pivot sits at the ball's center, facing its pivot's front (−Z). `Classic` is the studio's rigged snail (2026-11-09, from `Workspace.New.Snails.Snail`; the static one from 2026-11-06 is in `ServerStorage.!dump.Classic_Static`), scaled to 0.45, 4.1 studs tall with its foot on the ball's bottom, staged under `ReplicatedStorage.Ume.Assets.PlaceLoader.Default.Skins`: an invisible `RootPart` (its PrimaryPart and pivot, holding the 18 bones), the skinned `Body`, `Shell`, `LeftHand` and `RightHand` on Motor6Ds from it, an invisible `Handle` on the `Handle` Motor6D (where a held weapon's `Grip` goes), and an `AnimationController` with its `Animator`. A skin made for the rig keeps these names (the `SnailRig` library's README). Since 2026-11-11 the artist's `Clown`, `Skeleton`, `Devil`, `Robot`, `Knight`, `Cowboy`, `Ninja`, `Pirate` and `Soldier` are beside it, on the same skeleton: a skinned `Body` (with the hands in it) and `Shell` (`art/skins`) |
| `Assets.Snails.Animations` | The rig's animations, authored in `Workspace.Ume.ReplicatedStorage_Assets/Snails/Animations/`: an `Animation` each (`Idle`, `Walk`, `Hide`, `Show`, `Gun`, `MiniGun`, `Bazooka`, `ShotGun`) holding its `KeyframeSequence`, from the studio's snails (`Hide` and `Show` were their `1` and `2`; each weapon pose was its snail's `Shoot`). Their `AnimationId`s are empty until the owner publishes them: Studio plays the keyframes, live servers play nothing (`SnailRig`'s README) |
| `Assets.Snails` | The SnailTag and DamagePop billboards' holders, authored in `Workspace.Ume.ReplicatedStorage_Assets/Snails/`: a Model `PREFAB \| SnailTag` (and `PREFAB \| DamagePop`) with an invisible 1 × 1 × 1 `RootPart`, an `Attachment` under it, and the exported BillboardGui under that, named `U_SnailTag` (`U_DamagePop`). Clients clone only the billboard (`FindFirstChild("U_SnailTag", true)`) and name the copy `SnailTag` |

## Commands

`snails` (server, level 255). Each acts on the invoker's snail unless it names a participant id:

| Subcommand | Arguments |
| --- | --- |
| `damage` | `amount`, `participantId?` |
| `heal` | `amount`, `participantId?` |
| `kill` | `participantId?` |
| `push` | `x`, `y` (a speed change, in studs per second), `participantId?` |
