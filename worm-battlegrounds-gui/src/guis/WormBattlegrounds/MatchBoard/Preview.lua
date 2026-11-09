--[[
	Created By: 	Nari
]]

local _localName: string = "MatchBoardPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Screen ]]

-- The screen size the guis are laid out for, the Mobile boost and the PC floor, as ScreenScale's Settings
local DESIGN_HEIGHT: number = 1080
local DESIGN_WIDTH: number = 1920
local SMALL_SCREEN: number = 500
local MOBILE_BOOST: number = 1.3
local MIN_SCALE: number = 0.6

--[[ Examples ]]

-- One public row per mode, as the game shows them
--- @type { string }
local MODES = { "Deathmatch", "Duos", "Trios", "Quads" }

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
		{ Control = "Dropdown", Id = "S_Panel", Label = "Panel", Options = { "Play", "Setup", "Waiting room" }, Value = "Play" },
		{ Control = "Toggle", Id = "S_Party", Label = "Leads a party", Value = false },
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
	Shows the picked panel: the board with one lobby card per public mode, the setup (with No bots and the party's
	title for a party leader), or the waiting room with its players.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local party: boolean = preview.Values.S_Party

	--[[ Panels ]]

	preview.View:Get("U_Play").Instance.Visible = preview.Values.S_Panel == "Play"
	preview.View:Get("U_Setup").Instance.Visible = preview.Values.S_Panel == "Setup"
	preview.View:Get("U_WaitingRoom").Instance.Visible = preview.Values.S_Panel == "Waiting room"

	--[[ Play ]]

	preview.View:Get("U_Play", "S_Solo").Instance:FindFirstChild("Name1").Text = if party then "Play with party" else "Solo vs bots"
	local rows = preview.Fill("PREFAB | Row", #MODES) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(rows) do
		row.Root.Instance.LayoutOrder = index
		row:Get("S_Mode").Instance.Text = MODES[index]
		row:Get("S_Players").Instance.Text = `{index}/{index * 2 + 2} players`
		row:Get("S_Join").Instance:FindFirstChild("Name1").Text = if index == 1 then "Join" else "Join teams"
	end

	--[[ Setup ]]

	preview.View:Get("U_Setup", "S_Title").SetText(if party then "Play with party" else "Play solo")
	preview.View:Get("U_Setup", "S_None").Instance.Visible = party

	--[[ Waiting Room ]]

	preview.Fill("PREFAB | PlayerName", preview.Values.S_Players)
	preview.View:Get("U_WaitingRoom", "S_Count").SetText(`{preview.Values.S_Players} / 8 players`)

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales every panel to the previewed screen as the game's modules do: its height over the design height (or its
	width over the design width on a narrower screen), bigger on short Mobile screens and never under the floor on
	others, times each panel's device scale.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local width: number = Workspace.CurrentCamera.ViewportSize.X

	-- A screen narrower than the layout scales by its width, so side-by-side panels still fit
	local scale: number = math.min(height / DESIGN_HEIGHT, width / DESIGN_WIDTH)

	-- Boost short touch screens so the buttons stay big enough to tap; anything else never shrinks below the floor
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	elseif preview.Device ~= "Mobile" then
		scale = math.max(scale, MIN_SCALE)
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
