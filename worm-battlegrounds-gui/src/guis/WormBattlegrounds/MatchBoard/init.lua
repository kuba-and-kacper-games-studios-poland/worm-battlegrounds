--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The MatchBoard module turns it on, on the Lobby map, as I.UserInterface.UI["MatchBoard"]
	Name = "MatchBoard",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = -1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	--[[
		One panel at the bottom, just right of the centre so it clears the Loadout card on 4:3 screens and phones, showing
		one of three things in the same spot: U_Play (welcome, Play solo, the public matches), U_Setup (the solo or party
		match's bots), or U_WaitingRoom once the player joins a public match
	]]
	Root = {
		Primitive = "Folder",
		Children = {
			{
				Control = "Box",
				Id = "U_Play",
				Screen = true,
				-- On phones and tablets: shorter, its list scrolling instead, and drawn at 0.9
				Style = { "Panel", "Fixed", PlatformScale = { Utils_MobileScale = 0.9 } },
				Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromOffset(800, 700) } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.55, 0.978),
					Size = UDim2.fromOffset(800, 800),
				},
				Children = {
					{ Control = "Label", Id = "S_Welcome", Text = "Welcome, PlayerName", Align = "Center", Style = "Dim" },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Style = "Buttons",
						Children = {
							-- The panel's next step; in a party its leader's reads "Play with party"
							{ Control = "Button", Id = "S_Solo", Text = "Play solo", Grow = 1, Style = { "Primary", "Large" } },
							{
								Control = "Button",
								Id = "S_Custom",
								Text = "Custom",
								AutoWidth = true,
								Style = "Large",
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
					{ Control = "Label", Text = "Public matches", Align = "Center", Style = { "Heading", "Accent" } },
					-- One open public match per mode, two a row (PREFAB | Row), refreshed as they start
					{ Control = "Cells", Id = "U_Rows", Style = "Matches" },
				},
			},
			-- Before a solo or party match: the bots, what they mean, the coins, Start
			{
				Control = "Box",
				Id = "U_Setup",
				Screen = true,
				Visible = false,
				Style = { "Panel", "Fixed", PlatformScale = { Utils_MobileScale = 0.9 } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.55, 0.978),
					Size = UDim2.fromOffset(800, 660),
				},
				Children = {
					{
						Control = "Stack",
						Direction = "Horizontal",
						Children = {
							{ Control = "Label", Id = "S_Title", Text = "Play solo", Grow = 1, Style = "Title" },
							{
								Control = "Button",
								Id = "S_Back",
								Text = "Back",
								AutoWidth = true,
								Style = { "Danger", "Small" },
								Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" } },
							},
						},
					},
					{ Control = "Label", Text = "Bots", Style = "Heading" },
					-- The bots' difficulty; the picked one wears the kit's selected skin. No bots only shows in a party
					{
						Control = "Stack",
						Direction = "Horizontal",
						Fill = true,
						Style = "Buttons",
						Children = {
							{ Control = "Button", Id = "S_None", Text = "No bots", Style = "Tab" },
							{ Control = "Button", Id = "S_Easy", Text = "Easy", Style = "Tab" },
							{ Control = "Button", Id = "S_Medium", Text = "Medium", Style = "Tab" },
							{ Control = "Button", Id = "S_Hard", Text = "Hard", Style = "Tab" },
						},
					},
					{ Control = "Label", Id = "S_Description", Text = "Bots that hit more than half their shots.", Align = "Center", Style = "Dim" },
					{ Control = "Label", Id = "S_Reward", Text = "Win: 35 coins", Align = "Center", Style = "Price" },
					{
						Control = "Button",
						Id = "S_Start",
						Text = "Start",
						Style = { "Primary", "Large" },
						Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonA" } },
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
					Position = UDim2.fromScale(0.55, 0.978),
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
			One open public match on a purple card, as modes are: the mode with its players and timer across the top, then
			its map and Join (Join teams for team modes), blue since a list of matches has no one next step
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
						{ Control = "Label", Id = "S_Mode", Text = "Deathmatch", Grow = 1, Style = "Strong" },
						{ Control = "Label", Id = "S_Players", Text = "3 / 6", Style = "Small" },
						{ Control = "Label", Id = "S_Timer", Text = "0:30", Style = { "Small", "Warning" } },
					},
				},
				{
					Control = "Stack",
					Direction = "Horizontal",
					Children = {
						{ Control = "Label", Id = "S_Map", Text = "Picnic Plains", Grow = 1, Style = "Small" },
						-- Sized for "Join teams", so both labels read the same; small, as list rows' buttons are
						{ Control = "Button", Id = "S_Join", Text = "Join teams", AutoWidth = true, Style = "Small" },
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
