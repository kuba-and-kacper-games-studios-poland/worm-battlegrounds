--[[
	Created By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		The free crate's dialog: a full-screen WidgetManager widget (it was FreeCrate's U_Dialog until 2026-11-17), so it
		opens with WidgetManager's blur and dim like every lobby window. The lobby's tile and the crates screen's badge
		(FreeCrate) open it; the Crates module draws it on WidgetManager_Opened as I.UserInterface.UI["FreeCrateDialog"]
	]]
	Name = "FreeCrateDialog",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			{
				Primitive = "Frame",
				Id = "U_Widget",
				Props = { LayoutOrder = 0, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "Frame",
						Props = {
							LayoutOrder = 0,
							Name = "Content",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
						},
						Children = {
							-- The dialog: the confirmation's dark panel, the crate turning in light, LIKE and JOIN as pictures, and CLAIM
							{
								Primitive = "Frame",
								Id = "U_Dialog",
								Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromScale(0.9, 0.86) } },
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.8, 0.68),
									ZIndex = 10,
								},
								Children = {
									{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.86 } },
									{ Primitive = "UIScale", Id = "S_Pop", Props = { Scale = 1 } },
									-- The panel: the screens' dark fill (25, 25, 35), a dark outer line and the grey line inside it
									{
										Primitive = "Frame",
										Props = { Name = "Bg_Bottom", BackgroundColor3 = Color3.fromRGB(25, 25, 35), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.05, 0) } },
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
									{
										Primitive = "TextLabel",
										Props = {
											Name = "TitleText",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.075),
											Size = UDim2.fromScale(0.62, 0.085),
											ZIndex = 2,
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											Text = "FREE WEAPONS",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											RichText = true,
											TextScaled = true,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
											{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.0714 } },
											{
												Primitive = "UIGradient",
												Props = {
													Color = ColorSequence.new({
														ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 246, 192)),
														ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 194, 26)),
														ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 20)),
													}),
													Rotation = 90,
												},
											},
										},
									},
									-- The stage: the crate turning on a lit green backdrop, light rays wheeling behind it, twinkles round it
									{
										Primitive = "Frame",
										Id = "S_Hero",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BorderSizePixel = 0,
											ClipsDescendants = true,
											Position = UDim2.fromScale(0.5, 0.375),
											Size = UDim2.fromScale(0.88, 0.43),
											ZIndex = 2,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.07, 0) } },
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
											{
												Primitive = "UIGradient",
												Props = {
													Color = ColorSequence.new({
														ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 40, 26)),
														ColorSequenceKeypoint.new(0.5, Color3.fromRGB(58, 132, 58)),
														ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 40, 26)),
													}),
													Rotation = 90,
												},
											},
											-- The crates screen's sunburst (its S_Rays picture) in the dialog's green; code turns it
											{
												Primitive = "ImageLabel",
												Id = "S_Rays",
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.55),
													Size = UDim2.fromScale(1.6, 1.6),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 2,
													Image = "rbxassetid://109967588890262",
													ImageColor3 = Color3.fromRGB(220, 255, 170),
													ImageTransparency = 0.55,
													ScaleType = Enum.ScaleType.Fit,
												},
											},
											-- The crate's own glow behind it
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Glow",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.55),
													Size = UDim2.fromScale(1.15, 1.15),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 3,
													Image = "rbxassetid://124537809204603",
													ImageColor3 = Color3.fromRGB(190, 255, 150),
													ImageTransparency = 0.35,
												},
											},
											-- The crate: its 3D model the Crates module stands and turns in a WorldModel here
											{
												Primitive = "ViewportFrame",
												Id = "S_CrateView",
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.52),
													Size = UDim2.fromScale(1, 1),
													ZIndex = 4,
													Ambient = Color3.fromRGB(200, 200, 210),
													LightColor = Color3.fromRGB(255, 240, 220),
													LightDirection = Vector3.new(-1, -1, -1),
												},
											},
											-- The twinkles' layer (gui particles)
											{
												Primitive = "Frame",
												Id = "S_Sparkles",
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(1, 1),
													ZIndex = 5,
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "CrateLabel",
													AnchorPoint = Vector2.new(0.5, 1),
													BackgroundColor3 = Color3.fromRGB(29, 90, 34),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.95),
													Size = UDim2.fromScale(0.4, 0.13),
													ZIndex = 6,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.3, 0) } },
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
													{
														Primitive = "TextLabel",
														Props = {
															Name = "CrateLabelText",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(0.86, 0.66),
															ZIndex = 7,
															FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
															Text = "WEAPON CRATE",
															TextColor3 = Color3.fromRGB(201, 255, 190),
															RichText = true,
															TextScaled = true,
														},
														Children = {
															{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
															{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.1 } },
														},
													},
												},
											},
										},
									},
									-- LIKE: a picture tile (only asked: no game can check it), ticked once pressed
									{
										Primitive = "ImageButton",
										Id = "S_Like",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											AutoButtonColor = false,
											BackgroundColor3 = Color3.fromRGB(40, 40, 52),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.285, 0.715),
											Size = UDim2.fromScale(0.41, 0.18),
											ZIndex = 2,
										},
										Attributes = {
											ClickSound_Name = "Button_Click",
											ClickSound_PitchMax = 1,
											ClickSound_PitchMin = 1,
											ClickSound_PlaybackSpeed = 1,
											ClickSound_SoundGroup = "UI",
											ClickSound_TimePosition = 0,
											ClickSound_Volume = 1,
											Utils_ClickScale = 0.94,
											Utils_HoverScale = 1.04,
											Utils_ScaleAnimation = "Bouncy",
										},
										Tags = { Utils_ButtonScale = {}, Utils_ButtonSound = {} },
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.18, 0) } },
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(70, 70, 86), Thickness = 2 } },
											{
												Primitive = "Frame",
												Props = {
													Name = "IconBox",
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundColor3 = Color3.fromRGB(64, 140, 230),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.06, 0.5),
													Size = UDim2.fromScale(0.72, 0.72),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 3,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.25, 0) } },
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
													{
														Primitive = "TextLabel",
														Id = "S_LikeIcon",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.5, 0.52),
															Size = UDim2.fromScale(0.72, 0.72),
															ZIndex = 4,
															FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
															Text = "👍",
															TextColor3 = Color3.fromRGB(255, 255, 255),
															RichText = true,
															TextScaled = true,
														},
														Children = {
															{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
															{ Primitive = "UIScale", Id = "S_LikePop", Props = { Scale = 1 } },
														},
													},
												},
											},
											{
												Primitive = "TextLabel",
												Props = {
													Name = "StepTitle",
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.47, 0.38),
													Size = UDim2.fromScale(0.49, 0.4),
													ZIndex = 3,
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													Text = "LIKE",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextXAlignment = Enum.TextXAlignment.Left,
													RichText = true,
													TextScaled = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
													{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.09 } },
												},
											},
											{
												Primitive = "TextLabel",
												Props = {
													Name = "StepText",
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.47, 0.7),
													Size = UDim2.fromScale(0.49, 0.24),
													ZIndex = 3,
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
													Text = "the game's page",
													TextColor3 = Color3.fromRGB(167, 167, 182),
													TextXAlignment = Enum.TextXAlignment.Left,
													RichText = true,
													TextScaled = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
												},
											},
											{
												Primitive = "Frame",
												Id = "S_LikeDone",
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(90, 208, 106),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.96, 0.08),
													Size = UDim2.fromScale(0.38, 0.38),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													Visible = false,
													ZIndex = 5,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
													{
														Primitive = "TextLabel",
														Props = {
															Name = "Check",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(0.66, 0.66),
															ZIndex = 6,
															FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
															Text = "✓",
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
									-- JOIN: the group's own picture on a green tile, ticked once the server sees the player in it
									{
										Primitive = "ImageButton",
										Id = "S_Join",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											AutoButtonColor = false,
											BackgroundColor3 = Color3.fromRGB(40, 40, 52),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.715, 0.715),
											Size = UDim2.fromScale(0.41, 0.18),
											ZIndex = 2,
										},
										Attributes = {
											ClickSound_Name = "Button_Click",
											ClickSound_PitchMax = 1,
											ClickSound_PitchMin = 1,
											ClickSound_PlaybackSpeed = 1,
											ClickSound_SoundGroup = "UI",
											ClickSound_TimePosition = 0,
											ClickSound_Volume = 1,
											Utils_ClickScale = 0.94,
											Utils_HoverScale = 1.04,
											Utils_ScaleAnimation = "Bouncy",
										},
										Tags = { Utils_ButtonScale = {}, Utils_ButtonSound = {} },
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.18, 0) } },
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(70, 70, 86), Thickness = 2 } },
											{
												Primitive = "Frame",
												Props = {
													Name = "IconBox",
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundColor3 = Color3.fromRGB(77, 199, 97),
													BorderSizePixel = 0,
													ClipsDescendants = true,
													Position = UDim2.fromScale(0.06, 0.5),
													Size = UDim2.fromScale(0.72, 0.72),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 3,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.25, 0) } },
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
													{
														Primitive = "ImageLabel",
														Id = "S_GroupIcon",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(0.86, 0.86),
															ZIndex = 4,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.22, 0) } },
														},
													},
												},
											},
											{
												Primitive = "TextLabel",
												Id = "S_JoinTitle",
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.47, 0.38),
													Size = UDim2.fromScale(0.49, 0.4),
													ZIndex = 3,
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													Text = "JOIN",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextXAlignment = Enum.TextXAlignment.Left,
													RichText = true,
													TextScaled = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
													{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.09 } },
												},
											},
											{
												Primitive = "TextLabel",
												Props = {
													Name = "StepText",
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.47, 0.7),
													Size = UDim2.fromScale(0.49, 0.24),
													ZIndex = 3,
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
													Text = "The Snail Studio",
													TextColor3 = Color3.fromRGB(167, 167, 182),
													TextXAlignment = Enum.TextXAlignment.Left,
													RichText = true,
													TextScaled = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
												},
											},
											{
												Primitive = "Frame",
												Id = "S_JoinDone",
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(90, 208, 106),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.96, 0.08),
													Size = UDim2.fromScale(0.38, 0.38),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													Visible = false,
													ZIndex = 5,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
													{
														Primitive = "TextLabel",
														Props = {
															Name = "Check",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(0.66, 0.66),
															ZIndex = 6,
															FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
															Text = "✓",
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
									-- CLAIM: the crate shop's button, grey and locked until the player is in the group, then gold and shining
									{
										Primitive = "ImageButton",
										Id = "S_ClaimButton",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											AutoButtonColor = false,
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.895),
											Size = UDim2.fromScale(0.64, 0.13),
											ZIndex = 2,
										},
										Attributes = {
											ClickSound_Name = "Button_Click",
											ClickSound_PitchMax = 1,
											ClickSound_PitchMin = 1,
											ClickSound_PlaybackSpeed = 1,
											ClickSound_SoundGroup = "UI",
											ClickSound_TimePosition = 0,
											ClickSound_Volume = 1,
											Look_MainColor = Color3.fromRGB(255, 196, 40),
											Look_StrokeColor = Color3.fromRGB(230, 150, 20),
											Look_LockedMainColor = Color3.fromRGB(110, 110, 120),
											Look_LockedStrokeColor = Color3.fromRGB(90, 90, 100),
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
											{ Primitive = "UIScale", Id = "S_ClaimPulse", Props = { Scale = 1 } },
											{
												Primitive = "Frame",
												Props = { Name = "Background", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
												Children = {
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Main",
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.0015, 0.0556),
															Size = UDim2.fromScale(0.997, 0.8889),
															ZIndex = 2,
															Image = "rbxassetid://96244980257546",
															ImageColor3 = Color3.fromRGB(110, 110, 120),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													-- The light sweeping across CLAIM once it's lit
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Shine",
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.0015, 0.0556),
															Size = UDim2.fromScale(0.997, 0.8889),
															ZIndex = 3,
															Image = "rbxassetid://96244980257546",
															ImageColor3 = Color3.fromRGB(255, 255, 255),
															ScaleType = Enum.ScaleType.Fit,
														},
														Children = {
															{
																Primitive = "UIGradient",
																Id = "S_ClaimShine",
																Props = {
																	Offset = Vector2.new(-1, 0),
																	Rotation = 20,
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.44, 1),
																		NumberSequenceKeypoint.new(0.5, 0.3),
																		NumberSequenceKeypoint.new(0.56, 1),
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
															Size = UDim2.fromScale(1.0033, 1),
															ZIndex = 4,
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
															Position = UDim2.fromScale(0.0066, 0.0222),
															Size = UDim2.fromScale(0.9867, 0.9556),
															ZIndex = 5,
															Image = "rbxassetid://98742725293542",
															ImageColor3 = Color3.fromRGB(90, 90, 100),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
												},
											},
											{
												Primitive = "TextLabel",
												Id = "S_ClaimText",
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(0.72, 0.5),
													ZIndex = 6,
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													Text = "🔒 CLAIM",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													RichText = true,
													TextScaled = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
													{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.09 } },
												},
											},
										},
									},
									-- Close: the red X inside the panel's corner, clear of its edge; B presses it
									{
										Primitive = "ImageButton",
										Id = "S_CloseButton",
										Props = {
											AnchorPoint = Vector2.new(1, 0),
											AutoButtonColor = false,
											BackgroundColor3 = Color3.fromRGB(230, 64, 64),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.955, 0.03),
											Size = UDim2.fromScale(0.095, 0.095),
											SizeConstraint = Enum.SizeConstraint.RelativeXX,
											ZIndex = 6,
										},
										Attributes = {
											ClickSound_Name = "Button_Click-CloseWidget",
											ClickSound_PitchMax = 1,
											ClickSound_PitchMin = 1,
											ClickSound_PlaybackSpeed = 1,
											ClickSound_SoundGroup = "UI",
											ClickSound_TimePosition = 0,
											ClickSound_Volume = 1,
											Utils_ClickScale = 0.9,
											Utils_HoverScale = 1.08,
											Utils_ScaleAnimation = "Bouncy",
										},
										Tags = {
											Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" },
											Utils_ButtonScale = {},
											Utils_ButtonSound = {},
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.3, 0) } },
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
											{
												Primitive = "TextLabel",
												Props = {
													Name = "ButtonText",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(0.6, 0.6),
													ZIndex = 7,
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													Text = "X",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													RichText = true,
													TextScaled = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
													{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.1 } },
												},
											},
										},
									},
								},
							},
						},
					},
				},
			},
			{
				Primitive = "ImageButton",
				Props = { LayoutOrder = 0, Name = "MouseLockFix", BackgroundTransparency = 1, Modal = true },
			},
		},
	},
}

return _gui
