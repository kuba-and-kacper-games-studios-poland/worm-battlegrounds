--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: ume's Settings module finds it as I.UserInterface.UI["Settings"]
	Name = "Settings",
	-- Hidden until WidgetManager opens it
	Screen = { DisplayOrder = 5, Enabled = false, ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets },
	-- Mobile previews the touch-screen scale (Preview)
	Devices = { "Desktop", "Mobile" },

	--[[ Tree ]]

	-- The widget WidgetManager tweens in and out (U_Widget), and the MouseLockFix that frees the mouse while it shows.
	-- WidgetManager_Message's panel, banner and buttons, sized for a 1080 px tall screen: a driver sets S_ScreenScale
	Root = {
		Primitive = "Folder",
		Children = {
			-- The window: a dark panel under a blue title banner, then the settings in their groups
			{
				Primitive = "Frame",
				Id = "U_Widget",
				Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(720, 660) },
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
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
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.35, 0.65) } },
									{ Primitive = "UIStroke", Props = { Thickness = 3 } },
									{
										Primitive = "UIStroke",
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
								},
							},
						},
					},
					-- The banner across the top: the gear, the title and the close button over a glossy blue bar
					{
						Primitive = "Frame",
						Props = { Name = "Bg_Top", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(1, 24, 0, 68), ZIndex = 999 },
						Children = {
							{
								Primitive = "Frame",
								Props = { Name = "Banner", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(1, 0, 1, -6), ZIndex = 2 },
								Children = {
									{
										Primitive = "Frame",
										Props = {
											Name = "IconContainer",
											AnchorPoint = Vector2.new(0, 0.5),
											BackgroundTransparency = 1,
											Position = UDim2.new(0, 14, 0.5, 0),
											Size = UDim2.fromScale(0.75, 0.75),
										},
										Children = {
											{ Primitive = "UIAspectRatioConstraint" },
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "WidgetIcon",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Image = "rbxassetid://123765846716976",
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(1, 1),
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
													Position = UDim2.fromScale(0.5, 0.5),
													RichText = true,
													Size = UDim2.fromScale(0, 0.7),
													Text = "Settings",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextScaled = true,
													TextSize = 14,
													TextWrapped = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
													{ Primitive = "UIStroke", Props = { Thickness = 3 } },
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
									-- The blue bar
									{
										Primitive = "Frame",
										Props = { Name = "Background", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.5, 1) },
										Children = {
											{ Primitive = "UIStroke", Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
											{
												Primitive = "Frame",
												Props = { Name = "Background_Front", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -6), ZIndex = 2 },
												Children = {
													{
														Primitive = "UIStroke",
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
													{ Primitive = "UIStroke", Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
																	Position = UDim2.fromScale(0.5, 0.5),
																	RichText = true,
																	Size = UDim2.fromScale(0.8, 0.8),
																	Text = "X",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextScaled = true,
																	TextWrapped = true,
																},
																Children = {
																	{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
																	{ Primitive = "UIStroke", Props = { Thickness = 3 } },
																},
															},
															-- On Console the X hides and B (Circle) shows in its place, as on WidgetManager_Message
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
						Props = { Name = "Content", AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 1), Size = UDim2.new(1, 0, 1, -68) },
						Children = {
							-- The settings in their groups (PREFAB | Header, PREFAB | Setting, PREFAB | Stepper), 652 px wide and centred, so
							-- the scroll bar runs in the margin beside them
							{
								Primitive = "ScrollingFrame",
								Id = "U_List",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									AutomaticCanvasSize = Enum.AutomaticSize.Y,
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									BottomImage = "rbxassetid://136098030643767",
									CanvasSize = UDim2.fromScale(0, 0),
									MidImage = "rbxassetid://136098030643767",
									Position = UDim2.fromScale(0.5, 0.5),
									ScrollBarImageTransparency = 0.4,
									ScrollBarThickness = 6,
									ScrollingDirection = Enum.ScrollingDirection.Y,
									Size = UDim2.new(1, -16, 1, -12),
									TopImage = "rbxassetid://136098030643767",
									VerticalScrollBarInset = Enum.ScrollBarInset.None,
								},
								Children = {
									{
										Primitive = "UIListLayout",
										Props = { FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder },
									},
									{ Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0, 16), PaddingTop = UDim.new(0, 8) } },
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

	--[[ Templates ]]

	Templates = {
		-- A group's name over its settings, in the group's gradient (a driver colours it), at the bottom of its strip so
		-- it sits with its rows
		["PREFAB | Header"] = {
			Primitive = "Frame",
			Parent = "U_List",
			Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Size = UDim2.fromOffset(652, 44) },
			Children = {
				{
					Primitive = "TextLabel",
					Id = "S_Text",
					Props = {
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
						Position = UDim2.new(0, 4, 1, 0),
						RichText = true,
						Size = UDim2.new(1, -8, 0, 34),
						Text = "Sound",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 30,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 30 } },
						{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(230, 205, 255), Color3.fromRGB(150, 110, 255)), Rotation = 90 } },
						{ Primitive = "UIStroke", Props = { Thickness = 3 } },
					},
				},
			},
		},
		-- One switch: its name, what it does (when that isn't plain from the name), and an On/Off button (a driver colours
		-- the row in its group's colour, and the button green with On or red with Off)
		["PREFAB | Setting"] = {
			Primitive = "Frame",
			Parent = "U_List",
			Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.3, BorderSizePixel = 0, Size = UDim2.fromOffset(652, 90) },
			Children = {
				{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(42, 42, 42), Color3.fromRGB(13, 13, 13)), Rotation = 90, Transparency = NumberSequence.new(0.4, 0.44) } },
				{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(150, 110, 255), LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3, Transparency = 0.5 } },
				-- The group's colour fading down the row
				{
					Primitive = "Frame",
					Props = {
						Name = "Tint",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(150, 110, 255),
						BackgroundTransparency = 0.78,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = { { Primitive = "UIGradient", Props = { Rotation = 90, Transparency = NumberSequence.new(0.2, 0.9) } } },
				},
				{
					Primitive = "TextLabel",
					Id = "S_Name",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
						Position = UDim2.new(0.5, -58, 0.5, -16),
						RichText = true,
						Size = UDim2.fromOffset(500, 34),
						Text = "Show tips",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 28,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = {
						{ Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0, 2), PaddingTop = UDim.new(0, 2) } },
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 28 } },
						{ Primitive = "UIStroke", Props = { Thickness = 2.5 } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Detail",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
						Position = UDim2.new(0.5, -58, 0.5, 19),
						RichText = true,
						Size = UDim2.fromOffset(500, 30),
						Text = "Hints while you play",
						TextColor3 = Color3.fromRGB(172, 180, 190),
						TextScaled = true,
						TextSize = 24,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0, 2), PaddingTop = UDim.new(0, 2) } }, { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 24 } } },
				},
				-- Turns it on and off: WidgetManager_Message's OK button, green with On or red with Off
				{
					Primitive = "Frame",
					Props = { Name = "SwitchContainer", AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -18, 0.5, 0), Size = UDim2.fromOffset(124, 58) },
					Children = {
						{
							Primitive = "ImageButton",
							Id = "S_Switch",
							Tags = {
								Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
								Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
							},
							Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
							Children = {
								{ Primitive = "UIStroke", Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
												Position = UDim2.fromScale(0.5, 0.5),
												RichText = true,
												Size = UDim2.new(0.9, 0, 0, 28),
												Text = "On",
												TextColor3 = Color3.fromRGB(255, 255, 255),
												TextScaled = true,
												TextSize = 28,
												ZIndex = 3,
											},
											Children = {
												-- Grows with the button's press and hover scale (gui/format.md → Text)
												{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
												{ Primitive = "UIStroke", Props = { Thickness = 2.5 } },
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
									Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
									Children = {
										{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
									},
								},
							},
						},
					},
				},
			},
		},
		-- A volume: its name, what it does (when that isn't plain from the name), and the value in a dark box between a
		-- left and a right button (a driver writes the value, and greys out the button at the end it has reached)
		["PREFAB | Stepper"] = {
			Primitive = "Frame",
			Parent = "U_List",
			Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.3, BorderSizePixel = 0, Size = UDim2.fromOffset(652, 90) },
			Children = {
				{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(42, 42, 42), Color3.fromRGB(13, 13, 13)), Rotation = 90, Transparency = NumberSequence.new(0.4, 0.44) } },
				{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(150, 110, 255), LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3, Transparency = 0.5 } },
				-- The group's colour fading down the row
				{
					Primitive = "Frame",
					Props = {
						Name = "Tint",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(150, 110, 255),
						BackgroundTransparency = 0.78,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = { { Primitive = "UIGradient", Props = { Rotation = 90, Transparency = NumberSequence.new(0.2, 0.9) } } },
				},
				{
					Primitive = "TextLabel",
					Id = "S_Name",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
						Position = UDim2.new(0.5, -128, 0.5, -16),
						RichText = true,
						Size = UDim2.fromOffset(360, 34),
						Text = "Music",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 28,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = {
						{ Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0, 2), PaddingTop = UDim.new(0, 2) } },
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 28 } },
						{ Primitive = "UIStroke", Props = { Thickness = 2.5 } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Detail",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
						Position = UDim2.new(0.5, -128, 0.5, 19),
						RichText = true,
						Size = UDim2.fromOffset(360, 30),
						Text = "",
						TextColor3 = Color3.fromRGB(172, 180, 190),
						TextScaled = true,
						TextSize = 24,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0, 2), PaddingTop = UDim.new(0, 2) } }, { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 24 } } },
				},
				-- The value and its two buttons, at the row's right end
				{
					Primitive = "Frame",
					Props = { Name = "Stepper", AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -18, 0.5, 0), Size = UDim2.fromOffset(244, 56) },
					Children = {
						{
							Primitive = "UIListLayout",
							Props = {
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								Padding = UDim.new(0, 8),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							},
						},
						-- Steps the value down
						{
							Primitive = "Frame",
							Props = { Name = "LeftContainer", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromOffset(56, 56) },
							Children = {
								{
									Primitive = "ImageButton",
									Id = "S_Left",
									Tags = {
										Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
										Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
									},
									Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
									Children = {
										{ Primitive = "UIStroke", Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
														FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Heavy),
														Position = UDim2.fromScale(0.5, 0.5),
														RichText = true,
														Size = UDim2.new(0.8, 0, 0, 32),
														Text = "&lt;",
														TextColor3 = Color3.fromRGB(255, 255, 255),
														TextScaled = true,
														TextSize = 32,
														ZIndex = 3,
													},
													Children = {
														{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
														{ Primitive = "UIStroke", Props = { Thickness = 2.5 } },
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
													Props = {
														Name = "UIStroke_Highlight",
														BorderStrokePosition = Enum.BorderStrokePosition.Inner,
														Color = Color3.fromRGB(255, 255, 255),
														LineJoinMode = Enum.LineJoinMode.Miter,
														Thickness = 3,
														Transparency = 0.7,
													},
												},
												{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 195, 255), Color3.fromRGB(0, 251, 255)), Rotation = -90 } },
											},
										},
										{
											Primitive = "Frame",
											Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
											Children = {
												{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 195, 255), Color3.fromRGB(0, 251, 255)), Rotation = -90 } },
											},
										},
									},
								},
							},
						},
						-- The value, in a dark box outlined in the group's colour
						{
							Primitive = "Frame",
							Props = {
								Name = "ValueBox",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundTransparency = 0.45,
								BorderSizePixel = 0,
								LayoutOrder = 2,
								Size = UDim2.fromOffset(112, 50),
							},
							Children = {
								{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(150, 110, 255), LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
								{
									Primitive = "TextLabel",
									Id = "S_Value",
									Props = {
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = 1,
										FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
										Position = UDim2.fromScale(0.5, 0.5),
										RichText = true,
										Size = UDim2.new(1, -12, 0, 30),
										Text = "50%",
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextScaled = true,
										TextSize = 28,
									},
									Children = {
										{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 28 } },
										{ Primitive = "UIStroke", Props = { Thickness = 2.5 } },
									},
								},
							},
						},
						-- Steps the value up
						{
							Primitive = "Frame",
							Props = { Name = "RightContainer", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 3, Size = UDim2.fromOffset(56, 56) },
							Children = {
								{
									Primitive = "ImageButton",
									Id = "S_Right",
									Tags = {
										Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
										Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
									},
									Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
									Children = {
										{ Primitive = "UIStroke", Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
														FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Heavy),
														Position = UDim2.fromScale(0.5, 0.5),
														RichText = true,
														Size = UDim2.new(0.8, 0, 0, 32),
														Text = "&gt;",
														TextColor3 = Color3.fromRGB(255, 255, 255),
														TextScaled = true,
														TextSize = 32,
														ZIndex = 3,
													},
													Children = {
														{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
														{ Primitive = "UIStroke", Props = { Thickness = 2.5 } },
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
													Props = {
														Name = "UIStroke_Highlight",
														BorderStrokePosition = Enum.BorderStrokePosition.Inner,
														Color = Color3.fromRGB(255, 255, 255),
														LineJoinMode = Enum.LineJoinMode.Miter,
														Thickness = 3,
														Transparency = 0.7,
													},
												},
												{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 195, 255), Color3.fromRGB(0, 251, 255)), Rotation = -90 } },
											},
										},
										{
											Primitive = "Frame",
											Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
											Children = {
												{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 195, 255), Color3.fromRGB(0, 251, 255)), Rotation = -90 } },
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
}

return _gui
