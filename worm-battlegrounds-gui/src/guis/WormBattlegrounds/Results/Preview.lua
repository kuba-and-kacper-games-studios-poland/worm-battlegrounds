--[[
	Created By: 	Nari
]]

local _localName: string = "ResultsPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Placings: place, name, coins
--- @type { { string } }
local PLACINGS = {
	{ "1st", "Bax", "+60 coins" },
	{ "2nd", "Ninja", "+45 coins" },
	{ "3rd", "Pip", "+30 coins" },
	{ "4th", "Dot", "+20 coins" },
	{ "5th", "Rex", "+15 coins" },
	{ "6th", "Moss", "+10 coins" },
	{ "7th", "Fig", "+5 coins" },
	{ "8th", "Bun", "+5 coins" },
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
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the placings, the first three in their medal colours, and shows the level-up line.
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
		placing:Get("S_Coins").Instance.Text = PLACINGS[index][3]
	end

	--[[ Earned ]]

	preview.View:Get("U_Earned", "S_LevelUp").Instance.Visible = preview.Values.S_LevelUp
end

return Module
