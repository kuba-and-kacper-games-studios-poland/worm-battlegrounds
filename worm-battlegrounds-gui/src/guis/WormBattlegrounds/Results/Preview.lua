--[[
	Created By: 	Nari
]]

local _localName: string = "ResultsPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

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

--[[ Screen ]]

-- The screen height the guis are laid out for, and the boost on short Mobile screens, as ume's Settings module's
local DESIGN_HEIGHT: number = 1080
local SMALL_SCREEN: number = 500
local MOBILE_BOOST: number = 1.3

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
		{ Control = "Slider", Id = "S_Players", Label = "Players", Value = 4, Min = 2, Max = 8, Step = 2 },
		{ Control = "Toggle", Id = "S_LevelUp", Label = "Levelled up", Value = true },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the placings and shows the level-up line.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Placings ]]

	local placings = preview.Fill("PREFAB | Placing", preview.Values.S_Players) --- @type { UmeGui_Subview }

	--- @param placing UmeGui_Subview
	for index: number, placing in ipairs(placings) do
		placing:Get("S_Place").SetText(PLACINGS[index][1])
		placing:Get("S_Name").SetText(PLACINGS[index][2])
		placing:Get("S_Coins").SetText(PLACINGS[index][3])
	end

	--[[ Earned ]]

	preview.View:Get("U_Earned", "S_LevelUp").Instance.Visible = preview.Values.S_LevelUp

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales every panel to the previewed screen as the game's modules do: its height over the design height, bigger on
	short Mobile screens.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local scale: number = height / DESIGN_HEIGHT

	-- Boost short touch screens so the buttons stay big enough to tap
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	end

	--[[ Applying ]]

	for _index: number, descendant: Instance in ipairs(preview.View.Root:GetDescendants()) do
		if descendant:IsA("UIScale") and descendant.Name == "S_ScreenScale" then
			descendant.Scale = scale
		end
	end
end

return Module
