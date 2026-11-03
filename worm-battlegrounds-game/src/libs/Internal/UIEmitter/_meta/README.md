# UIEmitter

Client UI particle emitter library. Create emitters with `I.UIEmitter.new(params)`, then burst with `:Emit`, stream with `:Play` / `:Stop`, or tear down with `:Clear` / `:Destroy`.

Injected automatically during framework startup. Requires Ume to finish library injection before first use (the shared Heartbeat scheduler needs `I.S.RunService`).

| | |
| --- | --- |
| Folder | `src/libs/Internal/UIEmitter` |
| Exposes | `I.UIEmitter` |
| Runs on | Client |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | `new` |
| `Scripts/Emitter.lua` | An emitter instance and its methods |
| `Scripts/Particle.lua` | Spawning and updating particles |
| `Scripts/Scheduler.lua` | The shared Heartbeat loop every emitter runs on |
| `Scripts/Config.lua` | Reading, checking and compiling params (or a `ParticleEmitter`) |
| `Scripts/Sampler.lua` | Values, ranges and curves over a particle's life |
| `Scripts/Attraction.lua` | Particles flying to a target |
| `Scripts/Defaults.lua` | Default params |
| `_meta/_types.lua` | Params, config and instance types |

---

## Quick start

```lua
local emitter = I.UIEmitter.new({
	Parent = someFrame,
	Texture = "rbxassetid://123456789",
	Rate = 20,
	Lifetime = NumberRange.new(0.6, 1.2),
	Velocity = NumberRange.new(80, 140),
	Direction = Vector2.new(0, -1),
	SpreadAngle = 40,
	Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.15, 0.12),
		NumberSequenceKeypoint.new(1, 0),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	}),
})

emitter:Play()
-- later
emitter:Stop()
emitter:Destroy()
```

Burst without continuous rate:

```lua
local burst = I.UIEmitter.new({
	Parent = container,
	Rate = 0,
	Texture = currencyIcon,
	Lifetime = 1.5,
	AttractTo = targetGui,
	AttractStrength = 4000,
	AttractStopOnArrive = true,
})

burst:Emit(12)
```

You can also pass a Roblox `ParticleEmitter` instance whose `Parent` is a `GuiObject`. Common visual/motion fields are mapped; 3D shape fields are ignored (one warning per session).

---

## Public API

### `I.UIEmitter.new(params) -> UIEmitter_Instance`

`params` is either:

- a config table (`UIEmitter_Params`)
- a `ParticleEmitter` instance parented to a `GuiObject`

Returns a proxy instance. Reading `emitter.Rate` (or any config key) returns the current validated value. Writing `emitter.Rate = 30` re-validates the full config. Unknown keys error.

Writing a field re-validates the config; aliases (`LifeTime`, `Acceleration`) are resolved and cleared, so a later `emitter.Lifetime = 5` is never overridden by an earlier alias.

**Mutation note:** existing live particles keep the values sampled at spawn (strength, size curve, lifetime, etc.). Only fields marked with `AttractLiveFromEmitter = true` re-read numeric attract values from the emitter each frame. Changing `Texture`, flipbook settings, or size mid-flight does not retarget already-spawned particles.

### Instance methods

| Method          | Behavior                                                                                                |
| --------------- | ------------------------------------------------------------------------------------------------------- |
| `:Emit(count?, spawnAbsolutePoint?)` | Spawns an immediate burst. `count` defaults to `1`. Uses one shared spawn context for the whole burst. `spawnAbsolutePoint` (`Vector2`, screen space) overrides `EmitterPosition` and the emission shape for that burst. |
| `:Play()`       | Starts continuous emission at `Rate` particles/sec. On first play, also warm-starts `InitialParticles`. |
| `:Stop()`       | Stops continuous emission. Existing particles finish naturally.                                         |
| `:Prewarm(n)`   | Pre-creates up to `n` hidden pooled particles (capped by the pool limit) so the first bursts are cheap. |
| `:Clear()`      | Returns all active particles to the pool. Does not change playing state.                                |
| `:Destroy()`    | Stops emission, clears particles, destroys the pool, and marks the emitter unusable.                    |

---

## Value kinds (fixed, random, and curves)

