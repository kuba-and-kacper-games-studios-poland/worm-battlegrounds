# _Primitives_ButtonsAnimations

A lookup of every button animation ume's Utils ships: one button per `Utils_ScaleAnimation` preset (the entries in ume's `src/modules/Utils/Utils/Data/ButtonScalePresets.lua`), labelled with the preset's name. Every button is a copy of WidgetManager_Message's OK button, so only the animation differs. Open it in the Gui tool and hover, press and release them to compare, then copy the `Tags` into a gui. Its button colors are in `System/_Primitives_ButtonsColors`. It is made of `Primitive` nodes on a transparent frame, with no panel or background, and is never exported: no game module uses it. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/_Primitives_ButtonsAnimations"` |
| Modes | Night only: its values are its own, the same in any mode |
| Export | None: a lookup for the Gui tool |

It has no `Preview` size, so the Gui tool shows it over the whole viewport, without the shadow it draws under sized previews.

## Elements

| Element | Class | What it is |
| --- | --- | --- |
| `U_Buttons` | Frame | The transparent root: 24 px padding and a centred `UIGridLayout` of 210 × 60 px cells, 24 px apart |
| `S_<Preset>` | ImageButton | In `U_Buttons`, one per preset, grouped as in the presets file: `S_Default`, `S_Snappy`, `S_Soft`, `S_Heavy` (plain), `S_Bouncy`, `S_Spring`, `S_Jelly`, `S_Pop`, `S_Squish`, `S_Pulse`, `S_Rubber`, `S_Slam` (bouncy), `S_Wiggle`, `S_Tilt`, `S_Swing`, `S_Shake` (rotating). Each sits in a `<Preset>Container` frame: WidgetManager_Message's OK button with the preset's name as its text |

Every button carries the same tags, so only the animation differs:

```lua
Tags = {
	Utils_ButtonScale = { Utils_ScaleAnimation = "<Preset>" },
	Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
}
```

## Driven by

Nothing in game. In the Gui tool the Utils components bundled with the Ume plugin animate and sound the buttons, the same code a game runs. The plugin bundles its own UmeGui copy, so a changed preset shows there after ume-rbx's `./scripts/Sync.ps1 Gui -Local` and a plugin rebuild.

## Preview

`Preview.lua` (`UmeGui_Guis_System__Primitives_ButtonsAnimations_Preview`) adds one button, **Press all**: it plays a press on every button in reading order, 0.35 s apart, with its click sound (`preview.PlayPress`), so each preset's press and release can be watched without the mouse. A Gui tool too old to pass `PlayPress` gets a warning instead.

## Integration

### Setup

Not exported. To add a preset, add its entry to ume's `Utils/Data/ButtonScalePresets.lua`, run `./scripts/Sync.ps1 Libs`, and add its button here in the same place.

### Input

| Action | Mouse and keyboard | Touch | Gamepad |
| --- | --- | --- | --- |
| Play a preset | Hover a button, then press and release it | Tap a button | None |
| Press every button | The Gui tool's **Press all** | | |

### Looks

| State | Element | Look |
| --- | --- | --- |
| Rest, hover, press | Each `S_<Preset>` button | Its preset (ume's Utils README lists the feel of each), around ButtonScale's default hovered scale of 1.04 and pressed scale of 0.95; the Accept green of `System/_Primitives_ButtonsColors` |
