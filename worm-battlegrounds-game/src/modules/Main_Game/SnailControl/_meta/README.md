# SnailControl

Moving the active snail. When a turn starts, the server gives the snail's physics to its player's client, fills its
`Stamina` and turns on its `CanMove` attribute. That client binds the walk and jump controls and drives the snail
directly, so movement feels instant: it walks along the plane at `WALK_SPEED`, jumps when standing, climbs ledges up
to `STEP_HEIGHT`, and loses its ball's grip while walking so it slides along walls and up slopes. Each frame the server
charges the distance the snail moves sideways to `Stamina`. At 0 its client stops walking, but the turn goes on and the
snail can still jump. A snail in the air with jetpack fuel steers for free: flying spends fuel, never stamina. The jetpack
is one a match (the Jetpack row's single use), its `JetpackFuel` kept from turn to turn until it's spent, then the
jetpack comes off: the client reports what's left as it flies (`SnailControl_Fuel`), and the server takes at least what
its climb burned when the turn ends. A snail that burned fuel on its turn rests the jetpack on its next (`Match_TurnStarted`
turns `JetpackFlew` into `JetpackRest`): its fuel stays, but it can't fly that turn, on its client, in the server's
height check and for bots. A parachute closes when its snail lands or touches water or lava. The server takes the snail back when the turn ends, and snaps it back with a warning when it left
the arena's plane, went through the terrain, moved faster than its player could have made it, climbed higher than its jump and jetpack fuel
reach, or kept going well past an empty bar. The client follows the snail's attributes. The movement utilities (parachute, jetpack, speed, low gravity) are effects on the snail that Combat
applies, and the match HUD's touch buttons press the controls through `Hold`.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/SnailControl` |
| Runs on | Server, Client |
| Exposes | `I.SnailControl` (server, client) |
| Uses | `I.Snails`, `I.Console`, `ContextActionService`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The entry: `I.SnailControl` |
| `Client.lua` | The local player's controls: binding, walking, facing, jumping, climbing, grip; turns off the default avatar controls |
| `Settings.lua` | `SnailControl_Settings`: movement and the movement effects |
| `ServerSettings.lua` | `SnailControl_ServerSettings`: the server's checks, under a server name so clients never learn their margins |
| `Scripts/Server/Control.lua` | Starting and ending turns, the per-frame path, speed, height and stamina checks |
| `Scripts/Server/Effects.lua` | The movement effects, and closing parachutes on landing |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `snailcontrol` command |
| `_meta/_types.lua` | `SnailControl_Control`, a snail its player moves |

## API

### Server: `I.SnailControl`

| Function | Returns | What it does |
| --- | --- | --- |
| `StartTurn(participantId: string)` | `boolean` | Gives the snail to its player: ownership, full `Stamina`, `CanMove`. False for a snail out of play or one no player here moves (a bot's) |
| `EndTurn(participantId: string)` | | Takes the snail back: `CanMove` off, server ownership, facing kept, the turn's effects cleared. Call it before anything hits the snail |
| `Retreat(participantId: string, seconds: number)` | | After the snail placed Dynamite: fills its `Stamina` again and leaves its player moving it for `seconds`, then takes it back (`EndTurn`) |
| `Refill(participantId: string)` | `boolean` | Fills the snail's `Stamina` again, forgiving what it overspent; `false` when it isn't in play |
| `CloseParachute(participantId: string)` | | Closes the snail's parachute when it has one open (the match's landing closes any still open) |
| `ApplyEffect(participantId: string, effect: string, shiny: boolean?)` | `boolean` | `"Parachute"` (falls slowly, no fall damage until it lands), `"Jetpack"` (fuel to fly while holding jump), `"Speed"` (walks faster and further this turn) or `"LowGravity"` (jumps higher, falls slower this turn); shiny copies give a little more |

### Client: `I.SnailControl`

| Function | Returns | What it does |
| --- | --- | --- |
| `Hold(control: string, state: boolean)` | | Presses or releases `"Left"`, `"Right"` or `"Jump"` from an on-screen button, as its key does; nothing while the snail can't move |
| `GetFuelShare()` | `number` | The player's jetpack fuel left, 0 to 1 of the tank it went on with, as this screen burns it (MatchHud's fuel bar); 0 without a jetpack |