Config fields use one (or more) of these value kinds:

| Kind                 | Meaning                                                                     | How to write it                                     |
| -------------------- | --------------------------------------------------------------------------- | --------------------------------------------------- |
| **fixed**            | One constant for every particle                                             | `64`, `true`, `"Loop"`                              |
| **random**           | Sampled once when the particle spawns                                       | `NumberRange.new(10, 20)` or `{10, 20}`             |
| **curve**            | Evaluated over lifetime progress `0 → 1` each frame                         | `NumberSequence` / `ColorSequence`                  |
| **curve + envelope** | Lifetime curve, with Studio-style per-keypoint spread sampled once at spawn | `NumberSequenceKeypoint.new(time, value, envelope)` |

For numeric fields, a plain number is always the fixed form. You do not need to write
`NumberRange.new(10, 10)` or `{10, 10}` when the value should stay at `10`.
`NumberRange` remains a per-particle random value, while `NumberSequence` provides a
lifetime curve and optional per-keypoint envelope.

### Lifetime curves

`Size`, `Squash`, `Transparency`, and supported numeric motion fields are **curves**.
Lifetime alpha `0` is birth and `1` is death, for example:

```text
0.0 → 0
0.1 → 1
0.9 → 0.5
1.0 → 0
```

```lua
Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.1, 1),
	NumberSequenceKeypoint.new(0.9, 0.5),
	NumberSequenceKeypoint.new(1, 0),
})
```

### Can curves be random per particle? (Studio envelopes)

**Yes for numeric curves.** Roblox `NumberSequence` keypoints have an `Envelope`
(half-range). UIEmitter samples that envelope **once per particle at spawn**, then
evaluates the resulting curve over lifetime — the same idea as Size/Transparency
spread in Studio ParticleEmitter.

```lua
-- At progress 0.1, base size 1.0 with ±0.2 spread → each particle gets ~0.8..1.2
Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0, 0),
	NumberSequenceKeypoint.new(0.1, 1, 0.2),
	NumberSequenceKeypoint.new(0.9, 0.5, 0.1),
	NumberSequenceKeypoint.new(1, 0, 0),
})
```

**No for `Color`.** `ColorSequence` has no envelope API in Roblox, so color keypoints are fixed curves only.

`SizeScale` / `TransparencyScale` are separate **random** multipliers on top of the curve (not time-based).

Enums are case-insensitive on input and stored lowercase internally.

---

## Coordinate spaces

- Particle positions are stored in **Parent-local pixels** (`UDim2.fromOffset`).
- `EmitterPosition` / `AttractTo` `UDim2` and (by default) `Vector2` are resolved relative to **Container**.
- `AttractToSpace = "Absolute"` makes `AttractTo` `Vector2` values absolute screen pixels.
- Gravity `Vector3` input is converted to UI space (`Y` flipped) because world `Y+` is up while UI `Y+` is down.
- Default size is **Scale** space: `Size = 0.1` means 10% of the parent GuiObject size, with `AspectRatio = 1`.
- `EmissionArea` is **Container-relative scale**: `1` or `Vector2.new(1, 1)` fills the
  current container, and it automatically follows container/window resizing.

---

## Config reference

**Variation** column: `fixed` / `random` / `curve` / `curve + envelope`.

### Placement

| Field             | Default        | Variation | Description                                                                                                       |
| ----------------- | -------------- | --------- | ----------------------------------------------------------------------------------------------------------------- |
| `Parent`          | _(required)_   | fixed     | `GuiObject` that owns particle instances.                                                                         |
| `Container`       | `Parent`       | fixed     | Layout / cull / attract reference frame.                                                                          |
| `EmitterPosition` | `nil`          | fixed     | Spawn origin as `UDim2` or container-local `Vector2`. Falls back to `Properties.Position`, then container center. |
| `EmissionArea`    | `Vector2.zero` | fixed     | Spawn area scale relative to `Container` (`1, 1` fills it; a number expands to a square).                         |
| `EmissionShape`   | `"Point"`      | fixed     | `"Point"`, `"Rectangle"`, or `"Circle"`.                                                                          |

### Appearance

