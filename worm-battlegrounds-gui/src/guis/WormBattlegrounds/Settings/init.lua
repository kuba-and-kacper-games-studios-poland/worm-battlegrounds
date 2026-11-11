--[[
	Created By: 	HungryN00B
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
	-- The confirmation's dark panel with a SETTINGS title and a red close, sized for a 1080 px tall screen: a driver sets S_ScreenScale
	Root = {
		Primitive = "Folder",
		Children = {
			-- The window: the dark panel, SETTINGS and the close, then the settings in their groups
			{
				Primitive = "Frame",
				Id = "U_Widget",
				Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(720, 660) },
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					-- The panel: the confirmation's dark fill (25, 25, 35), a dark outer line and the screens' grey line inside it (the UIScale scales them)
					{
						Primitive = "Frame",
						Props = { Name = "Bg_Bottom", BackgroundColor3 = Color3.fromRGB(25, 25, 35), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = -999 },
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 22) } },
							{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
							{
								Primitive = "UIStroke",
								Props = { Name = "UIStroke_Inner", BorderStrokePosition = Enum.BorderStrokePosition.Inner, Color = Color3.fromRGB(130, 130, 130), Thickness = 3 },
							},
						},
					},
					-- The header: SETTINGS in the screens' white Londrina, and the red close (the Party card's kick button) in the top right corner
					{
						Primitive = "Frame",
						Props = { Name = "Bg_Top", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 999 },
						Children = {
							{
								Primitive = "TextLabel",
								Props = {
									Name = "TitleText",
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.new(0.5, 0, 0, 42),
									Size = UDim2.fromOffset(420, 52),
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									RichText = true,
									Text = "SETTINGS",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextScaled = true,
									TextSize = 52,
									TextWrapped = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.0714 } },
								},
							},
							{
								Primitive = "ImageButton",
								Props = {
									Name = "CloseButton",
									AnchorPoint = Vector2.new(0.5, 0.5),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.new(1, -44, 0, 42),
									Size = UDim2.fromOffset(60, 54),
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
									Interact_Button = { Interact_Function = "CloseCurrent", Interact_ModuleName = "WidgetManager" },
									Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" },
									Utils_ButtonScale = {},
									Utils_ButtonSound = {},
								},
								Children = {
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
													Position = UDim2.fromScale(0.013, 0.0714),
													Size = UDim2.fromScale(0.974, 0.8571),
													Image = "rbxassetid://84846546622398",
													ImageColor3 = Color3.fromRGB(255, 77, 77),
													ScaleType = Enum.ScaleType.Fit,
												},
												Attributes = { _ImageName = "1037_195__LobbyInventory__Main_gray" },
											},
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Stroke2",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													Size = UDim2.fromScale(1, 1),
													ZIndex = 2,
													Image = "rbxassetid://88288142561647",
													ImageColor3 = Color3.fromRGB(25, 25, 35),
													ScaleType = Enum.ScaleType.Fit,
												},
												Attributes = { _ImageName = "1117_46__LobbyInventory__Stroke2_gray" },
											},
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Stroke",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.0256, 0.0286),
													Size = UDim2.fromScale(0.9487, 0.9429),
													ZIndex = 3,
													Image = "rbxassetid://86088138491554",
													ImageColor3 = Color3.fromRGB(230, 64, 64),
													ScaleType = Enum.ScaleType.Fit,
												},
												Attributes = { _ImageName = "1117_47__LobbyInventory__Stroke_gray" },
											},
										},
									},
									-- The X, hidden on Console, where B shows in its place
									{
										Primitive = "TextLabel",
										Tags = { Utils_HideOnPlatform = { Utils_ConsoleVisibility = false } },
										Props = {
											Name = "X",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromScale(0.7692, 0.5714),
											ZIndex = 4,
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											RichText = true,
											Text = "X",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											TextScaled = true,
											TextSize = 34,
											TextWrapped = true,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
											{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.0882 } },
										},
									},
									-- On Console B (Circle) closes the window: a white border (gamepad-prompts' WhiteBorder) tinted black, and the white B in front
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
											Size = UDim2.fromScale(0.8, 0.8),
											ZIndex = 4,
										},
										Children = {
											{ Primitive = "UIAspectRatioConstraint" },
											{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)) } },
											{
												Primitive = "ImageLabel",
												Props = { Name = "Front", BackgroundTransparency = 1, Image = "rbxassetid://92252921636068", Size = UDim2.fromScale(1, 1), ZIndex = 5 },
											},
										},
									},
								},
							},
						},
					},
					{
						Primitive = "Frame",
						Props = { Name = "Content", AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 1), Size = UDim2.new(1, 0, 1, -84) },
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
