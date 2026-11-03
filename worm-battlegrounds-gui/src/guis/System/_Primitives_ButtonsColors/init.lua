--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "_Primitives_ButtonsColors",

	--[[ Tree ]]

	-- A transparent frame of buttons, one per button color to build guis from: the System guis' own (Accept, Cancel,
	-- Close), then I.Gradient's palette. Each is WidgetManager_Message's OK button with the Default animation and
	-- that gradient on its front and back. Plain instances that hold every value themselves
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
				Props = { Name = "AcceptContainer", BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Accept",
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
				Props = { Name = "CancelContainer", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Cancel",
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
											Text = "Cancel",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(186, 0, 0), Color3.fromRGB(255, 62, 62)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(186, 0, 0), Color3.fromRGB(255, 62, 62)), Rotation = -90 } },
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
				Props = { Name = "CloseContainer", BackgroundTransparency = 1, LayoutOrder = 3, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Close",
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
											Text = "Close",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(226, 0, 0), Color3.fromRGB(255, 100, 48)), Rotation = -90 } },
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
				Props = { Name = "BlueContainer", BackgroundTransparency = 1, LayoutOrder = 4, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Blue",
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
											Text = "Blue",
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
				Props = { Name = "BrownContainer", BackgroundTransparency = 1, LayoutOrder = 5, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Brown",
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
											Text = "Brown",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(112, 77, 61), Color3.fromRGB(190, 123, 69)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(112, 77, 61), Color3.fromRGB(190, 123, 69)), Rotation = -90 } },
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
				Props = { Name = "CyanContainer", BackgroundTransparency = 1, LayoutOrder = 6, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Cyan",
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
											Text = "Cyan",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 221, 255), Color3.fromRGB(150, 252, 244)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 221, 255), Color3.fromRGB(150, 252, 244)), Rotation = -90 } },
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
				Props = { Name = "GoldContainer", BackgroundTransparency = 1, LayoutOrder = 7, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Gold",
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
											Text = "Gold",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(255, 183, 0), Color3.fromRGB(252, 231, 0)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(255, 183, 0), Color3.fromRGB(252, 231, 0)), Rotation = -90 } },
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
				Props = { Name = "GrayContainer", BackgroundTransparency = 1, LayoutOrder = 8, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Gray",
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
											Text = "Gray",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(130, 143, 162), Color3.fromRGB(205, 220, 252)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(130, 143, 162), Color3.fromRGB(205, 220, 252)), Rotation = -90 } },
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
				Props = { Name = "GreenContainer", BackgroundTransparency = 1, LayoutOrder = 9, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Green",
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
											Text = "Green",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(90, 221, 29), Color3.fromRGB(153, 255, 0)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(90, 221, 29), Color3.fromRGB(153, 255, 0)), Rotation = -90 } },
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
				Props = { Name = "OrangeContainer", BackgroundTransparency = 1, LayoutOrder = 10, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Orange",
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
											Text = "Orange",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(255, 115, 0), Color3.fromRGB(255, 213, 0)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(255, 115, 0), Color3.fromRGB(255, 213, 0)), Rotation = -90 } },
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
				Props = { Name = "PinkContainer", BackgroundTransparency = 1, LayoutOrder = 11, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Pink",
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
											Text = "Pink",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(217, 25, 255), Color3.fromRGB(255, 146, 250)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(217, 25, 255), Color3.fromRGB(255, 146, 250)), Rotation = -90 } },
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
				Props = { Name = "PurpleContainer", BackgroundTransparency = 1, LayoutOrder = 12, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Purple",
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
											Text = "Purple",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(122, 60, 255), Color3.fromRGB(232, 105, 255)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(122, 60, 255), Color3.fromRGB(232, 105, 255)), Rotation = -90 } },
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
				Props = { Name = "RedContainer", BackgroundTransparency = 1, LayoutOrder = 13, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Red",
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
											Text = "Red",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(243, 24, 24), Color3.fromRGB(255, 105, 105)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(243, 24, 24), Color3.fromRGB(255, 105, 105)), Rotation = -90 } },
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
				Props = { Name = "SilverContainer", BackgroundTransparency = 1, LayoutOrder = 14, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Silver",
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
											Text = "Silver",
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
									{
										Primitive = "UIGradient",
										Props = {
											Color = ColorSequence.new({
												ColorSequenceKeypoint.new(0, Color3.fromRGB(169, 172, 175)),
												ColorSequenceKeypoint.new(0.5, Color3.fromRGB(232, 238, 244)),
												ColorSequenceKeypoint.new(1, Color3.fromRGB(169, 172, 175)),
											}),
											Rotation = -90,
										},
									},
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{
										Primitive = "UIGradient",
										Props = {
											Color = ColorSequence.new({
												ColorSequenceKeypoint.new(0, Color3.fromRGB(169, 172, 175)),
												ColorSequenceKeypoint.new(0.5, Color3.fromRGB(232, 238, 244)),
												ColorSequenceKeypoint.new(1, Color3.fromRGB(169, 172, 175)),
											}),
											Rotation = -90,
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
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Props = { Name = "WhiteContainer", BackgroundTransparency = 1, LayoutOrder = 15, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_White",
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
											Text = "White",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(191, 202, 217), Color3.fromRGB(255, 255, 255)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(191, 202, 217), Color3.fromRGB(255, 255, 255)), Rotation = -90 } },
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
				Props = { Name = "YellowContainer", BackgroundTransparency = 1, LayoutOrder = 16, Size = UDim2.fromScale(1, 1) },
				Children = {
					{
						Primitive = "ImageButton",
						Id = "S_Yellow",
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
											Text = "Yellow",
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
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(255, 234, 0), Color3.fromRGB(255, 239, 120)), Rotation = -90 } },
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Background_Back", BackgroundColor3 = Color3.fromRGB(180, 180, 180), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
								Children = {
									{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(255, 234, 0), Color3.fromRGB(255, 239, 120)), Rotation = -90 } },
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