| Field               | Default               | Variation                         | Description                                                                                      |
| ------------------- | --------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------ |
| `Texture`           | `""`                  | fixed                             | Image id. Empty → `Frame`; non-empty → `ImageLabel`. Digits become `rbxassetid://...`.           |
| `ZIndex`            | `0`                   | fixed                             | Particle `ZIndex`.                                                                               |
| `Squash`            | `1`                   | fixed / random / curve + envelope | Width/height stretch. A `NumberSequence` is evaluated over lifetime.                             |
| `Color`             | white sequence        | curve                             | `Color3` or `ColorSequence` over lifetime. No envelope randomization.                            |
| `Size`              | `NumberSequence(0.1)` | fixed / random / curve + envelope | `number`, `NumberRange`, or `NumberSequence` over lifetime. Envelopes are sampled once at spawn. |
| `SizeSpace`         | `"Scale"`             | fixed                             | `"Offset"` (pixels) or `"Scale"` (fraction of parent size).                                      |
| `SizeScale`         | `nil`                 | fixed / random                    | Extra per-particle size multiplier in `[0, 1]` when set.                                         |
| `AspectRatio`       | `1`                   | fixed                             | Adds/updates a `UIAspectRatioConstraint`.                                                        |
| `Transparency`      | `0`                   | fixed / random / curve + envelope | `number`, `NumberRange`, or `NumberSequence`. Envelopes are sampled once at spawn.               |
| `TransparencyScale` | `nil`                 | fixed / random                    | Extra per-particle transparency multiplier when set.                                             |
| `Properties`        | `{}`                  | fixed                             | Extra GuiObject properties at spawn. `Position` ignored.                                         |

### Flipbook (spritesheet)

Flipbook is **disabled** until `FlipbookImageSize`, `FlipbookGridX`, `FlipbookGridY`, and `FlipbookFPS` are all set. Requires a non-empty `Texture`.

| Field                 | Default  | Variation      | Description                                                                     |
| --------------------- | -------- | -------------- | ------------------------------------------------------------------------------- |
| `FlipbookImageSize`   | `nil`    | fixed          | Full source image size in pixels, e.g. `Vector2.new(1024, 1024)`.               |
| `FlipbookGridX`       | `nil`    | fixed          | Column count (`integer >= 1`).                                                  |
| `FlipbookGridY`       | `nil`    | fixed          | Row count (`integer >= 1`).                                                     |
| `FlipbookFPS`         | `nil`    | fixed / random | Frames per second, e.g. `10` or `NumberRange.new(10, 20)` sampled per particle. |
| `FlipbookStartRandom` | `false`  | fixed          | Start on a random frame.                                                        |
| `FlipbookMode`        | `"Loop"` | fixed          | `"Loop"`, `"OneShot"`, `"PingPong"`, or `"Random"`.                             |

Derived at validation time:

- cell size = `FlipbookImageSize / Vector2.new(FlipbookGridX, FlipbookGridY)`
- frame count = `FlipbookGridX * FlipbookGridY` (row-major)

Runtime uses Roblox spritesheet cropping:

- `ImageRectSize` = cell size
- `ImageRectOffset` = current cell top-left
- `ScaleType` = `Stretch`

Modes:

- **Loop** — wrap from last frame back to first
- **OneShot** — play once and hold the final frame
- **PingPong** — reverse direction at either end
- **Random** — pick a new random frame each FPS step

Frame properties are written only when the frame index changes.

Example:

```lua
I.UIEmitter.new({
	Parent = fxLayer,
	Texture = "rbxassetid://111",
	FlipbookImageSize = Vector2.new(1024, 1024),
	FlipbookGridX = 4,
	FlipbookGridY = 4,
	FlipbookFPS = NumberRange.new(10, 20),
	FlipbookStartRandom = true,
	FlipbookMode = "PingPong",
	Lifetime = 2,
	Rate = 0,
}):Emit(1)
```

### Motion

