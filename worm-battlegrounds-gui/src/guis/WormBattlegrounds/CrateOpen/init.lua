--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- Crates draws it on WidgetManager_Opened as I.UserInterface.UI["CrateOpen"]
	Name = "CrateOpen",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- The reveal: the crate shakes, bursts in the result's rarity colour, then shows the item (or 10 of them)
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Weapon crate",
		Style = "Large",
		Children = {
			{
				Primitive = "Frame",
				Id = "U_Stage",
				Props = { BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1, 0) },
				Children = {
					{ Primitive = "UIFlexItem", Props = { FlexMode = Enum.UIFlexMode.Fill } },
					-- The crate before it opens (shaken by code)
					{
						Control = "Picture",
						Id = "S_Crate",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(260, 260),
						},
					},
					-- I.UIEmitter bursts here, in the result's rarity colour
					{
						Primitive = "Frame",
						Id = "S_Burst",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 2,
						},
					},
					-- One result
					{
						Control = "Item",
						Id = "S_Card",
						Text = "Grenade",
						Subtext = "Rare",
						Image = "wb-grenade",
						Visible = false,
						Style = "Rare",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							ZIndex = 3,
						},
						Children = {
							{
								Control = "Label",
								Id = "S_Shiny",
								Text = "Shiny!",
								Align = "Center",
								Visible = false,
								Style = { "Heading", "Warning" },
								Props = { Position = UDim2.fromOffset(0, 6) },
							},
						},
					},
				},
			},
			-- Ten results at once (PREFAB | ResultCard)
			{ Control = "Cells", Id = "U_Cards", Visible = false, Style = "Grid", Props = { LayoutOrder = 2 } },
			{
				Control = "Stack",
				Direction = "Horizontal",
				Align = "Center",
				Style = "Buttons",
				Props = { LayoutOrder = 3 },
				Children = {
					{
						Control = "Button",
						Id = "S_OpenAgain",
						Text = "Open again",
						AutoWidth = true,
						Style = "Primary",
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		["PREFAB | ResultCard"] = {
			Control = "Item",
			Parent = "U_Cards",
			Text = "Shotgun",
			Subtext = "Common",
			Children = {
				{
					Control = "Label",
					Id = "S_Shiny",
					Text = "Shiny!",
					Align = "Center",
					Visible = false,
					Style = { "Small", "Warning" },
					Props = { Position = UDim2.fromOffset(0, 6) },
				},
			},
		},
	},
}

return _gui
