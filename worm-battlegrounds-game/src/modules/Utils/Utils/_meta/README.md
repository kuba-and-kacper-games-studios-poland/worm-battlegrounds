# Utils

Ready-made behaviours for guis and the world, applied by tag: button animations, sounds and keys, price tags and purchase-dependent visibility, per-device size, scale and visibility, resolution scalers for strokes, sliced images, grids and text, moving instances into place, and small animations (gradient scroll, hover, shake, spin, a text's shine, letters that move on their own). Designers tag instances in Studio, UmeGui guis carry the tags in their `Tags` tables, and code can `AddTag` at runtime: every component reads a missing attribute as its default and applies a changed attribute at once, so a tag works the same however it was added. A button's feedback is split across tags you combine: `Utils_ButtonScale` (or `Utils_ButtonTransform`) for the look, `Utils_ButtonSound` for the sounds, `Utils_ButtonKey` for a gamepad or keyboard key. ButtonScale's animations are presets in `Data/ButtonScalePresets.lua`, picked by name. Utils draws a key's press; ume's Interact module binds the keys and runs the button's callbacks (`I.Interact.OnPress`, `Interact_Button`). The Ume Roblox plugin's Gui tool runs the same Utils code (UmeGui mirrors it), so animations, sounds and keys behave the same in its preview.

| | |
| --- | --- |
| Folder | `src/modules/Utils/Utils` |
| Runs on | Client, Server |
| Exposes | `I.Utils` (client) |
| Uses | `I.Component`, `I.Sound`, `I.G_Marketplace`, `I.Network` (Group's `Group_IsMember`), `I.Replicator` (the Group folder), `I.Platform`, `I.HideOnPlay`, `I.Topic` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Starts the scaler scripts and the marketplace cache, registers the client components, `I.Utils` |
| `Server.lua` | Starts `MoveTo` |
| `Settings.lua` | The reference viewport size, price tag messages |
| `Data/ButtonScalePresets.lua` | ButtonScale's animations, one table of presets by name; the name is the `Utils_ScaleAnimation` value |
| `Components/Button/*.lua` | `Utils_ButtonKey`, `Utils_ButtonScale`, `Utils_ButtonSound`, `Utils_ButtonTransform` |
| `Components/Marketplace/*.lua` | `Utils_PriceTag`, `Utils_VisibleOnMarketplace` |
| `Components/Platform/*.lua` | `Utils_HideOnPlatform`, `Utils_PlatformScale`, `Utils_PlatformSize` |
| `Components/Scaler/*.lua` | `Utils_UIGrid`, `Utils_UITextSizeConstraint` (and the manifests of three tags handled by scripts) |
| `Components/Visual/*.lua` | `Utils_Motion`, `Utils_TextShine`, `Utils_UIGradientMove`, `Utils_UIHover`, `Utils_UIShake`, `Utils_UISpin` |
| `Components/Visual/LetterText/` | `Utils_LetterText` (`init.lua`), and `Motes.lua`, the motes it builds and moves |
| `Components/Utils/*.comp.json` | `Utils_MoveTo`, `Utils_MoveChildTo` (handled by `Scripts/MoveTo.lua`) |
| `Scripts/UIStrokeScaler.lua`, `UIStrokeScaler_Billboard.lua` | Scale tagged `UIStroke`s with the screen (or billboard) size; an untagged stroke gets its built thickness back. The billboard one skips a stroke while it is hidden (`GuiVisibility.IsShown`) |
| `Scripts/ImageSliceScaler.lua` | Scales tagged sliced images with the screen size; an untagged image gets its built slice scale back |
| `Scripts/MoveTo.lua` | Moves tagged instances (or their children) to their `Utils_Destination`, at start and whenever one is tagged later; each move in its own `pcall` |
| `Scripts/ButtonPress.lua` | The keyed buttons on screen and their presses: which shown button a key presses (the topmost gui's, the latest shown on a tie), and the press, release and activation the button components listen to |
| `Scripts/GuiVisibility.lua` | Tells the components whether their gui is shown (every `Visible` up the tree and the enclosing `ScreenGui` / `SurfaceGui` / `BillboardGui` `Enabled`): `Watch(instance, callback)` calls back on every change, following reparents; `IsShown(instance)` answers once. Every effect that moves a gui uses it to stop while hidden (the game's `practices.md` → Guis) |
| `Scripts/HideReasons.lua` | Hides an instance per reason (each component's tag), so HideOnPlatform and VisibleOnMarketplace don't undo each other |
| `Scripts/MarketplaceCache.lua` | One price and ownership cache for every price tag and marketplace visibility label; refreshes only the product a purchase or gift changed; the `Utils_InfoType` names |
| `_meta/_types.lua` | The animation rows, the ButtonTransform position entry, the press and visibility connections, LetterText's letter, sparkle and mote records |

## API

### Client: `I.Utils`

| Function | Returns | What it does |
| --- | --- | --- |
| `PressKey(keyCode: Enum.KeyCode, down: boolean)` | `GuiButton?`, `boolean` | Presses (`down`) or releases the shown `Utils_ButtonKey` button with that key, as a click would. The press picks the button on the gui with the highest `DisplayOrder` that takes input (`Interactable`), the latest shown on a tie, and plays its press; the release lets it go and activates it (its click sound) when it is still shown and takes input. Returns the button that took the key (nil when none did, and for A while gamepad navigation has a selection, which A presses itself; other keys still press their buttons then) and whether the release activated it. Interact calls it from its key binds |
| `PlayPress(button: GuiButton)` | | Plays a press on a button for an input that acted on it without a key of its own (a gamepad cycling the toolbar or the categories): its press look (`Utils_ButtonScale`, `Utils_ButtonTransform`), and 0.1 s later the release with its click sound (`Utils_ButtonSound`). Runs nothing the button does |
| `ConnectPress(button: GuiButton, phase: "Down" \| "Up" \| "Activated", callback: () -> ())` | `Utils_ButtonPressConnection` | Calls `callback` each time a key presses the button, lets it go, or activates it; for a button's own press look (TopBar's highlight). `Disconnect()` stops it |
| `IsGuiShown(instance: Instance)` | `boolean` | Whether every GuiObject from `instance` up is `Visible` and every ScreenGui, SurfaceGui or BillboardGui above it `Enabled` (`GuiVisibility.IsShown`); HoverInfo hides its box when the hovered element stops being shown |

## Usage

A button with an animation, the standard sounds and a key, as a UmeGui `Tags` table (the same attributes work in TagList+ or with `AddTag` and `SetAttribute`):

```lua
Tags = {
	Utils_ButtonScale = { Utils_ScaleAnimation = "Bouncy" },
	Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
	Utils_ButtonKey = { Utils_GamepadKey = "ButtonA", Utils_KeyboardKey = "E" },
}
```

## Network

Utils creates no remotes. `Scripts/MarketplaceCache.lua` listens to Marketplace's `Marketplace_AssetPurchaseSucceeded`, `Marketplace_BundlePurchaseSucceeded` and `Marketplace_GamePassPurchaseSucceeded`, and the marketplace components to `Marketplace_RobloxPlusUpdated` and invoke `Group_IsMember`.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DEFAULT_VIEWPORT_SIZE` | `1920 × 1080` | Screen size the scalers treat as 100% |
| `PRICETAG_MESSAGES` | `Error`, `Owned`, `Group`, `RobloxPlus` | Texts a price tag shows instead of a price |

## Components

All run on the client except `Utils_MoveTo` / `Utils_MoveChildTo`, which run on the server. `Utils_PriceTag` and `Utils_VisibleOnMarketplace` register after the player has loaded.

A missing attribute uses the default in the tables below, so a tag added by UmeGui or a runtime `AddTag` (which set only the attributes they are given) behaves like one set in TagList+. Changing an attribute on a tagged instance applies it at once, except on the marketplace components (`Utils_ProductName` on a price tag is the one live there) and `Utils_MoveTo` / `Utils_MoveChildTo`, which move once.

### Buttons

| Tag | Tag on | What it does |
| --- | --- | --- |
| `Utils_ButtonKey` | `ImageButton` or `TextButton` | Gives the button a gamepad key and a keyboard key that press it while it is shown (every `Visible` up the tree and its gui `Enabled`), as a click would (`Scripts/ButtonPress.lua`); Interact binds the keys |
| `Utils_ButtonScale` | `ImageButton` or `TextButton` | Plays its animation on hover, leave, press (click, touch or its key) and release. Plays no sound: add `Utils_ButtonSound` for that |
| `Utils_ButtonSound` | `ImageButton` or `TextButton` | Plays a sound on click, or when its key activates the button, and on hover |
| `Utils_ButtonTransform` | `GuiObject` | Scale, position and rotation on hover and click (or its button's key), plus an optional idle float |

| Attribute | On | Type | Default | What |
| --- | --- | --- | --- | --- |
| `Utils_GamepadKey`, `Utils_KeyboardKey` | ButtonKey | string | `""` | The `Enum.KeyCode` names of the keys that press the button (`ButtonA`, `ButtonB`, `Return`, `E`); empty for none. A name that isn't a KeyCode warns |
| `Utils_ScaleAnimation` | ButtonScale | string | `"Default"` | The animation (a preset in `Data/ButtonScalePresets.lua`, below). An unknown name warns and plays `Default` |
| `Utils_HoverScale`, `Utils_ClickScale` | ButtonScale | number | `1.04`, `0.95` | Scale while hovered / pressed, multiplied with the button's resting scale (its `UIScale`'s starting `Scale`, or PlatformScale's scale for the device) |
| `ClickSound_Name`, `HoverSound_Name` | ButtonSound | string | `"Button_Click"`, `"Button_Hover"` | Sound names (`I.Sound`); `""` plays nothing |
| `ClickSound_` / `HoverSound_` `Volume`, `SoundGroup`, `PlaybackSpeed`, `TimePosition`, `PitchMin`, `PitchMax` | ButtonSound | | `1`, `"UI"`, `1`, `0`, `1`, `1` | The sound's params; no pitch effect is added while both pitches are `1` |
| `Utils_ButtonTransform_EnableScale`, `_EnablePosition`, `_EnableRotation` | ButtonTransform | boolean | `true`, `false`, `false` | Which transforms run |
| `Utils_ButtonTransform_HoverScale`, `_ClickScale` | ButtonTransform | number | `1.04`, `0.95` | Multiplied with the resting scale, as on ButtonScale |
| `Utils_ButtonTransform_HoverPosition`, `_ClickPosition` | ButtonTransform | UDim2 | `0` | Offsets added to the object's starting position |
| `Utils_ButtonTransform_HoverRotation`, `_ClickRotation` | ButtonTransform | number | `0` | Degrees |
| `Utils_Hover`, `Utils_HoverOnHover`, `Utils_HoverOnClick` | ButtonTransform | boolean | `false`, `true`, `false` | The idle float and when it runs |
| `Utils_HoverOffset`, `Utils_HoverSpeed` | ButtonTransform | UDim2, number | `0`, `1` | The float's offset and speed; no float runs while the offset is `0` |

A hidden button goes back to rest (its resting scale and rotation), so it never shows again stuck hovered or pressed.

#### ButtonScale animations

Each entry in `Data/ButtonScalePresets.lua` is one animation (`Utils_ButtonScaleAnimation`), keyed by its name: four phases, `Hover`, `Leave`, `Press` and `Release`. A phase is a list of steps played one after another, each a tween of the button's `UIScale` (and its `Rotation`, when any step of the animation sets one):

| Step key | Type | What |
| --- | --- | --- |
| `Scale` | number | Multiplier of the scale the phase settles on: hovered for `Hover` (and `Release` while still hovered), pressed for `Press`, resting otherwise. `1` lands on it; the last step is usually `1` |
| `Rotation` | number? | Degrees added to the button's starting rotation; a step without one turns it back to `0` in an animation that rotates. A `Release` while still hovered adds them to the hover pose's rotation (the last `Hover` step's), so it lands back on that pose |
| `Time`, `EasingStyle`, `EasingDirection` | number, `Enum.EasingStyle`, `Enum.EasingDirection` | The step's tween |

A new phase stops the steps still to come of the one before. Add an animation by adding an entry; its key is the `Utils_ScaleAnimation` value. UmeGui's `System/_Primitives_ButtonsAnimations` gui shows every one on a button.

| Animation | Feel |
| --- | --- |
| `Default` | Quick grow on hover and a short shrink on press: the standard button feel |
| `Bouncy` | Overshoots and settles with a small bounce on every change |
| `Spring` | Springs past its size on hover and wobbles back after a click |
| `Jelly` | Wobbles like jelly: every change swings a few times before it rests |
| `Pop` | Plain hover, then a big burst on release that snaps back |
| `Squish` | Squeezes in slowly while held and bounces back up on release |
| `Snappy` | Near instant: every change lands in a few frames |
| `Soft` | Slow and smooth eases, for calm menus |
| `Wiggle` | Wiggles side to side on hover and on release (rotates) |
| `Tilt` | Tilts while hovered and leans the other way while held (rotates) |
| `Pulse` | Beats like a heart: a double pulse on hover and on release |
| `Heavy` | Weighty: slow to move and lands with a bounce |
| `Rubber` | Stretchy: elastic on hover and a long elastic snap after a click |
| `Swing` | Swings like a pendulum on hover and sways after a click (rotates) |
| `Shake` | Rattles side to side on hover and shakes hard after a click (rotates) |
| `Slam` | Lifts on hover, slams down hard on press and punches back up |

### Marketplace

| Tag | Tag on | What it does |
| --- | --- | --- |
| `Utils_PriceTag` | `TextLabel` | Shows the product's price (with a Robux icon), or `OWNED`, `JOIN GROUP`, `ROBLOX PLUS` |
| `Utils_VisibleOnMarketplace` | `GuiObject` | Visible only while the player doesn't own the product (or isn't in the group / Roblox Plus) |

| Attribute | On | Type | Default | What |
| --- | --- | --- | --- | --- |
| `Utils_ProductName` | both | string | `""` | A name from `src/global_data/Marketplace`, or `Group` / `RobloxPlus` with `Custom`; another `Custom` name warns |
| `Utils_InfoType` | both | string | `"GamePass"` | An `Enum.InfoType` name (`GamePass`, `Product`, `Asset`, `Bundle`), or `Custom` with `Utils_ProductName` `"Group"` or `"RobloxPlus"` |
| `Utils_CustomFormat` | PriceTag | string | `""` | `string.format` pattern for the price |
| `Utils_InsertRobuxIcon` | PriceTag | boolean | `true` | Prefix the Robux icon |
| `Utils_ForceGamePassCheck`, `Utils_CustomGamePassName` | PriceTag | boolean, string | `false`, `""` | Show `OWNED` from another game pass |
| `Utils_ShowIfMissing` | VisibleOnMarketplace | boolean | `true` | Visible when the player doesn't own the product |
| `Utils_CheckForGroup` | VisibleOnMarketplace | boolean | `false` | Group membership also counts as owning |

### Platform

| Tag | Tag on | What it does |
| --- | --- | --- |
| `Utils_HideOnPlatform` | any instance | Hides it on the devices whose visibility is `false` |
| `Utils_PlatformScale` | `GuiObject` | Adds a `UIScale` set per device (`0` keeps the built scale), and keeps that scale in the UIScale's `Utils_BaseScale` attribute so ButtonScale and ButtonTransform rest on it |
| `Utils_PlatformSize` | `GuiObject` | Sets `Size` per device (`0` keeps the built size) |

| Attribute | On | Type | Default |
| --- | --- | --- | --- |
| `Utils_DesktopVisibility`, `Utils_MobileVisibility`, `Utils_ConsoleVisibility`, `Utils_VRVisibility` | HideOnPlatform | boolean | `true` |
| `Utils_DesktopScale`, `Utils_MobileScale`, `Utils_ConsoleScale`, `Utils_VRScale` | PlatformScale | number | `0` |
| `Utils_DesktopSize`, `Utils_MobileSize`, `Utils_ConsoleSize`, `Utils_VRSize` | PlatformSize | UDim2 | `0` |

### Scalers

| Tag | Tag on | What it does |
| --- | --- | --- |
| `Utils_UIStroke` | `UIStroke` | Scales `Thickness` with the screen (`Scripts/UIStrokeScaler.lua`) |
| `Utils_UIStroke-Billboard` | `UIStroke` in a `BillboardGui` | The same for billboards, by distance (`Scripts/UIStrokeScaler_Billboard.lua`) |
| `Utils_SlicedImage` | sliced `ImageLabel` / `ImageButton` | Scales `SliceScale` with the screen (`Scripts/ImageSliceScaler.lua`) |
| `Utils_UIGrid` | `UIGridLayout` | Sizes cells so `Utils_RowAmount` fit across the parent's width (the inner width of a `ScrollingFrame`), following the layout to a new parent |
| `Utils_UITextSizeConstraint` | `UITextSizeConstraint` | Sets the text size range per device |

| Attribute | On | Type | Default | What |
| --- | --- | --- | --- | --- |
| `Utils_RowAmount` | UIGrid | number | `10` | Cells per row; a value not above `0` warns and uses `10` |
| `Utils_XScale`, `Utils_YScale` | UIGrid | number | `1` | Cell size multipliers |
| `Utils_Update` | UIGrid | boolean | | Set to `true` to resize the cells now; it turns itself back off |
| `Utils_DesktopSize`, `Utils_MobileSize`, `Utils_ConsoleSize`, `Utils_VRSize` | UITextSizeConstraint | NumberRange | `0` | Text size range per device, clamped to 1 to 100; another type warns and uses the built size |

The scalers keep each instance's built size in an attribute (`StrokeScaler_OriginalThickness`, `ImageSliceScaler_OriginalScale`).

### Moving

| Tag | Tag on | What it does |
| --- | --- | --- |
| `Utils_MoveTo` | any instance | Server: moves it into the instance its `Utils_Destination` ObjectValue points to |
| `Utils_MoveChildTo` | any instance | Server: moves its children there instead; removes itself after with `Utils_RemoveAfterMove` |

| Attribute or child | On | Type | Default | What |
| --- | --- | --- | --- | --- |
| `Utils_Destination` (ObjectValue child) | both | `Instance` | | Where to move |
| `Utils_RemoveAfterMove` | MoveChildTo | boolean | `true` | Destroy the emptied instance |

### Visual

| Tag | Tag on | What it does |
| --- | --- | --- |
| `Utils_LetterText` | `TextLabel` | Splits the text into letters that move, turn, grow and colour on their own by its `Utils_LetterEffects`, with halos, echoes, sparkles and motes. Without effects it does nothing and the label shows its own text, so a gui can carry the tag and code turn it on by writing the attributes. ume-gui's previews run this same component, from their copy of Utils (`src/engine/Libs/Mirror`) |
| `Utils_Motion` | `GuiObject`, `UIGradient` or `UIScale` | Plays one small looping motion, picked by `Utils_MotionKind`: `Spin`, `Rotate`, `Sweep`, `Glint`, `Breathe`, `Pulse`, `Twinkle`, `Travel`, `Drift`, `Flash`, `Flipbook`, `Turn`, `Hue`, `Float`. ume-gui's previews run this same component, so exported guis move as in their preview; it puts back what it moved when it stops |
| `Utils_TextShine` | `TextLabel` with a `UIGradient` | Drifts the gradient's colours up and down and sends a white glint across the letters (a white copy of the text, `Glint`, made on the first glint), as in ume-gui's previews, which run this same component. With neither drift nor glint it does nothing |
| `Utils_UIGradientMove` | `UIGradient` | Scrolls the gradient's colors |
| `Utils_UIHover` | `GuiObject` | Floats up and down |
| `Utils_UIShake` | `GuiObject` | Shakes while `Utils_Shake` is `true` |
| `Utils_UISpin` | `GuiObject` or `UIGradient` | Spins its rotation |

| Attribute | On | Type | Default | What |
| --- | --- | --- | --- | --- |
| `Utils_LetterEffects` | LetterText | string | `""` | The effects, comma separated. Motion: `Wave`, `Bounce`, `Shake`, `Pulse`, `Sway`, `Float`, `Orbit`, `Drip`, `Grow`, `Stomp`, `Glitch`, `Strike`. Colour: `Gradient`, `Rainbow`, `Flicker`, `OutlineCycle`, `Shimmer`, `Shade`, `Swap`, `Fade`. Extras: `Halo`, `Echo`, `Sparkle`, and the motes `Embers`, `Drops`, `Flakes`, `Comets`, `Rings`, `Gems`. Empty turns it off |
| `Utils_LetterIntensity`, `Utils_LetterSpeed` | LetterText | number | `1`, `1` | How strong and how fast the effects are |
| `Utils_LetterSpacing` | LetterText | number | `0` | Room between the letters, design px |
| `Utils_LetterColors` | LetterText | ColorSequence | | The letters' colours along the word (what `Gradient`, `OutlineCycle` and the extras use); without it they keep the label's `TextColor3` |
| `Utils_MotionKind` | Motion | string | `"Spin"` | The motion (above); an unknown kind does nothing |
| `Utils_MotionSpeed`, `Utils_MotionAmount` | Motion | number | `1`, the kind's | How fast, and how much (degrees, scale, transparency or frames, by kind) |
| `Utils_MotionPhase` | Motion | number | random | Seconds into its cycle it starts, so neighbours don't move in step |
| `Utils_MotionPath` | Motion | UDim2 | the kind's | The way a `Travel` or `Drift` element goes |
| `Utils_ShineColors` | TextShine | ColorSequence | the gradient's | Written to the gradient when set |
| `Utils_ShineDrift`, `Utils_ShineGlint` | TextShine | boolean | `false`, `false` | The colours drift (±0.18 of the height, every 5 s); a glint 1.2 text heights wide crosses in 0.8 s, every 2.6 s. Neither turns it off |
| `Utils_ShineSpeed` | TextShine | number | `1` | How fast both run |
| `Utils_MoveSpeed` | UIGradientMove | number | `1` | Scroll speed; `0` stops it |
| `Utils_SourceColor` | UIGradientMove | ColorSequence | | The authored colors, saved on the first bind so clones start from them; setting it recolors the gradient (stopped or scrolling). To recolor or stop a scroll, change this and `Utils_MoveSpeed` and keep the tag: removing it puts the old colors back |
| `Utils_HoverOffset`, `Utils_HoverSpeed` | UIHover | UDim2, number | `0`, `1` | Float offset and speed; `0` pauses it |
| `Utils_Shake`, `Utils_ShakeIntensity`, `Utils_ShakeFadeTime` | UIShake | boolean, number, number | `false`, `10`, `0.5` | Start a shake, its strength and fade |
| `Utils_SpinSpeed` | UISpin | number | `1` | Rotation speed; `0` pauses it |

The animated components pause while their gui isn't shown, follow it when the instance is moved to another container, and share one Heartbeat per component kind that runs only while something animates.

LetterText is the heaviest, so it does more to stay cheap on low-end devices:

- It builds its letters only while the label shows and only when the text, font or attributes changed: setting the same look again does nothing, and changes made together (a title's font and four attributes) build once, on the next resumption point.
- It reads where the letters sit only when the layout changes (the label's size, the guides' measured widths), not every frame, and writes only what its effects change: a word that only changes colour never writes a position.
- It steps at most about 60 times a second (`STEP_TIME`), and skips a label nobody can see this frame: scrolled out of its list's window, or on a billboard farther than its `MaxDistance`, behind the camera or off the screen.
- Inside a ScrollingFrame its letters sit in a CanvasGroup (turned letters aren't drawn there otherwise), the one costly part: keep moving labels in lists few, for example by hiding the rows of a closed section.
