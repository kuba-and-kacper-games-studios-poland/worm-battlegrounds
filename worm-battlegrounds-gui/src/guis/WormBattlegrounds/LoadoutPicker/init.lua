--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The INVENTORY window: a WidgetManager widget Loadout draws on WidgetManager_Opened; ported 1:1 from the studio's LobbyInventory (2026-11-09)
	Name = "LoadoutPicker",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			{
				Primitive = "Frame",
				Id = "U_Widget",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
				},
				Children = {
					{
						Primitive = "Frame",
						Props = {
							Name = "Content",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
						},
						Children = {
							{
								Primitive = "Frame",
								Props = {
									Name = "Inventory",
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 1,
									Position = UDim2.fromScale(0.5266, 0.5),
									Size = UDim2.fromScale(0.5464, 1.7796),
									ZIndex = 2,
								},
								Children = {
									{
										Primitive = "Frame",
										Props = {
											Name = "Inventory",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 0,
											Size = UDim2.fromScale(1, 1),
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Background",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 0,
													Size = UDim2.fromScale(1, 1),
												},
												Children = {
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "InventoryBackgroundTop",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.2323, 0),
															Size = UDim2.fromScale(0.7677, 0.5),
															Image = "rbxassetid://119896424288332",
														},
														Attributes = {
															_ImageName = "1089_9__LobbyInventory__InventoryBackgroundTop_image",
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "InventoryBackgroundBottom",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 1,
															Position = UDim2.fromScale(0, 0.5),
															Size = UDim2.fromScale(0.7677, 0.5),
															ZIndex = 2,
															Image = "rbxassetid://127413375434130",
														},
														Attributes = {
															_ImageName = "1089_17__LobbyInventory__InventoryBackgroundBottom_image",
														},
													},
												},
											},
											{
												Primitive = "CanvasGroup",
												Props = {
													Name = "Items",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 1,
													Position = UDim2.fromScale(0.1117, 0.3075),
													Size = UDim2.fromScale(0.7195, 0.4735),
													ZIndex = 2,
												},
												Children = {
													{
														Primitive = "ScrollingFrame",
														Id = "U_Items",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = false,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.5113, 0.5011),
															Rotation = 14.229,
															Size = UDim2.fromScale(0.7285, 1.033),
															CanvasSize = UDim2.fromScale(0.8554, 1.6816),
															ScrollBarThickness = 0,
															ScrollingDirection = Enum.ScrollingDirection.Y,
															AutomaticCanvasSize = Enum.AutomaticSize.Y,
															ScrollBarImageTransparency = 0.5,
														},
														Attributes = {
															_ScrollAutoLayoutNormalized = true,
															_UseCanvasHeight = true,
															_UseCanvasWidth = true,
														},
														Children = {
															{
																Primitive = "UIListLayout",
																Props = {
																	HorizontalAlignment = Enum.HorizontalAlignment.Center,
																	Padding = UDim.new(0.0319, 0),
																	SortOrder = Enum.SortOrder.LayoutOrder,
																},
															},
															{
																Primitive = "UIPadding",
																Props = {
																	PaddingTop = UDim.new(0.0099, 0),
																	PaddingBottom = UDim.new(0.0099, 0),
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "Fix",
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 9999,
																	Size = UDim2.fromScale(0.9999, 0),
																	ZIndex = 6,
																},
																Attributes = {
																	_ScrollAutoLayoutNormalized = true,
																},
																Children = {
																	{
																		Primitive = "UIAspectRatioConstraint",
																		Props = {
																			AspectRatio = 4.6125,
																			AspectType = Enum.AspectType.ScaleWithParentSize,
																		},
																		Attributes = {
																			_FigmaAspectManaged = true,
																		},
																	},
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "Fix",
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 9999,
																	Size = UDim2.fromScale(0.9999, 0),
																	ZIndex = 6,
																},
																Attributes = {
																	_ScrollAutoLayoutNormalized = true,
																},
																Children = {
																	{
																		Primitive = "UIAspectRatioConstraint",
																		Props = {
																			AspectRatio = 4.6125,
																			AspectType = Enum.AspectType.ScaleWithParentSize,
																		},
																		Attributes = {
																			_FigmaAspectManaged = true,
																		},
																	},
																},
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "Fix",
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 9999,
																	Size = UDim2.fromScale(0.9999, 0),
																	ZIndex = 6,
																},
																Attributes = {
																	_ScrollAutoLayoutNormalized = true,
																},
																Children = {
																	{
																		Primitive = "UIAspectRatioConstraint",
																		Props = {
																			AspectRatio = 4.6125,
																			AspectType = Enum.AspectType.ScaleWithParentSize,
																		},
																		Attributes = {
																			_FigmaAspectManaged = true,
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
												Props = {
													Name = "Header",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 2,
													Position = UDim2.fromScale(0.3663, 0.2612),
													Size = UDim2.fromScale(0.4805, 0.0364),
													ZIndex = 3,
												},
												Children = {
													{
														Primitive = "TextLabel",
														Props = {
															Name = "HeaderText",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0, 0.1643),
															Size = UDim2.fromScale(0.5197, 0.6714),
															Text = "INVENTORY",
															TextColor3 = Color3.fromRGB(255, 255, 255),
															TextSize = 40,
															TextWrapped = true,
															TextXAlignment = Enum.TextXAlignment.Left,
															FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
															RichText = true,
															TextScaled = true,
														},
														Children = {
															{
																Primitive = "UIStroke",
																Props = {
																	Thickness = 0.075,
																	StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
																},
															},
														},
													},
													{
														Primitive = "ImageButton",
														Id = "S_Close",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 1,
															Position = UDim2.fromScale(0.9226, 0.5),
															Size = UDim2.fromScale(0.1548, 1),
															ZIndex = 2,
														},
														Attributes = {
															HoverSound_SoundGroup = "UI",
															ClickSound_PitchMax = 1,
															Utils_ClickScale = 0.92,
															Utils_HoverScale = 1.04,
															HoverSound_PitchMax = 1,
															Interact_Function = "CloseCurrent",
															Utils_ScaleAnimation = "Bouncy",
															ClickSound_PitchMin = 1,
															Utils_KeyboardKey = "",
															ClickSound_Volume = 1,
															Utils_GamepadKey = "ButtonB",
															HoverSound_PitchMin = 1,
															HoverSound_Volume = 1,
															HoverSound_TimePosition = 0,
															HoverSound_PlaybackSpeed = 1,
															ClickSound_PlaybackSpeed = 1,
															Interact_ModuleName = "WidgetManager",
															HoverSound_Name = "Button_Hover",
															ClickSound_SoundGroup = "UI",
															ClickSound_TimePosition = 0,
															ClickSound_Name = "Button_Click",
														},
														Tags = {
															["Interact_Button"] = {},
															["Utils_ButtonKey"] = {},
															["Utils_ButtonScale"] = {},
															["Utils_ButtonSound"] = {},
														},
														Children = {
															-- B closes it on a pad (its Utils_ButtonKey), shown on Console
															{
																Primitive = "ImageLabel",
																Props = {
																	Name = "PadHint",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	Image = "rbxassetid://117564937183685",
																	Position = UDim2.fromScale(0.2, 0.2),
																	ScaleType = Enum.ScaleType.Fit,
																	Size = UDim2.fromScale(0.5, 0.5),
																	SizeConstraint = Enum.SizeConstraint.RelativeYY,
																	Visible = false,
																	ZIndex = 8,
																},
																Attributes = { Console_Action = "Back" },
																Tags = { Console_Hint = {} },
															},
															{
																Primitive = "Frame",
																Props = {
																	Name = "Background",
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 0,
																	Size = UDim2.fromScale(1, 1),
																},
																Children = {
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "Main",
																			BackgroundTransparency = 1,
																			BorderSizePixel = 0,
																			LayoutOrder = 0,
																			Position = UDim2.fromScale(0.013, 0.0714),
																			Size = UDim2.fromScale(0.974, 0.8571),
																			Image = "rbxassetid://84846546622398",
																			ImageColor3 = Color3.fromRGB(255, 77, 77),
																			ScaleType = Enum.ScaleType.Fit,
																		},
																		Attributes = {
																			_ImageName = "1037_195__LobbyInventory__Main_gray",
																		},
																	},
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "Stroke2",
																			BackgroundTransparency = 1,
																			BorderSizePixel = 0,
																			ClipsDescendants = true,
																			LayoutOrder = 1,
																			Size = UDim2.fromScale(1, 1),
																			ZIndex = 2,
																			Image = "rbxassetid://88288142561647",
																			ImageColor3 = Color3.fromRGB(25, 25, 35),
																			ScaleType = Enum.ScaleType.Fit,
																		},
																		Attributes = {
																			_ImageName = "1117_46__LobbyInventory__Stroke2_gray",
																		},
																	},
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "Stroke",
																			BackgroundTransparency = 1,
																			BorderSizePixel = 0,
																			ClipsDescendants = true,
																			LayoutOrder = 2,
																			Position = UDim2.fromScale(0.0256, 0.0286),
																			Size = UDim2.fromScale(0.9487, 0.9429),
																			ZIndex = 3,
																			Image = "rbxassetid://86088138491554",
																			ImageColor3 = Color3.fromRGB(230, 64, 64),
																			ScaleType = Enum.ScaleType.Fit,
																		},
																		Attributes = {
																			_ImageName = "1117_47__LobbyInventory__Stroke_gray",
																		},
																	},
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "Mask",
																			BackgroundTransparency = 1,
																			BorderSizePixel = 0,
																			LayoutOrder = 3,
																			Position = UDim2.fromScale(0.0256, 0.0286),
																			Size = UDim2.fromScale(0.9487, 0.9429),
																			ZIndex = 4,
																			Image = "rbxassetid://136659880877211",
																		},
																		Attributes = {
																			_ImageName = "1037_198__LobbyInventory__Mask_image",
																		},
																	},
																},
															},
															{
																Primitive = "TextLabel",
																Props = {
																	Name = "X",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 1,
																	Position = UDim2.fromScale(0.5, 0.5),
																	Size = UDim2.fromScale(0.7692, 0.5714),
																	ZIndex = 2,
																	Text = "X",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextSize = 34,
																	TextWrapped = true,
																	FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
																	RichText = true,
																	TextScaled = true,
																},
																Children = {
																	{
																		Primitive = "UIStroke",
																		Props = {
																			Thickness = 0.0882,
																			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
																		},
																	},
																},
															},
															{
																Primitive = "UIAspectRatioConstraint",
																Props = {
																	AspectRatio = 1.1148,
																},
															},
														},
													},
													{
														Primitive = "ImageButton",
														Id = "S_Empty",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 7,
															Position = UDim2.fromScale(0.7, 0.5),
															Size = UDim2.fromScale(0.26, 1),
															ZIndex = 8,
														},
														Attributes = {
															HoverSound_SoundGroup = "UI",
															ClickSound_PitchMax = 1,
															Utils_ClickScale = 0.92,
															Utils_HoverScale = 1.04,
															HoverSound_PitchMax = 1,
															ClickSound_TimePosition = 0,
															Utils_ScaleAnimation = "Bouncy",
															HoverSound_Name = "Button_Hover",
															ClickSound_Volume = 1,
															HoverSound_Volume = 1,
															HoverSound_TimePosition = 0,
															ClickSound_PlaybackSpeed = 1,
															HoverSound_PlaybackSpeed = 1,
															ClickSound_PitchMin = 1,
															ClickSound_SoundGroup = "UI",
															HoverSound_PitchMin = 1,
															ClickSound_Name = "Button_Click",
														},
														Tags = {
															["Utils_ButtonScale"] = {},
															["Utils_ButtonSound"] = {},
														},
														Children = {
															{
																Primitive = "Frame",
																Props = {
																	Name = "Background",
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 0,
																	Size = UDim2.fromScale(1, 1),
																},
																Children = {
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "Main",
																			BackgroundTransparency = 1,
																			BorderSizePixel = 0,
																			LayoutOrder = 0,
																			Position = UDim2.fromScale(0.0185, 0.0862),
																			Size = UDim2.fromScale(0.9629, 0.8276),
																			Image = "rbxassetid://81690686596045",
																			ImageColor3 = Color3.fromRGB(25, 25, 35),
																			ScaleType = Enum.ScaleType.Fit,
																		},
																		Attributes = {
																			_ImageName = "1050_53__LobbyInventory__Main_gray",
																		},
																	},
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "Stroke2",
																			BackgroundTransparency = 1,
																			BorderSizePixel = 0,
																			ClipsDescendants = true,
																			LayoutOrder = 1,
																			Size = UDim2.fromScale(1, 1),
																			ZIndex = 2,
																			Image = "rbxassetid://108637236257466",
																			ImageColor3 = Color3.fromRGB(25, 25, 35),
																			ScaleType = Enum.ScaleType.Fit,
																		},
																		Attributes = {
																			_ImageName = "1117_81__LobbyInventory__Stroke2_gray",
																		},
																	},
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "Stroke",
																			BackgroundTransparency = 1,
																			BorderSizePixel = 0,
																			ClipsDescendants = true,
																			LayoutOrder = 2,
																			Position = UDim2.fromScale(0.0172, 0.0345),
																			Size = UDim2.fromScale(0.9656, 0.931),
																			ZIndex = 3,
																			Image = "rbxassetid://133046217793083",
																			ImageColor3 = Color3.fromRGB(225, 225, 225),
																			ScaleType = Enum.ScaleType.Fit,
																		},
																		Attributes = {
																			_ImageName = "1117_82__LobbyInventory__Stroke_gray",
																		},
																	},
																},
															},
															{
																Primitive = "TextLabel",
																Props = {
																	Name = "Name1",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 1,
																	Position = UDim2.fromScale(0.5, 0.5),
																	Size = UDim2.fromScale(0.7931, 0.4483),
																	ZIndex = 2,
																	Text = "EMPTY",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextSize = 22,
																	TextWrapped = true,
																	FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
																	RichText = true,
																	TextScaled = true,
																},
																Children = {
																	{
																		Primitive = "UIStroke",
																		Props = {
																			Thickness = 0.1364,
																			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
																		},
																	},
																},
															},
															{
																Primitive = "UIAspectRatioConstraint",
																Props = {
																	AspectRatio = 2.0052,
																},
															},
														},
													},
												},
											},
										},
									},
									{
										Primitive = "UIAspectRatioConstraint",
										Props = {
											AspectRatio = 0.5459,
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
				Props = {
					Name = "MouseLockFix",
					BackgroundTransparency = 1,
					LayoutOrder = 0,
					Modal = true,
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		["PREFAB | ItemRow"] = {
			Parent = "U_Items",
			Primitive = "Frame",
			Props = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 0,
				Size = UDim2.fromScale(0.9999, 0),
			},
			Attributes = {
				_ScrollAutoLayoutNormalized = true,
			},
			Children = {
				{
					Primitive = "Frame",
					Props = {
						Name = "Content",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 0,
						Position = UDim2.fromScale(0.4259, 0.5),
						Rotation = -14.229,
						Size = UDim2.fromScale(0.8223, 1),
					},
					Children = {
						{
							Primitive = "UIListLayout",
							Props = {
								FillDirection = Enum.FillDirection.Horizontal,
								Padding = UDim.new(-0.0113, 0),
								SortOrder = Enum.SortOrder.LayoutOrder,
							},
						},
						{
							Primitive = "ImageButton",
							Props = {
								Name = "PREFAB | ItemCard",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Size = UDim2.fromScale(0.3409, 1),
								ZIndex = 2,
							},
							Attributes = {
								Look_Stroke2 = "rbxassetid://113084245969286",
								HoverInfo_Provider = "",
								ClickSound_PitchMax = 1,
								Utils_ClickScale = 0.92,
								Look_Stroke = "rbxassetid://138038418690572",
								Utils_HoverScale = 1.04,
								HoverInfo_Rarity = "",
								HoverSound_PitchMax = 1,
								ClickSound_TimePosition = 0,
								Look_StrokeColor = Color3.fromRGB(130, 130, 130),
								HoverSound_Name = "Button_Hover",
								Look_SelectedStroke2 = "rbxassetid://94010640004268",
								HoverSound_SoundGroup = "UI",
								Look_EquippedStroke2 = "rbxassetid://94010640004268",
								ClickSound_PitchMin = 1,
								Look_EquippedStrokeColor = Color3.fromRGB(120, 255, 140),
								Utils_ScaleAnimation = "Bouncy",
								ClickSound_Volume = 1,
								Look_EquippedStroke = "rbxassetid://122792730520630",
								Look_SelectedStroke = "rbxassetid://122792730520630",
								HoverSound_Volume = 1,
								HoverSound_TimePosition = 0,
								HoverInfo_Title = "",
								ClickSound_PlaybackSpeed = 1,
								HoverSound_PlaybackSpeed = 1,
								HoverSound_PitchMin = 1,
								ClickSound_SoundGroup = "UI",
								Look_SelectedStrokeColor = Color3.fromRGB(255, 255, 255),
								ClickSound_Name = "Button_Click",
							},
							Tags = {
								["HoverInfo_Target"] = {},
								["Utils_ButtonScale"] = {},
								["Utils_ButtonSound"] = {},
							},
							Children = {
								{
									Primitive = "Frame",
									Props = {
										Name = "Background",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 0,
										Position = UDim2.fromScale(-0.0025, -0.0357),
										Size = UDim2.fromScale(1.0049, 1.0714),
									},
									Children = {
										{
											Primitive = "ImageLabel",
											Props = {
												Name = "Main",
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 0,
												Position = UDim2.fromScale(0.0025, 0.0333),
												Size = UDim2.fromScale(0.9951, 0.9333),
												Image = "rbxassetid://131402009453053",
												ImageColor3 = Color3.fromRGB(25, 25, 35),
												ScaleType = Enum.ScaleType.Fit,
											},
											Attributes = {
												_ImageName = "1055_6__LobbyInventory__Main_gray",
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												Name = "Stroke2",
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												ClipsDescendants = true,
												LayoutOrder = 1,
												Position = UDim2.fromScale(0, 0),
												Size = UDim2.fromScale(1, 1),
												ZIndex = 2,
												Image = "rbxassetid://113084245969286",
												ImageColor3 = Color3.fromRGB(25, 25, 35),
												ScaleType = Enum.ScaleType.Fit,
											},
											Attributes = {
												_ImageName = "1117_16__LobbyInventory__Stroke2_gray",
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												Name = "Stroke",
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												ClipsDescendants = true,
												LayoutOrder = 2,
												Position = UDim2.fromScale(0.011, 0.0133),
												Size = UDim2.fromScale(0.978, 0.9733),
												ZIndex = 3,
												Image = "rbxassetid://138038418690572",
												ImageColor3 = Color3.fromRGB(130, 130, 130),
												ScaleType = Enum.ScaleType.Fit,
											},
											Attributes = {
												_ImageName = "1117_17__LobbyInventory__Stroke_gray",
											},
										},
									},
								},
								{
									Primitive = "ImageLabel",
									Id = "S_Rarity",
									Props = {
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 1,
										Position = UDim2.fromScale(0.1883, 0.0429),
										Size = UDim2.fromScale(0.1994, 0.1714),
										ZIndex = 2,
										Image = "rbxassetid://85551024067701",
										ImageColor3 = Color3.fromRGB(79, 194, 97),
										ScaleType = Enum.ScaleType.Fit,
									},
									Attributes = {
										_ImageName = "1066_2__LobbyInventory__Rarity_gray",
									},
								},
								{
									Primitive = "ImageLabel",
									Id = "S_Icon",
									Props = {
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										ClipsDescendants = true,
										LayoutOrder = 2,
										Position = UDim2.fromScale(0.2818, 0.0571),
										Size = UDim2.fromScale(0.4862, 0.6286),
										ZIndex = 3,
										Image = "rbxassetid://125272685999061",
									},
									Attributes = {
										_ImageName = "1055_9__LobbyInventory__Icon_image",
									},
								},
								{
									Primitive = "TextLabel",
									Id = "S_Amount",
									Props = {
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 3,
										Position = UDim2.fromScale(0.1261, 0.7714),
										Size = UDim2.fromScale(0.6077, 0.1714),
										ZIndex = 4,
										Text = "x5",
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextSize = 20,
										TextWrapped = true,
										FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
										RichText = true,
										TextScaled = true,
									},
								},
								{
									Primitive = "TextLabel",
									Id = "S_Name",
									Props = {
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 4,
										Position = UDim2.fromScale(0.0988, 0.6286),
										Size = UDim2.fromScale(0.7182, 0.1714),
										ZIndex = 5,
										Text = "Grenade",
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextSize = 20,
										TextWrapped = true,
										FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
										RichText = true,
										TextScaled = true,
									},
								},
								{
									Primitive = "UIAspectRatioConstraint",
									Props = {
										AspectRatio = 1.2911,
									},
								},
								{
									Primitive = "Frame",
									Id = "S_Locked",
									Props = {
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 5,
										Position = UDim2.fromScale(-0.0025, -0.0357),
										Size = UDim2.fromScale(1.0049, 1.0714),
										Visible = false,
										ZIndex = 6,
									},
									Children = {
										{
											Primitive = "ImageLabel",
											Props = {
												Name = "Locked",
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 0,
												Position = UDim2.fromScale(0.0025, 0.0333),
												Size = UDim2.fromScale(0.9951, 0.9333),
												Image = "rbxassetid://106332884923149",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
											Attributes = {
												_ImageName = "1055_96__LobbyInventory__Locked_gray",
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												Name = "LockedStroke",
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												ClipsDescendants = true,
												LayoutOrder = 1,
												Size = UDim2.fromScale(1, 1),
												ZIndex = 2,
												Image = "rbxassetid://135330945614455",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
											Attributes = {
												_ImageName = "1117_24__LobbyInventory__LockedStroke_gray",
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												Name = "LockIcon",
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												ClipsDescendants = true,
												LayoutOrder = 2,
												Position = UDim2.fromScale(0.3812, 0.26),
												Size = UDim2.fromScale(0.2394, 0.3267),
												ZIndex = 3,
												Image = "rbxassetid://131803930638166",
											},
											Attributes = {
												_ImageName = "1055_97__LobbyInventory__LockIcon_image",
											},
										},
									},
								},
							},
						},
					},
				},
				{
					Primitive = "UIAspectRatioConstraint",
					Props = {
						AspectRatio = 4.6125,
						AspectType = Enum.AspectType.ScaleWithParentSize,
					},
					Attributes = {
						_FigmaAspectManaged = true,
					},
				},
			},
		},
	},
}

return _gui
