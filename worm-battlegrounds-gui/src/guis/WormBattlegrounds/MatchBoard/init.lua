--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The MatchBoard module turns it on, on the Lobby map, as I.UserInterface.UI["MatchBoard"]
	Name = "MatchBoard",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- The middle panel: U_Play until the player joins a public match, then U_WaitingRoom in its place
	Root = {
		Primitive = "Folder",
		Children = {
			{
				Control = "Box",
				Id = "U_Play",
				Title = "Play",
				Screen = true,
				Style = { "Panel", "Fixed" },
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.53),
					Size = UDim2.fromOffset(780, 820),
				},
				Children = {
					-- 1v1 against a bot: opens SoloSetup to pick the difficulty
					{
						Control = "Button",
						Id = "U_Solo",
						Text = "Play solo",
						Style = "Primary",
						Tags = {
							Interact_Button = {
								Interact_ModuleName = "WidgetManager",
								Interact_Function = "Toggle",
								Interact_Arg1 = "SoloSetup",
							},
						},
					},
					{ Control = "Label", Text = "Public matches", Align = "Center", Style = "Heading" },
					-- The 3 open public lobbies, refreshed as they start (PREFAB | Row)
					{ Control = "Cells", Id = "U_Rows" },
					-- A private lobby for friends: opens CustomLobby
					{
						Control = "Button",
						Id = "U_Custom",
						Text = "Custom lobby",
						Tags = {
							Interact_Button = {
								Interact_ModuleName = "WidgetManager",
								Interact_Function = "Toggle",
								Interact_Arg1 = "CustomLobby",
							},
						},
					},
				},
			},
			-- The joined match's waiting room
			{
				Control = "Box",
				Id = "U_WaitingRoom",
				Screen = true,
				Visible = false,
				Style = { "Panel", "Fixed" },
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.53),
					Size = UDim2.fromOffset(780, 820),
				},
				Children = {
					{
						Control = "Label",
						Id = "S_Match",
						Text = "Duo team deathmatch • Fluffy Fallout",
						Align = "Center",
						Style = "Title",
					},
					{
						Control = "Label",
						Id = "S_Countdown",
						Text = "Match starts in 0:29",
						Align = "Center",
						Style = "Heading",
					},
					{ Control = "Label", Id = "S_Count", Text = "5 / 8 players", Align = "Center", Style = "Dim" },
					-- Everyone who joined (PREFAB | PlayerName)
					{ Control = "Cells", Id = "U_Players" },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Fill = true,
						Style = "Buttons",
						Children = {
							-- Starts early once two thirds vote; its text shows the votes (4 / 6)
							{ Control = "Button", Id = "S_Vote", Text = "Vote to start  4 / 6", Style = "Primary" },
							{ Control = "Button", Id = "S_Leave", Text = "Leave match", Style = "Danger" },
						},
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- One open public lobby: map picture, mode and map, players, the 30-second timer, Join (or Join teams)
		["PREFAB | Row"] = {
			Control = "Box",
			Parent = "U_Rows",
			Children = {
				{
					Control = "Stack",
					Direction = "Horizontal",
					Children = {
						{ Control = "Picture", Id = "S_Thumbnail", Style = "Thumbnail" },
						{
							Control = "Stack",
							Grow = 1,
							Style = "None",
							Children = {
								{ Control = "Label", Id = "S_Mode", Text = "Deathmatch", Style = "Strong" },
								{ Control = "Label", Id = "S_Map", Text = "Fluffy Fallout", Style = "Dim" },
							},
						},
						{ Control = "Label", Id = "S_Players", Text = "3 / 8" },
						{ Control = "Label", Id = "S_Timer", Text = "0:30", Style = "Warning" },
						{ Control = "Button", Id = "S_Join", Text = "Join", AutoWidth = true, Style = "Primary" },
					},
				},
			},
		},
		-- One player in the waiting room
		["PREFAB | PlayerName"] = {
			Control = "Stack",
			Parent = "U_Players",
			Direction = "Horizontal",
			Children = {
				{ Control = "Picture", Id = "S_Avatar", Style = "Avatar" },
				{ Control = "Label", Id = "S_Name", Text = "PlayerName", Grow = 1 },
			},
		},
	},
}

return _gui