| Field                   | Default   | Variation                         | Description                                                                                                                |
| ----------------------- | --------- | --------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `Velocity`              | `64`      | fixed / random / curve + envelope | Scalar speed, `Vector2`, `NumberRange`, or two-axis table. Curves update directional speed or vector motion over lifetime. |
| `Speed`                 | `nil`     | fixed / random / curve + envelope | When set, overrides the scalar part of directional velocity.                                                               |
| `Direction`             | `(0, -1)` | fixed / random / curve + envelope | Base launch direction (`Vector2` or two-axis table; sequence axes can curve).                                              |
| `SpreadAngle`           | `0`       | fixed / random / curve + envelope | Cone width in degrees with a stable per-particle spread roll.                                                              |
| `InitialVelocity`       | `nil`     | fixed (callback)                  | `(spawnAbsolutePoint: Vector2) -> Vector2?` after sampling.                                                                |
| `Gravity`               | `(0, 0)`  | fixed / random / curve + envelope | Acceleration in UI px/s². `Vector3` accepted (`Y` flipped); two-axis sequence tables can curve.                            |
| `Acceleration`          | `nil`     | fixed / random / curve + envelope | Alias for `Gravity`.                                                                                                       |
| `Drag`                  | `0`       | fixed / random / curve + envelope | Approximate exponential damping.                                                                                           |
| `Rotation`              | `0`       | fixed / random / curve + envelope | Initial degrees, or a lifetime rotation curve.                                                                             |
| `RotationSpeed`         | `0`       | fixed / random / curve + envelope | Degrees per second.                                                                                                        |
| `FaceMovementDirection` | `false`   | fixed                             | Rotate art to face velocity; `Rotation` becomes an offset.                                                                 |

### Shake

Enabled when `ShakeSpeed` is set.

| Field                         | Default | Variation                         | Description                                       |
| ----------------------------- | ------- | --------------------------------- | ------------------------------------------------- |
| `ShakeSpeed`                  | `nil`   | fixed / random / curve + envelope | Horizontal shake speed.                           |
| `ShakeDirectionChanges`       | `2..4`  | fixed / random                    | How many direction flips over lifetime.           |
| `ShakeDirectionBlendDuration` | `0.6`   | fixed / random / curve + envelope | Ease duration when flipping.                      |
| `ShakeLockVertical`           | `true`  | fixed                             | Lock vertical speed to upward drift.              |
| `HorizontalDrift`             | `nil`   | fixed / random / curve + envelope | Extra horizontal bias when not vertically locked. |

### Orbit

Enabled when `OrbitSpeed` is set. Replaces linear position integration.

| Field              | Default | Variation                         | Description                                        |
| ------------------ | ------- | --------------------------------- | -------------------------------------------------- |
| `OrbitSpeed`       | `nil`   | fixed / random / curve + envelope | Angular speed (sign also randomized per particle). |
| `OrbitRadius`      | `nil`   | fixed / random / curve + envelope | Radius in pixels.                                  |
| `OrbitRadiusScale` | `nil`   | fixed / random / curve + envelope | Radius as fraction of container min half-axis.     |

### Attraction

| Field                         | Default       | Variation                         | Description                                                               |
| ----------------------------- | ------------- | --------------------------------- | ------------------------------------------------------------------------- |
| `AttractTo`                   | `nil`         | fixed (or live GuiObject)         | `UDim2`, `Vector2`, `GuiObject`, or `(container) -> target`.              |
| `AttractToSpace`              | `"Container"` | fixed                             | `"Container"` or `"Absolute"` for `Vector2` targets.                      |
| `AttractAfter`                | `0`           | fixed / random                    | Delay in seconds before steering starts.                                  |
| `AttractStrength`             | `0`           | fixed / random / curve + envelope | Steering acceleration.                                                    |
| `AttractMaxSpeed`             | `0`           | fixed / random / curve + envelope | Speed cap; `0` = uncapped.                                                |
| `AttractArriveRadius`         | `0`           | fixed / random / curve + envelope | Arrival distance in pixels.                                               |
| `AttractStopOnArrive`         | `false`       | fixed                             | Snap/stop when arrived.                                                   |
| `AttractDestroyOnArrive`      | `false`       | fixed                             | Destroy particle when arrived.                                            |
| `AttractLiveFromEmitter`      | `false`       | fixed                             | Re-read numeric/bool attract fields from emitter each frame.              |
| `AttractPauseAtProgress`      | `nil`         | fixed / random                    | Hold lifetime at this progress (`0..1`) until release.                    |
| `AttractPauseMaxTime`         | `nil`         | fixed / random                    | Max **hold** time at the pause point (not total age).                     |
| `AttractReleaseDuration`      | `nil`         | fixed / random                    | After release/arrive-stop, compress remaining visuals over this duration. |
| `AttractArriveOnlyWhenPaused` | derived       | fixed                             | Defaults to `true` when `AttractPauseAtProgress` is set.                  |
| `AttractOnArrive`             | `nil`         | fixed (callback)                  | `(particle: GuiObject) -> ()` fired once on arrival.                      |

