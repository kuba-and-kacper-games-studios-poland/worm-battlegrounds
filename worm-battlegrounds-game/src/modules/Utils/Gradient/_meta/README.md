# Gradient

Named gradients for guis. Every `UIGradient` placed under the framework's `Gradient` storage folder is stored by its name (Color, Offset, Rotation, Transparency); code applies one by name (`label.UIGradient.Color = I.Gradient.GetColor("Gold")`) so a gradient is designed once and reused everywhere.

| | |
| --- | --- |
| Folder | `src/modules/Utils/Gradient` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.Gradient` (both) |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | Storing gradients from the storage folder, the getters |
| `_meta/_types.lua` | `Gradient_GradientTable` |

## API

### Global: `I.Gradient`

An unknown name returns the white `_default` gradient's value, or `nil` when `returnDefault` is `false`. The first lookup of each unknown name warns in Output (`Gradient (name) is missing - using _default.`); a `nil` name and `returnDefault = false` stay silent.

| Function | Returns | What it does |
| --- | --- | --- |
| `Set(gradientName: string, gradientData: Gradient_GradientTable \| UIGradient)` | | Stores or replaces a gradient |
| `Get(gradientName, returnDefault: boolean?)` | `Gradient_GradientTable?` | Every value of the gradient |
| `GetColor(gradientName, returnDefault?)` | `ColorSequence?` | |
| `GetOffset(gradientName, returnDefault?)` | `Vector2?` | |
| `GetRotation(gradientName, returnDefault?)` | `number?` | |
| `GetTransparency(gradientName, returnDefault?)` | `NumberSequence?` | |

## Usage

```lua
header.UIGradient.Color = I.Gradient.GetColor("Gold")
```

## In the place

| Instance | Where | What |
| --- | --- | --- |
| `Gradient` (Folder) | the framework's replicated folder (`I.Dirs.UmeReplicated`) | Holds the named `UIGradient`s read at start |
