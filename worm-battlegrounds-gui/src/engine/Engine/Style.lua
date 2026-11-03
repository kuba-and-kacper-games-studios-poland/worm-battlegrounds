--[[
	Created By: 	Nari
]]

local _localName: string = "Style"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class UmeGui_Engine_Style
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Merge

--[[
	Returns a new table with `override` laid over `base`. Nested records merge; arrays and other values replace.
]]
--- @param base { [any]: any } | nil
--- @param override { [any]: any } | nil
--- @return { [any]: any }
function Module.Merge(base, override)
	--[[ Local Variables ]]

	local merged = {} --- @type { [any]: any }

	--[[ Base ]]

	for key: any, value: any in pairs(base or {}) do
		merged[key] = if type(value) == "table" and value[1] == nil then Module.Merge(value, nil) else value
	end

	--[[ Override ]]

	for key: any, value: any in pairs(override or {}) do
		-- Merge records, replace arrays and plain values
		if type(value) == "table" and value[1] == nil and type(merged[key]) == "table" then
			merged[key] = Module.Merge(merged[key], value)
		else
			merged[key] = value
		end
	end

	--[[ Returning ]]

	return merged
end

--%%%%%%%%%%%%%%%%%%%% Resolve

--[[
	Returns a control's final style: Default, then each variant named in `spec`, then `spec`'s own keys.
	`spec` is a variant name (`"Primary"`) or a table (`{ "Primary", "Small", Fill = "Accent" }`).
]]
--- @param theme UmeGui_Theme
--- @param spec string | { [any]: any } | nil
--- @return UmeGui_Style
function Module.Resolve(theme, controlName: string, spec)
	--[[ Data ]]

	local variants = theme.Styles[controlName] --- @type { [string]: UmeGui_Style }?

	-- Check if the theme styles this control
	if not variants or not variants.Default then
		error(`[{_localName}]: Theme ({theme.Name}) has no Default style for ({controlName})!`, 0)
	end

	--[[ Local Variables ]]

	local style = Module.Merge(variants.Default, nil) --- @type UmeGui_Style
	local variantNames = if type(spec) == "string" then { spec } elseif type(spec) == "table" then spec else {} --- @type { [any]: any }

	--[[ Variants ]]

	for _index: number, variantName: string in ipairs(variantNames) do
		local variant = variants[variantName] --- @type UmeGui_Style?

		-- Check if the variant exists
		if not variant then
			error(`[{_localName}]: ({controlName}) has no style variant ({variantName})!`, 0)
		end

		style = Module.Merge(style, variant)
	end

	--[[ Overrides ]]

	-- Lay the node's own keys over the variants
	if type(spec) == "table" then
		local overrides = {} --- @type { [string]: any }
		for key: any, value: any in pairs(spec) do
			if type(key) == "string" then
				overrides[key] = value
			end
		end
		style = Module.Merge(style, overrides)
	end

	--[[ Returning ]]

	return style
end

--%%%%%%%%%%%%%%%%%%%% Color

--[[
	Returns a Color3 for a style value: a palette token for the mode, or a literal Color3.
]]
--- @param theme UmeGui_Theme
--- @param overrides { [string]: Color3 }
--- @return Color3
function Module.Color(theme, mode: string, overrides, value: any)
	--[[ Checks ]]

	-- Literal colors pass through
	if typeof(value) == "Color3" then
		return value
	end

	--[[ Data ]]

	local color: Color3? = overrides[value] or theme.Tokens.Palette[mode][value]

	-- Check if the palette has the token
	if not color then
		error(`[{_localName}]: Palette ({mode}) has no color ({tostring(value)})!`, 0)
	end

	--[[ Returning ]]

	return color
end

--%%%%%%%%%%%%%%%%%%%% Number

--[[
	Returns a number for a style value: a token from the group (`Size`, `Radius`, `Spacing`, …) or a literal number.
]]
--- @param theme UmeGui_Theme
--- @return number
function Module.Number(theme, group: string, value: any)
	--[[ Checks ]]

	-- Literal numbers pass through
	if type(value) == "number" then
		return value
	end

	--[[ Data ]]

	local number: number? = theme.Tokens[group] and theme.Tokens[group][value]

	-- Check if the group has the token
	if not number then
		error(`[{_localName}]: Tokens.{group} has no value ({tostring(value)})!`, 0)
	end

	--[[ Returning ]]

	return number
end

--%%%%%%%%%%%%%%%%%%%% Icon

--[[
	Returns the image for an icon value: an icon name from the theme's Icons, or an image id (`rbxassetid://…`) as is.
	Nil or an empty name is no image.
]]
--- @param theme UmeGui_Theme
--- @return string
function Module.Icon(theme, value: string?)
	--[[ Checks ]]

	-- No icon, or an image id that passes through
	if value == nil or value == "" then
		return ""
	elseif string.find(value, "://", 1, true) then
		return value
	end

	--[[ Data ]]

	local image: string? = theme.Tokens.Icons and theme.Tokens.Icons[value]

	-- Check if the theme has the icon
	if not image then
		error(`[{_localName}]: Tokens.Icons has no icon ({value})!`, 0)
	end

	--[[ Returning ]]

	return image
end

--%%%%%%%%%%%%%%%%%%%% Font

--[[
	Returns a Font for a style value: a font token or a literal Font.
]]
--- @param theme UmeGui_Theme
--- @return Font
function Module.Font(theme, value: any)
	--[[ Checks ]]

	-- Literal fonts pass through
	if typeof(value) == "Font" then
		return value
	end

	--[[ Data ]]

	local token = theme.Tokens.Font[value] --- @type UmeGui_FontToken?

	-- Check if the font token exists
	if not token then
		error(`[{_localName}]: Tokens.Font has no font ({tostring(value)})!`, 0)
	end

	--[[ Returning ]]

	return Font.new(token.Family, Enum.FontWeight[token.Weight])
end

return Module
