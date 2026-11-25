--[[
	Created By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The tutorial match's end in place of the results, as I.UserInterface.UI["TutorialWin"]; the Tutorial module opens it through WidgetManager
	Name = "TutorialWin",
	-- Hidden until WidgetManager opens it, over the game's huds
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- The widget WidgetManager tweens in and out (U_Widget), and the MouseLockFix that frees the mouse while it shows
	Root = {
		Primitive = "Folder",
		Children = {
			-- The card: the confirmation dialog's dark panel with its grey outline, a gold title and one button (the owner, 2026-11-24)
			{
				Primitive = "Frame",
				Id = "U_Widget",
				Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromScale(0.7, 0.34) } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.5, 0.26),
				},
				Children = {
					{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 2.2 } },
					-- The panel: the screens' dark fill (25, 25, 35), a dark outer line and the grey line inside it
					{
						Primitive = "Frame",
						Props = {
							Name = "Bg_Bottom",
							BackgroundColor3 = Color3.fromRGB(25, 25, 35),
							BorderSizePixel = 0,
							Size = UDim2.fromScale(1, 1),
							ZIndex = -999,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.08, 0) } },
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
							{
								Primitive = "UIStroke",
								Tags = { Utils_UIStroke = {} },
								Props = {
									Name = "UIStroke_Inner",
									BorderStrokePosition = Enum.BorderStrokePosition.Inner,
									Color = Color3.fromRGB(130, 130, 130),
									Thickness = 3,
								},
							},
						},
					},
					-- The title: "You won!" (or "Nice try!"), in the turn callout's gold with the title outline
					{
						Primitive = "Frame",
						Props = { Name = "Bg_Top", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 999 },
						Children = {
							{
								Primitive = "TextLabel",
								Id = "S_Title",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.34),
									Size = UDim2.fromScale(0.8, 0.3),
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									RichText = true,
									Text = "You won!",
									TextColor3 = Color3.fromRGB(255, 205, 60),
									TextScaled = true,
									TextSize = 72,
									TextWrapped = true,
								},
								Tags = { TextCase_Upper = {} },
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.06 } },
								},
							},
						},
					},
					-- CONTINUE: the confirmation's button in FIRE's yellow; A presses it
					{
						Primitive = "Frame",
						Props = { Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
						Children = {
							{
								Primitive = "ImageButton",
								Id = "S_Continue",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.72),
									Size = UDim2.fromScale(0.46, 0.27),
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
									Utils_HoverScale = 1.04,
									Utils_ScaleAnimation = "Bouncy",
								},
								Tags = {
									Utils_ButtonKey = { Utils_GamepadKey = "ButtonA" },
									Utils_ButtonScale = {},
									Utils_ButtonSound = {},
								},
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
													ImageColor3 = Color3.fromRGB(255, 196, 46),
													ScaleType = Enum.ScaleType.Fit,
												},
												Attributes = { _ImageName = "1020_5__Gacha__Main_gray" },
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
													ImageColor3 = Color3.fromRGB(240, 150, 30),
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
											Size = UDim2.fromScale(0.7, 0.5),
											ZIndex = 4,
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											RichText = true,
											Text = "CONTINUE",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											TextScaled = true,
											TextSize = 32,
											TextWrapped = true,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
											{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
										},
									},
									-- A (Cross) on the top right corner, on Console: A presses the button
									{
										Primitive = "ImageLabel",
										Id = "S_ContinueHint",
										Visible = false,
										Tags = { Console_Hint = {} },
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											Image = "rbxassetid://96386000008631",
											Position = UDim2.fromScale(0.96, 0.12),
											Size = UDim2.fromScale(1, 0.6),
											ZIndex = 5,
										},
										Children = {
											{ Primitive = "UIAspectRatioConstraint" },
										},
									},
								},
							},
						},
					},
				},
			},
			-- A modal button that frees the mouse from shift lock while the widget is enabled
			{ Primitive = "ImageButton", Props = { Name = "MouseLockFix", AutoButtonColor = false, BackgroundTransparency = 1, ImageTransparency = 1, Interactable = false, Modal = true, Selectable = false } },
		},
	},
}

return _gui
