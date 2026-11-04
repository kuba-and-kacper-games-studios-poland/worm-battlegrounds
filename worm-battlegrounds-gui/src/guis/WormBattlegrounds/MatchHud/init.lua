--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The MatchHud module turns it on, on the Match map, as I.UserInterface.UI["MatchHud"]
	Name = "MatchHud",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },
	Devices = { "Desktop", "Mobile", "Console" },

	--[[ Tree ]]

	--[[
		The match screen. MatchHud shows each block in its phase: U_Waiting, then U_Drop, then the turn blocks,
		U_KnockedOut once the player's worm is out
	]]
	Root = {
		Primitive = "Folder",
		Children = {
			--%%%%%%%%%%%%%%%%%%%% Top

			-- Whose turn (the banner only on the player's own turn), the 15-second timer, the wind
			{
				Control = "Box",
				Id = "U_Turn",
				Screen = true,
				-- Smaller on phones and tablets, so the tutorial hint fits under it
				Style = { "Hud", PlatformScale = { Utils_MobileScale = 0.6 } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0.011),
					Size = UDim2.fromOffset(480, 0),
				},
				Children = {
					{ Control = "Label", Id = "S_Banner", Text = "Your turn!", Align = "Center", Style = "Title" },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Style = "Loose",
						Children = {
							{ Control = "Label", Id = "S_Timer", Text = "15", Style = "Display" },
							-- Points the way the wind blows (rotated by code)
							{ Control = "Picture", Id = "S_WindArrow", Image = "chevron-small-right", Style = "Glyph" },
							{ Control = "Label", Id = "S_Wind", Text = "Wind 4", Style = "Heading" },
						},
					},
				},
			},
			-- Top right, under the top bar: a line per knockout (PREFAB | FeedLine)
			{
				Control = "Cells",
				Id = "U_KillFeed",
				Scroll = false,
				Style = "Fixed",
				Tags = { Utils_PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 0.8, Utils_ConsoleScale = 1, Utils_VRScale = 1 } },
				Props = {
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(0.9875, 0.067),
					Size = UDim2.fromOffset(560, 320),
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
				},
			},

			--%%%%%%%%%%%%%%%%%%%% Bottom

			-- The player's loadout: one box per slot (PREFAB | BarSlot); 1–5, a tap, or LB / RB pick one
			{
				Control = "Box",
				Id = "U_LoadoutBar",
				Screen = true,
				Style = "Hud",
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 0.989),
					Size = UDim2.fromOffset(720, 0),
				},
				Children = {
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Children = {
							{
								Control = "Label",
								Id = "S_PrevHint",
								Text = "LB",
								Visible = false,
								Style = "Strong",
								Tags = { Console_Hint = {} },
							},
							{
								Control = "Cells",
								Id = "U_Slots",
								Direction = "Horizontal",
								Scroll = false,
								Style = "Fixed",
								Props = { Size = UDim2.fromOffset(640, 120) },
							},
							{
								Control = "Label",
								Id = "S_NextHint",
								Text = "RB",
								Visible = false,
								Style = "Strong",
								Tags = { Console_Hint = {} },
							},
						},
					},
				},
			},
			-- Above the loadout bar: stamina on the player's turn, and the smiley that opens the emote wheel
			{
				Control = "Box",
				Id = "U_Stamina",
				Screen = true,
				Style = "Hud",
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					-- High enough to clear the bar on a phone, where panels are biggest for the screen
					Position = UDim2.fromScale(0.5, 0.79),
					Size = UDim2.fromOffset(420, 0),
				},
				Children = {
					{ Control = "Progress", Id = "S_Bar", Text = "Stamina", Value = 0.7, Style = "Stamina" },
				},
			},
			{
				Control = "Item",
				Id = "U_EmoteButton",
				Image = "wb-smiley",
				Screen = true,
				Style = "Small",
				Props = { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.21, 0.978) },
			},
			-- Bottom right: the shot's power and angle while aiming
			{
				Control = "Box",
				Id = "U_Power",
				Screen = true,
				Style = "Hud",
				Props = {
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.fromScale(0.9875, 0.978),
					Size = UDim2.fromOffset(320, 0),
				},
				Children = {
					{ Control = "Progress", Id = "S_Bar", Text = "Power", Value = 0.6, Style = "Power" },
					{ Control = "Label", Id = "S_Angle", Text = "Angle 45°", Align = "Center", Style = "Heading" },
				},
			},
			-- Phones and tablets: walk and jump buttons (aiming is a drag), each scaled with the screen
			{
				Primitive = "Frame",
				Id = "U_Touch",
				Tags = {
					Utils_HideOnPlatform = {
						Utils_DesktopVisibility = false,
						Utils_ConsoleVisibility = false,
						Utils_VRVisibility = false,
					},
				},
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
				},
				Children = {
					{
						Control = "Button",
						Id = "S_Left",
						Text = "&lt;",
						Screen = true,
						Props = {
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0.0125, 0.8),
							Size = UDim2.fromOffset(120, 112),
						},
					},
					{
						Control = "Button",
						Id = "S_Right",
						Text = "&gt;",
						Screen = true,
						Props = {
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0.11, 0.8),
							Size = UDim2.fromOffset(120, 112),
						},
					},
					{
						Control = "Button",
						Id = "S_Jump",
						Text = "Jump",
						Style = "Large",
						Screen = true,
						Props = {
							AnchorPoint = Vector2.new(1, 1),
							Position = UDim2.fromScale(0.9875, 0.73),
							Size = UDim2.fromOffset(160, 112),
						},
					},
				},
			},

			--%%%%%%%%%%%%%%%%%%%% Middle

			-- A circle of the player's emotes (PREFAB | WheelEmote), placed around the middle by code
			{
				Primitive = "Frame",
				Id = "U_EmoteWheel",
				Visible = false,
				Tags = { Utils_PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 1, Utils_ConsoleScale = 1, Utils_VRScale = 1 } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(440, 440),
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
				},
			},
			-- The drop phase: everyone picks where to land, all at once
			{
				Control = "Box",
				Id = "U_Drop",
				Screen = true,
				Visible = false,
				Style = { "Hud", PlatformScale = { Utils_MobileScale = 0.6 } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0.011),
					Size = UDim2.fromOffset(480, 0),
				},
				Children = {
					{ Control = "Label", Text = "Pick where to land", Align = "Center", Style = "Title" },
					{ Control = "Label", Id = "S_Timer", Text = "15", Align = "Center", Style = "Display" },
				},
			},
			-- The player's worm is out: watch the rest, or leave keeping their place
			{
				Control = "Box",
				Id = "U_KnockedOut",
				Screen = true,
				Visible = false,
				Style = "Panel",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(520, 0),
				},
				Children = {
					{ Control = "Label", Text = "You were knocked out!", Align = "Center", Style = "Title" },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Fill = true,
						Style = "Buttons",
						Children = {
							{
								Control = "Button",
								Id = "S_Spectate",
								Text = "Spectate",
								Style = "Primary",
								Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonA" } },
							},
							{
								Control = "Button",
								Id = "S_Leave",
								Text = "Leave",
								Style = "Danger",
								Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" } },
							},
						},
					},
				},
			},
			-- Before the match fills
			{
				Control = "Box",
				Id = "U_Waiting",
				Screen = true,
				Visible = false,
				Style = "Hud",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(480, 0),
				},
				Children = {
					{ Control = "Label", Text = "Waiting for players", Align = "Center", Style = "Title" },
					{ Control = "Label", Id = "S_Count", Text = "3 / 8", Align = "Center", Style = "Heading" },
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- A loadout slot: icon, uses left, the cooldown cover, its key
		["PREFAB | BarSlot"] = {
			Control = "Item",
			Parent = "U_Slots",
			Style = "Small",
			Children = {
				{
					Control = "Label",
					Id = "S_Key",
					Text = "1",
					Style = "Small",
					Tags = {
						Utils_HideOnPlatform = { Utils_MobileVisibility = false, Utils_ConsoleVisibility = false },
					},
					Props = { Position = UDim2.fromOffset(8, 4) },
				},
				{
					Control = "Label",
					Id = "S_Uses",
					Text = "×3",
					Align = "Right",
					Style = "Strong",
					Props = {
						AnchorPoint = Vector2.new(1, 1),
						Position = UDim2.new(1, -8, 1, -4),
						Size = UDim2.fromScale(0.6, 0),
					},
				},
				-- Covers the slot while it cools down, with the turns left
				{
					Control = "Box",
					Id = "S_Cooldown",
					Visible = false,
					-- A darker slot over the item, so the turns left read on their own
					Style = { "Fixed", Slab = { FillTransparency = 0.2, Fade = 0 } },
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Control = "Label", Id = "S_Turns", Text = "2", Align = "Center", Style = "Title" },
					},
				},
			},
		},
		-- "Bax knocked out Ninja with the Black hole grenade", names in team colours
		["PREFAB | FeedLine"] = {
			Control = "Label",
			Parent = "U_KillFeed",
			Text = "Bax knocked out Ninja with the Black hole grenade",
			Align = "Right",
			Style = { "Strong", "Outlined" },
		},
		-- An emote on the wheel
		["PREFAB | WheelEmote"] = {
			Control = "Item",
			Parent = "U_EmoteWheel",
			Style = "Small",
			Props = { AnchorPoint = Vector2.new(0.5, 0.5) },
		},
	},
}

return _gui
