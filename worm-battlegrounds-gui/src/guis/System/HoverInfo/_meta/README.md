# HoverInfo

The info box of ume's HoverInfo module, shown over a hovered element of any gui: WidgetManager_Message's dark panel
with a line in the item's rarity colour along its top, the rarity and tier over the name, a row per stat, the level
with its XP bar, and a row per enchantment. It is made of `Primitive` nodes, plain Roblox instances that hold every
value themselves, so no theme changes it. It is laid out for a 1080 px tall screen and scaled by its `S_ScreenScale`.
ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/HoverInfo"` |
| Modes | Night only |
| Devices | Desktop, Mobile: the Mobile preview adds the touch boost (`S_ScreenScale` ×1.3 on screens shorter than 500 px) |
| Export | A ScreenGui named `HoverInfo` in StarterGui: always enabled, `DisplayOrder` 50 (over every window), `IgnoreGuiInset` on, tagged `UserInterface_PreventHiding` so the UserInterface server leaves it on |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_HoverInfo` | Frame | The box, 340 wide at 1080, hidden until something is hovered; the module places it by the pointer and sets its height to `S_Content`'s |
| `U_HoverInfo` › `S_ScreenScale` | UIScale | Scales the box for the screen: the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px |
| `U_HoverInfo` › `S_Accent` | Frame | The 4 px line just inside the top edge, tinted in the item's rarity colour (a grey for an item with none) |
| `U_HoverInfo` › `S_Content` | Frame | Everything the box shows, top to bottom; it grows with its rows |
| `U_HoverInfo` › `S_Divider` | Frame | A faint line under the header, hidden when the item has nothing under it |
| `U_Header` › `S_Top` | Frame | The top line: hidden when the item has neither a rarity nor a tier |
| `U_Header` › `S_Rarity`, `S_RarityGlow` | TextLabel | The rarity, in its own look: ume's Rarity module writes its font, gradient (`UIGradient`), outline (`UIStroke`) and its glow behind it |
| `U_Header` › `S_Tier` | TextLabel | The tier in spaced capitals, `TIER 3`, on the right |
| `U_Header` › `S_Name` | TextLabel | The name, Work Sans ExtraBold 30; the module sets its height for the lines it wraps to |
| `U_Stats` | Frame | The stats, one `PREFAB \| Stat` each |
| `U_Level` › `S_Level`, `S_Xp`, `S_XpFill` | TextLabel, TextLabel, Frame | The level, the XP text right of it, and the bar's fill (its width the share of the way to the next level; hidden when empty) |
| `U_Enchantments` | Frame | The enchantments, one `PREFAB \| Enchantment` each |

## Prefabs

### `PREFAB | Stat`

In `U_Stats`, 30 tall: `S_Label` (the stat's name in spaced capitals, Source Sans Pro Heavy 22 in grey), `S_Badge`
(a short mark after it in its own gradient and outline, as a grade, hidden unless the stat has one) and `S_Value` (the
value on the right, Work Sans ExtraBold 22; the module may tint it).

### `PREFAB | Enchantment`

In `U_Enchantments`, 30 tall: `S_Name` and `S_Level` (the level in roman numerals), Work Sans ExtraBold 22 in violet.

## Driven by

ume's HoverInfo module (`src/modules/Main/HoverInfo/Client.lua`) finds this gui as `I.UserInterface.UI["HoverInfo"]`
and every Id above. It writes a content into the box, hides the parts the item doesn't have, keeps the box by the
pointer and inside the screen, and sets `S_ScreenScale` and the box's height. Elements tagged `HoverInfo_Target` show
it (the module's README).

## Preview

`Preview.lua` (`UmeGui_Guis_System_HoverInfo_Preview`) shows an example item: a Rare `Golden Sword`, tier 3, four
stats (one with a grade badge, one tinted gold), its level with the XP set in the preview, and up to four
enchantments. Its settings: **Level** (show the level), **XP** (the share of the bar) and **Enchantments** (how many).
The rarity keeps the gui's own Rare look; in game ume's Rarity module draws each rarity in its own.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `HoverInfo`. ume's UserInterface
   module moves it into each player's `PlayerGui` and keeps it as `I.UserInterface.UI["HoverInfo"]`.
2. A restyled copy keeps its `Name`, every `U_` and `S_` Id, the prefab names, the `UIGradient` and `UIStroke` inside
   `S_Rarity`, `S_RarityGlow` and `S_Badge`, and its `UserInterface_PreventHiding` tag.
3. ume modules: `Main/HoverInfo` draws it; `Utils/Rarity` writes the rarity's look; `Main/2_BackpackPlus` registers
   the provider for its slots.

### Input

| What | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Show an element's info | Hover it | Hold it (a long press) | Pick it | `HoverInfo_Target` on the element; the module follows a gamepad's pick |
| Hide it | Move off, or press the mouse | Lift the finger | Pick something else | The same |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Rest | The panel (`Background`) | WidgetManager_Message's: a black gradient from 0.35 to 0.65 transparency, a 3 px black outline and a white highlight along the top, 8 px corners |
| Rest | `S_XpFill` | `System/_Primitives_ButtonsColors`' Accept green (`Color3.fromRGB(50, 195, 24)` to `Color3.fromRGB(154, 255, 23)`) with the System buttons' white inner highlight, in a dark 20 px track outlined 3 px |
| Screen size | `S_ScreenScale` | Screen height / 1080; ×1.3 on Mobile screens shorter than 500 px. Strokes inside it carry no `Utils_UIStroke`, since the UIScale already scales them |
