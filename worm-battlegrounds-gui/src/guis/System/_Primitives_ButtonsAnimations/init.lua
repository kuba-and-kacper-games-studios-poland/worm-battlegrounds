--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "_Primitives_ButtonsAnimations",

	--[[ Tree ]]

	-- A transparent frame of buttons, one per ButtonScale preset in ume's Utils/Data/ButtonScalePresets.lua, each a copy
	-- of WidgetManager_Message's OK button named after its preset. Plain instances that hold every value themselves
	Root = {
		Primitive = "Frame",
		Id = "U_Buttons",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) },
		Children = {
			{ Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0, 24), PaddingLeft = UDim.new(0, 24), PaddingRight = UDim.new(0, 24), PaddingTop = UDim.new(0, 24) } },
			{
				Primitive = "UIGridLayout",
				Props = {
					CellPadding = UDim2.fromOffset(24, 24),
					CellSize = UDim2.fromOffset(210, 60),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "DefaultContainer", BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Default",
						Tags = {
							Utils_ButtonScale = {},
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Default",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "SnappyContainer", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Snappy",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Snappy" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Snappy",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "SoftContainer", BackgroundTransparency = 1, LayoutOrder = 3, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Soft",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Soft" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Soft",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "HeavyContainer", BackgroundTransparency = 1, LayoutOrder = 4, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Heavy",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Heavy" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Heavy",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "BouncyContainer", BackgroundTransparency = 1, LayoutOrder = 5, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Bouncy",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Bouncy" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Bouncy",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "SpringContainer", BackgroundTransparency = 1, LayoutOrder = 6, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Spring",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Spring" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Spring",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "JellyContainer", BackgroundTransparency = 1, LayoutOrder = 7, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Jelly",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Jelly" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Jelly",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "PopContainer", BackgroundTransparency = 1, LayoutOrder = 8, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Pop",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Pop" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Pop",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "SquishContainer", BackgroundTransparency = 1, LayoutOrder = 9, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Squish",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Squish" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Squish",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "PulseContainer", BackgroundTransparency = 1, LayoutOrder = 10, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Pulse",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Pulse" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Pulse",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "RubberContainer", BackgroundTransparency = 1, LayoutOrder = 11, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Rubber",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Rubber" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Rubber",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "SlamContainer", BackgroundTransparency = 1, LayoutOrder = 12, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Slam",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Slam" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Slam",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "WiggleContainer", BackgroundTransparency = 1, LayoutOrder = 13, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Wiggle",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Wiggle" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Wiggle",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "TiltContainer", BackgroundTransparency = 1, LayoutOrder = 14, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Tilt",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Tilt" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Tilt",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "SwingContainer", BackgroundTransparency = 1, LayoutOrder = 15, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Swing",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Swing" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Swing",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "ShakeContainer", BackgroundTransparency = 1, LayoutOrder = 16, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Shake",
						Tags = {
							Utils_ButtonScale = { Utils_ScaleAnimation = "Shake" },
							Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
						},
						Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
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
											Text = "Shake",
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
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
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
						},
					},
				},
			},
		},
	},
}

return _gui
