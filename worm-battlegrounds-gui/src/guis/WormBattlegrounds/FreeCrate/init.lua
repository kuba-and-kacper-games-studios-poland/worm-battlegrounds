--[[
	Created By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The free crate for joining the studio's group: a tile in the lobby and a badge on the crates screen, which open its dialog (FreeCrateDialog)
	Name = "FreeCrate",
	-- Over the crates screen (DisplayOrder 1); the Crates module turns it on in the lobby and on that screen while the crate is unclaimed
	Screen = { DisplayOrder = 2, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- The badge: the crate shop's button in yellow, FREE CRATE, a red dot with 1 on its corner
			{
				Primitive = "ImageButton",
				Id = "U_Button",
				Props = {
					AnchorPoint = Vector2.new(1, 0.5),
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.975, 0.42),
					Size = UDim2.fromScale(0.15, 0.075),
				},
				Attributes = {
					ClickSound_Name = "Button_Click",
					ClickSound_PitchMax = 1,
					ClickSound_PitchMin = 1,
					ClickSound_PlaybackSpeed = 1,
					ClickSound_SoundGroup = "UI",
					ClickSound_TimePosition = 0,
					ClickSound_Volume = 1,
					Utils_ClickScale = 0.92,
					Utils_HoverScale = 1.06,
					Utils_ScaleAnimation = "Bouncy",
				},
				Tags = { Utils_ButtonScale = {}, Utils_ButtonSound = {} },
				Children = {
					{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 3.6 } },
					{
						Primitive = "Frame",
						Props = { Name = "Background", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
						Children = {
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Main",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.0015, 0.0556),
									Size = UDim2.fromScale(0.997, 0.8889),
									Image = "rbxassetid://96244980257546",
									ImageColor3 = Color3.fromRGB(255, 205, 50),
									ScaleType = Enum.ScaleType.Fit,
								},
							},
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Stroke2",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Size = UDim2.fromScale(1.0033, 1),
									ZIndex = 2,
									Image = "rbxassetid://103072937449096",
									ImageColor3 = Color3.fromRGB(25, 25, 35),
									ScaleType = Enum.ScaleType.Fit,
								},
							},
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Stroke",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.0066, 0.0222),
									Size = UDim2.fromScale(0.9867, 0.9556),
									ZIndex = 3,
									Image = "rbxassetid://98742725293542",
									ImageColor3 = Color3.fromRGB(230, 165, 20),
									ScaleType = Enum.ScaleType.Fit,
								},
							},
						},
					},
					{
						Primitive = "TextLabel",
						Props = {
							Name = "ButtonText",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.78, 0.52),
							ZIndex = 4,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "FREE CRATE",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							RichText = true,
							TextScaled = true,
							TextWrapped = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.1 } },
						},
					},
					-- The red dot: one reward waiting
					{
						Primitive = "Frame",
						Props = {
							Name = "Dot",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(235, 55, 55),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.97, 0.12),
							Size = UDim2.fromScale(0.42, 0.42),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							ZIndex = 5,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
							{
								Primitive = "TextLabel",
								Props = {
									Name = "DotText",
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.7, 0.7),
									ZIndex = 6,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									Text = "1",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
								},
							},
						},
					},
				},
			},
			-- The lobby's tile: the menu's tile in gold, left of STYLE, with the weapon crate, a sweeping light and the red dot
			{
				Primitive = "ImageButton",
				Id = "U_LobbyButton",
				Visible = false,
				Props = {
					AnchorPoint = Vector2.new(1, 0),
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.735, 0.092),
					Size = UDim2.fromScale(0.1, 0.115),
					ZIndex = 5,
				},
				Attributes = {
					ClickSound_Name = "Button_Click",
					ClickSound_PitchMax = 1,
					ClickSound_PitchMin = 1,
					ClickSound_PlaybackSpeed = 1,
					ClickSound_SoundGroup = "UI",
					ClickSound_TimePosition = 0,
					ClickSound_Volume = 1,
					HoverSound_Name = "Button_Hover",
					HoverSound_PitchMax = 1,
					HoverSound_PitchMin = 1,
					HoverSound_PlaybackSpeed = 1,
					HoverSound_SoundGroup = "UI",
					HoverSound_TimePosition = 0,
					HoverSound_Volume = 1,
					Utils_ClickScale = 0.92,
					Utils_HoverScale = 1.06,
					Utils_ScaleAnimation = "Bouncy",
				},
				Tags = { Utils_ButtonScale = {}, Utils_ButtonSound = {} },
				Children = {
					{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.2058 } },
					{
						Primitive = "Frame",
						Props = {
							Name = "Background",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.062, -0.0467),
							Size = UDim2.fromScale(0.9459, 0.9907),
						},
						Children = {
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Main",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.0083, 0.0472),
									Size = UDim2.fromScale(0.9833, 0.9057),
									Image = "rbxassetid://124280522035091",
									ImageColor3 = Color3.fromRGB(255, 196, 40),
									ScaleType = Enum.ScaleType.Fit,
								},
								Children = {
									{
										Primitive = "UIGradient",
										Props = {
											Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 170, 60)),
											Rotation = 90,
										},
									},
								},
							},
							-- The light sweeping across the tile: the same shape in white, shown through a moving band
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Shine",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.0083, 0.0472),
									Size = UDim2.fromScale(0.9833, 0.9057),
									ZIndex = 2,
									Image = "rbxassetid://124280522035091",
									ImageColor3 = Color3.fromRGB(255, 255, 255),
									ScaleType = Enum.ScaleType.Fit,
								},
								Children = {
									{
										Primitive = "UIGradient",
										Id = "S_TileShine",
										Props = {
											Offset = Vector2.new(-1, 0),
											Rotation = 20,
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 1),
												NumberSequenceKeypoint.new(0.42, 1),
												NumberSequenceKeypoint.new(0.5, 0.35),
												NumberSequenceKeypoint.new(0.58, 1),
												NumberSequenceKeypoint.new(1, 1),
											}),
										},
									},
								},
							},
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Stroke2",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									ClipsDescendants = true,
									Size = UDim2.fromScale(1, 1),
									ZIndex = 3,
									Image = "rbxassetid://98436890421039",
									ImageColor3 = Color3.fromRGB(25, 25, 35),
									ScaleType = Enum.ScaleType.Fit,
								},
							},
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Stroke",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									ClipsDescendants = true,
									Position = UDim2.fromScale(0.0164, 0.0189),
									Size = UDim2.fromScale(0.9672, 0.9623),
									ZIndex = 4,
									Image = "rbxassetid://100794772551035",
									ImageColor3 = Color3.fromRGB(255, 240, 170),
									ScaleType = Enum.ScaleType.Fit,
								},
							},
						},
					},
					-- The weapon crate (art/crates), as on the WEAPONS tile
					{
						Primitive = "ImageLabel",
						Id = "S_TileIcon",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Image = "rbxassetid://100039001608184",
							Position = UDim2.fromScale(0.53, 0.4),
							ScaleType = Enum.ScaleType.Fit,
							Size = UDim2.fromScale(0.68, 0.68),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							ZIndex = 5,
						},
						Children = {
							{ Primitive = "UIScale", Id = "S_TileBob", Props = { Scale = 1 } },
						},
					},
					{
						Primitive = "TextLabel",
						Props = {
							Name = "Name1",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.4652, 0.8692),
							Size = UDim2.fromScale(0.9302, 0.2617),
							ZIndex = 6,
							Text = "FREE WEAPONS",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.125 } },
						},
					},
					{
						Primitive = "Frame",
						Props = {
							Name = "Dot",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(235, 55, 55),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.95, 0.06),
							Size = UDim2.fromScale(0.26, 0.26),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							ZIndex = 7,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
							{
								Primitive = "TextLabel",
								Props = {
									Name = "DotText",
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.7, 0.7),
									ZIndex = 8,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									Text = "1",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
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
