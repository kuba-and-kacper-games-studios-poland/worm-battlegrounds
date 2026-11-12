--[[
	Created By: 	Nari
]]

local _localName: string = "ShopPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Diamond packs (name, diamonds, Robux) and game passes (name, benefits, Robux), as the wiki proposes them
--- @type { { string } }
local PACKS = {
	{ "Handful", "250", "99" },
	{ "Pouch", "500", "199" },
	{ "Bag", "1,000", "399" },
	{ "Chest", "1,500", "599" },
	{ "Vault", "2,500", "899" },
}
--- @type { { string } }
local PASSES = {
	{ "Slot 4", "Opens loadout slot 4", "149" },
	{ "Slot 5", "Opens loadout slot 5, after slot 4", "299" },
	{ "Double Coins", "Every coin reward from matches is doubled", "349" },
	{ "VIP", "A gold name and VIP tag in chat, an exclusive VIP snail skin, and one free skin crate every day", "199" },
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

--- @class UmeGui_Guis_WormBattlegrounds_Shop_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the 5 diamond packs and the 4 game passes.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Packs ]]

	local packs = preview.Fill("PREFAB | Pack", #PACKS) --- @type { UmeGui_Subview }

	--- @param pack UmeGui_Subview
	for index: number, pack in ipairs(packs) do
		pack.Root.Instance.LayoutOrder = index
		pack:Get("S_Name").Instance.Text = PACKS[index][1]
		pack:Get("S_Info").Instance.Text = `{PACKS[index][2]} diamonds`
		pack:Get("S_Price").Instance.Text = PACKS[index][3]
	end

	--[[ Passes ]]

	local passes = preview.Fill("PREFAB | Pass", #PASSES) --- @type { UmeGui_Subview }

	--- @param pass UmeGui_Subview
	for index: number, pass in ipairs(passes) do
		pass.Root.Instance.LayoutOrder = index
		pass:Get("S_Name").Instance.Text = PASSES[index][1]
		pass:Get("S_Benefits").Instance.Text = PASSES[index][2]
		pass:Get("S_Price").Instance.Text = PASSES[index][3]
	end
end

return Module
