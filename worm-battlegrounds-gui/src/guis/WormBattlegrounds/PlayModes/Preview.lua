--[[
	Created By: 	Nari
]]

local _localName: string = "PlayModesPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Public matches as MatchBoard lists them: mode, map, players, time left, team mode
--- @type { { [string]: any } }
local ROWS = {
	{ Mode = "Deathmatch", Map = "Picnic Plains", Players = "3 / 8", Timer = "0:24", Teams = false },
	{ Mode = "Duo team deathmatch", Map = "Picnic Plains", Players = "5 / 8", Timer = "0:12", Teams = true },
	{ Mode = "Trio team deathmatch", Map = "Picnic Plains", Players = "2 / 6", Timer = "0:29", Teams = true },
}

--[[ Screen ]]

-- The screen size the guis are laid out for, and the boost on short Mobile screens, as the ScreenScale module's
local DESIGN_HEIGHT: number = 1080
local DESIGN_WIDTH: number = 1920
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

--- @class UmeGui_Guis_WormBattlegrounds_PlayModes_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Rows", Label = "Public matches", Value = 3, Min = 0, Max = 3, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the public match rows and scales the window to the screen.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
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

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales the window to the previewed screen as the game's modules do: its height over the design height (or its
	width over the design width on a narrower screen), bigger on short Mobile screens, times its device scale.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local width: number = Workspace.CurrentCamera.ViewportSize.X
	local scale: number = math.min(height / DESIGN_HEIGHT, width / DESIGN_WIDTH)

	-- Boost short touch screens so the buttons stay big enough to tap
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	end

	--[[ Applying ]]

	for _index: number, descendant: Instance in ipairs(preview.View.Root:GetDescendants()) do
		if descendant:IsA("UIScale") and descendant.Name == "S_ScreenScale" then
			-- Times the window's scale for the previewed device (its Utils_PlatformScale tag), as ScreenScale does
			local deviceScale: number = descendant.Parent:GetAttribute(`Utils_{preview.Device}Scale`) or 0
			descendant.Scale = scale * (if deviceScale == 0 then 1 else deviceScale)
		end
	end
end

return Module
