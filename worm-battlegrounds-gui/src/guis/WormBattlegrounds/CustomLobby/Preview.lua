--[[
	Created By: 	Nari
]]

local _localName: string = "CustomLobbyPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The maps in rotation and the player counts they take
--- @type { { string } }
local MAPS = {
	{ "Picnic Plains", "2 / 4 / 6" },
	{ "Desert", "2 / 4 / 6" },
	{ "Rockslide Ridge", "2 / 4 / 6" },
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

--- @class UmeGui_Guis_WormBattlegrounds_CustomLobby_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Toggle", Id = "S_Room", Label = "Lobby created", Value = false },
		{ Control = "Slider", Id = "S_Members", Label = "In the lobby", Value = 2, Min = 1, Max = 8, Step = 1 },
		{
			Control = "Slider",
			Id = "S_Invitable",
			Label = "Players in this server",
			Value = 4,
			Min = 0,
			Max = 10,
			Step = 1,
		},
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the create step or the room, with the maps (the first picked), the members and the players who can be invited.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Steps ]]

	preview.View:Get("U_Create").Instance.Visible = not preview.Values.S_Room
	preview.View:Get("U_Room").Instance.Visible = preview.Values.S_Room

	--[[ Maps ]]

	local choices = preview.Fill("PREFAB | MapChoice", #MAPS) --- @type { UmeGui_Subview }

	--- @param choice UmeGui_Subview
	for index: number, choice in ipairs(choices) do
		local button: ImageButton = choice.Root.Instance
		local picked: boolean = index == 1
		button.LayoutOrder = index
		choice:Get("S_Name").Instance.Text = MAPS[index][1]
		choice:Get("S_Name").Instance.TextColor3 = button:GetAttribute(if picked then "Look_SelectedTextColor" else "Look_TextColor")
		choice:Get("S_Info").Instance.Text = `{MAPS[index][2]} players`
		button.Background.Stroke.ImageColor3 = button:GetAttribute(if picked then "Look_SelectedStrokeColor" else "Look_StrokeColor")
		button.Background.Stroke.Image = button:GetAttribute(if picked then "Look_SelectedStroke" else "Look_Stroke")
		button.Background.Stroke2.Image = button:GetAttribute(if picked then "Look_SelectedStroke2" else "Look_Stroke2")
	end

	--[[ Room ]]

	preview.Fill("PREFAB | Member", preview.Values.S_Members)
	preview.Fill("PREFAB | Invitable", preview.Values.S_Invitable)
end

return Module