## Usage

```lua
I.SnailControl.StartTurn(participantId)
-- … the player fires
I.SnailControl.EndTurn(participantId)
```

## Network

The owner client follows its snail's `CanMove`, `Stamina` and `JetpackFuel` attributes, and its movement reaches the
server through physics ownership.

### Server

**Receive: RemoteEvents**

- `SnailControl_Fuel @ (player: Player, left: number)`: the jetpack fuel left on the moving snail, every `FUEL_REPORT_INTERVAL` while it flies and once when it stops; it only lowers `JetpackFuel`

## Controls

| Action | Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Walk | A / D, ← / → | Left stick, D-pad ← / → (Console's `Move`, `WalkLeft`, `WalkRight`) | The match HUD's ◀ ▶ buttons (`Hold`) |
| Jump | Space | A (Console's `Jump`) | The match HUD's jump button (`Hold`) |

Bound at `Enum.ContextActionPriority.High` while `CanMove` is on, and sunk: the keys here, the pad's buttons through
`I.Console.Bind` (the Console module's scheme owns which buttons they are).

## Settings

| Key | Default | What |
| --- | --- | --- |
| `WALK_SPEED` | `8` | Walking speed, in studs per second |
| `JUMP_SPEED` | `33` | A jump's upward speed: about 5 studs high at a snail's light gravity (Snails' `GRAVITY_SCALE`) |
| `STEP_HEIGHT`, `STEP_SPEED` | `2`, `16` | Ledges up to this height are climbed by walking into them, with this upward push |
| `STAMINA_STUDS` | `40` | How far a snail may walk in a turn |
| `STICK_DEADZONE` | `0.3` | How far the left stick must lean |
| `PARACHUTE_FALL_SPEED` | `6` | An open parachute's fall speed |
| `JETPACK_FUEL`, `JETPACK_SPEED`, `FUEL_REPORT_INTERVAL` | `6`, `16`, `0.2` | Seconds of flight for the whole match, the upward speed, and how often the flying client reports the fuel left |
| `SPEED_MULTIPLIER` | `1.5` | Walk speed and stamina with the speed potion |
| `LOW_GRAVITY_SCALE` | `0.4` | With the low gravity potion, the share of a snail's own light gravity (Snails' `GRAVITY_SCALE`) left: the ball's `Lift` holds up the rest, and goes back to the snail's usual lift when the turn's effects end |
| `SHINY_BOOST` | Jetpack 1.2, Speed 1.1, LowGravity 0.9, Parachute 0.8 | What a shiny copy multiplies its effect's number by |

### Server settings (`ServerSettings.lua`)

| Key | Default | What |
| --- | --- | --- |
| `CHECK_INTERVAL`, `SPEED_TOLERANCE`, `MOVE_SLACK` | `0.25`, `1.5`, `2` | The server compares the snail with where it was up to an interval ago; more than tolerance × walk speed sideways (or jump speed up) over at least one interval, plus the slack, snaps it back |
| `STAMINA_GRACE` | `8` | How far a snail may still move sideways after its stamina runs out (its client learning of it, momentum through the air, slides) before the server snaps it back |
| `LIFT_GRACE` | `3` | How far a snail may climb past its reach before the server snaps it back. Its reach is a jump (`JUMP_SPEED`² / 2g, higher under low gravity) above the ground it last stood on plus `MOVE_SLACK`, and above that `JETPACK_SPEED` studs per second of the `JetpackFuel` it has left and burned this turn |
| `PLANE_SLACK` | `0.5` | How far a snail may stray off the arena's plane (in Z) before the server snaps it back |

## In the place

Snail attributes it writes: `CanMove` (the owner may move it), `Stamina` (studs left this turn), and the effects'
`Parachute`, `JetpackFuel`, `SpeedMultiplier` and `LowGravity`; `JetpackFlew` (it burned fuel this turn) and
`JetpackRest` (the jetpack rests this turn).

## Commands

`snailcontrol` (server, level 255). Each acts on the invoker's snail unless it names a participant id:

| Subcommand | Arguments |
| --- | --- |
| `turn` | `participantId?` |
| `end` | `participantId?` |
| `refill` | `participantId?` |
