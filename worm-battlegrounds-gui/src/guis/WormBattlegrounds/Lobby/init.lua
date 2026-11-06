--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Lobby module turns it on, on the Lobby map, as I.UserInterface.UI["Lobby"]
	Name = "Lobby",
	Theme = "WormBattlegroundsBrawl",
	-- Under every other gui, over the whole screen, so the lobby's 3D stage shows behind it
	Screen = { DisplayOrder = -1000, Enabled = false, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			--[[
				Top centre: the game's name (shortcut: text in the kit's font until the owner's logo exists, then a
				picture); on phones and tablets small enough to sit between the Party tab and the coin bar
			]]
			{
				Primitive = "Frame",
				Id = "U_Logo",
				Tags = { Utils_PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 0.4, Utils_ConsoleScale = 1, Utils_VRScale = 1 } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.03),
					Size = UDim2.fromOffset(1200, 140),
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					{ Control = "Label", Text = "Worm Battlegrounds", Align = "Center", Style = { "Hero", "Gold" } },
				},
			},
			-- Top right, under the currency bar (clear of it on phones too): Crates and Skins, each opening its window
			{
				Primitive = "Frame",
				Id = "U_Menu",
				Tags = { Utils_PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 0.8, Utils_ConsoleScale = 1, Utils_VRScale = 1 } },
				Props = {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.9875, 0.165),
					Size = UDim2.fromOffset(340, 200),
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "End",
						Style = "Buttons",
						Children = {
							{
								Control = "Item",
								Id = "U_OpenCrates",
								Text = "Crates",
								Image = "wb-crate",
								Style = "Square",
								Children = {
									-- Crates fills it: FREE while a free crate waits, else how many crates the coins open
									{
										Control = "Box",
										Id = "S_Badge",
										Visible = false,
										Style = { "Badge", "Fixed" },
										Props = {
											AnchorPoint = Vector2.new(1, 0),
											Position = UDim2.new(1, 16, 0, -16),
											Size = UDim2.fromOffset(104, 56),
										},
										Children = {
											{ Control = "Label", Id = "S_Count", Text = "FREE", Align = "Center", Style = "Strong" },
										},
									},
								},
								Tags = {
									Interact_Button = {
										Interact_ModuleName = "WidgetManager",
										Interact_Function = "Toggle",
										Interact_Arg1 = "Crates",
									},
								},
							},
							-- Shows the equipped skin
							{
								Control = "Item",
								Id = "U_Skins",
								Text = "Skins",
								Subtext = "Classic",
								Style = "Square",
								Tags = {
									Interact_Button = {
										Interact_ModuleName = "WidgetManager",
										Interact_Function = "Toggle",
										Interact_Arg1 = "Skins",
									},
								},
							},
						},
					},
				},
			},
			-- The tutorial's arrow layer: Tutorial moves S_Arrow over what the player should press
			{
				Primitive = "Frame",
				Id = "U_Pointer",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 10,
				},
				Children = {
					{
						Control = "Picture",
						Id = "S_Arrow",
						Image = "chevron-small-down",
						Style = "Glyph",
						Visible = false,
					},
				},
			},
		},
	},
}

return _gui
