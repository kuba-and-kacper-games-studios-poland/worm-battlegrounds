# HoverInfo

An info box that shows over a hovered element of any gui: its name, its rarity in its look and the rarity's colour on
a line along the top, its tier, a row per stat, its level with an XP bar, and a row per enchantment, each part hidden
when the element has none. One shared box, in the `HoverInfo` gui, serves every gui. An element opts in with the
`HoverInfo_Target` tag (in its gui's table), and gets its content from a provider a module registers
(`HoverInfo_Provider`), or from its own `HoverInfo_Title` and `HoverInfo_Rarity` attributes. The box shows while the
mouse is over the element, while a finger holds it (a long press), or while a gamepad has it (or something inside it)
picked. It stays by the pointer and inside the screen: right of and under the mouse, centred above the element for a
finger or a gamepad. It hides when the pointer leaves, on a mouse press, and when the element is destroyed or stops
being shown.

| | |
| --- | --- |
| Folder | `src/modules/Main/HoverInfo` |
| Runs on | Client |
| Exposes | `I.HoverInfo` (client) |
| Uses | `I.UserInterface` (the `HoverInfo` gui), `I.Component`, `I.Rarity` (`GetLook`, `ApplyLook`), `I.Utils` (`IsGuiShown`), `I.Platform` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The box: drawing a content, placing it by the pointer, following a gamepad's pick, the screen scale, the providers, `I.HoverInfo` |
| `Components/Target.lua` | `HoverInfo_Target`: shows and hides the box on the mouse and on a long press |
| `Settings.lua` | The gui, the screen scale, the pointer gap and edge margin, the no-rarity colour, the enchantment numerals |
| `_meta/_types.lua` | `HoverInfo_Content`, `HoverInfo_Stat`, `HoverInfo_Badge`, `HoverInfo_Level`, `HoverInfo_Enchantment`, `HoverInfo_Provider`, `HoverInfo_Input` |

## API

### Client: `I.HoverInfo`

| Function | Returns | What it does |
| --- | --- | --- |
| `Show(target: GuiObject, input: HoverInfo_Input?)` | | Shows the box for an element, filled from `GetContent`, placed for `input` (`"Mouse"` by default, `"Touch"`, `"Gamepad"`); an element with no content hides the box. `HoverInfo_Target` calls it |
| `Hide(target: GuiObject?)` | | Hides the box; with a `target`, only when it shows for that element |
| `RegisterProvider(name: string, provider: HoverInfo_Provider)` | | Names the function that gives the content of the elements whose `HoverInfo_Provider` is `name`; warns when the name is taken |
| `GetContent(target: GuiObject)` | `HoverInfo_Content?` | What the box shows for an element: its provider's content, else `{ Name = HoverInfo_Title, Rarity = HoverInfo_Rarity }`, else nil. Warns for a provider that isn't registered |

A content (`HoverInfo_Content`) has `Name`, and optionally `Rarity` (a name `I.Rarity` has a look for), `Tier`,
`Stats` (`{ Label, Value, Color?, Badge? }`: `Color` tints the value, `Badge` is a `HoverInfo_Badge`, `{ Text, Colors, Stroke }`, a short mark after the label in a three-colour gradient, as a stat's grade), `Level` (`{ Level, Xp, Progress }`: `Xp` is the text right of the level, `Progress` 0 to
1 fills it, and an empty bar hides its fill) and `Enchantments` (`{ Name, Level }`, the level written in `NUMERALS`).

## Usage

```lua
-- Client: give the info of every element tagged HoverInfo_Target with HoverInfo_Provider = "Pets"
I.HoverInfo.RegisterProvider("Pets", function(target: GuiObject)
	local pet = petsBySlot[target]
	if not pet then
		return nil
	end
	return {
		Name = pet.Name,
		Rarity = pet.Rarity,
		Stats = { { Label = "Luck", Value = `x{pet.Luck}` } },
	}
end)
```

In the gui's table, tag the element (a slot, a card, a button):

```lua
Tags = { HoverInfo_Target = { HoverInfo_Provider = "Pets" } },
-- or, for a fixed text: HoverInfo_Target = { HoverInfo_Title = "Golden Key", HoverInfo_Rarity = "Legendary" }
```

## Network

No remotes or Topics: everything it shows comes from the client's own data, through the providers.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `GUI_NAME` | `"HoverInfo"` | The gui the box is drawn in |
| `DESIGN_HEIGHT`, `SMALL_SCREEN`, `MOBILE_BOOST` | `1080`, `500`, `1.3` | `S_ScreenScale` is the screen's height over `DESIGN_HEIGHT`, ×`MOBILE_BOOST` on Mobile screens shorter than `SMALL_SCREEN`, as every window |
| `POINTER_GAP` | `18` | Pixels between the pointer (or the element) and the box |
| `EDGE_MARGIN` | `8` | Pixels the box keeps from the screen's edges |
| `ACCENT_COLOR` | `Color3.fromRGB(154, 163, 173)` | The top line for an item with no rarity, the gui's common grey |
| `NAME_WIDTH`, `NAME_TEXT_SIZE`, `NAME_HEIGHT` | `308`, `30`, `36` | The name's width and text size at 1080, and its height for one line: a longer name wraps and the label grows to fit it |
| `NUMERALS` | `I` … `X` | How enchantment levels are written; a higher level is written as a number |

## In the place

| Instance | What |
| --- | --- |
| `StarterGui.HoverInfo` | An export of ume-gui's `System/HoverInfo` (or the game's own copy) (`DisplayOrder` 50, always enabled, `IgnoreGuiInset`, tagged `UserInterface_PreventHiding`): `U_HoverInfo` (hidden until shown; the module sets its height to `S_Content`'s) with `S_ScreenScale`, `S_Accent`, `S_Content`, `S_Divider`, `U_Header` (`S_Top` with `S_Rarity`, `S_RarityGlow`, `S_Tier`; `S_Name`), `U_Stats` with `PREFAB \| Stat` (`S_Label`, `S_Value`), `U_Level` (`S_Level`, `S_Xp`, `S_XpFill`) and `U_Enchantments` with `PREFAB \| Enchantment` (`S_Name`, `S_Level`) |

## Components

### `HoverInfo_Target` (`Components/Target.lua`)

Shows the box while the mouse is over the element (not for the mouse events a tap sends) and while a finger holds it
(`TouchLongPress`), and hides it when the mouse leaves or the finger lifts. A gamepad's pick (`GuiService.SelectedObject`,
or anything inside a target) is followed by `Client.lua`. Skips copies in ReplicatedStorage and StarterGui.

| Tag on | Side | Needs |
| --- | --- | --- |
| `GuiObject` | `RegisterOnLoaded` (client) | The `HoverInfo` gui |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `HoverInfo_Provider` | string | `""` | The registered provider that gives the element's content (`BackpackPlus` for its slots) |
| `HoverInfo_Title` | string | `""` | Without a provider: the name shown |
| `HoverInfo_Rarity` | string | `""` | Without a provider: the rarity shown with the title |
