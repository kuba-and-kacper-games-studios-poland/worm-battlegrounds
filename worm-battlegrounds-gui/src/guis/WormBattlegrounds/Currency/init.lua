--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- System's Currency, with the game's coin and diamond bar: ume's Currency slots find it as I.UserInterface.UI["Currency"]
	Name = "Currency",
	Theme = "WormBattlegroundsBrawl",
	-- Built disabled; the UserInterface server enables it at start (PreventHiding)
	Screen = { DisplayOrder = -999, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },
	ScreenTags = { UserInterface_PreventHiding = {} },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- The area currency orbs fly in (System's, kept as it is)
			{
				Primitive = "Frame",
				Id = "U_OrbsContainer",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.8, 0.8),
				},
			},
			-- Top right, on a dark pill: coins and diamonds (Currency_Slot labels ume's Currency writes), + opens the Shop
			{
				Control = "Box",
				Id = "U_Bar",
				Screen = true,
				Style = "Pill",
				Props = {
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(0.9875, 0.011),
					Size = UDim2.fromOffset(440, 0),
				},
				Children = {
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Children = {
							-- Each icon and count on a frame of its own, whose UIScale the count's Currency_Slot pulses as orbs arrive
							{
								Primitive = "Frame",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									AutomaticSize = Enum.AutomaticSize.XY,
									BackgroundTransparency = 1,
									Size = UDim2.new(),
								},
								Children = {
									{
										Control = "Stack",
										Direction = "Horizontal",
										Align = "Center",
										Props = { AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.new() },
										Children = {
											{ Control = "Picture", Id = "S_CoinIcon", Image = "wb-coin", Style = "Glyph" },
											{
												Control = "Label",
												Id = "S_Coins",
												Text = "0",
												Style = { "Heading", "Coin" },
												Tags = { Currency_Slot = { Currency_Name = "Coins" } },
											},
										},
									},
									{ Primitive = "UIScale", Id = "S_CoinsScale" },
								},
							},
							{
								Primitive = "Frame",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									AutomaticSize = Enum.AutomaticSize.XY,
									BackgroundTransparency = 1,
									Size = UDim2.new(),
								},
								Children = {
									{
										Control = "Stack",
										Direction = "Horizontal",
										Align = "Center",
										Props = { AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.new() },
										Children = {
											{ Control = "Picture", Id = "S_DiamondIcon", Image = "wb-diamond", Style = "Glyph" },
											{
												Control = "Label",
												Id = "S_Diamonds",
												Text = "0",
												Style = { "Heading", "Diamond" },
												Tags = { Currency_Slot = { Currency_Name = "Diamonds" } },
											},
										},
									},
									{ Primitive = "UIScale", Id = "S_DiamondsScale" },
								},
							},
							{
								Control = "Button",
								Id = "S_Add",
								Text = "",
								Icon = "plus-large",
								Style = { "Price", "Square" },
								Props = { Size = UDim2.fromOffset(96, 96) },
								Tags = {
									Interact_Button = {
										Interact_ModuleName = "WidgetManager",
										Interact_Function = "Toggle",
										Interact_Arg1 = "Shop",
									},
								},
							},
						},
					},
				},
			},
		},
	},
}

return _gui
