--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: ume's BackpackPlus module finds it as I.UserInterface.UI["BackpackPlus"]
	Name = "BackpackPlus",
	-- Under the game's other guis, shown from the start (PreventHiding)
	Screen = { DisplayOrder = -1, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },
	ScreenTags = { UserInterface_PreventHiding = {} },

	--[[ Tree ]]

	-- The backpack view and the toolbar under it. Plain instances that hold every value themselves, so no theme
	-- changes them: the look every BackpackPlus-style gui shares is a dark gradient fill, a 3 px black outline and a
	-- half-white highlight fading down from the top edge, with heavy white text outlined in black. Corners are 8 px at
	-- 1080p, as a scale of each element's shorter side (0.02 on the panel, 0.1 on the categories and slots), so they keep
	-- that look at every screen size
	Root = {
		Primitive = "Folder",
		Children = {
			-- The backpack view, hidden until BackpackPlus opens it: every tool the player holds, with a search and filters
			{
				Primitive = "Frame",
				Id = "U_Backpack",
				Visible = false,
				Props = { AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.875), Size = UDim2.fromScale(0.5, 1) },
				Children = {
					{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 2.25 } },
					-- The backpack's contents, along its bottom edge: the backpack's own shape on Desktop, 1.2 times taller on Mobile
					-- (Utils_PlatformSize), where six tools to a row would otherwise leave less than two rows in view
					{
						Primitive = "Frame",
						Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromScale(1, 1.2) } },
						Props = { Name = "Body", AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(1, 1) },
						Children = {
							-- The search bar on the right and the favourite mode button on the left, a little taller on Mobile
							{
								Primitive = "Frame",
								Tags = {
									Utils_PlatformSize = { Utils_MobileSize = UDim2.new(1, -24, 0.11, 0) },
								},
								Props = { Name = "Top", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 12), Size = UDim2.new(1, -24, 0.07, 0), ZIndex = 2 },
								Children = {
									{
										Primitive = "Frame",
										Id = "S_SearchBarContainer",
										Props = { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 6.5 } },
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
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
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
																Props = {
																	Rotation = 90,
																	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.9003, 1), NumberSequenceKeypoint.new(1, 1) }),
																},
															},
														},
													},
													{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
													{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.5) } },
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Content",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(1, 0.8),
													ZIndex = 2,
												},
												Children = {
													-- Clear of the pill's round ends: the text starts past the left curve, the icon ends before the right
													{ Primitive = "UIPadding", Props = { PaddingLeft = UDim.new(0.06, 0), PaddingRight = UDim.new(0.04, 0) } },
													-- Filters the items by name as the player types; takes the width the icon leaves
													{
														Primitive = "TextBox",
														Id = "S_SearchBar",
														Props = {
															BackgroundTransparency = 1,
															FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold),
															LayoutOrder = 1,
															PlaceholderColor3 = Color3.fromRGB(128, 128, 128),
															PlaceholderText = "...",
															RichText = true,
															Size = UDim2.fromScale(0, 0.9),
															Text = "",
															TextColor3 = Color3.fromRGB(255, 255, 255),
															TextScaled = true,
															TextWrapped = true,
															TextXAlignment = Enum.TextXAlignment.Left,
														},
														Children = {
															{ Primitive = "UIFlexItem", Props = { FlexMode = Enum.UIFlexMode.Fill } },
															{ Primitive = "UIGradient", Props = { Rotation = -90 } },
														},
													},
													{
														Primitive = "Frame",
														Props = { Name = "SearchIconContainer", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromScale(1, 1) },
														Children = {
															{ Primitive = "UIAspectRatioConstraint" },
															{
																Primitive = "ImageLabel",
																Props = {
																	Name = "SearchIcon",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	Image = "rbxassetid://97113897838734",
																	Position = UDim2.fromScale(0.5, 0.5),
																	Size = UDim2.fromScale(0.8, 0.8),
																},
																Children = {
																	{ Primitive = "UIGradient", Props = { Rotation = -90 } },
																},
															},
														},
													},
													{
														Primitive = "UIListLayout",
														Props = {
															FillDirection = Enum.FillDirection.Horizontal,
															Padding = UDim.new(0.02, 0),
															SortOrder = Enum.SortOrder.LayoutOrder,
															VerticalAlignment = Enum.VerticalAlignment.Center,
														},
													},
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Id = "S_FavoriteButtonContainer",
										Props = { AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 5 } },
											-- Turns favourite mode on and off (the BackpackPlus_FavoriteButton component)
											{
												Primitive = "ImageButton",
												Id = "S_FavoriteButton",
												Tags = {
													BackpackPlus_FavoriteButton = {},
													Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
													Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
												},
												Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
												Children = {
													{
														Primitive = "Frame",
														Id = "S_Background",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
														},
														Children = {
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
																		Props = {
																			Rotation = 90,
																			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.9003, 1), NumberSequenceKeypoint.new(1, 1) }),
																		},
																	},
																},
															},
															{
																Primitive = "UIStroke",
																Tags = { Utils_UIStroke = {} },
																Props = { Thickness = 3 },
																Children = {
																	{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(255, 115, 0), Color3.fromRGB(255, 213, 0)), Rotation = -90 } },
																},
															},
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.5) } },
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "Content",
															AnchorPoint = Vector2.new(0.5, 0.55),
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 2,
														},
														Children = {
															{
																Primitive = "ImageLabel",
																Props = {
																	Name = "ButtonIcon",
																	BackgroundTransparency = 1,
																	Image = "rbxassetid://130403847148314",
																	LayoutOrder = 2,
																	Size = UDim2.fromScale(0.8, 0.8),
																	SizeConstraint = Enum.SizeConstraint.RelativeYY,
																	ZIndex = 2,
																},
															},
															{
																Primitive = "TextLabel",
																Props = {
																	Name = "ButtonText",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	AutomaticSize = Enum.AutomaticSize.X,
																	BackgroundTransparency = 1,
																	FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
																	LayoutOrder = 1,
																	Position = UDim2.fromScale(0.4, 0.5),
																	RichText = true,
																	Size = UDim2.fromScale(0, 0.85),
																	Text = "Favorite",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextScaled = true,
																	TextSize = 14,
																	TextWrapped = true,
																	ZIndex = 2,
																},
																Children = {
																	{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 2 } },
																},
															},
															{
																Primitive = "UIListLayout",
																Props = {
																	FillDirection = Enum.FillDirection.Horizontal,
																	HorizontalAlignment = Enum.HorizontalAlignment.Center,
																	Padding = UDim.new(0, 6),
																	SortOrder = Enum.SortOrder.LayoutOrder,
																	VerticalAlignment = Enum.VerticalAlignment.Center,
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
							-- The items: BackpackPlus clones a slot per tool into S_ItemsContainer. Under the top row on Mobile too
							{
								Primitive = "ScrollingFrame",
								Tags = {
									Utils_PlatformSize = { Utils_MobileSize = UDim2.fromScale(1, 0.82) },
								},
								Props = {
									Name = "ItemsScrollingFrame",
									Active = true,
									AnchorPoint = Vector2.new(0, 1),
									AutomaticCanvasSize = Enum.AutomaticSize.Y,
									BackgroundTransparency = 1,
									BottomImage = "rbxassetid://136098030643767",
									CanvasSize = UDim2.fromScale(0, 0),
									MidImage = "rbxassetid://136098030643767",
									Position = UDim2.fromScale(0, 1),
									ScrollBarImageTransparency = 0.4,
									ScrollBarThickness = 6,
									ScrollingDirection = Enum.ScrollingDirection.Y,
									Size = UDim2.fromScale(1, 0.88),
									TopImage = "rbxassetid://136098030643767",
									ZIndex = 2,
								},
								Children = {
									{
										Primitive = "Frame",
										Id = "S_ItemsContainer",
										Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 100) },
										Children = {
											{
												Primitive = "UIGridLayout",
												Id = "S_ItemsContainerGridLayout",
												Props = { CellPadding = UDim2.fromScale(0, 0), CellSize = UDim2.fromOffset(92, 92), SortOrder = Enum.SortOrder.LayoutOrder },
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "9999 | Padding",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											LayoutOrder = 9999,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromScale(0.02, 0.02),
										},
										Children = {
											{ Primitive = "UIAspectRatioConstraint" },
										},
									},
									{ Primitive = "UIListLayout", Props = { HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder } },
								},
							},
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.35) } },
									{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
									{
										Primitive = "UIStroke",
										Tags = { Utils_UIStroke = {} },
										Props = { Name = "UIStroke_Highlight", BorderStrokePosition = Enum.BorderStrokePosition.Inner, Color = Color3.fromRGB(255, 255, 255), Thickness = 3, Transparency = 0.5 },
										Children = {
											{
												Primitive = "UIGradient",
												Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.9003, 1), NumberSequenceKeypoint.new(1, 1) }) },
											},
										},
									},
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.02, 0) } },
								},
							},
							-- A modal button that frees the mouse from shift lock while the backpack is open
							{
								Primitive = "ImageButton",
								Props = { Name = "MouseLockFix", AutoButtonColor = false, BackgroundTransparency = 1, ImageTransparency = 1, Interactable = false, Modal = true, Selectable = false },
							},
							-- Category filters along the backpack's left side; each is a BackpackPlus_FilterButton that filters by its
							-- BackpackPlus_FilterCategory ("" shows every item)
							{
								Primitive = "Frame",
								Props = { Name = "CategoryButtonsContainer", AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.fromOffset(-10, 0), Size = UDim2.fromScale(1, 0.75) },
								Children = {
									{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.25 } },
									{
										Primitive = "Frame",
										Id = "U_Category-All",
										Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.85 } },
											-- D-pad up above the first category, on Console only (Console_Hint): with the backpack open it selects the
											-- category above. ume's Console module shows it and swaps it to the player's pad
											{
												Primitive = "ImageLabel",
												Id = "S_CategoryUpHint",
												Visible = false,
												Tags = { Console_Hint = {} },
												Props = {
													AnchorPoint = Vector2.new(0.5, 1),
													BackgroundTransparency = 1,
													Image = "rbxassetid://96798501786319",
													Position = UDim2.new(0.5, 0, 0, -6),
													Size = UDim2.fromScale(0.45, 0.45),
													ZIndex = 3,
												},
												Children = {
													{ Primitive = "UIAspectRatioConstraint" },
												},
											},
											{
												Primitive = "ImageButton",
												Tags = {
													BackpackPlus_FilterButton = { BackpackPlus_FilterCategory = "" },
													Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
													Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
												},
												Props = {
													Name = "CategoryButton",
													AnchorPoint = Vector2.new(0.5, 0.5),
													AutoButtonColor = false,
													BackgroundTransparency = 1,
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
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 2,
														},
														Children = {
															{
																Primitive = "TextLabel",
																Id = "S_ItemName",
																Props = {
																	AnchorPoint = Vector2.new(0.5, 0),
																	BackgroundTransparency = 1,
																	FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
																	Position = UDim2.fromScale(0.5, 0.025),
																	RichText = true,
																	Size = UDim2.fromScale(0.85, 0.275),
																	Text = "All",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextScaled = true,
																	TextWrapped = true,
																	TextXAlignment = Enum.TextXAlignment.Left,
																	ZIndex = 2,
																},
																Children = {
																	{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 2 } },
																},
															},
															{
																Primitive = "CanvasGroup",
																Props = {
																	Name = "IconContainer",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	Position = UDim2.fromScale(0.5, 0.5),
																	Size = UDim2.fromScale(1, 1),
																},
																Children = {
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "ButtonIcon",
																			AnchorPoint = Vector2.new(0.5, 0.5),
																			BackgroundTransparency = 1,
																			Image = "rbxassetid://100917525065819",
																			Position = UDim2.fromScale(0.65, 0.675),
																			Rotation = 3.5,
																			Size = UDim2.fromScale(1.15, 1.15),
																		},
																		Children = {
																			{ Primitive = "UIAspectRatioConstraint" },
																		},
																	},
																	{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
																},
															},
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "Highlight",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 3,
														},
														Children = {
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
																	{ Primitive = "UIGradient", Props = { Rotation = 90, Transparency = NumberSequence.new(0.5) } },
																},
															},
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
														},
													},
													{
														Primitive = "Frame",
														Id = "S_Background",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
														},
														Children = {
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.35) } },
															{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
														},
													},
												},
											},
										},
									},
									{
										Primitive = "UIListLayout",
										Props = { HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, VerticalFlex = Enum.UIFlexAlignment.Fill },
									},
									{
										Primitive = "Frame",
										Id = "U_Category-1",
										Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 2, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.85 } },
											{
												Primitive = "ImageButton",
												Tags = {
													BackpackPlus_FilterButton = { BackpackPlus_FilterCategory = "Category1" },
													Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
													Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
												},
												Props = {
													Name = "CategoryButton",
													AnchorPoint = Vector2.new(0.5, 0.5),
													AutoButtonColor = false,
													BackgroundTransparency = 1,
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
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 2,
														},
														Children = {
															{
																Primitive = "TextLabel",
																Id = "S_ItemName",
																Props = {
																	AnchorPoint = Vector2.new(0.5, 0),
																	BackgroundTransparency = 1,
																	FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
																	Position = UDim2.fromScale(0.5, 0.025),
																	RichText = true,
																	Size = UDim2.fromScale(0.85, 0.275),
																	Text = "Cat 1",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextScaled = true,
																	TextWrapped = true,
																	TextXAlignment = Enum.TextXAlignment.Left,
																	ZIndex = 2,
																},
																Children = {
																	{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 2 } },
																},
															},
															{
																Primitive = "CanvasGroup",
																Props = {
																	Name = "IconContainer",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	Position = UDim2.fromScale(0.5, 0.5),
																	Size = UDim2.fromScale(1, 1),
																},
																Children = {
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "ButtonIcon",
																			AnchorPoint = Vector2.new(0.5, 0.5),
																			BackgroundTransparency = 1,
																			Image = "rbxassetid://71577319225515",
																			Position = UDim2.fromScale(0.65, 0.675),
																			Rotation = 3.5,
																			Size = UDim2.fromScale(1.15, 1.15),
																		},
																		Children = {
																			{ Primitive = "UIAspectRatioConstraint" },
																		},
																	},
																	{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
																},
															},
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "Highlight",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 3,
														},
														Children = {
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
																	{ Primitive = "UIGradient", Props = { Rotation = 90, Transparency = NumberSequence.new(0.5) } },
																},
															},
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
														},
													},
													{
														Primitive = "Frame",
														Id = "S_Background",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
														},
														Children = {
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.35) } },
															{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
														},
													},
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Id = "U_Category-2",
										Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 3, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
										Children = {
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.85 } },
											-- D-pad down below the last category, on Console only: with the backpack open it selects the category below. A
											-- game that adds categories moves it to its last one
											{
												Primitive = "ImageLabel",
												Id = "S_CategoryDownHint",
												Visible = false,
												Tags = { Console_Hint = {} },
												Props = {
													AnchorPoint = Vector2.new(0.5, 0),
													BackgroundTransparency = 1,
													Image = "rbxassetid://118675586273862",
													Position = UDim2.new(0.5, 0, 1, 6),
													Size = UDim2.fromScale(0.45, 0.45),
													ZIndex = 3,
												},
												Children = {
													{ Primitive = "UIAspectRatioConstraint" },
												},
											},
											{
												Primitive = "ImageButton",
												Tags = {
													BackpackPlus_FilterButton = { BackpackPlus_FilterCategory = "Category2" },
													Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 },
													Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
												},
												Props = {
													Name = "CategoryButton",
													AnchorPoint = Vector2.new(0.5, 0.5),
													AutoButtonColor = false,
													BackgroundTransparency = 1,
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
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 2,
														},
														Children = {
															{
																Primitive = "TextLabel",
																Id = "S_ItemName",
																Props = {
																	AnchorPoint = Vector2.new(0.5, 0),
																	BackgroundTransparency = 1,
																	FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
																	Position = UDim2.fromScale(0.5, 0.025),
																	RichText = true,
																	Size = UDim2.fromScale(0.85, 0.275),
																	Text = "Cat 2",
																	TextColor3 = Color3.fromRGB(255, 255, 255),
																	TextScaled = true,
																	TextWrapped = true,
																	TextXAlignment = Enum.TextXAlignment.Left,
																	ZIndex = 2,
																},
																Children = {
																	{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 2 } },
																},
															},
															{
																Primitive = "CanvasGroup",
																Props = {
																	Name = "IconContainer",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	Position = UDim2.fromScale(0.5, 0.5),
																	Size = UDim2.fromScale(1, 1),
																},
																Children = {
																	{
																		Primitive = "ImageLabel",
																		Props = {
																			Name = "ButtonIcon",
																			AnchorPoint = Vector2.new(0.5, 0.5),
																			BackgroundTransparency = 1,
																			Image = "rbxassetid://109691263448311",
																			Position = UDim2.fromScale(0.65, 0.675),
																			Rotation = 3.5,
																			Size = UDim2.fromScale(1.15, 1.15),
																		},
																		Children = {
																			{ Primitive = "UIAspectRatioConstraint" },
																		},
																	},
																	{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
																},
															},
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "Highlight",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundTransparency = 1,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
															ZIndex = 3,
														},
														Children = {
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
																	{ Primitive = "UIGradient", Props = { Rotation = 90, Transparency = NumberSequence.new(0.5) } },
																},
															},
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
														},
													},
													{
														Primitive = "Frame",
														Id = "S_Background",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 255, 255),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 1),
														},
														Children = {
															{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.35) } },
															{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
														},
													},
												},
											},
										},
									},
								},
							},
							-- B (Circle on PlayStation) at the backpack's top right corner, which closes it: on Console only (Console_Hint),
							-- where ume's Console module shows it and swaps it to the player's pad. The ColorThick style, whose heavier light
							-- rim reads on the dark backpack
							{
								Primitive = "ImageLabel",
								Id = "S_CloseHint",
								Visible = false,
								Tags = { Console_Hint = {} },
								Props = { BackgroundTransparency = 1, Image = "rbxassetid://130460272434611", Position = UDim2.new(1, 10, 0, 0), Size = UDim2.fromScale(1, 0.14) },
								Children = {
									{ Primitive = "UIAspectRatioConstraint" },
								},
							},
						},
					},
				},
			},
			-- The toolbar along the bottom edge: BackpackPlus clones a slot per toolbar key into it and sizes every slot, the
			-- backpack and its grid from this width (ten slots on Desktop, six on Mobile). On Mobile it is narrower, so its
			-- slots stay a thumb's size between the thumbstick and the jump button, and never narrower than 348 px (58 px
			-- slots), for portrait screens
			{
				Primitive = "Frame",
				Id = "U_Toolbar",
				Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromScale(0.425, 0.1) } },
				Props = { AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.995), Size = UDim2.new(0.5, 50, 0.1, 0) },
				Children = {
					{ Primitive = "UISizeConstraint", Props = { MinSize = Vector2.new(348, 0) } },
					{
						Primitive = "UIListLayout",
						Props = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Bottom,
						},
					},
					-- The bumpers either side of the slots, on Console only (Console_Hint), where ume's Console module shows them and
					-- swaps them to the player's pad: LB (L1) equips the previous Tool, RB (R1) the next. Ordered around the slots
					-- (LayoutOrder 1 to 10) and centred on them
					-- LB (L1)
					{
						Primitive = "ImageLabel",
						Id = "S_PreviousHint",
						Visible = false,
						Tags = { Console_Hint = {} },
						Props = { BackgroundTransparency = 1, Image = "rbxassetid://83675298913757", LayoutOrder = -1, Size = UDim2.fromScale(1, 0.85) },
						Children = {
							{ Primitive = "UIAspectRatioConstraint" },
							{ Primitive = "UIFlexItem", Props = { ItemLineAlignment = Enum.ItemLineAlignment.Center } },
						},
					},
					-- RB (R1)
					{
						Primitive = "ImageLabel",
						Id = "S_NextHint",
						Visible = false,
						Tags = { Console_Hint = {} },
						Props = { BackgroundTransparency = 1, Image = "rbxassetid://118989647484332", LayoutOrder = 1000, Size = UDim2.fromScale(1, 0.85) },
						Children = {
							{ Primitive = "UIAspectRatioConstraint" },
							{ Primitive = "UIFlexItem", Props = { ItemLineAlignment = Enum.ItemLineAlignment.Center } },
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One tool: its viewport or icon, its name, its key and quantity, and a mark while it is a favourite
		["PREFAB | Slot"] = {
			Primitive = "Frame",
			Parent = "U_Toolbar",
			Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
			Children = {
				{ Primitive = "UIAspectRatioConstraint" },
				-- D-pad down above the slot, which unequips its Tool: on Console only (Console_Hint), and only over the equipped
				-- Tool's toolbar slot while the backpack is closed. BackpackPlus clears Console_HintHidden there and sets it
				-- everywhere else; ume's Console module shows the hint and swaps it to the player's pad
				{
					Primitive = "ImageLabel",
					Id = "S_UnequipHint",
					Visible = false,
					Tags = { Console_Hint = {} },
					Attributes = { Console_HintHidden = true },
					Props = {
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundTransparency = 1,
						Image = "rbxassetid://118675586273862",
						Position = UDim2.new(0.5, 0, 0, -2),
						Size = UDim2.fromScale(0.4, 0.4),
						ZIndex = 5,
					},
					Children = {
						{ Primitive = "UIAspectRatioConstraint" },
					},
				},
				{
					Primitive = "ImageButton",
					Id = "S_SlotButton",
					Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
					Attributes = { Interact_Function = "", Interact_ModuleName = "" },
					Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -10, 1, -10) },
					Children = {
						{
							Primitive = "Frame",
							Id = "S_BackgroundGlowContainer",
							Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.65, 0.65), ZIndex = 2 },
							Children = {
								{ Primitive = "UIShadow", Props = { BlurRadius = UDim.new(0.85, 0), Color = Color3.fromRGB(128, 128, 128), Transparency = 0.5 } },
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
							},
						},
						{
							Primitive = "Frame",
							Id = "S_Background",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundTransparency = 0.2,
								BorderSizePixel = 0,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
							},
							Children = {
								{ Primitive = "UIGradient" },
								{
									Primitive = "UIStroke",
									Tags = { Utils_UIStroke = {} },
									Props = { Name = "UIStroke_Highlight", BorderStrokePosition = Enum.BorderStrokePosition.Inner, Color = Color3.fromRGB(255, 255, 255), Thickness = 3, Transparency = 0.5 },
									Children = {
										{
											Primitive = "UIGradient",
											Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.9003, 1), NumberSequenceKeypoint.new(1, 1) }) },
										},
									},
								},
								{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.1, 0) } },
							},
						},
						{
							Primitive = "Frame",
							Props = { Name = "Content", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ZIndex = 3 },
							Children = {
								{
									Primitive = "ImageLabel",
									Id = "S_ItemIcon",
									Visible = false,
									Props = {
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = 1,
										Image = "rbxassetid://136406065725570",
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.fromScale(0.8, 0.8),
									},
									Children = {
										{ Primitive = "UIAspectRatioConstraint" },
									},
								},
								{
									Primitive = "TextLabel",
									Id = "S_ItemName",
									Props = {
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = 1,
										FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
										Position = UDim2.fromScale(0.5, 0.5),
										RichText = true,
										Size = UDim2.fromScale(0.925, 0.6),
										Text = "Item Name",
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextScaled = true,
										TextWrapped = true,
										ZIndex = 2,
									},
									Children = {
										{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 1.5 } },
									},
								},
								{
									Primitive = "Frame",
									-- Hides the key on Console, where the bumpers pick a slot; the module shows and hides S_KeyCode itself
									Tags = { Utils_HideOnPlatform = { Utils_ConsoleVisibility = false } },
									Props = { Name = "KeyCodeContainer", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
									Children = {
										{
											Primitive = "TextLabel",
											Id = "S_KeyCode",
											Props = {
												BackgroundTransparency = 1,
												FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
												Position = UDim2.fromOffset(6, 2),
												RichText = true,
												Size = UDim2.fromScale(0.9, 0.225),
												Text = "0",
												TextColor3 = Color3.fromRGB(255, 255, 255),
												TextScaled = true,
												TextWrapped = true,
												TextXAlignment = Enum.TextXAlignment.Left,
												TextYAlignment = Enum.TextYAlignment.Top,
												ZIndex = 2,
											},
											Children = {
												{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 1.5 } },
											},
										},
									},
								},
								{
									Primitive = "TextLabel",
									Id = "S_Quantity",
									Props = {
										AnchorPoint = Vector2.new(1, 0),
										BackgroundTransparency = 1,
										FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
										Position = UDim2.new(1, -6, 0, 2),
										RichText = true,
										Size = UDim2.fromScale(0.9, 0.225),
										Text = "x0",
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextScaled = true,
										TextWrapped = true,
										TextXAlignment = Enum.TextXAlignment.Right,
										TextYAlignment = Enum.TextYAlignment.Top,
										ZIndex = 2,
									},
									Children = {
										{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 1.5 } },
									},
								},
								{
									Primitive = "ViewportFrame",
									Id = "S_ItemViewportFrame",
									Visible = false,
									Props = {
										Ambient = Color3.fromRGB(255, 255, 255),
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = 1,
										LightColor = Color3.fromRGB(255, 255, 255),
										LightDirection = Vector3.new(0.15, 0.75, 0.75),
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.fromScale(1, 1),
									},
									Children = {
										{ Primitive = "WorldModel", Id = "S_ItemWorldModel" },
									},
								},
								{
									Primitive = "Frame",
									Id = "S_FavoriteIconContainer",
									Props = { AnchorPoint = Vector2.new(0.5, 0.333), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(0.275, 0.275) },
									Children = {
										{
											Primitive = "ImageLabel",
											Id = "S_FavoriteIcon",
											Props = {
												AnchorPoint = Vector2.new(0.5, 0.5),
												BackgroundTransparency = 1,
												Image = "rbxassetid://83025028886663",
												Position = UDim2.fromScale(0.5, 0.5),
												Size = UDim2.fromScale(1, 1),
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
}

return _gui
