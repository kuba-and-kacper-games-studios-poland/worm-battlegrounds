--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--[[ Attributes ]]

--- @type { { string } }
local FONT_ATTRIBUTES = {
	{ "Color", "color" },
	{ "Size", "size" },
	{ "Font_Family", "family" },
	{ "Font_Face", "face" },
	{ "Font_Weight", "weight" },
	{ "Transparency", "transparency" },
}

--- @type { { string } }
local STROKE_ATTRIBUTES = {
	{ "Stroke_Color", "color" },
	{ "Stroke_Thickness", "thickness" },
	{ "Stroke_Transparency", "transparency" },
	{ "Stroke_Joins", "joins" },
	{ "Stroke_Sizing", "sizing" },
}

--- @type { { string } }
local MARK_ATTRIBUTES = {
	{ "Mark_Color", "color" },
	{ "Mark_Transparency", "transparency" },
}

--[[ Styles ]]

--- @type { { string } }
local STYLE_TAGS = {
	{ "Bold", "b" },
	{ "Italic", "i" },
	{ "Underline", "u" },
	{ "Strikethrough", "s" },
	{ "Uppercase", "uc" },
	{ "Smallcaps", "sc" },
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% To Attribute Value

--[[
	Converts a param value to its rich text attribute string. Color3 becomes `#RRGGBB`.
]]
--- @return string
local function toAttributeValue(value: any)
	--[[ Returning ]]

	if typeof(value) == "Color3" then
		return `#{value:ToHex()}`
	end

	return tostring(value)
end

--%%%%%%%%%%%%%%%%%%%% Build Attributes

--[[
	Builds the attribute string for one tag from the params that are set.
]]
--- @param params RichText_Table
--- @param attributes { { string } }
--- @return string
local function buildAttributes(params, attributes)
	--[[ Building ]]

	local parts = {} --- @type { string }

	--- @param attribute { string }
	for _index: number, attribute in ipairs(attributes) do
		local value: any = params[attribute[1]]

		if value then
			table.insert(parts, ` {attribute[2]}="{toAttributeValue(value)}"`)
		end
	end

	--[[ Returning ]]

	return table.concat(parts)
end

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

--- @class Ume_Library_RichText : Ume_Library
local RichText = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function RichText._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.RichText = RichText --- @type Ume_Library_RichText
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Format

--[[
	Wraps `input` in rich text tags built from `params` (font, stroke, mark, then style tags).
]]
--- @param params RichText_Table?
--- @return string
function RichText.Format(input: string?, params)
	--[[ Checks ]]

	-- Return empty input without tags
	if input == nil or input == "" then
		return ""
	end

	params = params or {}

	--[[ Tags ]]

	local openTags = {} --- @type { string }
	local closeTags = {} --- @type { string }

	local fontAttributes: string = buildAttributes(params, FONT_ATTRIBUTES)
	if fontAttributes ~= "" then
		table.insert(openTags, `<font{fontAttributes}>`)
		table.insert(closeTags, 1, "</font>")
	end

	local strokeAttributes: string = buildAttributes(params, STROKE_ATTRIBUTES)
	if strokeAttributes ~= "" then
		table.insert(openTags, `<stroke{strokeAttributes}>`)
		table.insert(closeTags, 1, "</stroke>")
	end

	local markAttributes: string = buildAttributes(params, MARK_ATTRIBUTES)
	if markAttributes ~= "" then
		table.insert(openTags, `<mark{markAttributes}>`)
		table.insert(closeTags, 1, "</mark>")
	end

	--[[ Styles ]]

	--- @param styleTag { string }
	for _index: number, styleTag in ipairs(STYLE_TAGS) do
		if params[styleTag[1]] then
			table.insert(openTags, `<{styleTag[2]}>`)
			table.insert(closeTags, 1, `</{styleTag[2]}>`)
		end
	end

	--[[ Returning ]]

	return table.concat(openTags) .. tostring(input) .. table.concat(closeTags)
end

return RichText
