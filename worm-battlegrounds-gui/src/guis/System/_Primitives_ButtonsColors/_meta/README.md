# _Primitives_ButtonsColors

A lookup of the button colors to build System-styled guis from: one button per gradient, labelled with its name. Every button is a copy of WidgetManager_Message's OK button with the `Default` animation and that gradient on its front and back, so only the color differs. The first three are the gradients the System guis' own buttons use; the rest are ume's `I.Gradient` palette (the `UIGradient`s in the place's `ReplicatedStorage.Ume.Gradient`), which a game module applies by name. Pick a button's color here before writing a gui. Its animations are in `System/_Primitives_ButtonsAnimations`. It is made of `Primitive` nodes on a transparent frame, with no panel or background, and is never exported. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/_Primitives_ButtonsColors"` |
| Modes | Night only: its values are its own, the same in any mode |
| Export | None: a lookup for the Gui tool |

It has no `Preview` size, so the Gui tool shows it over the whole viewport, without the shadow it draws under sized previews.

## Colors

Every gradient runs bottom to top (`Rotation = -90` on the button's `UIGradient`s).

| Button | Source | Gradient (bottom → top) | Use it for |
| --- | --- | --- | --- |
| `Accept` | System guis | `50, 195, 24` → `154, 255, 23` | OK, accept, confirm: WidgetManager_Message's OK and WidgetManager_Confirmation's Accept |
| `Cancel` | System guis | `186, 0, 0` → `255, 62, 62` | Decline, cancel: WidgetManager_Confirmation's Decline |
| `Close` | System guis | `226, 0, 0` → `255, 100, 48` | The X that closes a widget |
| `Blue` | `I.Gradient` | `0, 195, 255` → `0, 251, 255` | |
| `Brown` | `I.Gradient` | `112, 77, 61` → `190, 123, 69` | |
| `Cyan` | `I.Gradient` | `0, 221, 255` → `150, 252, 244` | |
| `Gold` | `I.Gradient` | `255, 183, 0` → `252, 231, 0` | |
| `Gray` | `I.Gradient` | `130, 143, 162` → `205, 220, 252` | |
| `Green` | `I.Gradient` | `90, 221, 29` → `153, 255, 0` | |
| `Orange` | `I.Gradient` | `255, 115, 0` → `255, 213, 0` | |
| `Pink` | `I.Gradient` | `217, 25, 255` → `255, 146, 250` | |
| `Purple` | `I.Gradient` | `122, 60, 255` → `232, 105, 255` | |
| `Red` | `I.Gradient` | `243, 24, 24` → `255, 105, 105` | |
| `Silver` | `I.Gradient` | `169, 172, 175` → `232, 238, 244` (at 0.5) → `169, 172, 175` | |
| `White` | `I.Gradient` | `191, 202, 217` → `255, 255, 255` | |
| `Yellow` | `I.Gradient` | `255, 234, 0` → `255, 239, 120` | |

The palette rows copy the place's `ReplicatedStorage.Ume.Gradient` as it was on 2026-10-19; a game that changes those gradients changes what `I.Gradient.GetColor(name)` gives at runtime, not this lookup.

## Elements

| Element | Class | What it is |
| --- | --- | --- |
| `U_Buttons` | Frame | The transparent root: 24 px padding and a centred `UIGridLayout` of 210 × 60 px cells, 24 px apart |
| `S_<Color>` | ImageButton | In `U_Buttons`, one per row of the table above, each in a `<Color>Container` frame: WidgetManager_Message's OK button (white inner highlight, gloss, outlined white text) with that gradient on its `Background_Front` and `Background_Back` |

Every button carries the same tags:

```lua
Tags = {
	Utils_ButtonScale = {},
	Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
}
```

## Driven by

Nothing in game. In the Gui tool the Utils components bundled with the Ume plugin animate and sound the buttons.

## Integration

### Setup

Not exported. When a System gui gets a new button color, or the place's `Gradient` folder changes, add or change its button here and its row above.

### Input

| Action | Mouse and keyboard | Touch | Gamepad |
| --- | --- | --- | --- |
| Hover or press a button | Hover, then press and release it | Tap a button | None |

### Looks

| State | Element | Look |
| --- | --- | --- |
| Rest, hover, press | Each `S_<Color>` button | Its gradient (above), ButtonScale's `Default` preset at the default hovered scale of 1.04 and pressed scale of 0.95 |
