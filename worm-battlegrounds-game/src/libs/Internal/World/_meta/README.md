# World

3D helpers: move models and characters, weld, turn off collisions, scale to a size in studs, move the pivot, and point-in-region and facing checks.

| | |
| --- | --- |
| Folder | `src/libs/Internal/World` |
| Exposes | `I.World` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Every function |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.World.MoveModelToPosition(model: Model, goalPos: CFrame)` |  | Moves a model so the bottom of its bounding box sits on `goalPos` instead of its pivot. |
| `I.World.MoveCharacterToPosition(character: Model, goalPos: CFrame)` |  | Moves a character so the midpoint of its foot attachments stands on `goalPos`. |
| `I.World.Weld(rootPart: BasePart, model: Model)` | `{ WeldConstraint }` | Welds every BasePart in the model to `rootPart` and unanchors them. |
| `I.World.DisableCollisions(instance: Instance)` |  | Disables collision, touch, and query on `instance` and every BasePart under it. |
| `I.World.ScaleModelToStuds(model: Model, x: number?, y: number?, z: number?)` |  | Uniformly scales a model so it fits inside the given stud dimensions (omitted axes are ignored). |
| `I.World.AdjustModelOriginOffset(model: Model, xRatio: number?, yRatio: number?, zRatio: number?)` |  | Moves the model's pivot to a point inside its bounding box without moving the model. Ratios run from 0 to 1 per axis (0.5 is the center); omitted axes stay centered. |
| `I.World.IsPointInRegion(point: Vector3, regionCFrame: CFrame, regionSize: Vector3)` | `boolean` | Returns whether a point is inside an oriented box. |
| `I.World.IsPointInModel(point: Vector3, model: Model)` | `boolean` | Returns whether a point is inside the model's bounding box. |
| `I.World.IsFacing(pos1: CFrame, pos2: CFrame, maxAngleDegrees: number)` | `boolean` | Returns whether `pos1` looks at `pos2` within `maxAngleDegrees`. Coincident positions count as facing. |
