--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The MatchBoard module turns it on, on the Lobby map, as I.UserInterface.UI["MatchBoard"]
	Name = "MatchBoard",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	--[[
		The middle panel, low enough for the tutorial hint above it: U_Play until the player joins a public match, then
		U_WaitingRoom in its place
	]]
	Root = {
		Primitive = "Folder",
		Children = {
			{
				Control = "Box",
				Id = "U_Play",
				Title = "Play",
				Screen = true,
				-- On phones and tablets: shorter, its list scrolling instead, and drawn at 0.9 so a match card fits whole
				Style = { "Panel", "Fixed", PlatformScale = { Utils_MobileScale = 0.9 } },
				Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromOffset(560, 600) } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 0.978),
					Size = UDim2.fromOffset(720, 860),
				},
				Children = {
					-- 1v1 against a bot: opens SoloSetup to pick the difficulty
					{
						Control = "Button",
						Id = "U_Solo",
						Text = "Play solo",
						Style = { "Primary", "Large" },
						Tags = {
							Interact_Button = {
								Interact_ModuleName = "WidgetManager",
								Interact_Function = "Toggle",
								Interact_Arg1 = "SoloSetup",
							},
						},
					},
					-- Hidden on phones and tablets, so a whole match card fits under Play solo
					{
						Control = "Label",
						Text = "Public matches",
						Align = "Center",
						Style = "Heading",
						Tags = { Utils_HideOnPlatform = { Utils_MobileVisibility = false } },
					},
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
				-- On phones and tablets: shorter, its list scrolling instead, and drawn at 0.9 so a match card fits whole
				Style = { "Panel", "Fixed", PlatformScale = { Utils_MobileScale = 0.9 } },
				Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromOffset(560, 600) } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 0.978),
					Size = UDim2.fromOffset(720, 860),
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
		--[[
			One open public lobby on a purple card: map picture, mode and map, players and the 30-second timer, then Join
			(or Join teams), blue since a list of matches has no one next step
		]]
		["PREFAB | Row"] = {
			Control = "Box",
			Parent = "U_Rows",
			Style = { "Card", "Event" },
			Children = {
				{
					Control = "Stack",
					Direction = "Horizontal",
					Children = {
						{ Control = "Picture", Id = "S_Thumbnail", Style = { "Thumbnail", Width = 160, Height = 90 } },
						{
							Control = "Stack",
							Grow = 1,
							Style = "None",
							Children = {
								{ Control = "Label", Id = "S_Mode", Text = "Deathmatch", Style = "Strong" },
								{ Control = "Label", Id = "S_Map", Text = "Fluffy Fallout", Style = { "Small", "Map" } },
								{
									Control = "Stack",
									Direction = "Horizontal",
									Children = {
										{ Control = "Label", Id = "S_Players", Text = "3 / 8", Style = "Small" },
										{ Control = "Label", Id = "S_Timer", Text = "0:30", Style = { "Small", "Warning" } },
									},
								},
							},
						},
						{ Control = "Button", Id = "S_Join", Text = "Join", AutoWidth = true },
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
