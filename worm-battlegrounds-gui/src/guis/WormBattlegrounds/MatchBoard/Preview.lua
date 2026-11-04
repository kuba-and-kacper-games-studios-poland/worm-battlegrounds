--[[
	Created By: 	Nari
]]

local _localName: string = "MatchBoardPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Public lobbies as MatchBoard lists them: mode, map, players, time left, team mode
--- @type { { [string]: any } }
local ROWS = {
	{ Mode = "Deathmatch", Map = "Fluffy Fallout", Players = "3 / 8", Timer = "0:24", Teams = false },
	{ Mode = "Duo team deathmatch", Map = "Lava Lagoon", Players = "5 / 8", Timer = "0:12", Teams = true },
	{ Mode = "Trio team deathmatch", Map = "Brick Bay", Players = "2 / 6", Timer = "0:29", Teams = true },
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

--- @class UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Rows", Label = "Public matches", Value = 3, Min = 0, Max = 3, Step = 1 },
		{ Control = "Toggle", Id = "S_Joined", Label = "Joined a match", Value = false },
		{
			Control = "Slider",
			Id = "S_Players",
			Label = "Players in the waiting room",
			Value = 5,
			Min = 1,
			Max = 8,
			Step = 1,
		},
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the public match rows and the waiting room's players, and shows the panel the player is on.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Panels ]]

	preview.View:Get("U_Play").Instance.Visible = not preview.Values.S_Joined
	preview.View:Get("U_WaitingRoom").Instance.Visible = preview.Values.S_Joined

	--[[ Rows ]]

	local rows = preview.Fill("PREFAB | Row", preview.Values.S_Rows) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(rows) do
		local example = ROWS[index] --- @type { [string]: any }
		row:Get("S_Mode").SetText(example.Mode)
		row:Get("S_Map").SetText(example.Map)
		row:Get("S_Players").SetText(example.Players)
		row:Get("S_Timer").SetText(example.Timer)
		row:Get("S_Join").SetText(if example.Teams then "Join teams" else "Join")
	end

	--[[ Waiting Room ]]

	preview.Fill("PREFAB | PlayerName", preview.Values.S_Players)
	preview.View:Get("U_WaitingRoom", "S_Count").SetText(`{preview.Values.S_Players} / 8 players`)

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
