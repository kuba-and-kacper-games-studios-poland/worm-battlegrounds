--[[
	Created By: 	Nari
]]

local _localName: string = "MatchBoardPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- One public card per mode, as the game shows them, each with a map
--- @type { string }
local MODES = { "Deathmatch", "Duo", "Trio", "Quads" }

--- @type { string }
local MAPS = { "Picnic Plains", "Rolling Plains", "Echo Caverns", "Volcano Isle" }

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
		{ Control = "Dropdown", Id = "S_Panel", Label = "Panel", Options = { "Play", "Setup" }, Value = "Play" },
		{ Control = "Toggle", Id = "S_Party", Label = "Leads a party", Value = false },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the picked panel: the board with one lobby card per public mode, or the setup (with No bots and the party's
	title for a party leader).
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local party: boolean = preview.Values.S_Party

	--[[ Panels ]]

	preview.View:Get("U_Play").Instance.Visible = preview.Values.S_Panel == "Play"
	preview.View:Get("U_Setup").Instance.Visible = preview.Values.S_Panel == "Setup"

	--[[ Play ]]

	preview.View:Get("U_Play", "S_Solo").Instance:FindFirstChild("Name1").Text = if party then "Play with party" else "Solo vs bots"
	local rows = preview.Fill("PREFAB | Row", #MODES) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(rows) do
		row.Root.Instance.LayoutOrder = index
		row:Get("S_Mode").Instance.Text = MODES[index]
		row:Get("S_Map").Instance.Text = MAPS[index]
		row:Get("S_Join").Instance:FindFirstChild("Name1").Text = "Join"
	end

	--[[ Setup ]]

	preview.View:Get("U_Setup", "S_Title").Instance.Text = if party then "Play with party" else "Play solo"
	preview.View:Get("U_Setup", "S_None").Instance.Visible = party
	preview.View:Get("U_Setup", "S_RewardAmount").Instance.Visible = not party
end

return Module
