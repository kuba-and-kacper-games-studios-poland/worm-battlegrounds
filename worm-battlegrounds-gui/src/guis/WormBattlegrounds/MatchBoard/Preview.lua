--[[
	Created By: 	Nari
]]

local _localName: string = "MatchBoardPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

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
		row:Get("S_Join").Instance:FindFirstChild("Name1").Text = "Join"
	end

	--[[ Setup ]]

	preview.View:Get("U_Setup", "S_Title").Instance.Text = if party then "Play with party" else "Play solo"
	preview.View:Get("U_Setup", "S_None").Instance.Visible = party
	preview.View:Get("U_Setup", "S_RewardAmount").Instance.Visible = not party

	--[[ Waiting Room ]]

	local players = preview.Fill("PREFAB | PlayerName", preview.Values.S_Players) --- @type { UmeGui_Subview }

	--- @param player UmeGui_Subview
	for index: number, player in ipairs(players) do
		player.Root.Instance.LayoutOrder = index
	end
	preview.View:Get("U_WaitingRoom", "S_Info").Instance.Text = `Deathmatch  |  Picnic Plains  |  {preview.Values.S_Players} / 8 players`
end

return Module
