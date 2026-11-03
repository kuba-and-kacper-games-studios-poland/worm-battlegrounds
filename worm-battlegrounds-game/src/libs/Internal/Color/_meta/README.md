# Color

Colour helpers: sample and remap `ColorSequence`s, measure luminance, tint.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Color` |
| Exposes | `I.Color` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Every function |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Color.GetColorAtTime(sequence: ColorSequence, goalTime: number)` | `Color3` | Returns the interpolated color of a ColorSequence at `goalTime` (clamped to the sequence). |
| `I.Color.GetColorLuminance(color: Color3)` | `number` | Returns the perceptual grayscale luminance of a color (0–1). |
| `I.Color.ToGrayscaleTint(color: Color3, tintColor: Color3)` | `Color3` | Converts a color to grayscale, then scales `tintColor` by that luminance. |
| `I.Color.MapColorSequence(sequence: ColorSequence, mapper: (color: Color3) -> Color3)` | `ColorSequence` | Returns a ColorSequence with every keypoint color passed through `mapper`. |
| `I.Color.LerpColorSequence(fromSequence: ColorSequence, toSequence: ColorSequence, alpha: number)` | `ColorSequence` | Interpolates between two ColorSequences at the keypoint times of `fromSequence`. `toSequence` is sampled at those times, so the keypoint counts do not have to match. |

## Usage

```lua
local mid: Color3 = I.Color.GetColorAtTime(gradient.Color, 0.5)
```
