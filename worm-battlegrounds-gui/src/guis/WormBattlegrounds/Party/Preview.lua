--[[
	Created By: 	Nari
]]

local _localName: string = "PartyPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The most players in a party, as Party's MAX_PARTY
local MAX_PARTY: number = 4

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

--- @class UmeGui_Guis_WormBattlegrounds_Party_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Members", Label = "Members", Value = 2, Min = 1, Max = 4, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the column as the Party module does for a leader: the members (the first leads, the others with Kick), then
	a + card per free place, and Leave while in a party.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local count: number = preview.Values.S_Members

	--[[ Members ]]

	local members = preview.Fill("PREFAB | Member", count) --- @type { UmeGui_Subview }

	--- @param member UmeGui_Subview
	for index: number, member in ipairs(members) do
		member:Get("S_Name").Instance.Text = `Player{index}`
		member:Get("S_Level").Instance.Text = `Lv {index * 7}`
		member:Get("S_Crown").Instance.Visible = index == 1
		member:Get("S_Kick").Instance.Visible = index > 1
	end

	--[[ Invites ]]

	local invites = preview.Fill("PREFAB | Invite", MAX_PARTY - count) --- @type { UmeGui_Subview }

	--- @param invite UmeGui_Subview
	for index: number, invite in ipairs(invites) do
		invite.Root.Instance.LayoutOrder = MAX_PARTY + index
	end

	--[[ Leave ]]

	preview.View:Get("U_Party", "S_Leave").Instance.Visible = count > 1
end

return Module
