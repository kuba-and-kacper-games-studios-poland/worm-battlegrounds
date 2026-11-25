--[[
	Created By: 	HungryN00B
]]

local _localName: string = "MatchSetupPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The map cards: Random first, then maps of the rotation
--- @type { string }
local MAPS = { "Random", "Picnic Plains", "Desert", "Rolling Plains" }

-- Solo's difficulty cards and their glyphs (MatchBoard's DIFFICULTY_ICONS)
--- @type { string }
local DIFFICULTIES = { "Easy", "Medium", "Hard" }

--- @type { string }
local GLYPHS = { "rbxassetid://88105304367362", "rbxassetid://94010149349376", "rbxassetid://103240032909077" }

-- Their colours (MatchBoard's DIFFICULTY_COLORS): the wash and the glyph's tint
--- @type { Color3 }
local COLORS = { Color3.fromRGB(110, 220, 110), Color3.fromRGB(255, 190, 70), Color3.fromRGB(255, 85, 80) }

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
	the diamonds a solo win pays, and the map cards with Random first; solo shows the difficulty cards (Medium picked)
	instead of the maps and the bots row.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local kind: string = preview.Values.S_Kind

	--[[ Texts ]]

	preview.View:Get("U_Setup", "S_Title").Instance.Text = if kind == "Local" then "Local play" elseif kind == "Party" then "Play with party" else "Play solo"
	preview.View:Get("U_Setup", "S_PlayersRow").Instance.Visible = kind == "Local"
	preview.View:Get("U_Setup", "S_WindBox").Instance.Visible = kind == "Local"
	preview.View:Get("U_Setup", "S_None").Instance.Visible = kind ~= "Solo"
	preview.View:Get("U_Setup", "S_RewardAmount").Instance.Visible = kind == "Solo"
	preview.View:Get("U_Setup", "S_DifficultyRow").Instance.Visible = kind == "Solo"
	preview.View:Get("U_Setup", "S_MapRow").Instance.Visible = kind ~= "Solo"
	preview.View:Get("U_Setup", "S_BotsRow").Instance.Visible = kind ~= "Solo"

	--[[ Difficulties ]]

	local difficultyCards = preview.Fill("PREFAB | Difficulty", #DIFFICULTIES, preview.View:Get("U_Setup", "S_DifficultyList").Instance) --- @type { UmeGui_Subview }

	--- @param card UmeGui_Subview
	for index: number, card in ipairs(difficultyCards) do
		card.Root.Instance.LayoutOrder = index
		card:Get("S_Name").Instance.Text = DIFFICULTIES[index]
		card:Get("S_Glyph").Instance.Image = GLYPHS[index]
		card:Get("S_Glyph").Instance.ImageColor3 = Color3.new(1, 1, 1):Lerp(COLORS[index], 0.45)
		card:Get("S_Tint").Instance.ImageColor3 = COLORS[index]
	end

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