### Lifetime

| Field      | Default | Variation      | Description                                               |
| ---------- | ------- | -------------- | --------------------------------------------------------- |
| `Lifetime` | `1`     | fixed / random | Seconds alive. Not a curve — a duration sampled at spawn. |
| `LifeTime` | `nil`   | fixed / random | Alias for `Lifetime`.                                     |

### Emission / pooling

| Field                 | Default    | Variation      | Description                                                |
| --------------------- | ---------- | -------------- | ---------------------------------------------------------- |
| `Rate`                | `10`       | fixed          | Particles per second while playing.                        |
| `MaxParticles`        | `0`        | fixed          | Cap; `0` = unlimited. Also clamps pool size.               |
| `CullOffscreen`       | `true`     | fixed          | Periodically destroy particles outside the container rect. |
| `InitialParticles`    | `0`        | fixed          | Warm-start count on first `:Play()`.                       |
| `InitialAgeProgress`  | `0.2..0.7` | fixed / random | Normalized age for warm-started particles.                 |
| `InitialSpawnPerStep` | `nil`      | fixed          | Warm-start spawn budget per frame (default `2`).           |

---

## Performance notes

- One shared `Heartbeat` connection drives every active emitter; it disconnects when no emitter has work. Each emitter step is isolated with `pcall`, and an emitter that fails three frames in a row is paused and cleared instead of erroring every frame.
- Delta time is clamped; spawn rate is budgeted per frame to avoid hitch cascades.
- Layout (`AbsolutePosition` / `AbsoluteSize` of Parent and Container) is read once per emitter per frame or burst, never per particle.
- `NumberSequence` / `ColorSequence` values are flattened once into cached Lua arrays, so frames never touch `.Keypoints`. Flat curves collapse to constants.
- Particle motion uses Luau-native `Vector3` math (allocation-free) internally; `Vector2` appears only at API boundaries.
- Property writes are change-detected and quantized: position to whole pixels, color and transparency to 8-bit steps, rotation to 0.1°, scale sizes to 1/10000. Particles whose visuals cannot change (constant size, color, transparency, rotation) skip the visual pass entirely.
- Particles are pooled per class (`ImageLabel` vs `Frame`, up to 256 per emitter). Pooled particles stay parented with `Visible = false`; reparenting costs far more than toggling visibility. They still show up in `Parent:GetChildren()` as hidden `UIParticle` objects until `:Destroy()`.
- Live particles are stored in a dense array with swap-remove, so deaths are O(1).
- Offscreen culling runs every `CULL_INTERVAL` against the container rect of that frame (it follows resizes); a particle is not culled during its first interval.
- `AttractTo` is resolved once per emitter per frame, not per particle. Flipbook `ImageRectOffset` writes happen only on frame changes.
- For big first bursts, call `:Prewarm(n)` while loading so `:Emit` reuses hidden particles instead of creating and parenting new ones.

---

## Internal layout

```
UIEmitter/
  init.lua              -- public facade + InjectUme
  _types.lua            -- UIEmitter_Params / Instance / Ume_Library_UIEmitter
  README.md
  Scripts/
    Emitter.lua         -- New, Emit/Play/Stop/Clear/Destroy, config proxy
    Scheduler.lua       -- shared Heartbeat registry
    Particle.lua        -- spawn, visuals, flipbook, pooling
    Attraction.lua      -- steering / pause / arrive
    Config.lua          -- normalize + validate
    Defaults.lua        -- keys, defaults, tunables
    Sampler.lua         -- random + sequence helpers
```
