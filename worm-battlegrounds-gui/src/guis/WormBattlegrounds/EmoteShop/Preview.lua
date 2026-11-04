--[[
	Created By: 	Nari
]]

local _localName: string = "EmoteShopPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The 8 emotes bought with coins: name, level needed, price
--- @type { { string } }
local EMOTES = {
	{ "Thumbs up", "Any level", "100 coins" },
	{ "Laugh", "Any level", "250 coins" },
	{ "Dance", "Level 10", "500 coins" },
	{ "Flex", "Level 20", "900 coins" },
	{ "Taunt", "Level 35", "1,400 coins" },
	{ "Cry", "Level 50", "1,900 coins" },
	{ "Backflip", "Level 75", "2,400 coins" },
	{ "Victory Trumpet", "Level 100", "3,000 coins" },
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

--- @class UmeGui_Guis_WormBattlegrounds_EmoteShop_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Owned", Label = "Owned", Value = 2, Min = 0, Max = 8, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills one row per emote; the first ones are owned.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Rows ]]

	local rows = preview.Fill("PREFAB | EmoteRow", #EMOTES) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(rows) do
		local owned: boolean = index <= preview.Values.S_Owned
		row:Get("S_Name").SetText(EMOTES[index][1])
		row:Get("S_Level").SetText(EMOTES[index][2])
		row:Get("S_Price").SetText(EMOTES[index][3])
		row:Get("S_Buy").Instance.Visible = not owned
		row:Get("S_Owned").Instance.Visible = owned
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
