--[[
	Created By: 	HungryN00B
]]

local _localName: string = "MatchSetupPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The map cards: Random first, then maps of the rotation
--- @type { string }
local MAPS = { "Random", "Picnic Plains", "Desert", "Rolling Plains" }

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

--- @class UmeGui_Guis_WormBattlegrounds_MatchSetup_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Dropdown", Id = "S_Kind", Label = "Match", Options = { "Solo", "Party", "Local" }, Value = "Solo" },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the setup for the picked match: its title, the players row for local play, No bots for a party or local play,
	the coins a solo win pays, and the map cards with Random first.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local kind: string = preview.Values.S_Kind

	--[[ Texts ]]

	preview.View:Get("U_Setup", "S_Title").Instance.Text = if kind == "Local" then "Local play" elseif kind == "Party" then "Play with party" else "Play solo"
	preview.View:Get("U_Setup", "S_PlayersRow").Instance.Visible = kind == "Local"
	preview.View:Get("U_Setup", "S_None").Instance.Visible = kind ~= "Solo"
	preview.View:Get("U_Setup", "S_RewardAmount").Instance.Visible = kind == "Solo"

	--[[ Maps ]]

	local cards = preview.Fill("PREFAB | SoloMap", #MAPS) --- @type { UmeGui_Subview }

	--- @param card UmeGui_Subview
	for index: number, card in ipairs(cards) do
		card.Root.Instance.LayoutOrder = index
		card:Get("S_Name").Instance.Text = MAPS[index]
		card:Get("S_RandomIcon").Instance.Visible = index == 1
		card:Get("S_Info").Instance.Visible = index == 1
	end
end

return Module
