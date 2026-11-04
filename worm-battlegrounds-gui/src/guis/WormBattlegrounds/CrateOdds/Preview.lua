--[[
	Created By: 	Nari
]]

local _localName: string = "CrateOddsPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- A weapon crate's drops: name, rarity, chance (adding up to 100%)
--- @type { { string } }
local ODDS = {
	{ "Grenade", "Common", "25%" },
	{ "Shotgun", "Common", "25%" },
	{ "Cluster bomb", "Uncommon", "18%" },
	{ "Homing missile", "Uncommon", "14%" },
	{ "Airstrike", "Rare", "10%" },
	{ "Earthquake", "Epic", "6%" },
	{ "Black hole grenade", "Legendary", "2%" },
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

--- @class UmeGui_Guis_WormBattlegrounds_CrateOdds_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the odds with a weapon crate's drops.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Rows ]]

	local rows = preview.Fill("PREFAB | OddsRow", #ODDS) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(rows) do
		row:Get("S_Name").SetText(ODDS[index][1])
		row:Get("S_Rarity").SetText(ODDS[index][2])
		row:Get("S_Chance").SetText(ODDS[index][3])
	end

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
