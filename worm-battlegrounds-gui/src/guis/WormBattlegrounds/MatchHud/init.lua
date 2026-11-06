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
				-- A little smaller on phones and tablets, so the kill feed fits beside it; its wind text stays 15 px on a phone
				Style = { "Hud", PlatformScale = { Utils_MobileScale = 0.7 } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0.011),
					Size = UDim2.fromOffset(480, 0),
				},
				Children = {
					-- "Your turn!" on the player's own turn; on other worms' turns "Bax's turn", in their team colour
					{ Control = "Label", Id = "S_Banner", Text = "Your turn!", Align = "Center", Style = "Title" },
					-- On other worms' turns: how long until the player's own ("You're next!", "Your turn in 3 turns")
					{
						Control = "Label",
						Id = "S_Wait",
						Text = "Your turn in 3 turns",
						Align = "Center",
						Visible = false,
						Style = "Heading",
					},
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Style = "Loose",
						Children = {
							-- The turn's seconds, by a stopwatch
							{
								Control = "Stack",
								Direction = "Horizontal",
								Align = "Center",
								Style = "Tight",
								Children = {
									{ Control = "Picture", Image = "wb-clock", Style = "Icon" },
									{ Control = "Label", Id = "S_Timer", Text = "15", Style = "Display" },
								},
							},
							-- The wind: gusts, the way it blows (the arrow, rotated by code) and its strength 0 to 10
							{
								Control = "Stack",
								Direction = "Horizontal",
								Align = "Center",
								Style = "Tight",
								Children = {
									{ Control = "Picture", Image = "wb-wind", Style = "Icon" },
									{ Control = "Picture", Id = "S_WindArrow", Image = "chevron-small-right", Style = "Glyph" },
									{ Control = "Label", Id = "S_Wind", Text = "10", Style = "Heading" },
								},
							},
						},
					},
				},
			},
			-- Top right, under the top bar: a line per knockout (PREFAB | FeedLine); narrower on phones and tablets, beside the turn panel
			{
				Control = "Cells",
				Id = "U_KillFeed",
				Scroll = false,
				Style = "Fixed",
				Tags = {
					Utils_PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 1, Utils_ConsoleScale = 1, Utils_VRScale = 1 },
					Utils_PlatformSize = { Utils_MobileSize = UDim2.fromOffset(440, 320) },
				},
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

			--[[
				The player's loadout: one box per slot (PREFAB | BarSlot); 1–5, a tap, or LB / RB pick one. Stamina and the
				shot's power sit in a row on top of the slots, inside the same block, so they hug the bar on every screen
			]]
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
						Fill = true,
						Style = "Loose",
						Children = {
							-- On the player's turn: how far the worm can still walk
							{
								Control = "Stack",
								Id = "U_Stamina",
								Style = "None",
								Children = {
									{ Control = "Progress", Id = "S_Bar", Text = "Stamina", Value = 0.7, Style = "Stamina" },
								},
							},
							-- While aiming: the shot's power, then its angle (sized for "-90°")
							{
								Control = "Stack",
								Id = "U_Power",
								Direction = "Horizontal",
								Align = "Center",
								Style = "Tight",
								Children = {
									{ Control = "Progress", Id = "S_Bar", Text = "Power", Value = 0.6, Grow = 1, Style = "Power" },
									{ Control = "Label", Id = "S_Angle", Text = "-90°", Style = "Heading" },
								},
							},
						},
					},
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
			-- Right of the bar, clear of Jump on a phone: the smiley that opens the emote wheel
			{
				Control = "Item",
				Id = "U_EmoteButton",
				Image = "wb-smiley",
				Screen = true,
				Style = "Small",
				Props = { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.81, 0.978) },
			},
			--[[
				Phones and tablets: walk buttons in the bottom-left corner and Jump in the bottom-right (aiming is a press and hold), on
				the bar's line, each scaled with the screen
			]]
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
							Position = UDim2.fromScale(0.0125, 0.978),
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
							Position = UDim2.fromScale(0.11, 0.978),
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
							Position = UDim2.fromScale(0.9875, 0.978),
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
			-- The drop phase: everyone picks where to land, all at once (sized like the turn panel)
			{
				Control = "Box",
				Id = "U_Drop",
				Screen = true,
				Visible = false,
				Style = { "Hud", PlatformScale = { Utils_MobileScale = 0.7 } },
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
					-- A corner badge: sized by the slot, so it stays inside it
					Props = { Position = UDim2.fromOffset(8, 4), Size = UDim2.fromScale(0.5, 0.4) },
				},
				{
					Control = "Label",
					Id = "S_Uses",
					Text = "x3",
					Align = "Right",
					Style = "Strong",
					Props = {
						AnchorPoint = Vector2.new(1, 1),
						Position = UDim2.new(1, -8, 1, -4),
						Size = UDim2.fromScale(0.6, 0.4),
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
