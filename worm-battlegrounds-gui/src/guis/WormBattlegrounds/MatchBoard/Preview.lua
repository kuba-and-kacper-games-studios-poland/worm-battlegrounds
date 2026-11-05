--[[
	Created By: 	Nari
]]

local _localName: string = "MatchBoardPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Screen ]]

-- The screen size the guis are laid out for, and the boost on short Mobile screens, as ume's Settings module's
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

--- @class UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
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
	Fills the waiting room's players, and shows the Play row or the waiting room.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Panels ]]

	preview.View:Get("U_Play").Instance.Visible = not preview.Values.S_Joined
	preview.View:Get("U_WaitingRoom").Instance.Visible = preview.Values.S_Joined

	--[[ Waiting Room ]]

	preview.Fill("PREFAB | PlayerName", preview.Values.S_Players)
	preview.View:Get("U_WaitingRoom", "S_Count").SetText(`{preview.Values.S_Players} / 8 players`)

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales every panel to the previewed screen as the game's modules do: its height over the design height (or its
	width over the design width on a narrower screen), bigger on short Mobile screens, times each panel's device scale.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local width: number = Workspace.CurrentCamera.ViewportSize.X

	-- A screen narrower than the layout scales by its width, so side-by-side panels still fit
	local scale: number = math.min(height / DESIGN_HEIGHT, width / DESIGN_WIDTH)

	-- Boost short touch screens so the buttons stay big enough to tap
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	end

	--[[ Applying ]]

	for _index: number, descendant: Instance in ipairs(preview.View.Root:GetDescendants()) do
		if descendant:IsA("UIScale") and descendant.Name == "S_ScreenScale" then
			-- Times the panel's scale for the previewed device (its Utils_PlatformScale tag), as ScreenScale does
			local deviceScale: number = descendant.Parent:GetAttribute(`Utils_{preview.Device}Scale`) or 0
			descendant.Scale = scale * (if deviceScale == 0 then 1 else deviceScale)
		end
	end
end

return Module
