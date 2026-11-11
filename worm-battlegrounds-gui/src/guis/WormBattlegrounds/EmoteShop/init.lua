--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		The EMOTES panel, ported 1:1 from the gui maker's Emotes design (2026-11-11, the Customise design's cards):
		a full-screen WidgetManager widget whose panel stands on the right. Cosmetics draws it on WidgetManager_Opened as
		I.UserInterface.UI["EmoteShop"]
	]]
	Name = "EmoteShop",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			{
				Primitive = "Frame",
				Id = "U_Widget",
				Props = {
					LayoutOrder = 0,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
				},
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
							-- The panel: the EMOTES title, a close (B on a pad), and three cards across (U_Emotes)
							{
								Primitive = "Frame",
								Props = {
									Name = "Right",
									AnchorPoint = Vector2.new(1, 0.5),
									BackgroundTransparency = 1,
									LayoutOrder = 0,
									Position = UDim2.fromScale(0.8906, 0.4898),
									Size = UDim2.fromScale(0.2365, 0.5014),
								},
								Children = {
									{
										Primitive = "ScrollingFrame",
										Props = {
											Name = "Items",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 0,
											Position = UDim2.fromScale(0, 0.169),
											Size = UDim2.fromScale(1, 0.831),
											CanvasSize = UDim2.fromScale(0, 0),
											AutomaticCanvasSize = Enum.AutomaticSize.Y,
											ScrollBarThickness = 0,
											ScrollingDirection = Enum.ScrollingDirection.Y,
											ScrollBarImageTransparency = 0.5,
										},
										Attributes = {
											_ScrollAutoLayoutNormalized = true,
											_UseCanvasHeight = true,
											_UseCanvasWidth = false,
										},
										Children = {
											{
												Primitive = "UIPadding",
												Props = {
													PaddingLeft = UDim.new(0.0154, 0),
													PaddingRight = UDim.new(0.0154, 0),
												},
											},
											{
												Primitive = "Frame",
												Id = "U_Emotes",
												Props = {
													AutomaticSize = Enum.AutomaticSize.Y,
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 2,
													Size = UDim2.fromScale(1, 0),
												},
												Children = {
													{
														Primitive = "UIGridLayout",
														Props = {
															CellSize = UDim2.new(0.3409, 0, 0, 100000),
															CellPadding = UDim2.fromScale(-0.012, 0),
															FillDirectionMaxCells = 3,
															HorizontalAlignment = Enum.HorizontalAlignment.Center,
															SortOrder = Enum.SortOrder.LayoutOrder,
														},
														Children = {
															{
																Primitive = "UIAspectRatioConstraint",
																Props = { AspectRatio = 1.0625 },
															},
														},
													},
												},
											},
											{
												Primitive = "UIListLayout",
												Props = {
													HorizontalAlignment = Enum.HorizontalAlignment.Center,
													SortOrder = Enum.SortOrder.LayoutOrder,
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "TopGap",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 1,
													Size = UDim2.new(1, 0, 0, 100000),
												},
												Children = {
													{
														Primitive = "UIAspectRatioConstraint",
														Props = { AspectRatio = 55 },
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "BottomTail",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 3,
													Size = UDim2.new(1, 0, 0, 100000),
												},
												Children = {
													{
														Primitive = "UIAspectRatioConstraint",
														Props = { AspectRatio = 11 },
													},
												},
											},
										},
									},
									{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.8385 } },
									{
										Primitive = "Frame",
										Props = {
											Name = "Title",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 0,
											Position = UDim2.fromScale(0.0923, 0),
											Size = UDim2.fromScale(0.5023, 0.1468),
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
															Position = UDim2.fromScale(0.0033, 0.0472),
															Size = UDim2.fromScale(0.9933, 0.9057),
															Image = "rbxassetid://112977595313916",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1001_35__Customise__Main_gray" },
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
															Image = "rbxassetid://84001867536175",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = {
															_ImageName = "1122_117__Customise__Stroke2_gray",
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
															Position = UDim2.fromScale(0.0066, 0.0189),
															Size = UDim2.fromScale(0.9868, 0.9623),
															ZIndex = 3,
															Image = "rbxassetid://87357826700501",
															ImageColor3 = Color3.fromRGB(130, 130, 130),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1122_118__Customise__Stroke_gray" },
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Mask",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = true,
															LayoutOrder = 3,
															Position = UDim2.fromScale(0.0033, 0.0472),
															Size = UDim2.fromScale(0.9933, 0.9057),
															ZIndex = 4,
															Image = "rbxassetid://105330948323225",
														},
														Attributes = { _ImageName = "1015_2__Customise__Mask_image" },
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
													Position = UDim2.fromScale(0.1005, 0.2354),
													Size = UDim2.fromScale(0.7929, 0.5404),
													ZIndex = 2,
													Text = "EMOTES",
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextSize = 56,
													TextScaled = true,
													TextWrapped = true,
													RichText = true,
												},
												Tags = { ["TextCase_Upper"] = {} },
												Children = {
													{
														Primitive = "UIStroke",
														Props = {
															Thickness = 0.0714,
															StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
														},
													},
													{ Primitive = "UIPadding" },
												},
											},
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 2.8698 } },
										},
									},
									-- The design has no close: the Party card's red kick button, closing through WidgetManager
									{
										Primitive = "ImageButton",
										Id = "S_Close",
										Props = {
											AnchorPoint = Vector2.new(1, 0),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 2,
											Position = UDim2.fromScale(0.985, 0.02),
											Size = UDim2.fromScale(0.133, 0.1),
											ZIndex = 6,
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
											Interact_Button = {
												Interact_ModuleName = "WidgetManager",
												Interact_Function = "CloseCurrent",
											},
											Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" },
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
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextSize = 34,
													TextScaled = true,
													TextWrapped = true,
													RichText = true,
												},
												Children = {
													{
														Primitive = "UIStroke",
														Props = {
															Thickness = 0.0882,
															StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
														},
													},
													{ Primitive = "UIPadding" },
												},
											},
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.1148 } },
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
					LayoutOrder = 0,
					Name = "MouseLockFix",
					BackgroundTransparency = 1,
					Modal = true,
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		--[[
			An emote's card (the design's): its rarity badge, icon and name; while it isn't owned, the Skins tile's
			locked cover with its price in coins and the level it needs. A press buys it
		]]
		["PREFAB | EmoteCard"] = {
			Parent = "U_Emotes",
			Primitive = "ImageButton",
			Props = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 0,
				Size = UDim2.new(0.2058, 0, 0, 132),
				ImageTransparency = 1,
				AutoButtonColor = false,
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
					Id = "S_Locked",
					Props = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 4,
						Position = UDim2.fromScale(-0.0026, -0.0379),
						Size = UDim2.fromScale(1.0053, 1.0758),
						Visible = false,
						ZIndex = 5,
					},
					Children = {
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "Locked",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.0026, 0.0352),
								Size = UDim2.fromScale(0.9948, 0.9296),
								Image = "rbxassetid://95813647474691",
								ImageColor3 = Color3.fromRGB(0, 0, 0),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = { _ImageName = "998_558__Customise__Locked_gray" },
						},
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "LockedStroke",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 1,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 2,
								Image = "rbxassetid://70604777404258",
								ImageColor3 = Color3.fromRGB(0, 0, 0),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = { _ImageName = "1122_38__Customise__LockedStroke_gray" },
						},
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "LockIcon",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.4041, 0.2254),
								Size = UDim2.fromScale(0.2392, 0.3239),
								ZIndex = 3,
								Image = "rbxassetid://122622598084740",
							},
							Attributes = { _ImageName = "998_562__Customise__LockIcon_image" },
						},
						{
							Primitive = "TextLabel",
							Id = "S_Price",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.58, 0.56),
								Size = UDim2.fromScale(0.5, 0.16),
								ZIndex = 4,
								Text = "500",
								FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextSize = 24,
								TextScaled = true,
								TextWrapped = true,
								RichText = true,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							Children = {
								{
									Primitive = "UIStroke",
									Props = { Thickness = 0.125, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
								},
								{
									Primitive = "ImageLabel",
									Props = {
										Name = "CurrencyIcon",
										AnchorPoint = Vector2.new(1, 0.5),
										BackgroundTransparency = 1,
										LayoutOrder = 0,
										Position = UDim2.fromScale(-0.04, 0.5),
										Size = UDim2.fromScale(1.3, 1.3),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										ZIndex = 4,
										Image = "rbxassetid://111931430831562",
										ScaleType = Enum.ScaleType.Fit,
									},
								},
							},
						},
						{
							Primitive = "TextLabel",
							Id = "S_Level",
							Props = {
								AnchorPoint = Vector2.new(1, 0),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.95, 0.075),
								Size = UDim2.fromScale(0.52, 0.12),
								ZIndex = 4,
								Text = "Level 10",
								FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
								TextColor3 = Color3.fromRGB(255, 196, 0),
								TextSize = 20,
								TextScaled = true,
								TextWrapped = true,
								RichText = true,
								TextXAlignment = Enum.TextXAlignment.Right,
							},
							Tags = { ["TextCase_Upper"] = {} },
							Children = {
								{
									Primitive = "UIStroke",
									Props = { Thickness = 0.125, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
								},
							},
						},
					},
				},
				{
					Primitive = "Frame",
					Props = {
						Name = "Background",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 0,
						Position = UDim2.fromScale(-0.0026, -0.0379),
						Size = UDim2.fromScale(1.0053, 1.0758),
					},
					Children = {
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "Main",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 0,
								Position = UDim2.fromScale(0.0026, 0.0352),
								Size = UDim2.fromScale(0.9948, 0.9296),
								Image = "rbxassetid://90549993291211",
								ImageColor3 = Color3.fromRGB(25, 25, 35),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = { _ImageName = "998_62__Customise__Main_gray" },
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
								Image = "rbxassetid://96937182308528",
								ImageColor3 = Color3.fromRGB(25, 25, 35),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = { _ImageName = "1122_2__Customise__Stroke2_gray" },
						},
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "Stroke",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								ClipsDescendants = true,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.0117, 0.0141),
								Size = UDim2.fromScale(0.9766, 0.9718),
								ZIndex = 3,
								Image = "rbxassetid://88353524985200",
								ImageColor3 = Color3.fromRGB(130, 130, 130),
								ScaleType = Enum.ScaleType.Fit,
							},
							Attributes = { _ImageName = "1122_3__Customise__Stroke_gray" },
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
						Position = UDim2.fromScale(0.1886, 0.0455),
						Size = UDim2.fromScale(0.2123, 0.1818),
						ZIndex = 2,
						Image = "rbxassetid://85551024067701",
						ImageColor3 = Color3.fromRGB(68, 141, 224),
						ScaleType = Enum.ScaleType.Fit,
					},
					Attributes = { _ImageName = "1074_89__Customise__Rarity_gray" },
				},
				{
					Primitive = "ImageLabel",
					Id = "S_Icon",
					Props = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ClipsDescendants = true,
						LayoutOrder = 2,
						Position = UDim2.fromScale(0.2768, 0.0606),
						Size = UDim2.fromScale(0.4941, 0.6364),
						ZIndex = 3,
						Image = "rbxassetid://139377864778126",
					},
					Attributes = { _ImageName = "998_65__Customise__Icon_image" },
				},
				{
					Primitive = "TextLabel",
					Id = "S_Name",
					Props = {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 3,
						Position = UDim2.fromScale(0.0528, 0.7424),
						Size = UDim2.fromScale(0.7647, 0.1742),
						ZIndex = 6,
						Text = "Dance",
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 19,
						TextScaled = true,
						TextWrapped = true,
						RichText = true,
					},
					Children = { { Primitive = "UIPadding" } },
				},
				{ Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0.175, 0) } },
			},
		},
	},
}

return _gui
