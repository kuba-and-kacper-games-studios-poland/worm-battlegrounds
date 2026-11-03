--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: ume's WidgetManager finds it as I.UserInterface.UI["WidgetManager_Confirmation"]
	Name = "WidgetManager_Confirmation",
	-- Hidden until WidgetManager opens it, over the game's huds
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- The widget WidgetManager tweens in and out (U_Widget), and the MouseLockFix that frees the mouse while it shows.
	-- Plain instances that hold every value themselves, so no theme changes them
	Root = {
		Primitive = "Folder",
		Children = {
			-- The card: a dark panel under a blue title banner, the message, then the two answers
			{
				Primitive = "Frame",
				Id = "U_Widget",
				Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromScale(0.88, 0.44) } },
				Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.8, 0.4) },
				Children = {
					{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.75 } },
					-- The panel: dark gradient, black outline and a white highlight along its top edge
					{
						Primitive = "Frame",
						Props = { Name = "Bg_Bottom", AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 1), Size = UDim2.new(1, 0, 1, -32), ZIndex = -999 },
						Children = {
							{
								Primitive = "Frame",
								Props = {
									Name = "Background",
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(1, 1),
								},
								Children = {
									-- Round corners, 8 px at 1080p; the banner covers the top two
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.02, 0) } },
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.35, 0.65) } },
									{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
									{
										Primitive = "UIStroke",
										Tags = { Utils_UIStroke = {} },
										Props = {
											Name = "UIStroke_Highlight",
											BorderStrokePosition = Enum.BorderStrokePosition.Inner,
											Color = Color3.fromRGB(255, 255, 255),
											Thickness = 3,
											Transparency = 0.5,
										},
										Children = {
											{
												Primitive = "UIGradient",
												Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.9003, 1), NumberSequenceKeypoint.new(1, 1) }) },
											},
										},
									},
									{
										Primitive = "CanvasGroup",
										Props = { Name = "EffectGroup", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ZIndex = 3 },
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.02, 0) } },
											{
												Primitive = "ImageLabel",
												Visible = false,
												Props = {
													Name = "Stars",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Image = "rbxassetid://15819389370",
													ImageTransparency = 0.95,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 10,
													ScaleType = Enum.ScaleType.Tile,
													Size = UDim2.fromScale(1.5, 1.5),
													TileSize = UDim2.fromOffset(512, 512),
												},
												Children = {
													{ Primitive = "UIGradient", Props = { Rotation = -90, Transparency = NumberSequence.new(0, 1) } },
												},
											},
										},
									},
								},
							},
						},
					},
					-- The banner across the top: an icon, the title and the close button over a glossy blue bar
					{
						Primitive = "Frame",
						Props = { Name = "Bg_Top", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(1, 24, 0, 68), ZIndex = 999 },
						Children = {
							{
								Primitive = "Frame",
								Props = { Name = "Banner", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -6), ZIndex = 2 },
								Children = {
									{
										Primitive = "Frame",
										Props = {
											Name = "IconContainer",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											LayoutOrder = 1,
											Position = UDim2.fromOffset(16, 16),
											Size = UDim2.fromScale(1.35, 1.35),
										},
										Children = {
											{ Primitive = "UIAspectRatioConstraint" },
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "WidgetIcon",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Image = "rbxassetid://108331872296638",
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(1, 1),
													SliceCenter = Rect.new(66, 0, 473, 126),
												},
												Children = {
													{ Primitive = "UIAspectRatioConstraint" },
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "NameContainer",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											LayoutOrder = 2,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromScale(0.7, 1),
										},
										Children = {
											{
												Primitive = "TextLabel",
												Props = {
													Name = "WidgetNameText",
													AnchorPoint = Vector2.new(0.5, 0.515),
													AutomaticSize = Enum.AutomaticSize.X,
													BackgroundTransparency = 1,
													FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
													LayoutOrder = 2,
													Position = UDim2.fromScale(0.5, 0.5),
													RichText = true,
													Size = UDim2.fromScale(0, 0.7),
													Text = "You sure?",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextScaled = true,
													TextSize = 14,
													TextWrapped = true,
												},
												Children = {
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
												},
											},
										},
									},
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
								Children = {
									{
										Primitive = "UIListLayout",
										Props = {
											FillDirection = Enum.FillDirection.Horizontal,
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											HorizontalFlex = Enum.UIFlexAlignment.Fill,
											Padding = UDim.new(0, 4),
											SortOrder = Enum.SortOrder.LayoutOrder,
											VerticalAlignment = Enum.VerticalAlignment.Center,
										},
									},
									{
										Primitive = "Frame",
										Props = { Name = "Background", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.5, 1) },
										Children = {
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
											{
												Primitive = "CanvasGroup",
												Props = {
													Name = "GlossGroup",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													GroupTransparency = 0.5,
													Interactable = false,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(1, 1),
													ZIndex = 3,
												},
												Children = {
													{
														Primitive = "UIGradient",
														Props = {
															Rotation = 90,
															Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.9, 1), NumberSequenceKeypoint.new(1, 1) }),
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0, 0.5),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.6383 } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.new(0, 57, 0.5, 0),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.5351 } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.new(0, 185, 0.5, 0),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.2796 } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.new(0, 256, 0.5, 0),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.1275 } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.new(0, 352, 0.5, 0),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.3267 } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.new(0, 506, 0.5, 0),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.3878 } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.new(0, 577, 0.5, 0),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.6025 } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.new(0, 710, 0.5, 0),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.1506 } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "GlossFrame",
															AnchorPoint = Vector2.new(0, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BackgroundTransparency = 0.5,
															BorderSizePixel = 0,
															Position = UDim2.new(0, 783, 0.5, 0),
															Rotation = 5,
															Size = UDim2.fromScale(1.15, 1.15),
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.8312 } },
														},
													},
													{
														Primitive = "ImageLabel",
														Visible = false,
														Props = {
															Name = "SwirlPattern",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															Image = "rbxassetid://91386541771837",
															ImageTransparency = 0.5,
															Position = UDim2.fromScale(0.5, 0.5),
															Rotation = 180,
															Size = UDim2.fromScale(1, 16),
															ZIndex = 2,
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = { Name = "Background_Front", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -6), ZIndex = 2 },
												Children = {
													{
														Primitive = "UIStroke",
														Tags = { Utils_UIStroke = {} },
														Props = {
															Name = "UIStroke_Highlight",
															BorderStrokePosition = Enum.BorderStrokePosition.Inner,
															Color = Color3.fromRGB(255, 255, 255),
															LineJoinMode = Enum.LineJoinMode.Miter,
															Thickness = 3,
															Transparency = 0.7,
														},
													},
													{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 55, 255), Color3.fromRGB(0, 200, 255)), Rotation = -90 } },
												},
											},
											{
												Primitive = "Frame",
												Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
												Children = {
													{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 55, 255), Color3.fromRGB(0, 200, 255)), Rotation = -90 } },
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Props = { Name = "CloseButtonContainer", AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0), Size = UDim2.fromScale(1, 1), ZIndex = 3 },
										Children = {
											{ Primitive = "UIAspectRatioConstraint" },
											-- Closes the widget through Interact (WidgetManager.CloseCurrent); B (Circle) presses it
											{
												Primitive = "ImageButton",
												Tags = {
													Interact_Button = { Interact_Function = "CloseCurrent", Interact_ModuleName = "WidgetManager" },
													Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" },
													Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
													Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
												},
												Props = {
													Name = "CloseButton",
													AnchorPoint = Vector2.new(0.5, 0.5),
													AutoButtonColor = false,
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(1, 1),
												},
												Children = {
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
													{
														Primitive = "Frame",
														Props = { Name = "Container", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -6), ZIndex = 3 },
														Children = {
															{
																Primitive = "TextLabel",
																Tags = { Utils_HideOnPlatform = { Utils_ConsoleVisibility = false } },
																Props = {
																	Name = "ButtonText",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Heavy),
																	LayoutOrder = 2,
																	Position = UDim2.fromScale(0.5, 0.5),
																	RichText = true,
																	Size = UDim2.fromScale(0.8, 0.8),
																	Text = "X",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextScaled = true,
																	TextWrapped = true,
																},
																Children = {
																	{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
																},
															},
															-- On Console the X hides and B (Circle) shows in its place: B closes the widget. Two layers so it reads like the X: a white
															-- border (gamepad-prompts' WhiteBorder) tinted black by its UIGradient, as the X's UIStroke, and the white B in front
															{
																Primitive = "ImageLabel",
																Id = "S_CloseHint",
																Visible = false,
																Tags = { Console_Hint = {} },
																Props = {
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	Image = "rbxassetid://91247872695106",
																	Position = UDim2.fromScale(0.5, 0.5),
																	Size = UDim2.fromScale(1.1, 1.1),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint" },
																	{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)) } },
																	-- The B itself, white (gamepad-prompts' White)
																	{
																		Primitive = "ImageLabel",
																		Props = { Name = "Front", BackgroundTransparency = 1, Image = "rbxassetid://92252921636068", Size = UDim2.fromScale(1, 1) },
																	},
																},
															},
														},
													},
													{
														Primitive = "Frame",
														Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
														Children = {
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(226, 0, 0), Color3.fromRGB(255, 100, 48)), Rotation = -90 } },
														},
													},
													{
														Primitive = "Frame",
														Props = { Name = "Background_Front", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -6), ZIndex = 2 },
														Children = {
															{
																Primitive = "UIStroke",
																Tags = { Utils_UIStroke = {} },
																Props = {
																	Name = "UIStroke_Highlight",
																	BorderStrokePosition = Enum.BorderStrokePosition.Inner,
																	Color = Color3.fromRGB(255, 255, 255),
																	LineJoinMode = Enum.LineJoinMode.Miter,
																	Thickness = 3,
																	Transparency = 0.7,
																},
															},
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(226, 0, 0), Color3.fromRGB(255, 100, 48)), Rotation = -90 } },
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
						Primitive = "Frame",
						Props = { Name = "Content", AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(1, 0.865) },
						Children = {
							{
								Primitive = "Frame",
								Props = { Name = "Top", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(1, 0.775), ZIndex = 2 },
								Children = {
									-- The question; ConfirmationWidget writes it
									{
										Primitive = "TextLabel",
										Id = "S_MessageText",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
											Position = UDim2.fromScale(0.5, 0.525),
											RichText = true,
											Size = UDim2.fromScale(0.85, 0.8),
											Text = "Message",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											TextScaled = true,
											TextWrapped = true,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 48 } },
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3.5 } },
										},
									},
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Bottom", AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.925), Size = UDim2.fromScale(1, 0.165) },
								Children = {
									{
										Primitive = "UIListLayout",
										Props = {
											FillDirection = Enum.FillDirection.Horizontal,
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											Padding = UDim.new(0, 24),
											SortOrder = Enum.SortOrder.LayoutOrder,
											VerticalAlignment = Enum.VerticalAlignment.Center,
										},
									},
									{
										Primitive = "Frame",
										Props = { Name = "AcceptContainer", BackgroundTransparency = 1, Size = UDim2.fromScale(0.3, 1) },
										Children = {
											-- Runs the confirmation's onAccept; A (Cross) presses it
											{
												Primitive = "ImageButton",
												Id = "S_AcceptButton",
												Tags = {
													Utils_ButtonKey = { Utils_GamepadKey = "ButtonA" },
													Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
													Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
												},
												Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
												Children = {
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
													{
														Primitive = "Frame",
														Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
														Children = {
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
														},
													},
													{
														Primitive = "Frame",
														Props = { Name = "Background_Front", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -6), ZIndex = 2 },
														Children = {
															{
																Primitive = "UIStroke",
																Tags = { Utils_UIStroke = {} },
																Props = {
																	Name = "UIStroke_Highlight",
																	BorderStrokePosition = Enum.BorderStrokePosition.Inner,
																	Color = Color3.fromRGB(255, 255, 255),
																	LineJoinMode = Enum.LineJoinMode.Miter,
																	Thickness = 3,
																	Transparency = 0.7,
																},
															},
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
														},
													},
													{
														Primitive = "Frame",
														Props = { Name = "Container", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -6), ZIndex = 4 },
														Children = {
															{
																Primitive = "TextLabel",
																Props = {
																	Name = "ButtonText",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
																	LayoutOrder = 2,
																	Position = UDim2.fromScale(0.5, 0.5),
																	RichText = true,
																	Size = UDim2.fromScale(0.9, 0.6),
																	Text = "Accept",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextScaled = true,
																	TextWrapped = true,
																	ZIndex = 3,
																},
																Children = {
																	{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 2.5 } },
																},
															},
														},
													},
													{
														Primitive = "CanvasGroup",
														Props = {
															Name = "GlossGroup",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															GroupTransparency = 0.7,
															Interactable = false,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 3,
														},
														Children = {
															{
																Primitive = "UIGradient",
																Props = {
																	Rotation = 90,
																	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.9, 1), NumberSequenceKeypoint.new(1, 1) }),
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.1826 } },
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0.0994, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.56 } },
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0.3244, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.7403 } },
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0.607, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.8941 } },
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0.9419, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.22 } },
																},
															},
														},
													},
													-- A (Cross) on the top right corner, on Console: A presses the button
													{
														Primitive = "ImageLabel",
														Id = "S_AcceptHint",
														Visible = false,
														Tags = { Console_Hint = {} },
														Props = {
															BackgroundTransparency = 1,
															Image = "rbxassetid://96386000008631",
															AnchorPoint = Vector2.new(0.5, 0.5),
															Position = UDim2.new(1, -6, 0, 6),
															Size = UDim2.fromScale(1, 0.7),
															ZIndex = 6,
														},
														Children = {
															{ Primitive = "UIAspectRatioConstraint" },
														},
													},
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Props = { Name = "DeclineContainer", BackgroundTransparency = 1, Size = UDim2.fromScale(0.3, 1) },
										Children = {
											-- Runs its onDecline; X (Square) presses it
											{
												Primitive = "ImageButton",
												Id = "S_DeclineButton",
												Tags = {
													Utils_ButtonKey = { Utils_GamepadKey = "ButtonX" },
													Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
													Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
												},
												Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
												Children = {
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
													{
														Primitive = "Frame",
														Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
														Children = {
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(186, 0, 0), Color3.fromRGB(255, 62, 62)), Rotation = -90 } },
														},
													},
													{
														Primitive = "Frame",
														Props = { Name = "Background_Front", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -6), ZIndex = 2 },
														Children = {
															{
																Primitive = "UIStroke",
																Tags = { Utils_UIStroke = {} },
																Props = {
																	Name = "UIStroke_Highlight",
																	BorderStrokePosition = Enum.BorderStrokePosition.Inner,
																	Color = Color3.fromRGB(255, 255, 255),
																	LineJoinMode = Enum.LineJoinMode.Miter,
																	Thickness = 3,
																	Transparency = 0.7,
																},
															},
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(186, 0, 0), Color3.fromRGB(255, 62, 62)), Rotation = -90 } },
														},
													},
													{
														Primitive = "Frame",
														Props = { Name = "Container", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -6), ZIndex = 4 },
														Children = {
															{
																Primitive = "TextLabel",
																Props = {
																	Name = "ButtonText",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
																	LayoutOrder = 2,
																	Position = UDim2.fromScale(0.5, 0.5),
																	RichText = true,
																	Size = UDim2.fromScale(0.9, 0.6),
																	Text = "Decline",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextScaled = true,
																	TextWrapped = true,
																	ZIndex = 3,
																},
																Children = {
																	{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 2.5 } },
																},
															},
														},
													},
													{
														Primitive = "CanvasGroup",
														Props = {
															Name = "GlossGroup",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															GroupTransparency = 0.7,
															Interactable = false,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 3,
														},
														Children = {
															{
																Primitive = "UIGradient",
																Props = {
																	Rotation = 90,
																	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.9, 1), NumberSequenceKeypoint.new(1, 1) }),
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.1826 } },
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0.0994, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.56 } },
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0.3244, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.7403 } },
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0.607, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.8941 } },
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "GlossFrame",
																	AnchorPoint = Vector2.new(0, 0.5),
																	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
																	BackgroundTransparency = 0.5,
																	BorderSizePixel = 0,
																	Position = UDim2.fromScale(0.9419, 0.5),
																	Rotation = 5,
																	Size = UDim2.fromScale(1.15, 1.15),
																},
																Children = {
																	{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.22 } },
																},
															},
														},
													},
													-- X (Square) on the top right corner, on Console: X presses the button
													{
														Primitive = "ImageLabel",
														Id = "S_DeclineHint",
														Visible = false,
														Tags = { Console_Hint = {} },
														Props = {
															BackgroundTransparency = 1,
															Image = "rbxassetid://122507607734627",
															AnchorPoint = Vector2.new(0.5, 0.5),
															Position = UDim2.new(1, -6, 0, 6),
															Size = UDim2.fromScale(1, 0.7),
															ZIndex = 6,
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
