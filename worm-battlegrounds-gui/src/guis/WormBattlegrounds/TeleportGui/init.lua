--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		ume's Teleport clones it from ServerStorage.Ume.UtilityGuis into each teleported player's PlayerGui. The map's
		scene fills U_Scene at runtime (the Transition module), under the plate: the band, the texts and the progress bar
	]]
	Name = "TeleportGui",
	-- Shown as soon as it's cloned, over everything, edge to edge
	Screen = { DisplayOrder = 100, Enabled = true, ResetOnSpawn = false, ScreenInsets = Enum.ScreenInsets.None, ClipToDeviceSafeArea = false },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- Covers the game while the teleport happens: the scene, a soft shade, then the plate
			{
				Primitive = "Frame",
				Id = "U_Backdrop",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(7, 17, 28),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					LayoutOrder = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 2,
				},
				Children = {
					-- The map's layers, one frame per scene, built by the Transition module
					{
						Primitive = "Frame",
						Id = "U_Scene",
						Props = { BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1 },
					},
					-- Darker at the top and behind the title, so the white text reads on any sky
					{
						Primitive = "CanvasGroup",
						Id = "U_Shade",
						Props = { BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
						Children = {
							{
								Primitive = "Frame",
								Props = { Name = "Top", BackgroundColor3 = Color3.fromRGB(8, 9, 16), BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.fromScale(1, 0.22) },
								Children = {
									{ Primitive = "UIGradient", Props = { Rotation = 90, Transparency = NumberSequence.new(0.62, 1) } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Left", BackgroundColor3 = Color3.fromRGB(8, 9, 16), BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromScale(0.5, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Transparency = NumberSequence.new(0.58, 1) } },
								},
							},
							{
								Primitive = "Frame",
								Props = {
									Name = "Bottom",
									AnchorPoint = Vector2.new(0, 1),
									BackgroundColor3 = Color3.fromRGB(8, 9, 16),
									BorderSizePixel = 0,
									LayoutOrder = 2,
									Position = UDim2.fromScale(0, 1),
									Size = UDim2.fromScale(1, 0.42),
								},
								Children = {
									{ Primitive = "UIGradient", Props = { Rotation = 90, Transparency = NumberSequence.new(1, 0.45) } },
								},
							},
						},
					},
					-- The plate: everything the player reads, which rises in and drops away together
					{
						Primitive = "Frame",
						Id = "U_Plate",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 2,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 3,
						},
						Children = {
							-- A slim navy bar along the bottom; the progress line runs along its top edge
							{
								Primitive = "Frame",
								Id = "S_Band",
								Props = {
									AnchorPoint = Vector2.new(0.5, 1),
									BackgroundColor3 = Color3.fromRGB(17, 18, 29),
									BackgroundTransparency = 0.08,
									BorderSizePixel = 0,
									LayoutOrder = 0,
									Position = UDim2.fromScale(0.5, 1),
									Size = UDim2.fromScale(1, 0.115),
								},
							},
							-- "Heading to", "Finding a match", "Back to", in the map's accent colour
							{
								Primitive = "Frame",
								Id = "S_KickerBar",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 212, 59),
									BorderSizePixel = 0,
									LayoutOrder = 1,
									Position = UDim2.fromScale(0.054, 0.712),
									Size = UDim2.fromScale(0.022, 0.009),
									ZIndex = 2,
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_Kicker",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 2,
									Position = UDim2.fromScale(0.082, 0.712),
									Size = UDim2.fromScale(0.5, 0.04),
									ZIndex = 2,
									Text = "HEADING TO",
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									TextColor3 = Color3.fromRGB(255, 212, 59),
									TextSize = 36,
									TextScaled = true,
									TextXAlignment = Enum.TextXAlignment.Left,
									RichText = true,
								},
								Children = {
									{ Primitive = "UIStroke", Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize } },
								},
							},
							-- The map's name, or "Finding a match" while the server seats the player
							{
								Primitive = "TextLabel",
								Id = "S_Title",
								Props = {
									AnchorPoint = Vector2.new(0, 0),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 3,
									Position = UDim2.fromScale(0.05, 0.735),
									Size = UDim2.fromScale(0.6, 0.11),
									ZIndex = 2,
									Text = "DESERT",
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 100,
									TextScaled = true,
									TextXAlignment = Enum.TextXAlignment.Left,
									RichText = true,
								},
								Children = {
									{ Primitive = "UIStroke", Props = { Thickness = 0.06, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize } },
									{ Primitive = "UIScale", Id = "S_TitleScale", Props = { Scale = 1 } },
								},
							},
							-- Three accent squares after the title while the match is being found; code places them by the title's width
							{
								Primitive = "Frame",
								Id = "S_Dots",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 4,
									Position = UDim2.fromScale(0.5, 0.807),
									Size = UDim2.fromScale(0.08, 0.019),
									Visible = false,
									ZIndex = 2,
								},
								Children = {
									{
										Primitive = "UIListLayout",
										Props = { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0.07, 0), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center },
									},
									{
										Primitive = "Frame",
										Props = { Name = "Dot", BackgroundColor3 = Color3.fromRGB(255, 212, 59), BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Height } },
										},
									},
									{
										Primitive = "Frame",
										Props = { Name = "Dot", BackgroundColor3 = Color3.fromRGB(255, 212, 59), BorderSizePixel = 0, LayoutOrder = 2, Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Height } },
										},
									},
									{
										Primitive = "Frame",
										Props = { Name = "Dot", BackgroundColor3 = Color3.fromRGB(255, 212, 59), BorderSizePixel = 0, LayoutOrder = 3, Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Height } },
										},
									},
								},
							},
							-- The mode's glyph and "Deathmatch · 6 snails" on the band
							{
								Primitive = "ImageLabel",
								Id = "S_ModeIcon",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 5,
									Position = UDim2.fromScale(0.054, 0.9425),
									Size = UDim2.fromScale(0.05, 0.042),
									ZIndex = 2,
									Image = "rbxassetid://88744460498201",
								},
								Children = {
									{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Height } },
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_Info",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 6,
									Position = UDim2.fromScale(0.084, 0.9425),
									Size = UDim2.fromScale(0.42, 0.032),
									ZIndex = 2,
									Text = 'DEATHMATCH  <font transparency="0.3">·  6 SNAILS</font>',
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 34,
									TextScaled = true,
									TextXAlignment = Enum.TextXAlignment.Left,
									RichText = true,
								},
								Children = {
									{ Primitive = "UIStroke", Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize } },
								},
							},
							-- A tip, changing while the plate shows
							{
								Primitive = "Frame",
								Id = "S_TipChip",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 212, 59),
									BorderSizePixel = 0,
									LayoutOrder = 7,
									Position = UDim2.fromScale(0.555, 0.9425),
									Size = UDim2.fromScale(0.034, 0.03),
									ZIndex = 2,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.25, 0) } },
									{
										Primitive = "TextLabel",
										Props = {
											Name = "ChipText",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.54),
											Size = UDim2.fromScale(0.8, 0.74),
											ZIndex = 3,
											Text = "TIP",
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											TextColor3 = Color3.fromRGB(12, 12, 20),
											TextSize = 24,
											TextScaled = true,
											RichText = true,
										},
									},
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_Tip",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 8,
									Position = UDim2.fromScale(0.597, 0.9425),
									Size = UDim2.fromScale(0.35, 0.027),
									ZIndex = 2,
									Text = "A GRENADE BURSTS AS SOON AS IT STOPS ROLLING",
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextTransparency = 0.18,
									TextSize = 28,
									TextScaled = true,
									TextXAlignment = Enum.TextXAlignment.Left,
									RichText = true,
								},
								Children = {
									{ Primitive = "UIStroke", Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize } },
								},
							},
							-- The progress line along the bar's top edge, with the shell glyph rolling at its head
							{
								Primitive = "Frame",
								Id = "S_Track",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 0.9,
									BorderSizePixel = 0,
									LayoutOrder = 9,
									Position = UDim2.fromScale(0.5, 0.885),
									Size = UDim2.fromScale(1, 0.006),
									ZIndex = 2,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
									{
										Primitive = "Frame",
										Props = {
											Name = "Fill",
											AnchorPoint = Vector2.new(0, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 212, 59),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0, 0.5),
											Size = UDim2.fromScale(0.4, 1),
											ZIndex = 3,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
										},
									},
									{
										Primitive = "ImageLabel",
										Props = {
											Name = "Shell",
											AnchorPoint = Vector2.new(0.5, 0.62),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.4, 0.5),
											Size = UDim2.fromScale(0.05, 9),
											ZIndex = 4,
											Image = "rbxassetid://137985730069220",
										},
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Height } },
										},
									},
								},
							},
						},
					},
				},
			},
			-- ume's Teleport waits this long after showing the card, so its intro plays before the teleport
			{ Primitive = "NumberValue", Props = { Name = "GuiAnimDuration", Value = 0.45 } },
		},
	},
}

return _gui
