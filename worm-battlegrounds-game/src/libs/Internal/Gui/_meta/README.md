# Gui

Gui helpers: fit a model into a viewport camera, and check whether the mouse is over a gui object.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Gui` |
| Exposes | `I.Gui` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Every function |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Gui.FitModelToViewportCamera(model: Model, camera: Camera, rotation: CFrame, x: number?, y: number?)` |  | Scales and places a model so it appears `x` by `y` studs wide in the camera view, accounting for `rotation`. Mutates the model (ScaleTo, PivotTo), so pass a preview clone rather than a live gameplay model. |
| `I.Gui.IsMouseOverObject(mouse: Mouse, guiObject: GuiObject)` | `boolean` | Returns whether the mouse is inside the GuiObject's absolute rect. |
