--[[
	Created By: 	Nari
]]

local _localName: string = "HoverInfoPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TextService: TextService = game:GetService("TextService")
local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Example ]]

-- The example item: its name, its rarity's colour (the top line; ume's Rarity module draws the rarity itself in game),
-- its tier and its stats, one with a grade badge and one with a coloured value
local NAME: string = "Golden Sword"
local RARITY_COLOR: Color3 = Color3.fromRGB(0, 195, 255)
local TIER: number = 3
--- @type { { [string]: any } }
local STATS = {
	{ Label = "Damage", Value = "1,250", Badge = true },
	{ Label = "Speed", Value = "0.8 s" },
	{ Label = "Range", Value = "12 studs" },
	{ Label = "Bonus", Value = "+15% Coins", Color = Color3.fromRGB(255, 200, 40) },
}

-- Enchantments in the order an item would list them, and the roman numerals their levels are written in
local ENCHANTMENTS = { "Sharpness", "Swiftness", "Fortune", "Reach" } --- @type { string }
local NUMERALS = { "I", "II", "III", "IV", "V" } --- @type { string }

-- The XP the example level needs, and the level shown
local XP_NEEDED: number = 1200
local LEVEL: number = 12

--[[ Name ]]

-- The name's width (the box's 340 less its sides' padding), its text size and its height for one line, as ume's
-- HoverInfo module's NAME_WIDTH, NAME_TEXT_SIZE and NAME_HEIGHT
local NAME_WIDTH: number = 308
local NAME_TEXT_SIZE: number = 30
local NAME_HEIGHT: number = 36

--[[ Screen ]]

-- The screen height the box is laid out for, and the boost on short Mobile screens, as ume's HoverInfo module's
local DESIGN_HEIGHT: number = 1080
local SMALL_SCREEN: number = 500
local MOBILE_BOOST: number = 1.3

--[[ Views ]]

-- The contents whose box already follows their height, so a rebuilt view connects once
local fittedContents = setmetatable({}, { __mode = "k" }) --- @type { [Frame]: boolean }

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

