--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		ume's Teleport clones it from ServerStorage.Ume.UtilityGuis into each teleported player's PlayerGui. Ported 1:1
		from the studio's Loading design (2026-11-12)
	]]
	Name = "TeleportGui",
	-- Shown as soon as it's cloned, over everything, edge to edge
	Screen = { DisplayOrder = 100, Enabled = true, ResetOnSpawn = false, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- Covers the game while the teleport happens; the Transition module slides it from its middle, card and all
			{
				Primitive = "Frame",
				Id = "U_Backdrop",
				Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ZIndex = 2 },
				Children = {
					{
						Primitive = "ImageLabel",
						Props = {
							Name = "Main",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ClipsDescendants = true,
							LayoutOrder = 0,
							Size = UDim2.fromScale(1, 1),
							Image = "rbxassetid://110345153505204",
							ImageColor3 = Color3.fromRGB(7, 17, 28),
						},
						Attributes = { _ImageName = "1212_991__Loading__Main_gray" },
					},
					{
						Primitive = "ImageLabel",
						Props = {
							Name = "Texture",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ClipsDescendants = true,
							LayoutOrder = 1,
							Size = UDim2.fromScale(1, 1),
							ZIndex = 2,
							Image = "rbxassetid://110725321871329",
						},
						Attributes = { _ImageName = "1212_992__Loading__Texture_image" },
					},
					-- The card: the map's picture, and where the player is going
					{
						Primitive = "Frame",
						Id = "U_Card",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 2,
							Position = UDim2.fromScale(0.5, 0.4657),
							Size = UDim2.fromScale(0.2742, 0.2481),
							ZIndex = 3,
						},
						Children = {
							{
								Primitive = "Frame",
								Props = { Name = "MapIcon", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0, Position = UDim2.fromScale(0.0734, 0), Size = UDim2.fromScale(0.8531, 0.7463) },
								Children = {
									{
										Primitive = "Frame",
										Props = { Name = "MapIconBackground", BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.65, BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.07, 0) } },
										},
									},
									{
										Primitive = "ImageLabel",
										Id = "S_Image",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											ClipsDescendants = true,
											LayoutOrder = 1,
											Position = UDim2.fromScale(0.1667, 0.28),
											Size = UDim2.fromScale(0.6667, 0.61),
											ZIndex = 2,
											Image = "rbxassetid://125855584029865",
										},
										Attributes = { _ImageName = "1212_1002__Loading__MapIcon_image" },
									},
								},
							},
							-- "Heading to <map>…", "Back to the lobby…"
							{
								Primitive = "TextLabel",
								Id = "S_Text",
								Props = {
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 1,
									Position = UDim2.fromScale(0, 0.8507),
									Size = UDim2.fromScale(1, 0.1493),
									ZIndex = 2,
									Text = "HEADING TO LOREM IPSUM...",
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 34,
									TextScaled = true,
									TextWrapped = true,
									RichText = true,
								},
								Tags = { TextCase_Upper = {} },
								Children = {
									{ Primitive = "UIStroke", Props = { Thickness = 0.0882, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize } },
								},
							},
							{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.9641 } },
						},
					},
				},
			},
			-- ume's Teleport waits this long after showing the card, so its slide plays before the teleport
			{ Primitive = "NumberValue", Props = { Name = "GuiAnimDuration", Value = 0.45 } },
		},
	},
}

return _gui
