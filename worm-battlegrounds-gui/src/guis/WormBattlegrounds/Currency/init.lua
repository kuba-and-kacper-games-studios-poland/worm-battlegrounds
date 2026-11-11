--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- System's Currency, with the game's coin and diamond bar: ume's Currency slots find it as I.UserInterface.UI["Currency"]
	Name = "Currency",
	-- Built disabled; the UserInterface server enables it at start (PreventHiding)
	Screen = { DisplayOrder = -999, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },
	ScreenTags = { UserInterface_PreventHiding = {} },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- The area currency orbs fly in (System's, kept as it is)
			{
				Primitive = "Frame",
				Id = "U_OrbsContainer",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.8, 0.8),
				},
			},
			--[[
				Top right, the gui maker's bar (2026-11-11, in the Gacha design's pictures): a coin chip and a diamond chip
				(Currency_Slot counts ume's Currency writes, each pulsing its own UIScale), and + that opens the Shop
			]]
			{
				Primitive = "Frame",
				Id = "U_Bar",
				Props = { AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 2, Position = UDim2.fromScale(0.95, 0.0315), Size = UDim2.fromScale(0.2461, 0.0502) },
				Children = {
					{
						Primitive = "Frame",
						Props = { Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.fromScale(1, 1), ZIndex = 6 },
						Children = {
							{ Primitive = "UIPadding" },
							{ Primitive = "UIListLayout", Props = { HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 16) } },
							{
								Primitive = "Frame",
								Props = { Name = "Stack", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIPadding" },
									{
										Primitive = "UIListLayout",
										Props = {
											FillDirection = Enum.FillDirection.Horizontal,
											HorizontalAlignment = Enum.HorizontalAlignment.Right,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											SortOrder = Enum.SortOrder.LayoutOrder,
											Padding = UDim.new(0.0169, 0),
										},
									},
									{
										Primitive = "Frame",
										Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(0.4148, 1) },
										Children = {
											{
												Primitive = "Frame",
												Props = { Name = "Stack", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
												Children = {
													{ Primitive = "UIPadding" },
													{
														Primitive = "ImageLabel",
														Id = "S_CoinIcon",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(143, 211, 255),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 1,
															Position = UDim2.fromScale(0.176, 0.5),
															Size = UDim2.fromScale(0.2159, 0.78),
															ZIndex = 2,
															Image = "rbxassetid://111931430831562",
															ScaleType = Enum.ScaleType.Fit,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 18) } },
															{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(11, 16, 32), Thickness = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border } },
														},
													},
													{
														Primitive = "TextLabel",
														Id = "S_Coins",
														Props = {
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 2,
															Position = UDim2.fromScale(0.3, 0.2683),
															Size = UDim2.fromScale(0.6, 0.4634),
															ZIndex = 3,
															Text = "0",
															FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
															TextColor3 = Color3.fromRGB(255, 255, 255),
															TextSize = 48,
															TextScaled = true,
															TextWrapped = true,
															RichText = true,
															TextXAlignment = Enum.TextXAlignment.Left,
														},
														Attributes = { Currency_CustomFormat = "", Currency_Name = "Coins", Currency_ShortFrom = 10000, Currency_SpawnOrbs = false },
														Tags = { ["Currency_Slot"] = {}, ["TextCase_Upper"] = {} },
														Children = {
															{ Primitive = "UIStroke", Props = { Thickness = 0.0938, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize } },
															{ Primitive = "UIPadding", Props = { PaddingRight = UDim.new(0.03, 0) } },
														},
													},
												},
											},
											{ Primitive = "UIScale", Id = "S_CoinsScale" },
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 3.6134 } },
											{
												Primitive = "Frame",
												Props = { Name = "Background", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.fromScale(1, 1) },
												Children = {
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Main",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.0034, 0.061),
															Size = UDim2.fromScale(0.9931, 0.878),
															Image = "rbxassetid://132693594544527",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1018_489__Gacha__Main_gray" },
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
															Image = "rbxassetid://110464716728942",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1126_52__Gacha__Stroke2_gray" },
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Stroke",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = true,
															LayoutOrder = 2,
															Position = UDim2.fromScale(0.0068, 0.0244),
															Size = UDim2.fromScale(0.9865, 0.9512),
															ZIndex = 3,
															Image = "rbxassetid://129410270943519",
															ImageColor3 = Color3.fromRGB(130, 130, 130),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1126_53__Gacha__Stroke_gray" },
													},
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromScale(0.4148, 1) },
										Children = {
											{
												Primitive = "Frame",
												Props = { Name = "Stack", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
												Children = {
													{ Primitive = "UIPadding" },
													{
														Primitive = "ImageLabel",
														Id = "S_DiamondIcon",
														Props = {
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(143, 211, 255),
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 1,
															Position = UDim2.fromScale(0.176, 0.5),
															Size = UDim2.fromScale(0.2159, 0.78),
															ZIndex = 2,
															Image = "rbxassetid://107933415897221",
															ScaleType = Enum.ScaleType.Fit,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 18) } },
															{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(11, 16, 32), Thickness = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border } },
														},
													},
													{
														Primitive = "TextLabel",
														Id = "S_Diamonds",
														Props = {
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 2,
															Position = UDim2.fromScale(0.3, 0.2683),
															Size = UDim2.fromScale(0.6, 0.4634),
															ZIndex = 3,
															Text = "0",
															FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
															TextColor3 = Color3.fromRGB(255, 255, 255),
															TextSize = 48,
															TextScaled = true,
															TextWrapped = true,
															RichText = true,
															TextXAlignment = Enum.TextXAlignment.Left,
														},
														Attributes = { Currency_CustomFormat = "", Currency_Name = "Diamonds", Currency_ShortFrom = 10000, Currency_SpawnOrbs = false },
														Tags = { ["Currency_Slot"] = {}, ["TextCase_Upper"] = {} },
														Children = {
															{ Primitive = "UIStroke", Props = { Thickness = 0.0938, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize } },
															{ Primitive = "UIPadding", Props = { PaddingRight = UDim.new(0.03, 0) } },
														},
													},
												},
											},
											{ Primitive = "UIScale", Id = "S_DiamondsScale" },
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 3.6134 } },
											{
												Primitive = "Frame",
												Props = { Name = "Background", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.fromScale(1, 1) },
												Children = {
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Main",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															LayoutOrder = 0,
															Position = UDim2.fromScale(0.0034, 0.061),
															Size = UDim2.fromScale(0.9931, 0.878),
															Image = "rbxassetid://132693594544527",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1018_489__Gacha__Main_gray" },
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
															Image = "rbxassetid://110464716728942",
															ImageColor3 = Color3.fromRGB(25, 25, 35),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1126_52__Gacha__Stroke2_gray" },
													},
													{
														Primitive = "ImageLabel",
														Props = {
															Name = "Stroke",
															BackgroundTransparency = 1,
															BorderSizePixel = 0,
															ClipsDescendants = true,
															LayoutOrder = 2,
															Position = UDim2.fromScale(0.0068, 0.0244),
															Size = UDim2.fromScale(0.9865, 0.9512),
															ZIndex = 3,
															Image = "rbxassetid://129410270943519",
															ImageColor3 = Color3.fromRGB(130, 130, 130),
															ScaleType = Enum.ScaleType.Fit,
														},
														Attributes = { _ImageName = "1126_53__Gacha__Stroke_gray" },
													},
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Id = "S_Add",
										Props = { BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 3, Size = UDim2.fromScale(0.1365, 1) },
										Children = {
											{
												Primitive = "ImageButton",
												Props = {
													Name = "Button",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(1, 1),
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
													Interact_Arg1 = "Shop",
													Interact_Function = "Toggle",
													Interact_ModuleName = "WidgetManager",
													Utils_ClickScale = 0.92,
													Utils_HoverScale = 1.04,
													Utils_ScaleAnimation = "Bouncy",
												},
												Tags = { ["Interact_Button"] = {}, ["Utils_ButtonScale"] = {}, ["Utils_ButtonSound"] = {} },
												Children = {
													{
														Primitive = "Frame",
														Props = { Name = "Background", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.fromScale(1, 1) },
														Children = {
															{
																Primitive = "ImageLabel",
																Props = {
																	Name = "Main",
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 0,
																	Position = UDim2.fromScale(-0.0032, -0.0083),
																	Size = UDim2.fromScale(1.0147, 1.0166),
																	Image = "rbxassetid://97235681367178",
																},
																Attributes = { _ImageName = "1018_464__Gacha__Main_gray" },
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
																	Image = "rbxassetid://95688740078512",
																	ImageColor3 = Color3.fromRGB(25, 25, 35),
																	ImageTransparency = 1,
																	ScaleType = Enum.ScaleType.Fit,
																},
																Attributes = { _ImageName = "1126_54__Gacha__Stroke2_gray" },
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	Name = "Stroke",
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	ClipsDescendants = true,
																	LayoutOrder = 2,
																	Position = UDim2.fromScale(0.0159, 0.0189),
																	Size = UDim2.fromScale(0.9683, 0.9623),
																	ZIndex = 3,
																	Image = "rbxassetid://115753650835461",
																	ImageColor3 = Color3.fromRGB(230, 150, 0),
																	ImageTransparency = 1,
																	ScaleType = Enum.ScaleType.Fit,
																},
																Attributes = { _ImageName = "1126_55__Gacha__Stroke_gray" },
															},
															{
																Primitive = "ImageLabel",
																Props = {
																	Name = "Mask",
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 3,
																	Position = UDim2.fromScale(0.0159, 0.0189),
																	Size = UDim2.fromScale(0.9683, 0.9623),
																	ZIndex = 4,
																	Image = "rbxassetid://102884751367093",
																	ImageTransparency = 1,
																},
																Attributes = { _ImageName = "1018_467__Gacha__Mask_image" },
															},
														},
													},
													{
														Primitive = "Frame",
														Props = { Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
														Children = {
															{ Primitive = "UIPadding" },
															{
																Primitive = "ImageLabel",
																Props = {
																	Name = "Icon",
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	BackgroundTransparency = 1,
																	BorderSizePixel = 0,
																	LayoutOrder = 0,
																	Position = UDim2.fromScale(0.5, 0.5),
																	Size = UDim2.fromScale(0.5, 0.6),
																	Image = "rbxassetid://134817447648270",
																	ScaleType = Enum.ScaleType.Fit,
																},
															},
														},
													},
												},
											},
											{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.1889 } },
										},
									},
								},
							},
						},
					},
					{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 8.7097 } },
				},
			},
		},
	},
}

return _gui
