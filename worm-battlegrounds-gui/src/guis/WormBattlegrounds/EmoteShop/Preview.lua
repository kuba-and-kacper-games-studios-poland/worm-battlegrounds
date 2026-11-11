--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

local _localName: string = "EmoteShopPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The 8 emotes bought with coins: name, level needed, price
--- @type { { string } }
local EMOTES = {
	{ "Thumbs up", "1", "100" },
	{ "Laugh", "1", "250" },
	{ "Dance", "10", "500" },
	{ "Flex", "20", "900" },
	{ "Taunt", "35", "1,400" },
	{ "Cry", "50", "1,900" },
	{ "Backflip", "75", "2,400" },
	{ "Victory Trumpet", "100", "3,000" },
}

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
	Fills one card per emote; the first ones are owned, the rest show their price and level on the locked cover.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Cards ]]

	local cards = preview.Fill("PREFAB | EmoteCard", #EMOTES) --- @type { UmeGui_Subview }

	--- @param card UmeGui_Subview
	for index: number, card in ipairs(cards) do
		local owned: boolean = index <= preview.Values.S_Owned
		card:Get("S_Name").Instance.Text = EMOTES[index][1]
		card:Get("S_Level").Instance.Text = `Level {EMOTES[index][2]}`
		card:Get("S_Price").Instance.Text = EMOTES[index][3]
		card:Get("S_Locked").Instance.Visible = not owned
	end
end

return Module
