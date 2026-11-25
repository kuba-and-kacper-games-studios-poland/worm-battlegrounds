--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The lobby's LOADOUT and EMOTES (right): the Loadout and Cosmetics modules fill it, on the Lobby map; ported 1:1 from the studio's LobbyInventory (2026-11-09)
	Name = "Loadout",
	Screen = { DisplayOrder = -1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			{
				Primitive = "Frame",
				Id = "U_Loadout",
				Props = {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 3,
					Position = UDim2.fromScale(0.9756, 0.2511),
					Size = UDim2.fromScale(0.1354, 0.4776),
					ZIndex = 4,
				},
				Children = {
					{
						Primitive = "Frame",
						Props = {
							Name = "Loadout",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 0,
							Size = UDim2.fromScale(1, 1),
						},
						Children = {
							{
								Primitive = "TextLabel",
								Props = {
									Name = "HeaderText",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 0,
									Size = UDim2.fromScale(1, 0.0644),
									Text = "LOADOUT",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 32,
									TextWrapped = true,
									TextXAlignment = Enum.TextXAlignment.Right,
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
								Id = "U_Slots",
								Props = {
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 1,
									Position = UDim2.fromScale(0, 0.0787),
									Size = UDim2.fromScale(1, 0.6726),
									ZIndex = 2,
								},
								Children = {
									{
										Primitive = "UIListLayout",
										Props = {
											Padding = UDim.new(0.0319, 0),
											SortOrder = Enum.SortOrder.LayoutOrder,
										},
									},
									{
										Primitive = "Frame",
										Id = "U_Row1",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 1,
											Size = UDim2.fromScale(1, 0.2261),
										},
										Children = {
											{
												Primitive = "UIListLayout",
												Props = {
													FillDirection = Enum.FillDirection.Horizontal,
													HorizontalAlignment = Enum.HorizontalAlignment.Right,
													SortOrder = Enum.SortOrder.LayoutOrder,
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Id = "U_Row2",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 2,
											Size = UDim2.fromScale(1, 0.2261),
										},
										Children = {
											{
												Primitive = "UIListLayout",
												Props = {
													FillDirection = Enum.FillDirection.Horizontal,
													HorizontalAlignment = Enum.HorizontalAlignment.Right,
													SortOrder = Enum.SortOrder.LayoutOrder,
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Id = "U_Row3",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 3,
											Size = UDim2.fromScale(1, 0.2261),
										},
										Children = {
											{
												Primitive = "UIListLayout",
												Props = {
													FillDirection = Enum.FillDirection.Horizontal,
													HorizontalAlignment = Enum.HorizontalAlignment.Right,
													SortOrder = Enum.SortOrder.LayoutOrder,
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Id = "U_Row4",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 4,
											Size = UDim2.fromScale(1, 0.2261),
										},
										Children = {
											{
												Primitive = "UIListLayout",
												Props = {
													FillDirection = Enum.FillDirection.Horizontal,
													HorizontalAlignment = Enum.HorizontalAlignment.Right,
													SortOrder = Enum.SortOrder.LayoutOrder,
												},
											},
										},
									},
								},
							},
							{
								Primitive = "Frame",
								Id = "U_EmoteSection",
								Props = {
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 2,
									Position = UDim2.fromScale(0, 0.7764),
									Size = UDim2.fromScale(1, 0.2236),
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
											Size = UDim2.fromScale(1, 0.288),
											Text = "EMOTES",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											TextSize = 32,
											TextWrapped = true,
											TextXAlignment = Enum.TextXAlignment.Right,
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
										Id = "U_Emotes",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 0,
											Position = UDim2.fromScale(0, 0.32),
											Size = UDim2.fromScale(1, 0.68),
											ZIndex = 2,
										},
										Children = {
											{
												Primitive = "UIListLayout",
												Props = {
													FillDirection = Enum.FillDirection.Horizontal,
													HorizontalAlignment = Enum.HorizontalAlignment.Right,
													VerticalAlignment = Enum.VerticalAlignment.Center,
													SortOrder = Enum.SortOrder.LayoutOrder,
												},
											},
											{
												Primitive = "ImageButton",
												Id = "S_Shop",
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 999,
													Size = UDim2.fromScale(1, 0.92),
													ZIndex = 3,
												},
												Attributes = {
													HoverSound_SoundGroup = "UI",
													ClickSound_PitchMax = 1,
													Utils_ClickScale = 0.92,
													Utils_HoverScale = 1.04,
													Interact_Arg1 = "EmoteShop",
													HoverSound_PitchMax = 1,
													Interact_Function = "Toggle",
													Utils_ScaleAnimation = "Bouncy",
													HoverSound_Name = "Button_Hover",
													Interact_ModuleName = "WidgetManager",
													ClickSound_Volume = 1,
													HoverSound_Volume = 1,
													HoverSound_TimePosition = 0,
													ClickSound_TimePosition = 0,
													ClickSound_PlaybackSpeed = 1,
													HoverSound_PitchMin = 1,
													HoverSound_PlaybackSpeed = 1,
													ClickSound_SoundGroup = "UI",
													ClickSound_PitchMin = 1,
													ClickSound_Name = "Button_Click",
												},
												Tags = {
													["Interact_Button"] = {},
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
																Attributes = {
																	_ImageName = "1050_120__LobbyInventory__Main_gray",
																},
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
																Attributes = {
																	_ImageName = "1050_120__LobbyInventory__Main_gray",
																},
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
																Attributes = {
																	_ImageName = "1050_120__LobbyInventory__Main_gray",
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
																	Size = UDim2.fromScale(1.0067, 1),
																	ZIndex = 2,
																	Image = "rbxassetid://120228011865765",
																	ImageColor3 = Color3.fromRGB(25, 25, 35),
																	ScaleType = Enum.ScaleType.Fit,
																},
																Attributes = {
																	_ImageName = "1117_56__LobbyInventory__Stroke2_gray",
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
																	Position = UDim2.fromScale(0.0133, 0.0185),
																	Size = UDim2.fromScale(0.9735, 0.963),
																	ZIndex = 3,
																	Image = "rbxassetid://81979878629232",
																	ImageColor3 = Color3.fromRGB(61, 61, 61),
																	ScaleType = Enum.ScaleType.Fit,
																},
																Attributes = {
																	_ImageName = "1117_57__LobbyInventory__Stroke_gray",
																},
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
													-- Wave's icon (Emote_Wave's IconId), in the slot card's picture box
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Icon",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 2,
															Position = UDim2.fromScale(0.2333, 0.0918),
															Size = UDim2.fromScale(0.5333, 0.8163),
															ZIndex = 3,
															Image = "rbxassetid://132166182456244",
															ScaleType = Enum.ScaleType.Fit,
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
					--[[
						The look tab (the owner's pick, 2026-11-25): LOOK and a copy of the slot card per look (Normal, Shiny,
						Golden), left of the column beside the card it opened from; Loadout clones the cards into S_Cards
						(Look_CardSize: a slot card's size there), tags the worn one EQUIPPED in the picker's equipped green
						(Look_WornTag) and moves the tab down to that card's row
					]]
					{
						Primitive = "Frame",
						Id = "U_Looks",
						Props = {
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 3,
							Position = UDim2.fromScale(-0.03, 0),
							Size = UDim2.fromScale(1, 0.5778),
							Visible = false,
							ZIndex = 4,
						},
						Children = {
							{
								Primitive = "TextLabel",
								Props = {
									Name = "HeaderText",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 0,
									Size = UDim2.fromScale(1, 0.1115),
									Text = "LOOK",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 32,
									TextWrapped = true,
									TextXAlignment = Enum.TextXAlignment.Right,
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
								Id = "S_Cards",
								Props = {
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 1,
									Position = UDim2.fromScale(0, 0.1362),
									Size = UDim2.fromScale(1, 0.8638),
									ZIndex = 2,
								},
								Attributes = {
									Look_CardSize = UDim2.fromScale(0.5, 0.3048),
									Look_WornTag = ColorSequence.new(Color3.fromRGB(190, 255, 200), Color3.fromRGB(120, 255, 140)),
								},
								Children = {
									{
										Primitive = "UIListLayout",
										Props = {
											HorizontalAlignment = Enum.HorizontalAlignment.Right,
											Padding = UDim.new(0.043, 0),
											SortOrder = Enum.SortOrder.LayoutOrder,
										},
									},
								},
							},
						},
					},
					{
						Primitive = "UIAspectRatioConstraint",
						Props = {
							AspectRatio = 0.4651,
						},
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		["PREFAB | Slot"] = {
			Parent = "U_Row1",
			Primitive = "ImageButton",
			Props = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 0,
				Size = UDim2.fromScale(0.5, 1),
			},
			Attributes = {
				Look_Stroke2 = "rbxassetid://120228011865765",
				ClickSound_PitchMax = 1,
				Utils_ClickScale = 0.92,
				Look_Stroke = "rbxassetid://81979878629232",
				Utils_HoverScale = 1.04,
				HoverSound_PitchMax = 1,
				ClickSound_TimePosition = 0,
				Look_StrokeColor = Color3.fromRGB(130, 130, 130),
				Utils_ScaleAnimation = "Bouncy",
				HoverSound_Name = "Button_Hover",
				HoverSound_PitchMin = 1,
				Look_SelectedStrokeColor = Color3.fromRGB(255, 255, 255),
				ClickSound_Volume = 1,
				Look_SelectedStroke2 = "rbxassetid://84807110391560",
				HoverSound_PlaybackSpeed = 1,
				Look_SelectedStroke = "rbxassetid://137492693569058",
				HoverSound_TimePosition = 0,
				HoverSound_SoundGroup = "UI",
				ClickSound_PlaybackSpeed = 1,
				HoverSound_Volume = 1,
				ClickSound_PitchMin = 1,
				ClickSound_SoundGroup = "UI",
				Look_EmptyStrokeColor = Color3.fromRGB(61, 61, 61),
				ClickSound_Name = "Button_Click",
				Look_ShinyTag = ColorSequence.new(Color3.fromRGB(255, 205, 245), Color3.fromRGB(230, 130, 215)),
				Look_GoldenTag = ColorSequence.new(Color3.fromRGB(255, 224, 102), Color3.fromRGB(255, 181, 31)),
				Look_PriceGap = 0.15,
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
							Attributes = {
								_ImageName = "1050_120__LobbyInventory__Main_gray",
							},
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
							Attributes = {
								_ImageName = "1050_120__LobbyInventory__Main_gray",
							},
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
							Attributes = {
								_ImageName = "1050_120__LobbyInventory__Main_gray",
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
								Size = UDim2.fromScale(1.0067, 1),
								ZIndex = 2,
								Image = "rbxassetid://120228011865765",
								ImageColor3 = Color3.fromRGB(25, 25, 35),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = {
								_ImageName = "1117_56__LobbyInventory__Stroke2_gray",
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
								Position = UDim2.fromScale(0.0133, 0.0185),
								Size = UDim2.fromScale(0.9735, 0.963),
								ZIndex = 3,
								Image = "rbxassetid://81979878629232",
								ImageColor3 = Color3.fromRGB(130, 130, 130),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = {
								_ImageName = "1117_57__LobbyInventory__Stroke_gray",
							},
						},
						{
							Primitive = "Frame",
							Id = "S_Foil",
							Props = {
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 3,
								Size = UDim2.fromScale(1, 1),
								Visible = false,
								ZIndex = 4,
							},
							Children = {
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "Holo",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 0,
										Position = UDim2.fromScale(0.003, 0.0463),
										Size = UDim2.fromScale(0.9941, 0.9074),
										Image = "rbxassetid://91511289193689",
										ImageTransparency = 0.55,
										ScaleType = Enum.ScaleType.Fit,
									},
									Children = {
										{
											Primitive = "UIGradient",
											Props = {
												Color = ColorSequence.new({
													ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 220)),
													ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 235, 150)),
													ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 255, 220)),
													ColorSequenceKeypoint.new(0.75, Color3.fromRGB(140, 190, 255)),
													ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 150, 255)),
												}),
												Rotation = 35,
											},
											Tags = { ["Utils_UIGradientMove"] = { Utils_MoveSpeed = 0.25 } },
										},
									},
								},
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "Sheen",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 1,
										Position = UDim2.fromScale(0.003, 0.0463),
										Size = UDim2.fromScale(0.9941, 0.9074),
										ZIndex = 2,
										Image = "rbxassetid://91511289193689",
										ImageTransparency = 0.25,
										ScaleType = Enum.ScaleType.Fit,
									},
									Children = {
										{
											Primitive = "UIGradient",
											Props = {
												Rotation = 25,
												Transparency = NumberSequence.new({
													NumberSequenceKeypoint.new(0, 1),
													NumberSequenceKeypoint.new(0.38, 1),
													NumberSequenceKeypoint.new(0.5, 0.1),
													NumberSequenceKeypoint.new(0.62, 1),
													NumberSequenceKeypoint.new(1, 1),
												}),
											},
											Tags = { ["Utils_Motion"] = { Utils_MotionKind = "Sweep", Utils_MotionSpeed = 1 } },
										},
									},
								},
								{
									Primitive = "Frame",
									Props = {
										Name = "Sparkle",
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = 1,
										LayoutOrder = 2,
										Position = UDim2.fromScale(0.12, 0.56),
										Size = UDim2.fromScale(0.16, 0.16),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										ZIndex = 3,
									},
									Tags = { ["Utils_Motion"] = { Utils_MotionKind = "Twinkle", Utils_MotionSpeed = 1.3 } },
									Children = {
										{
											Primitive = "Frame",
											Props = {
												Name = "Across",
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundColor3 = Color3.fromRGB(255, 235, 250),
												BorderSizePixel = 0,
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(1, 0.16),
											},
											Children = {
												{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
												{
													Primitive = "UIGradient",
													Props = { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) },
												},
											},
										},
										{
											Primitive = "Frame",
											Props = {
												Name = "Down",
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundColor3 = Color3.fromRGB(255, 235, 250),
												BorderSizePixel = 0,
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(0.16, 1),
											},
											Children = {
												{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
												{
													Primitive = "UIGradient",
													Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) },
												},
											},
										},
									},
								},
								{
									Primitive = "Frame",
									Props = {
										Name = "Sparkle",
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = 1,
										LayoutOrder = 3,
										Position = UDim2.fromScale(0.88, 0.62),
										Size = UDim2.fromScale(0.12, 0.12),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										ZIndex = 3,
									},
									Tags = { ["Utils_Motion"] = { Utils_MotionKind = "Twinkle", Utils_MotionSpeed = 0.9 } },
									Children = {
										{
											Primitive = "Frame",
											Props = {
												Name = "Across",
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundColor3 = Color3.fromRGB(220, 245, 255),
												BorderSizePixel = 0,
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(1, 0.16),
											},
											Children = {
												{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
												{
													Primitive = "UIGradient",
													Props = { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) },
												},
											},
										},
										{
											Primitive = "Frame",
											Props = {
												Name = "Down",
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundColor3 = Color3.fromRGB(220, 245, 255),
												BorderSizePixel = 0,
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(0.16, 1),
											},
											Children = {
												{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
												{
													Primitive = "UIGradient",
													Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) },
												},
											},
										},
									},
								},
							},
						},
						{
							Primitive = "Frame",
							Id = "S_Gold",
							Props = {
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 4,
								Size = UDim2.fromScale(1, 1),
								Visible = false,
								ZIndex = 4,
							},
							Children = {
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "Wash",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 0,
										Position = UDim2.fromScale(0.003, 0.0463),
										Size = UDim2.fromScale(0.9941, 0.9074),
										Image = "rbxassetid://91511289193689",
										ImageColor3 = Color3.fromRGB(255, 196, 60),
										ImageTransparency = 0.8,
										ScaleType = Enum.ScaleType.Fit,
									},
								},
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "Sheen",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										LayoutOrder = 1,
										Position = UDim2.fromScale(0.003, 0.0463),
										Size = UDim2.fromScale(0.9941, 0.9074),
										ZIndex = 2,
										Image = "rbxassetid://91511289193689",
										ImageColor3 = Color3.fromRGB(255, 240, 190),
										ImageTransparency = 0.35,
										ScaleType = Enum.ScaleType.Fit,
									},
									Children = {
										{
											Primitive = "UIGradient",
											Props = {
												Rotation = 25,
												Transparency = NumberSequence.new({
													NumberSequenceKeypoint.new(0, 1),
													NumberSequenceKeypoint.new(0.38, 1),
													NumberSequenceKeypoint.new(0.5, 0.1),
													NumberSequenceKeypoint.new(0.62, 1),
													NumberSequenceKeypoint.new(1, 1),
												}),
											},
											Tags = { ["Utils_Motion"] = { Utils_MotionKind = "Sweep", Utils_MotionSpeed = 1 } },
										},
									},
								},
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "Rim",
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										ClipsDescendants = true,
										LayoutOrder = 2,
										Position = UDim2.fromScale(0.0133, 0.0185),
										Size = UDim2.fromScale(0.9735, 0.963),
										ZIndex = 3,
										Image = "rbxassetid://81979878629232",
										ScaleType = Enum.ScaleType.Fit,
									},
									Children = {
										{
											Primitive = "UIGradient",
											Props = {
												Color = ColorSequence.new({
													ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 110, 20)),
													ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 200, 60)),
													ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 240, 170)),
													ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 200, 60)),
													ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 110, 20)),
												}),
												Rotation = 45,
											},
											Tags = { ["Utils_Motion"] = { Utils_MotionKind = "Glint", Utils_MotionSpeed = 1 } },
										},
									},
								},
								{
									Primitive = "Frame",
									Props = {
										Name = "Sparkle",
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = 1,
										LayoutOrder = 3,
										Position = UDim2.fromScale(0.12, 0.56),
										Size = UDim2.fromScale(0.18, 0.18),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										ZIndex = 4,
									},
									Tags = { ["Utils_Motion"] = { Utils_MotionKind = "Twinkle", Utils_MotionSpeed = 1.3 } },
									Children = {
										{
											Primitive = "Frame",
											Props = {
												Name = "Across",
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundColor3 = Color3.fromRGB(255, 236, 160),
												BorderSizePixel = 0,
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(1, 0.16),
											},
											Children = {
												{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
												{
													Primitive = "UIGradient",
													Props = { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) },
												},
											},
										},
										{
											Primitive = "Frame",
											Props = {
												Name = "Down",
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundColor3 = Color3.fromRGB(255, 236, 160),
												BorderSizePixel = 0,
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(0.16, 1),
											},
											Children = {
												{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
												{
													Primitive = "UIGradient",
													Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) },
												},
											},
										},
									},
								},
								{
									Primitive = "Frame",
									Props = {
										Name = "Sparkle",
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = 1,
										LayoutOrder = 4,
										Position = UDim2.fromScale(0.88, 0.62),
										Size = UDim2.fromScale(0.14, 0.14),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										ZIndex = 4,
									},
									Tags = { ["Utils_Motion"] = { Utils_MotionKind = "Twinkle", Utils_MotionSpeed = 0.9 } },
									Children = {
										{
											Primitive = "Frame",
											Props = {
												Name = "Across",
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundColor3 = Color3.fromRGB(255, 250, 220),
												BorderSizePixel = 0,
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(1, 0.16),
											},
											Children = {
												{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
												{
													Primitive = "UIGradient",
													Props = { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) },
												},
											},
										},
										{
											Primitive = "Frame",
											Props = {
												Name = "Down",
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundColor3 = Color3.fromRGB(255, 250, 220),
												BorderSizePixel = 0,
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(0.16, 1),
											},
											Children = {
												{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
												{
													Primitive = "UIGradient",
													Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) },
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
					Primitive = "ImageLabel",
					Id = "S_Icon",
					Props = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ClipsDescendants = true,
						AnchorPoint = Vector2.new(0.5, 0.5),
						LayoutOrder = 1,
						Position = UDim2.fromScale(0.52, 0.45),
						Size = UDim2.fromScale(0.5, 0.48),
						ZIndex = 2,
						Image = "rbxassetid://125272685999061",
						ScaleType = Enum.ScaleType.Fit,
					},
					Attributes = {
						_ImageName = "1055_9__LobbyInventory__Icon_image",
					},
				},
				-- The slot's key, in the control hints' key cap (the owner, 2026-11-25: every text in its own place and style)
				{
					Primitive = "TextLabel",
					Id = "S_Number",
					Props = {
						BackgroundColor3 = Color3.fromRGB(25, 25, 35),
						BackgroundTransparency = 0.1,
						BorderSizePixel = 0,
						LayoutOrder = 2,
						Position = UDim2.fromScale(0.115, 0.1),
						Size = UDim2.fromScale(0.25, 0.25),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						ZIndex = 6,
						Text = "1",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 25,
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
						RichText = true,
						TextScaled = true,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.25, 0) } },
						{
							Primitive = "UIStroke",
							Tags = { Utils_UIStroke = {} },
							Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(130, 130, 130), Thickness = 2 },
						},
						{
							Primitive = "UIPadding",
							Props = {
								PaddingTop = UDim.new(0.19, 0),
								PaddingBottom = UDim.new(0.19, 0),
								PaddingLeft = UDim.new(0.1, 0),
								PaddingRight = UDim.new(0.1, 0),
							},
						},
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
					},
				},
				-- How many copies the player owns, a quiet count in a dark pill (10 make it Shiny, 100 Golden)
				{
					Primitive = "TextLabel",
					Id = "S_Amount",
					Props = {
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(13, 13, 20),
						BackgroundTransparency = 0.35,
						BorderSizePixel = 0,
						LayoutOrder = 3,
						Position = UDim2.fromScale(0.905, 0.1),
						Size = UDim2.fromScale(0.3, 0.24),
						ZIndex = 6,
						Text = "x5",
						TextColor3 = Color3.fromRGB(220, 220, 228),
						TextSize = 18,
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
						RichText = true,
						TextScaled = true,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
						{
							Primitive = "UIPadding",
							Props = {
								PaddingTop = UDim.new(0.12, 0),
								PaddingBottom = UDim.new(0.12, 0),
								PaddingLeft = UDim.new(0.12, 0),
								PaddingRight = UDim.new(0.12, 0),
							},
						},
						{
							Primitive = "UIStroke",
							Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
						},
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Name",
					Props = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0.5, 1),
						LayoutOrder = 4,
						Position = UDim2.fromScale(0.48, 0.95),
						Size = UDim2.fromScale(0.8, 0.27),
						ZIndex = 5,
						Text = "Grenade",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 18,
						TextWrapped = false,
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
						RichText = true,
						TextScaled = true,
					},
					Children = {
						{
							Primitive = "UIStroke",
							Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
						},
					},
				},
				{
					Primitive = "UIAspectRatioConstraint",
					Props = {
						AspectRatio = 1.5306,
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Plus",
					Props = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 2,
						Position = UDim2.fromScale(0.3662, 0.1939),
						Size = UDim2.fromScale(0.2667, 0.602),
						Visible = false,
						ZIndex = 3,
						Text = "+",
						TextColor3 = Color3.fromRGB(154, 154, 154),
						TextSize = 50,
						TextWrapped = true,
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
						RichText = true,
						TextScaled = true,
					},
				},
				--[[
					SHINY or GOLDEN, on a tag across the card's top edge in the variant's colours (the reward card's NEXT tag, the
					crate card's BEST tag), set by code from Look_ShinyTag and Look_GoldenTag
				]]
				{
					Primitive = "Frame",
					Id = "S_Shiny",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						LayoutOrder = 3,
						Position = UDim2.fromScale(0.56, 0.02),
						Rotation = -4,
						Size = UDim2.fromScale(0.42, 0.19),
						Visible = false,
						ZIndex = 7,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.3, 0) } },
						{
							Primitive = "UIStroke",
							Tags = { Utils_UIStroke = {} },
							Props = { Color = Color3.fromRGB(20, 20, 28), Thickness = 3 },
						},
						{
							Primitive = "UIGradient",
							Id = "S_ShinyGradient",
							Props = {
								Color = ColorSequence.new(Color3.fromRGB(255, 205, 245), Color3.fromRGB(230, 130, 215)),
								Rotation = 90,
							},
						},
						{
							Primitive = "TextLabel",
							Id = "S_ShinyText",
							Tags = { TextCase_Upper = {} },
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(0.84, 0.74),
								ZIndex = 8,
								Text = "Shiny",
								TextColor3 = Color3.fromRGB(255, 255, 255),
								FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
								RichText = true,
								TextScaled = true,
							},
							Children = {
								{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
								{
									Primitive = "UIStroke",
									Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
								},
							},
						},
					},
				},
				{
					Primitive = "Frame",
					Id = "S_Lock",
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
								Name = "LockIcon",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								ClipsDescendants = true,
								AnchorPoint = Vector2.new(0.5, 0.5),
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.5, 0.34),
								Size = UDim2.fromScale(0.22, 0.34),
								ZIndex = 3,
								Image = "rbxassetid://131803930638166",
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = { _ImageName = "1055_97__LobbyInventory__LockIcon_image" },
						},
						{
							Primitive = "TextLabel",
							Id = "S_Price",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 3,
								Position = UDim2.fromScale(0.5, 0.72),
								Size = UDim2.fromScale(0.9, 0.28),
								ZIndex = 5,
								Text = "2,500",
								FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextSize = 18,
								TextScaled = true,
								TextWrapped = false,
								RichText = true,
								TextXAlignment = Enum.TextXAlignment.Center,
							},
							Children = {
								{
									Primitive = "UIStroke",
									Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
								},
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "CurrencyIcon",
										AnchorPoint = Vector2.new(1, 0.5),
										BackgroundTransparency = 1,
										LayoutOrder = 0,
										Position = UDim2.new(0.5, -24, 0.5, 0),
										Size = UDim2.fromScale(1, 1),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										ZIndex = 5,
										Image = "rbxassetid://98200575516825",
										ScaleType = Enum.ScaleType.Fit,
									},
								},
							},
						},
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "Main",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
								Image = "rbxassetid://91511289193689",
								ImageColor3 = Color3.fromRGB(0, 0, 0),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = { _ImageName = "1050_120__LobbyInventory__Main_gray" },
						},
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "Stroke",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								ClipsDescendants = true,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
								ZIndex = 3,
								Image = "rbxassetid://81979878629232",
								ImageColor3 = Color3.fromRGB(39, 39, 39),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = { _ImageName = "1117_57__LobbyInventory__Stroke_gray" },
						},
					},
				},
			},
		},
	},
}

return _gui
