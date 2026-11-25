--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

local _localName: string = "ResultsPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Placings: place, name, diamonds
--- @type { { string } }
local PLACINGS = {
	{ "1st", "Bax", "+30 diamonds" },
	{ "2nd", "Ninja", "+23 diamonds" },
	{ "3rd", "Pip", "+15 diamonds" },
	{ "4th", "Dot", "+10 diamonds" },
	{ "5th", "Rex", "+8 diamonds" },
	{ "6th", "Moss", "+5 diamonds" },
	{ "7th", "Fig", "+3 diamonds" },
	{ "8th", "Bun", "+3 diamonds" },
}

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

--- @class UmeGui_Guis_WormBattlegrounds_Results_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Players", Label = "Players", Value = 4, Min = 2, Max = 4, Step = 1 },
		{ Control = "Toggle", Id = "S_LevelUp", Label = "Levelled up", Value = true },
		{ Control = "Slider", Id = "S_XpShare", Label = "Level bar", Value = 0.38, Min = 0, Max = 1, Step = 0.01 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the placings, the first three in their medal colours, shows the level-up line, and fills the level bar as far
	as its slider (156 XP a level, as level 14's).
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Placings ]]

	local placings = preview.Fill("PREFAB | Placing", preview.Values.S_Players) --- @type { UmeGui_Subview }

	--- @param placing UmeGui_Subview
	for index: number, placing in ipairs(placings) do
		local root: Frame = placing:Get("S_Place").Instance.Parent
		local look: string = if index <= 3 then tostring(index) else ""
		placing:Get("S_Place").Instance.Text = PLACINGS[index][1]
		placing:Get("S_Place").Instance.TextColor3 = root:GetAttribute(`Look_{look}PlaceColor`)
		placing:Get("S_Stroke").Instance.ImageColor3 = root:GetAttribute(`Look_{look}StrokeColor`)
		placing:Get("S_Name").Instance.Text = PLACINGS[index][2]
		placing:Get("S_Username").Instance.Text = `@{PLACINGS[index][2]}`
		placing:Get("S_Diamonds").Instance.Text = PLACINGS[index][3]
	end

	--[[ Earned ]]

	preview.View:Get("U_Earned", "S_LevelUp").Instance.Visible = preview.Values.S_LevelUp
	preview.View:Get("U_Earned", "S_XpFill").Instance.Size = UDim2.fromScale(preview.Values.S_XpShare, 1)
	preview.View:Get("U_Earned", "S_XpCount").Instance.Text = `{math.floor(preview.Values.S_XpShare * 156)} / 156 XP`
end

return Module
