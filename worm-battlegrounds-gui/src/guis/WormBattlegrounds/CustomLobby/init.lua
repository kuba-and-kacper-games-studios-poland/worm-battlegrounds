--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- MatchBoard draws it on WidgetManager_Opened as I.UserInterface.UI["CustomLobby"]
	Name = "CustomLobby",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- A private lobby: U_Create to set it up, then U_Room in its place. Custom matches pay no coins
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Custom lobby",
		Style = "Large",
		Children = {
			{
				Control = "Box",
				Id = "U_Create",
				-- A page of the window, not a slot of its own: the maps sit on the slots
				Style = { "Fixed", Padding = 0, Slab = { Fill = "" } },
				Children = {
					{ Control = "Label", Text = "Map", Style = "Heading" },
					-- The 6 maps (PREFAB | MapChoice); the picked one is selected
					{ Control = "Cells", Id = "U_Maps", Style = "Grid" },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Style = "Buttons",
						Children = {
							{ Control = "Label", Text = "Mode", Style = "Heading" },
							{
								Control = "Button",
								Id = "S_Deathmatch",
								Text = "Deathmatch",
								AutoWidth = true,
								Selected = true,
								Style = "Tab",
							},
							{ Control = "Button", Id = "S_Teams", Text = "Teams", AutoWidth = true, Style = "Tab" },
						},
					},
					{
						Control = "Stack",
						Direction = "Horizontal",
						Style = "Buttons",
						Children = {
							{ Control = "Label", Text = "Players", Style = "Heading" },
							-- Tabs: slate at rest, the picked one blue
							{ Control = "Button", Id = "S_Players2", Text = "2", AutoWidth = true, Selected = true, Style = "Tab" },
							{ Control = "Button", Id = "S_Players4", Text = "4", AutoWidth = true, Style = "Tab" },
							{ Control = "Button", Id = "S_Players6", Text = "6", AutoWidth = true, Style = "Tab" },
							{ Control = "Button", Id = "S_Players8", Text = "8", AutoWidth = true, Style = "Tab" },
						},
					},
					{ Control = "Button", Id = "S_Create", Text = "Create lobby", Style = "Primary" },
				},
			},
			{
				Control = "Box",
				Id = "U_Room",
				Visible = false,
				Style = { "Fixed", Padding = 0, Slab = { Fill = "" } },
				Children = {
					{
						Control = "Label",
						Id = "S_Info",
						Text = "Teams • Fluffy Fallout • 4 players",
						Align = "Center",
						Style = "Heading",
					},
					{ Control = "Label", Text = "In the lobby", Style = "Strong" },
					-- Who's in (PREFAB | Member)
					{ Control = "Cells", Id = "U_Members" },
					{ Control = "Label", Text = "Players in this server", Style = "Strong" },
					-- Who can be invited (PREFAB | Invitable)
					{ Control = "Cells", Id = "U_Invitable" },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Fill = true,
						Style = "Buttons",
						Children = {
							{ Control = "Button", Id = "S_InviteFriends", Text = "Invite friends" },
							-- Only the owner sees it
							{ Control = "Button", Id = "S_Start", Text = "Start", Style = "Primary" },
							{ Control = "Button", Id = "S_Leave", Text = "Leave", Style = "Danger" },
						},
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		["PREFAB | MapChoice"] = {
			Control = "Item",
			Parent = "U_Maps",
			Text = "Fluffy Fallout",
			Subtext = "2 · 4 · 6",
		},
		["PREFAB | Member"] = {
			Control = "Stack",
			Parent = "U_Members",
			Direction = "Horizontal",
			Children = {
				{ Control = "Picture", Id = "S_Avatar", Style = "Avatar" },
				{ Control = "Label", Id = "S_Name", Text = "PlayerName", Grow = 1 },
			},
		},
		["PREFAB | Invitable"] = {
			Control = "Stack",
			Parent = "U_Invitable",
			Direction = "Horizontal",
			Children = {
				{ Control = "Picture", Id = "S_Avatar", Style = "Avatar" },
				{ Control = "Label", Id = "S_Name", Text = "PlayerName", Grow = 1 },
				{
					Control = "Button",
					Id = "S_Invite",
					Text = "Invite",
					AutoWidth = true,
					Style = "Small",
				},
			},
		},
	},
}

return _gui
