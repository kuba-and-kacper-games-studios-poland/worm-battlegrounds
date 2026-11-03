--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The ScreenGui ume's TopBar module finds (I.UserInterface.UI["TopBar"]); a game's own copy keeps this name
	Name = "TopBar",
	-- Drawn in Roblox's top bar, between Roblox's own buttons, over every other gui
	Screen = {
		ClipToDeviceSafeArea = true,
		DisplayOrder = 1000000,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension,
		ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets,
	},
	-- Shown from the start: the server disables every other gui until its module opens it
	ScreenTags = { UserInterface_PreventHiding = {} },
	-- Console shows a button's gamepad key next to its icon (S_KeyHint)
	Devices = { "Desktop", "Console" },

	--[[ Tree ]]

	-- The bar, as tall as its buttons need: the TopBar module keeps its bottom on the bottom of Roblox's top bar inset
	-- (GuiService.TopbarInset). Plain instances, as Roblox's own top bar draws them, so no theme changes it
	Root = {
		Primitive = "Frame",
		Id = "U_Bar",
		Props = { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 10), Size = UDim2.new(1, 0, 0, 48) },
		Children = {
			{ Primitive = "UIPadding", Props = { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 16) } },

			--[[ Sides ]]

			-- The buttons on the left half, from the left edge
			{
				Primitive = "Frame",
				Id = "U_Left",
				Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(0.5, 1) },
				Children = {
					{
						Primitive = "UIListLayout",
						Props = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							Padding = UDim.new(0, 8),
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						},
					},
				},
			},
			-- The buttons on the right half, from the right edge
			{
				Primitive = "Frame",
				Id = "U_Right",
				Props = {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.fromScale(0.5, 1),
				},
				Children = {
					{
						Primitive = "UIListLayout",
						Props = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Right,
							Padding = UDim.new(0, 8),
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One button, cloned into U_Left or U_Right by the TopBar module (I.TopBar.AddButton). A 44 px circle until a
		-- text or a key hint widens it; the module shows S_Icon, S_Text and S_KeyHint and pads S_Content while it has a
		-- text or shows its key
		["PREFAB | Button"] = {
			Primitive = "ImageButton",
			Parent = "U_Left",
			Tags = { Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
			Props = {
				AutoButtonColor = false,
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Image = "",
				ImageTransparency = 1,
				Size = UDim2.fromOffset(44, 44),
			},
			Children = {
				-- The round fill, Roblox's top bar grey
				{
					Primitive = "Frame",
					Props = {
						Name = "Background",
						BackgroundColor3 = Color3.fromRGB(18, 18, 20),
						BackgroundTransparency = 0.08,
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
					},
				},
				-- The icon and the text side by side, centred
				{
					Primitive = "Frame",
					Id = "S_Content",
					Props = { AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
					Children = {
						{
							Primitive = "UIListLayout",
							Props = {
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
								Padding = UDim.new(0, 6),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							},
						},
						-- None until the button has a text
						{ Primitive = "UIPadding", Id = "S_Padding" },
						{
							Primitive = "ImageLabel",
							Id = "S_Icon",
							Visible = false,
							Props = { BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(0.6, 0.6) },
							Children = {
								{ Primitive = "UIAspectRatioConstraint" },
							},
						},
						{
							Primitive = "TextLabel",
							Id = "S_Text",
							Visible = false,
							Props = {
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundTransparency = 1,
								FontFace = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
								LayoutOrder = 2,
								Size = UDim2.fromScale(0, 1),
								Text = "",
								TextColor3 = Color3.new(1, 1, 1),
								TextSize = 18,
							},
						},
						-- The gamepad key that presses the button, after its icon and text; the TopBar module gives it the key's
						-- icon and shows it on Console only
						{
							Primitive = "ImageLabel",
							Id = "S_KeyHint",
							Visible = false,
							Props = { BackgroundTransparency = 1, LayoutOrder = 3, Size = UDim2.fromScale(0.6, 0.6) },
							Children = {
								{ Primitive = "UIAspectRatioConstraint" },
							},
						},
					},
				},
				-- Lightens the button while it is hovered or pressed, over the icon and the text
				{
					Primitive = "Frame",
					Id = "S_Highlight",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -8, 1, -8),
						ZIndex = 3,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
					},
				},
			},
		},
	},
}

return _gui
