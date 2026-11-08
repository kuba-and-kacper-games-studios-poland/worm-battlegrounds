# SnailControl

Moving the active snail. When a turn starts, the server gives the snail's physics to its player's client, fills its
`Stamina` and turns on its `CanMove` attribute. That client binds the walk and jump controls and drives the snail
directly, so movement feels instant: it walks along the plane at `WALK_SPEED`, jumps when standing, climbs ledges up
to `STEP_HEIGHT`, and loses its ball's grip while walking so it slides along walls and up slopes. Each frame the server
charges the distance the snail moves sideways to `Stamina`. At 0 its client stops walking, but the turn goes on and the
snail can still jump. The server takes the snail back when the turn ends, and snaps it back with a warning when it went
through the terrain, moved faster than its player could have made it, climbed higher than its jump and jetpack fuel
reach, or kept going well past an empty bar. No remotes: the client follows the
snail's attributes. The movement utilities (parachute, jetpack, speed, low gravity) are effects on the snail that Combat
applies, and the match HUD's touch buttons press the controls through `Hold`.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/SnailControl` |
| Runs on | Server, Client |
| Exposes | `I.SnailControl` (server, client) |
| Uses | `I.Snails`, `ContextActionService`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The entry: `I.SnailControl` |
| `Client.lua` | The local player's controls: binding, walking, facing, jumping, climbing, grip; turns off the default avatar controls |
| `Settings.lua` | `SnailControl_Settings`: movement, the checks, the movement effects |
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
| `ApplyEffect(participantId: string, effect: string, shiny: boolean?)` | `boolean` | `"Parachute"` (falls slowly, no fall damage until it lands), `"Jetpack"` (fuel to fly while holding jump), `"Speed"` (walks faster and further this turn) or `"LowGravity"` (jumps higher, falls slower this turn); shiny copies give a little more |

### Client: `I.SnailControl`

| Function | Returns | What it does |
| --- | --- | --- |
| `Hold(control: string, state: boolean)` | | Presses or releases `"Left"`, `"Right"` or `"Jump"` from an on-screen button, as its key does; nothing while the snail can't move |

## Usage

```lua
I.SnailControl.StartTurn(participantId)
-- … the player fires
I.SnailControl.EndTurn(participantId)
```

## Network

No remotes: the owner client follows its snail's `CanMove` and `Stamina` attributes, and its movement reaches the server
through physics ownership.

## Controls

| Action | Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Walk | A / D, ← / → | Left stick, D-pad | The match HUD's ◀ ▶ buttons (`Hold`) |
| Jump | Space | A | The match HUD's jump button (`Hold`) |

Bound at `Enum.ContextActionPriority.High` while `CanMove` is on, and sunk.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `WALK_SPEED` | `8` | Walking speed, in studs per second |
| `JUMP_SPEED` | `44` | A jump's upward speed: about 5 studs high at default gravity |
| `STEP_HEIGHT`, `STEP_SPEED` | `2`, `16` | Ledges up to this height are climbed by walking into them, with this upward push |
| `STAMINA_STUDS` | `20` | How far a snail may walk in a turn |
| `STICK_DEADZONE` | `0.3` | How far the left stick must lean |
| `CHECK_INTERVAL`, `SPEED_TOLERANCE`, `MOVE_SLACK` | `0.25`, `1.5`, `2` | The server compares the snail with where it was up to an interval ago; more than tolerance × walk speed sideways (or jump speed up) over at least one interval, plus the slack, snaps it back |
| `STAMINA_GRACE` | `8` | How far a snail may still move sideways after its stamina runs out (its client learning of it, momentum through the air, slides) before the server snaps it back |
| `LIFT_GRACE` | `3` | How far a snail may climb past its reach before the server snaps it back. Its reach is a jump (`JUMP_SPEED`² / 2g, higher under low gravity) above the ground it last stood on plus `MOVE_SLACK`, and above that `JETPACK_SPEED` studs per second of the `JetpackFuel` it was given |
| `PARACHUTE_FALL_SPEED` | `6` | An open parachute's fall speed |
| `JETPACK_FUEL`, `JETPACK_SPEED` | `3`, `16` | Seconds of flight, and the upward speed |
| `SPEED_MULTIPLIER` | `1.5` | Walk speed and stamina with the speed potion |
| `LOW_GRAVITY_SCALE` | `0.4` | Gravity's share with the low gravity potion |
| `SHINY_BOOST` | Jetpack 1.2, Speed 1.1, LowGravity 0.9, Parachute 0.8 | What a shiny copy multiplies its effect's number by |

## In the place

Snail attributes it writes: `CanMove` (the owner may move it), `Stamina` (studs left this turn), and the effects'
`Parachute`, `JetpackFuel`, `SpeedMultiplier` and `LowGravity`.

## Commands

`snailcontrol` (server, level 255). Each acts on the invoker's snail unless it names a participant id:

| Subcommand | Arguments |
| --- | --- |
| `turn` | `participantId?` |
| `end` | `participantId?` |
| `refill` | `participantId?` |
