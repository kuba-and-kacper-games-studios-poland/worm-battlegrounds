--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

local _localName: string = "MatchBoardPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- One public card per mode, as the game shows them, each with a map and the players seated in its filling match
--- @type { string }
local MODES = { "Deathmatch", "Duo", "Trio" }

--- @type { string }
local MAPS = { "Rolling Plains", "Desert", "Echo Caverns" }

--- @type { string }
local PLAYERS = { "2/4", "1/4", "3/6" }

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
		{ Control = "Toggle", Id = "S_Party", Label = "Leads a party", Value = false },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the board with one lobby card per public mode (Play with party for a party leader).
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local party: boolean = preview.Values.S_Party

	--[[ Play ]]

	preview.View:Get("U_Play", "S_Solo").Instance:FindFirstChild("Name1").Text = if party then "Play with party" else "Play solo"
	local rows = preview.Fill("PREFAB | Row", #MODES) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(rows) do
		row.Root.Instance.LayoutOrder = index
		row:Get("S_Mode").Instance.Text = MODES[index]
		row:Get("S_Map").Instance.Text = MAPS[index]
		row:Get("S_Players").Instance.Text = PLAYERS[index]
		row:Get("S_Join").Instance:FindFirstChild("Name1").Text = "Join"
	end
end

return Module
