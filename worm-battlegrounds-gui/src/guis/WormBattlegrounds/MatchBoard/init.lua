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
		Bottom centre: U_Play (Play, the quick match, and Modes for the rest) until the player joins a public match, then
		U_WaitingRoom in its place
	]]
	Root = {
		Primitive = "Folder",
		Children = {
			{
				Primitive = "Frame",
				Id = "U_Play",
				Tags = { Utils_PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 0.9, Utils_ConsoleScale = 1, Utils_VRScale = 1 } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.978),
					Size = UDim2.fromOffset(760, 144),
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Style = "Buttons",
						Children = {
							-- The quick match: joins the open public match closest to starting
							{ Control = "Button", Id = "S_Quick", Text = "Play", Grow = 1, Style = { "Primary", "Hero" } },
							-- Opens PlayModes: solo against a bot, the public matches, a custom lobby
							{
								Control = "Button",
								Id = "S_Modes",
								Text = "Modes",
								AutoWidth = true,
								Style = "Hero",
								Tags = {
									Interact_Button = {
										Interact_ModuleName = "WidgetManager",
										Interact_Function = "Toggle",
										Interact_Arg1 = "PlayModes",
									},
								},
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
