--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- System's Currency, with the game's coin and diamond bar: ume's Currency slots find it as I.UserInterface.UI["Currency"]
	Name = "Currency",
	Theme = "WormBattlegrounds",
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
			-- Top middle: coins and diamonds (Currency_Slot labels ume's Currency writes), + opens the Shop
			{
				Control = "Box",
				Id = "U_Bar",
				Screen = true,
				Style = "Panel",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 12),
					Size = UDim2.fromOffset(520, 0),
				},
				Children = {
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Children = {
							{ Control = "Picture", Id = "S_CoinIcon", Image = "wb-coin", Style = "Glyph" },
							{
								Control = "Label",
								Id = "S_Coins",
								Text = "0",
								Style = { "Heading", "Coin" },
								Tags = { Currency_Slot = { Currency_Name = "Coins" } },
							},
							{ Control = "Picture", Id = "S_DiamondIcon", Image = "wb-diamond", Style = "Glyph" },
							{
								Control = "Label",
								Id = "S_Diamonds",
								Text = "0",
								Style = { "Heading", "Diamond" },
								Tags = { Currency_Slot = { Currency_Name = "Diamonds" } },
							},
							{
								Control = "Button",
								Id = "S_Add",
								Text = "+",
								AutoWidth = true,
								Style = { "Primary", "Small" },
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
