--[[
	Created By: 	Nari
]]

local _localName: string = "MatchWaitingPreview"

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

--- @class UmeGui_Guis_WormBattlegrounds_MatchWaiting_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Players", Label = "Players seated", Value = 3, Min = 1, Max = 8, Step = 1 },
		{ Control = "Slider", Id = "S_Ready", Label = "Players ready", Value = 1, Min = 0, Max = 8, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the room with example seats, the first ones READY, the last one still joining.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local seated: number = preview.Values.S_Players
	local ready: number = math.min(preview.Values.S_Ready, seated)

	--[[ Players ]]

	local players = preview.Fill("PREFAB | PlayerName", seated) --- @type { UmeGui_Subview }

	--- @param player UmeGui_Subview
	for index: number, player in ipairs(players) do
		player.Root.Instance.LayoutOrder = index
		player:Get("S_ReadyTag").Instance.Visible = index <= ready
		if index == seated and seated > 1 then
			player:Get("S_Username").Instance.Text = "Joining…"
		end
	end

	--[[ Texts ]]

	preview.View:Get("U_WaitingRoom", "S_Title").Instance.Text = "Duo · Echo Caverns"
	preview.View:Get("U_WaitingRoom", "S_Status").Instance.Text = "Starts in 0:23"
	preview.View:Get("U_WaitingRoom", "S_PlayersHeader").Instance.Text = `Players {seated}/4`
	preview.View:Get("U_WaitingRoom", "S_Ready").Instance:FindFirstChild("S_Text").Text = `Vote to start {ready}/{seated}`
end

return Module
