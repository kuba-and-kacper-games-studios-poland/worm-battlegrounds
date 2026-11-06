--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Party module turns it on, on the Lobby map, as I.UserInterface.UI["Party"]
	Name = "Party",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	--[[
		Top left: up to 4 players who join matches together. The tab ("Party 2/4") folds and opens the panel under it:
		open on PC, folded on phones and tablets, where the open panel would cover the Loadout card
	]]
	Root = {
		Primitive = "Frame",
		Id = "U_Party",
		-- The kit's panel scale per device; a little smaller on phones and tablets, so a full party fits under the tab
		Tags = { Utils_PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 0.85, Utils_ConsoleScale = 1, Utils_VRScale = 1 } },
		Props = {
			AnchorPoint = Vector2.new(0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.0125, 0.067),
			Size = UDim2.fromOffset(500, 0),
		},
		Children = {
			{ Primitive = "UIScale", Id = "S_ScreenScale" },
			{
				Control = "Stack",
				Style = "Tight",
				Props = { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.fromScale(1, 0) },
				Children = {
					-- Party's code writes the count and shows it selected (the kit's blue) while the panel is open
					{ Control = "Button", Id = "S_Tab", Text = "Party", Icon = "chevron-small-down", Style = "Tab" },
					-- As tall as its members, the buttons under them
					{
						Control = "Box",
						Id = "S_Panel",
						Style = "Panel",
						Children = {
							-- The party's players (PREFAB | Member)
							{
								Control = "Cells",
								Id = "U_Members",
								Scroll = false,
								Style = "Fixed",
								Props = { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.fromScale(1, 0) },
							},
							-- Invite players in this server, or friends through Roblox's prompt: blue, the lobby's yellows are Play and a free crate
							{
								Control = "Stack",
								Direction = "Horizontal",
								Fill = true,
								Style = "Buttons",
								Children = {
									{ Control = "Button", Id = "U_Invite", Text = "Invite players", Style = "Small" },
									{ Control = "Button", Id = "U_InviteFriends", Text = "Invite friends", Style = "Small" },
								},
							},
							{ Control = "Button", Id = "U_Leave", Text = "Leave party", Style = { "Danger", "Small" } },
						},
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- A party member: avatar, name, level, the leader's crown, and Kick (leader only)
		["PREFAB | Member"] = {
			Control = "Stack",
			Parent = "U_Members",
			Direction = "Horizontal",
			Children = {
				{ Control = "Picture", Id = "S_Avatar", Style = "Avatar" },
				{
					Control = "Stack",
					Grow = 1,
					Style = "None",
					Children = {
						{ Control = "Label", Id = "S_Name", Text = "PlayerName", Style = "Strong" },
						{ Control = "Label", Id = "S_Level", Text = "Level 12", Style = { "Small", "Dim" } },
					},
				},
				{ Control = "Picture", Id = "S_Crown", Image = "wb-crown", Style = "Glyph" },
				{ Control = "Button", Id = "S_Kick", Text = "Kick", AutoWidth = true, Style = { "Danger", "Small" } },
			},
		},
	},
}

return _gui
