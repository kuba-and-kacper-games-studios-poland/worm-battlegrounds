--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The lobby's PUBLIC MATCHES and PLAY SOLO with LOCAL and CUSTOM (bottom); the studio's LobbyRework port (2026-11-24, over the 2026-11-09 LobbyInventory one). The solo, party and local setup is its own widget since 2026-11-17 (MatchSetup)
	Name = "MatchBoard",
	Screen = { DisplayOrder = -1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			{
				Primitive = "Frame",
				Id = "U_Play",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
				},
				Children = {
					--[[
						The bottom bar: the public matches and the buttons (LOCAL, CUSTOM, PLAY SOLO) side by side, right-aligned a fixed
						gap apart (0.0142 of the screen), so on screens wider than 16:9, where both keep their shape and shrink to the
						height, the gap stays and the margin grows on the left. The bar slides away as one (Board's Slide Play)
					]]
					{
						Primitive = "Frame",
						Props = {
							Name = "BottomBar",
							AnchorPoint = Vector2.new(1, 1),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 5,
							Position = UDim2.fromScale(0.9681, 0.9472),
							Size = UDim2.fromScale(0.938, 0.2028),
							ZIndex = 6,
						},
						Children = {
							{
								Primitive = "UIListLayout",
								Props = {
									FillDirection = Enum.FillDirection.Horizontal,
									HorizontalAlignment = Enum.HorizontalAlignment.Right,
									VerticalAlignment = Enum.VerticalAlignment.Bottom,
									Padding = UDim.new(0.01514, 0),
									SortOrder = Enum.SortOrder.LayoutOrder,
								},
							},
							{
								Primitive = "Frame",
								Props = {
									Name = "BottomLeft",
									AnchorPoint = Vector2.new(0, 1),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 1,
									Size = UDim2.fromScale(0.7464, 1),
									ZIndex = 6,
								},
								Children = {
									{
										Primitive = "Frame",
										Props = {
											Name = "ActiveLobbies",
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
													Position = UDim2.fromScale(0, 0.2237),
													Size = UDim2.fromScale(1, 0.7763),
												},
												Children = {
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Main",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.0016, 0.0294),
															Size = UDim2.fromScale(0.9968, 0.9412),
															Image = "rbxassetid://74482805824942",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = {
															_ImageName = "1050_27__LobbyInventory__Main_gray",
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "MainFill",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.0016, 0.0294),
															Size = UDim2.fromScale(0.9968, 0.9412),
															Image = "rbxassetid://74482805824942",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = {
															_ImageName = "1050_27__LobbyInventory__Main_gray",
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "MainFill",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.0016, 0.0294),
															Size = UDim2.fromScale(0.9968, 0.9412),
															Image = "rbxassetid://74482805824942",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = {
															_ImageName = "1050_27__LobbyInventory__Main_gray",
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
															Image = "rbxassetid://94881140849770",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = {
															_ImageName = "1117_74__LobbyInventory__Stroke2_gray",
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
															Position = UDim2.fromScale(0.0015, 0.0118),
															Size = UDim2.fromScale(0.997, 0.9765),
															ZIndex = 3,
															Image = "rbxassetid://98455727844429",
															ImageColor3 = Color3.fromRGB(130, 130, 130),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = {
															_ImageName = "1117_75__LobbyInventory__Stroke_gray",
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Mask",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = true,
															LayoutOrder = 3,
															Position = UDim2.fromScale(0.0016, 0.0294),
															Size = UDim2.fromScale(0.9968, 0.9412),
															ZIndex = 4,
															Image = "rbxassetid://107725301113778",
														},
														Attributes = {
															_ImageName = "1050_30__LobbyInventory__Mask_image",
														},
													},
												},
											},
											{
												Primitive = "TextLabel",
												Props = {
													Name = "HeaderText",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 1,
													Position = UDim2.fromScale(0.0179, 0),
													Size = UDim2.fromScale(0.2976, 0.1735),
													ZIndex = 2,
													Text = "PUBLIC MATCHES",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextSize = 32,
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
															Thickness = 0.07,
															StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Lobbies Viewport",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 2,
													Position = UDim2.fromScale(0.0155, 0.3196),
													Size = UDim2.fromScale(0.969, 0.5845),
													ZIndex = 3,
												},
												Children = {
													{
														Primitive = "Frame",
														Props = {
															Name = "Scroll mask",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = true,
															LayoutOrder = 0,
															Size = UDim2.fromScale(1, 1),
														},
														Children = {
															{
																Primitive = "ScrollingFrame",
																Id = "U_Rows",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 0,
																	Size = UDim2.fromScale(1, 1),
																	CanvasSize = UDim2.fromScale(0, 1),
																	ScrollBarThickness = 4,
																	ScrollingDirection = Enum.ScrollingDirection.X,
																	AutomaticCanvasSize = Enum.AutomaticSize.X,
																	ScrollBarImageTransparency = 0.5,
																	Selectable = false,
																},
																Attributes = {
																	_ScrollAutoLayoutNormalized = true,
																	_UseCanvasHeight = false,
																	_UseCanvasWidth = true,
																},
																Children = {
																	{
																		Primitive = "UIListLayout",
																		Props = {
																			FillDirection = Enum.FillDirection.Horizontal,
																			Padding = UDim.new(0.015, 0),
																			SortOrder = Enum.SortOrder.LayoutOrder,
																		},
																	},
																	{
																		Primitive = "UIPadding",
																		Props = {
																			PaddingTop = UDim.new(0.0625, 0),
																			PaddingBottom = UDim.new(0.0625, 0),
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
										Primitive = "UIAspectRatioConstraint",
										Props = {
											AspectRatio = 6.1381,
										},
									},
								},
							},
							-- LOCAL and CUSTOM over PLAY SOLO, at the bottom right (the studio's LobbyRework, 2026-11-24)
							{
								Primitive = "Frame",
								Props = {
									Name = "BottomRight",
									AnchorPoint = Vector2.new(1, 1),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 2,
									Size = UDim2.fromScale(0.2385, 0.9497),
									ZIndex = 6,
								},
								Children = {
									--[[
										One square tile in LOCAL's and CUSTOM's place (the owner, 2026-11-25): the Loadout's EMOTES tile with the top
										bar's gear in the glyphs' look (white, an ink outline round it). It opens FriendsMatch (LOCAL or CUSTOM), by a
										click or the pad's X (CUSTOM's key before)
									]]
									{
										Primitive = "ImageButton",
										Id = "S_Friends",
										-- Over PLAY SOLO's left end, clear of the Loadout column's EMOTES on a full loadout (2026-11-26)
										Props = {
											AnchorPoint = Vector2.new(0, 1),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 0,
											Position = UDim2.fromScale(0, 0.1256),
											Size = UDim2.fromScale(0.5, 0.33),
											ZIndex = 3,
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
											Interact_Arg1 = "FriendsMatch",
											Interact_Function = "Toggle",
											Interact_ModuleName = "WidgetManager",
											Utils_ClickScale = 0.92,
											Utils_GamepadKey = "ButtonX",
											Utils_HoverScale = 1.04,
											Utils_KeyboardKey = "",
											Utils_ScaleAnimation = "Bouncy",
										},
										Tags = { ["Interact_Button"] = {}, ["Utils_ButtonKey"] = {}, ["Utils_ButtonScale"] = {}, ["Utils_ButtonSound"] = {} },
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Background",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 0,
													Position = UDim2.fromScale(-0.003, -0.051),
													Size = UDim2.fromScale(1.006, 1.102),
												},
												Children = {
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Main",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.003, 0.0463),
															Size = UDim2.fromScale(0.9941, 0.9074),
															Image = "rbxassetid://91511289193689",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1050_120__LobbyInventory__Main_gray" },
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "MainFill",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.003, 0.0463),
															Size = UDim2.fromScale(0.9941, 0.9074),
															Image = "rbxassetid://91511289193689",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1050_120__LobbyInventory__Main_gray" },
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "MainFill",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.003, 0.0463),
															Size = UDim2.fromScale(0.9941, 0.9074),
															Image = "rbxassetid://91511289193689",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1050_120__LobbyInventory__Main_gray" },
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Stroke2",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = true,
															LayoutOrder = 1,
															Size = UDim2.fromScale(1.0067, 1),
															ZIndex = 2,
															Image = "rbxassetid://120228011865765",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1117_56__LobbyInventory__Stroke2_gray" },
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Stroke",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = true,
															LayoutOrder = 2,
															Position = UDim2.fromScale(0.0133, 0.0185),
															Size = UDim2.fromScale(0.9735, 0.963),
															ZIndex = 3,
															Image = "rbxassetid://81979878629232",
															ImageColor3 = Color3.fromRGB(130, 130, 130),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1117_57__LobbyInventory__Stroke_gray" },
													},
												},
											},
											{
												Primitive = "UIAspectRatioConstraint",
												Props = {
													AspectRatio = 1.5306,
													AspectType = Enum.AspectType.FitWithinMaxSize,
													DominantAxis = Enum.DominantAxis.Height,
												},
											},
											-- The gear: the top bar's settings picture in white over eight ink copies nudged round it
											{
												Primitive = "Frame",
												Props = {
													Name = "Icon",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 2,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(0.62, 0.62),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 4,
												},
												Children = {
													{
														Primitive = "ImageLabel",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.560, 0.500),
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://123765846716976",
															ImageColor3 = Color3.fromRGB(0, 0, 0),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 1,
															Position = UDim2.fromScale(0.542, 0.542),
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://123765846716976",
															ImageColor3 = Color3.fromRGB(0, 0, 0),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 2,
															Position = UDim2.fromScale(0.500, 0.560),
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://123765846716976",
															ImageColor3 = Color3.fromRGB(0, 0, 0),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 3,
															Position = UDim2.fromScale(0.458, 0.542),
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://123765846716976",
															ImageColor3 = Color3.fromRGB(0, 0, 0),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 4,
															Position = UDim2.fromScale(0.440, 0.500),
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://123765846716976",
															ImageColor3 = Color3.fromRGB(0, 0, 0),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 5,
															Position = UDim2.fromScale(0.458, 0.458),
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://123765846716976",
															ImageColor3 = Color3.fromRGB(0, 0, 0),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 6,
															Position = UDim2.fromScale(0.500, 0.440),
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://123765846716976",
															ImageColor3 = Color3.fromRGB(0, 0, 0),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 7,
															Position = UDim2.fromScale(0.542, 0.458),
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://123765846716976",
															ImageColor3 = Color3.fromRGB(0, 0, 0),
															ScaleType = Enum.ScaleType.Fit,
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Glyph",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 9,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 2,
															Image = "rbxassetid://123765846716976",
															ScaleType = Enum.ScaleType.Fit,
														},
													},
												},
											},
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "PadHint",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 1,
													LayoutOrder = 1,
													Position = UDim2.fromScale(0.12, 0.14),
													Size = UDim2.fromScale(0.38, 0.38),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													Visible = false,
													ZIndex = 8,
													Image = "rbxassetid://116629055704033",
													ScaleType = Enum.ScaleType.Fit,
												},
												Attributes = {
													Console_Action = "Custom",
												},
												Tags = { ["Console_Hint"] = {} },
											},
										},
									},
									{
										Primitive = "ImageButton",
										Id = "S_Solo",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 1,
											Position = UDim2.fromScale(0.5, 0.5918),
											Size = UDim2.fromScale(1, 0.62),
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
										Tags = { ["Utils_ButtonScale"] = {}, ["Utils_ButtonSound"] = {} },
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
															Size = UDim2.fromScale(1, 1),
															Image = "rbxassetid://106999015477412",
															ImageColor3 = Color3.fromRGB(255, 215, 110),
															ScaleType = Enum.ScaleType.Stretch,
														},
														Attributes = {
															_ImageName = "1309_195__LobbyRework__Main_gray",
														},
													},
													-- The outline: the shape in ink, nudged 3 design pixels each way round it, under the fill (the design's own outline
													-- picture was cut off at its edges)
													{
														Primitive = "Frame",
														Props = {
															Name = "Stroke2",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 1,
															Position = UDim2.fromScale(0, 0),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 0,
														},
														Children = {
															{
																Primitive = "ImageLabel",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 0,
																	Position = UDim2.fromScale(0.0093, 0),
																	Size = UDim2.fromScale(1, 1),
																	Image = "rbxassetid://106999015477412",
																	ImageColor3 = Color3.fromRGB(0, 0, 0),
																	ScaleType = Enum.ScaleType.Stretch,
																},
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 1,
																	Position = UDim2.fromScale(0.0066, 0.0219),
																	Size = UDim2.fromScale(1, 1),
																	Image = "rbxassetid://106999015477412",
																	ImageColor3 = Color3.fromRGB(0, 0, 0),
																	ScaleType = Enum.ScaleType.Stretch,
																},
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 2,
																	Position = UDim2.fromScale(0, 0.0313),
																	Size = UDim2.fromScale(1, 1),
																	Image = "rbxassetid://106999015477412",
																	ImageColor3 = Color3.fromRGB(0, 0, 0),
																	ScaleType = Enum.ScaleType.Stretch,
																},
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 3,
																	Position = UDim2.fromScale(-0.0066, 0.0219),
																	Size = UDim2.fromScale(1, 1),
																	Image = "rbxassetid://106999015477412",
																	ImageColor3 = Color3.fromRGB(0, 0, 0),
																	ScaleType = Enum.ScaleType.Stretch,
																},
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 4,
																	Position = UDim2.fromScale(-0.0093, 0),
																	Size = UDim2.fromScale(1, 1),
																	Image = "rbxassetid://106999015477412",
																	ImageColor3 = Color3.fromRGB(0, 0, 0),
																	ScaleType = Enum.ScaleType.Stretch,
																},
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 5,
																	Position = UDim2.fromScale(-0.0066, -0.0219),
																	Size = UDim2.fromScale(1, 1),
																	Image = "rbxassetid://106999015477412",
																	ImageColor3 = Color3.fromRGB(0, 0, 0),
																	ScaleType = Enum.ScaleType.Stretch,
																},
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 6,
																	Position = UDim2.fromScale(0, -0.0313),
																	Size = UDim2.fromScale(1, 1),
																	Image = "rbxassetid://106999015477412",
																	ImageColor3 = Color3.fromRGB(0, 0, 0),
																	ScaleType = Enum.ScaleType.Stretch,
																},
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 7,
																	Position = UDim2.fromScale(0.0066, -0.0219),
																	Size = UDim2.fromScale(1, 1),
																	Image = "rbxassetid://106999015477412",
																	ImageColor3 = Color3.fromRGB(0, 0, 0),
																	ScaleType = Enum.ScaleType.Stretch,
																},
															},
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Mask",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = true,
															LayoutOrder = 2,
															Size = UDim2.fromScale(1, 1),
															ZIndex = 3,
															Image = "rbxassetid://104442174772891",
														},
														Attributes = {
															_ImageName = "1309_197__LobbyRework__Mask_image",
														},
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Stroke",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 3,
															Size = UDim2.fromScale(1, 1),
															ZIndex = 4,
															Image = "rbxassetid://114984631034960",
															ImageColor3 = Color3.fromRGB(255, 240, 201),
															ScaleType = Enum.ScaleType.Stretch,
														},
														Attributes = {
															_ImageName = "1309_200__LobbyRework__Stroke_gray",
														},
													},
												},
											},
											{
												Primitive = "TextLabel",
												Props = {
													Name = "Name1",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 1,
													Position = UDim2.fromScale(0.1163, 0.33),
													Size = UDim2.fromScale(0.7674, 0.34),
													ZIndex = 2,
													Text = "Play solo",
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextSize = 40,
													TextScaled = true,
													TextWrapped = true,
												},
												Tags = { ["TextCase_Upper"] = {} },
												Children = {
													{
														Primitive = "UIStroke",
														Props = {
															Thickness = 0.06,
															StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
														},
													},
													{
														Primitive = "UIPadding",
														Props = {
															PaddingLeft = UDim.new(0.0121, 0),
															PaddingRight = UDim.new(0.0121, 0),
														},
													},
													{
														Primitive = "UITextSizeConstraint",
														Props = {
															MaxTextSize = 46,
															MinTextSize = 6,
														},
													},
												},
											},
											{
												Primitive = "ImageLabel",
												Id = "S_SoloIcon",
												Props = {
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													ClipsDescendants = true,
													LayoutOrder = 2,
													Position = UDim2.fromScale(0.0542, 0.26),
													Size = UDim2.fromScale(0.145, 0.48),
													ZIndex = 3,
													Image = "rbxassetid://119204758692964",
													ScaleType = Enum.ScaleType.Fit,
												},
												Attributes = {
													_ImageName = "1320_11__LobbyRework__Icon_image",
												},
											},
										},
									},
									{
										Primitive = "UIAspectRatioConstraint",
										Props = {
											AspectRatio = 2.0673,
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

	--[[ Prefabs ]]

	Templates = {
		["PREFAB | Row"] = {
			Parent = "U_Rows",
			Primitive = "Frame",
			Props = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 0,
				Position = UDim2.fromOffset(-8, 0),
				Size = UDim2.fromScale(0.3356, 1),
			},
			Attributes = { _ScrollAutoLayoutNormalized = true },
			Children = {
				{
					Primitive = "Frame",
					Props = {
						Name = "Background",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 0,
						Position = UDim2.fromScale(-0.0079, -0.0446),
						Size = UDim2.fromScale(1.0159, 1.0893),
					},
					Children = {
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "Main",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.0078, 0.041),
								Size = UDim2.fromScale(0.9844, 0.918),
								Image = "rbxassetid://100792283334050",
								ImageColor3 = Color3.fromRGB(25, 25, 35),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = {
								_ImageName = "1314_4__LobbyRework__Main_gray",
							},
						},
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "MainFill",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.0078, 0.041),
								Size = UDim2.fromScale(0.9844, 0.918),
								Image = "rbxassetid://100792283334050",
								ImageColor3 = Color3.fromRGB(25, 25, 35),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = {
								_ImageName = "1314_4__LobbyRework__Main_gray",
							},
						},
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "MainFill",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.0078, 0.041),
								Size = UDim2.fromScale(0.9844, 0.918),
								Image = "rbxassetid://100792283334050",
								ImageColor3 = Color3.fromRGB(25, 25, 35),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = {
								_ImageName = "1314_4__LobbyRework__Main_gray",
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
								Size = UDim2.fromScale(1, 1.0082),
								ZIndex = 2,
								Image = "rbxassetid://125948086807225",
								ImageColor3 = Color3.fromRGB(25, 25, 35),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = {
								_ImageName = "1314_5__LobbyRework__Stroke2_gray",
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
								Position = UDim2.fromScale(0.0047, 0.0164),
								Size = UDim2.fromScale(0.9906, 0.9672),
								ZIndex = 3,
								Image = "rbxassetid://121983589310460",
								ImageColor3 = Color3.fromRGB(130, 130, 130),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = {
								_ImageName = "1314_6__LobbyRework__Stroke_gray",
							},
						},
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "Mask",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								ClipsDescendants = true,
								LayoutOrder = 3,
								Position = UDim2.fromScale(0.0078, 0.041),
								Size = UDim2.fromScale(0.9844, 0.918),
								ZIndex = 4,
								Image = "rbxassetid://115221168251133",
							},
							Attributes = {
								_ImageName = "1314_7__LobbyRework__Mask_image",
							},
						},
					},
				},
				-- The map's picture over the whole card, fading out to the right before Join (the owner, 2026-11-15)
				{
					Primitive = "ImageLabel",
					Id = "S_MapIcon",
					Props = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 1,
						Size = UDim2.fromScale(1, 1),
						ZIndex = 2,
						Image = "rbxassetid://74309174128470",
					},
					Attributes = {
						_ImageName = "1314_10__LobbyRework__MapIcon_image",
					},
					Children = {
						{
							Primitive = "UIGradient",
							Props = { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 0), NumberSequenceKeypoint.new(0.72, 1), NumberSequenceKeypoint.new(1, 1) }) },
						},
					},
				},
				{
					Primitive = "ImageLabel",
					Props = {
						Name = "Stroke3",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ClipsDescendants = true,
						LayoutOrder = 2,
						Position = UDim2.fromScale(0.0039, 0),
						Size = UDim2.fromScale(0.9921, 1),
						ZIndex = 3,
						Image = "rbxassetid://110163151616791",
						ImageColor3 = Color3.fromRGB(25, 25, 35),
						ScaleType = Enum.ScaleType.Fit,
					},
					Attributes = {
						_ImageName = "1314_11__LobbyRework__Stroke3_gray",
					},
				},
				{
					Primitive = "Frame",
					Props = {
						Name = "Timer",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 3,
						Position = UDim2.fromScale(0.679, 0.0893),
						Size = UDim2.fromScale(0.2659, 0.2321),
						ZIndex = 4,
					},
					Children = {
						{
							Primitive = "UIListLayout",
							Props = {
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0.0536, 0),
							},
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "TimerIcon",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Size = UDim2.fromScale(0.177, 0.8612),
							},
							Children = {
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "TimerIcon",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 0,
										ClipsDescendants = true,
										Position = UDim2.fromScale(-0.1, -0.0909),
										Size = UDim2.fromScale(1.2, 1.1818),
										Image = "rbxassetid://74977191257243",
									},
									Attributes = {
										_ImageName = "1314_14__LobbyRework__TimerIcon_image",
									},
								},
							},
						},
						{
							Primitive = "TextLabel",
							Id = "S_Timer",
							Props = {
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 1,
								Size = UDim2.fromScale(0.4554, 1),
								ZIndex = 2,
								Text = "0:06",
								FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextSize = 22,
								TextScaled = true,
								TextWrapped = true,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							Children = {
								{
									Primitive = "UIStroke",
									Props = {
										Thickness = 0.07,
										StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
									},
								},
								{
									Primitive = "UIPadding",
								},
								{
									Primitive = "UITextSizeConstraint",
									Props = {
										MaxTextSize = 26,
										MinTextSize = 6,
									},
								},
							},
						},
					},
				},
				{
					Primitive = "Frame",
					Props = {
						Name = "ModeIcon",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 4,
						Position = UDim2.fromScale(0.057, 0.1071),
						Size = UDim2.fromScale(0.076, 0.2857),
						ZIndex = 5,
					},
					Children = {
						-- The card's mode icon (MatchBoard's MODE_ICONS)
						{
							Primitive = "ImageLabel",
							Id = "S_ModeIcon",
							Props = {
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								ClipsDescendants = true,
								Position = UDim2.fromScale(-0.0312, 0),
								Size = UDim2.fromScale(1.0312, 1.0312),
								Image = "rbxassetid://96388734428457",
							},
							Attributes = {
								_ImageName = "1314_19__LobbyRework__ModeIcon_image",
							},
						},
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Mode",
					Props = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 5,
						Position = UDim2.fromScale(0.1472, 0.1027),
						Size = UDim2.fromScale(0.5223, 0.2946),
						ZIndex = 6,
						Text = "DEATHMATCH",
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 28,
						TextScaled = true,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Tags = { ["TextCase_Upper"] = {} },
					Children = {
						{
							Primitive = "UIStroke",
							Props = {
								Thickness = 0.07,
								StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
							},
						},
						{
							Primitive = "UIPadding",
							Props = {
								PaddingLeft = UDim.new(0.0182, 0),
								PaddingRight = UDim.new(0.0182, 0),
							},
						},
						{
							Primitive = "UITextSizeConstraint",
							Props = {
								MaxTextSize = 34,
								MinTextSize = 6,
							},
						},
					},
				},
				{
					Primitive = "Frame",
					Props = {
						Name = "Map",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 6,
						Position = UDim2.fromScale(0.0285, 0.5536),
						Size = UDim2.fromScale(0.6125, 0.3214),
						ZIndex = 7,
					},
					Children = {
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "Band",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Size = UDim2.fromScale(1, 1),
								Image = "rbxassetid://132133568472219",
								ImageColor3 = Color3.fromRGB(14, 14, 20),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = {
								_ImageName = "1314_23__LobbyRework__Band_gray",
							},
						},
						{
							Primitive = "TextLabel",
							Id = "S_Map",
							Props = {
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 1,
								Position = UDim2.fromScale(0.062, 0.1389),
								Size = UDim2.fromScale(0.6202, 0.7222),
								ZIndex = 2,
								Text = "Rolling Plains",
								FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextSize = 22,
								TextScaled = true,
								TextWrapped = true,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							Children = {
								{
									Primitive = "UIStroke",
									Props = {
										Thickness = 0.07,
										StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
									},
								},
								{
									Primitive = "UIPadding",
									Props = {
										PaddingLeft = UDim.new(0.0251, 0),
										PaddingRight = UDim.new(0.0251, 0),
									},
								},
								{
									Primitive = "UITextSizeConstraint",
									Props = {
										MaxTextSize = 27,
										MinTextSize = 6,
									},
								},
							},
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "Players",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.7171, 0.1389),
								Size = UDim2.fromScale(0.2597, 0.7222),
								ZIndex = 3,
							},
							Children = {
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "CapacityIcon",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 0,
										ClipsDescendants = true,
										Position = UDim2.fromScale(0, 0.1671),
										Size = UDim2.fromScale(0.2687, 0.6658),
										Image = "rbxassetid://110975268442036",
									},
									Attributes = {
										_ImageName = "1314_26__LobbyRework__CapacityIcon_image",
									},
								},
								-- The players seated in the match a Join would put the player in, from every server (Matchmaking)
								{
									Primitive = "TextLabel",
									Id = "S_Players",
									Props = {
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 1,
										Position = UDim2.fromScale(0.3134, 0),
										Size = UDim2.fromScale(0.6866, 1),
										ZIndex = 2,
										Text = "2/4",
										FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextSize = 22,
										TextScaled = true,
										TextWrapped = true,
										TextXAlignment = Enum.TextXAlignment.Left,
									},
									Children = {
										{
											Primitive = "UIStroke",
											Props = {
												Thickness = 0.07,
												StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
											},
										},
										{
											Primitive = "UIPadding",
										},
										{
											Primitive = "UITextSizeConstraint",
											Props = {
												MaxTextSize = 27,
												MinTextSize = 6,
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
					Id = "S_Join",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 7,
						Position = UDim2.fromScale(0.8119, 0.6607),
						Size = UDim2.fromScale(0.2849, 0.5),
						ZIndex = 8,
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
					Tags = { ["Utils_ButtonScale"] = {}, ["Utils_ButtonSound"] = {} },
					Children = {
						-- A bright rim round JOIN, its own picture stretched larger behind it in pale yellow, hidden (ImageTransparency 1) until the Tutorial's public matches hint pulses it (2026-11-25)
						{
							Primitive = "ImageLabel",
							Id = "S_Glow",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1.12, 1.25),
								ZIndex = 0,
								Image = "rbxassetid://93006114159082",
								ImageColor3 = Color3.fromRGB(255, 246, 190),
								ImageTransparency = 1,
								ScaleType = Enum.ScaleType.Stretch,
							},
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
										Size = UDim2.fromScale(1, 1),
										Image = "rbxassetid://93006114159082",
										ImageColor3 = Color3.fromRGB(255, 178, 74),
										ScaleType = Enum.ScaleType.Fit,
									},
									Attributes = {
										_ImageName = "1314_30__LobbyRework__Main_gray",
									},
								},
								-- The outline: the shape in ink, nudged 3 design pixels each way round it, under the fill (the design's own outline
								-- picture was cut off at its edges)
								{
									Primitive = "Frame",
									Props = {
										Name = "Stroke2",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 1,
										Position = UDim2.fromScale(0, 0),
										Size = UDim2.fromScale(1, 1),
										ZIndex = 0,
									},
									Children = {
										{
											Primitive = "ImageLabel",
											Props = {
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 0,
												Position = UDim2.fromScale(0.0219, 0.0),
												Size = UDim2.fromScale(1, 1),
												Image = "rbxassetid://93006114159082",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 1,
												Position = UDim2.fromScale(0.0155, 0.0331),
												Size = UDim2.fromScale(1, 1),
												Image = "rbxassetid://93006114159082",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 2,
												Position = UDim2.fromScale(0.0, 0.0469),
												Size = UDim2.fromScale(1, 1),
												Image = "rbxassetid://93006114159082",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 3,
												Position = UDim2.fromScale(-0.0155, 0.0331),
												Size = UDim2.fromScale(1, 1),
												Image = "rbxassetid://93006114159082",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 4,
												Position = UDim2.fromScale(-0.0219, 0.0),
												Size = UDim2.fromScale(1, 1),
												Image = "rbxassetid://93006114159082",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 5,
												Position = UDim2.fromScale(-0.0155, -0.0331),
												Size = UDim2.fromScale(1, 1),
												Image = "rbxassetid://93006114159082",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 6,
												Position = UDim2.fromScale(-0.0, -0.0469),
												Size = UDim2.fromScale(1, 1),
												Image = "rbxassetid://93006114159082",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
										},
										{
											Primitive = "ImageLabel",
											Props = {
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												LayoutOrder = 7,
												Position = UDim2.fromScale(0.0155, -0.0331),
												Size = UDim2.fromScale(1, 1),
												Image = "rbxassetid://93006114159082",
												ImageColor3 = Color3.fromRGB(0, 0, 0),
												ScaleType = Enum.ScaleType.Fit,
											},
										},
									},
								},
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "Mask",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										ClipsDescendants = true,
										LayoutOrder = 2,
										Size = UDim2.fromScale(1, 1),
										ZIndex = 3,
										Image = "rbxassetid://124654736670609",
									},
									Attributes = {
										_ImageName = "1314_32__LobbyRework__Mask_image",
									},
								},
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "Stroke",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 3,
										Size = UDim2.fromScale(1, 1),
										ZIndex = 4,
										Image = "rbxassetid://75093108868495",
										ImageColor3 = Color3.fromRGB(255, 214, 170),
										ScaleType = Enum.ScaleType.Fit,
									},
									Attributes = {
										_ImageName = "1314_35__LobbyRework__Stroke_gray",
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
								Size = UDim2.fromScale(0.9167, 0.5893),
								ZIndex = 2,
								Text = "JOIN",
								FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextSize = 28,
								TextScaled = true,
								TextWrapped = true,
							},
							Tags = { ["TextCase_Upper"] = {} },
							Children = {
								{
									Primitive = "UIStroke",
									Props = {
										Thickness = 0.07,
										StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
									},
								},
								{
									Primitive = "UIPadding",
									Props = {
										PaddingLeft = UDim.new(0.0364, 0),
										PaddingRight = UDim.new(0.0364, 0),
									},
								},
								{
									Primitive = "UITextSizeConstraint",
									Props = {
										MaxTextSize = 34,
										MinTextSize = 6,
									},
								},
							},
						},
					},
				},
				{
					Primitive = "UIAspectRatioConstraint",
					Props = {
						AspectRatio = 3.7589,
						AspectType = Enum.AspectType.ScaleWithParentSize,
						DominantAxis = Enum.DominantAxis.Height,
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