--- @class UmeGui_Guis_System_HoverInfo_Preview
local Module = {

	--[[ Settings ]]

	-- Whether the item shows its level, its XP towards the next one, and how many enchantments it has
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Toggle", Id = "S_ShowLevel", Label = "Level", Value = true },
		{ Control = "Slider", Id = "S_Xp", Label = "XP", Value = 0.28, Min = 0, Max = 1, Step = 0.01, Format = "Percent" },
		{ Control = "Slider", Id = "S_Enchantments", Label = "Enchantments", Value = 2, Min = 0, Max = 4, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Writes the example item as ume's HoverInfo module would: its rarity colour, tier and name, its stats, its level and
	XP, and its enchantments, hiding the parts it has none of.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local view = preview.View --- @type UmeGui_View
	local enchantmentCount: number = preview.Values.S_Enchantments
	local xp: number = math.round(preview.Values.S_Xp * XP_NEEDED)
	local name: TextLabel = view:Get("U_Header", "S_Name").Instance

	--[[ Header ]]

	view:Get("U_HoverInfo").Instance.Visible = true
	view:Get("U_HoverInfo", "S_Accent").Instance.BackgroundColor3 = RARITY_COLOR
	view:Get("U_Header", "S_Tier").Instance.Text = Module._getSpaced(`TIER {TIER}`)
	name.Text = NAME
	name.Size = UDim2.new(1, 0, 0, Module._getNameHeight(name))

	--[[ Stats ]]

	local statRows = preview.Fill("PREFAB | Stat", #STATS) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(statRows) do
		local stat = STATS[index] --- @type { [string]: any }
		row.Root.Instance.LayoutOrder = index
		row:Get("S_Label").Instance.Text = Module._getSpaced(string.upper(stat.Label))
		row:Get("S_Value").Instance.Text = stat.Value
		row:Get("S_Value").Instance.TextColor3 = stat.Color or Color3.fromRGB(255, 255, 255)
		row:Get("S_Badge").Instance.Visible = stat.Badge == true
	end

	--[[ Level ]]

	view:Get("U_Level").Instance.Visible = preview.Values.S_ShowLevel
	view:Get("U_Level", "S_Level").Instance.Text = `Level {LEVEL}`
	view:Get("U_Level", "S_Xp").Instance.Text = `{xp} / {XP_NEEDED} XP`
	view:Get("U_Level", "S_XpFill").Instance.Size = UDim2.fromScale(preview.Values.S_Xp, 1)
	view:Get("U_Level", "S_XpFill").Instance.Visible = preview.Values.S_Xp > 0

	--[[ Enchantments ]]

	local enchantmentRows = preview.Fill("PREFAB | Enchantment", enchantmentCount) --- @type { UmeGui_Subview }
	view:Get("U_Enchantments").Instance.Visible = enchantmentCount > 0

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(enchantmentRows) do
		row.Root.Instance.LayoutOrder = index
		row:Get("S_Name").Instance.Text = ENCHANTMENTS[index]
		row:Get("S_Level").Instance.Text = NUMERALS[(index % #NUMERALS) + 1]
	end

	--[[ Divider ]]

	view:Get("U_HoverInfo", "S_Divider").Instance.Visible = #STATS > 0 or preview.Values.S_ShowLevel or enchantmentCount > 0

	--[[ Scaling ]]

	Module._applyScreenScale(preview)
	Module._fitBox(view)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales the box to the previewed screen as ume's HoverInfo module does: its height over the design height, bigger on
	short Mobile screens.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local scale: number = height / DESIGN_HEIGHT

	-- Boost short touch screens
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	end

	--[[ Applying ]]

	preview.View:Get("U_HoverInfo", "S_ScreenScale").Instance.Scale = scale
end

--%%%%%%%%%%%%%%%%%%%% Fit Box

--[[
	Keeps the box as tall as its rows, as ume's HoverInfo module does: an AutomaticSize box would never shrink, since its
	panel is sized by it. Connects once per built view.
]]
--- @param view UmeGui_View
function Module._fitBox(view)
	--[[ Local Variables ]]

	local box: Frame = view:Get("U_HoverInfo").Instance
	local content: Frame = view:Get("U_HoverInfo", "S_Content").Instance
	local screenScale: UIScale = view:Get("U_HoverInfo", "S_ScreenScale").Instance

	--[[ Checks ]]

	-- Skip a view whose box already follows its rows
	if fittedContents[content] then
		return
	end

	--[[ Connections ]]

	fittedContents[content] = true
	content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		box.Size = UDim2.new(box.Size.X, UDim.new(0, content.AbsoluteSize.Y / screenScale.Scale))
	end)
	box.Size = UDim2.new(box.Size.X, UDim.new(0, content.AbsoluteSize.Y / screenScale.Scale))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Name Height

--[[
	The name's height for the lines it wraps to at its design size, in the label's own font, as ume's HoverInfo module
	works it out.
]]
--- @return number
function Module._getNameHeight(label: TextLabel)
	--[[ Local Variables ]]

	local params: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
	params.Text = label.Text
	params.Font = label.FontFace
	params.Size = NAME_TEXT_SIZE
	params.Width = NAME_WIDTH

	--[[ Measuring ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(TextService.GetTextBoundsAsync, TextService, params)

	--[[ Returning ]]

	return if success then math.max(NAME_HEIGHT, result.Y + NAME_HEIGHT - NAME_TEXT_SIZE) else NAME_HEIGHT
end

--%%%%%%%%%%%%%%%%%%%% Get Spaced

--[[
	Returns a text with a hair space between its letters, as the box writes its small capitals.
]]
--- @return string
function Module._getSpaced(text: string)
	return table.concat(string.split(text, ""), "\u{200A}")
end

return Module
