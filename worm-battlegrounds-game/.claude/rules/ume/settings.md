# Ume settings

How a module's `Settings.lua` is written. Example: `docs/guides/settings-structure.md`.

## Shape

- One table, `local _settings = {`, typed by `--- @class ModuleName_Settings` directly above it, with no `@field`
  lines, and returned with `return _settings`. No author header (`luau/authorship.md`).
- Keys are UPPER_SNAKE_CASE constants. Nothing changes them at runtime.
- Settings never `require` other modules or `Scripts/`. A setting that needs a runtime API requires the Ume pointer and
  calls `I.*` inside a function, so it resolves when called. Another module's constants are read from code that has
  `I`: `I.Settings["ModuleName"]`.

## Categories

- A table of two or more keys puts every key under a category bar: `--%%%%%%%%%%%%%%%%%%%% Name` (20 `%`, Title Case),
  with a blank line above and below it. The first bar comes after the blank line that follows `{`. Never a
  `--[[ Name ]]` label as a category, and never an empty category.
- Inside a value (a row, a list), group with `--[[ Name ]]` labels (`luau/types.md` → Table sections).

## Comments

- A key whose purpose isn't obvious gets a comment above it; one comment may cover the keys right under it that go
  together (`ROW_FADE_AT`, `ROW_FADE_TIME`).
- Written as `luau/comments.md` → Outside functions says.
- `--- @type` only on a table value whose type isn't obvious, between the comment and the key.
- A blank line above every comment, `--- @type`, label and bar, after `{` too. Only the lines of one comment touch:
  the text, then `--- @type`, then the key.

```lua
--- @class Shop_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Timing

	-- Seconds into a row's slide where it starts to fade, and how long the fade takes.
	ROW_FADE_AT = 0.38,
	ROW_FADE_TIME = 0.3,

	--%%%%%%%%%%%%%%%%%%%% Gui

	--[[
		The price arrows' colours when a price goes up (green) or down (red): gradient top, bottom, then
		the outline.
	]]
	--- @type { Color3 }
	PRICE_UP_COLORS = { Color3.fromRGB(154, 255, 23), Color3.fromRGB(50, 195, 24), Color3.fromRGB(26, 112, 18) },

	--- @type { Color3 }
	PRICE_DOWN_COLORS = { Color3.fromRGB(255, 110, 100), Color3.fromRGB(220, 40, 40), Color3.fromRGB(120, 16, 16) },
}
return _settings
```

```lua
	-- BAD
	--[[ Gui ]]
	-- The price arrows' colours when a price goes up (green) or down (red): gradient top, bottom, then
	-- the outline.
	--- @type { Color3 }
	PRICE_UP_COLORS = { Color3.fromRGB(154, 255, 23), Color3.fromRGB(50, 195, 24), Color3.fromRGB(26, 112, 18) },
	--- @type { Color3 }
	PRICE_DOWN_COLORS = { Color3.fromRGB(255, 110, 100), Color3.fromRGB(220, 40, 40), Color3.fromRGB(120, 16, 16) },
```

The BAD block has three faults: a label where a bar belongs, a comment on stacked `--` lines, and a `--- @type`
touching the key above it.
