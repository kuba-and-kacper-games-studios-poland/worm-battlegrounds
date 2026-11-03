--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: ume's AFKTeleport module finds it as I.UserInterface.UI["AFKTeleport"]
	Name = "AFKTeleport",
	-- Hidden until AFKTeleport shows the countdown, and drawn over the game's own guis
	Screen = { DisplayOrder = 10, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- The warning an idle player sees in the middle of the screen before being moved to the lobby: AFKTeleport writes the
	-- seconds left into S_Time and hides the gui on any input. Plain instances in BackpackPlus's look (a dark gradient
	-- panel, a 3 px black outline, a half-white highlight fading down from the top edge, white text outlined in black),
	-- so no theme changes it
	Root = {
		Primitive = "Frame",
		Id = "U_Warning",
		Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.22, 0.22) },
		Children = {
			{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 2 } },
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
								Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.9, 1), NumberSequenceKeypoint.new(1, 1) }) },
							},
						},
					},
					{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 12) } },
				},
			},
			-- The texts, top to bottom: the question, the seconds left, what happens then and how to stay, 12 px in from the
			-- sides (the corner radius) and 10 px from the top and bottom
			{
				Primitive = "Frame",
				Props = { Name = "Content", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -24, 1, -20), ZIndex = 2 },
				Children = {
					{
						Primitive = "UIListLayout",
						Props = { HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center },
					},
					{
						Primitive = "TextLabel",
						Props = {
							Name = "TitleText",
							BackgroundTransparency = 1,
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
							RichText = true,
							Size = UDim2.fromScale(1, 0.22),
							Text = "Are you still there?",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextWrapped = true,
						},
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 2 } },
						},
					},
					-- The seconds left, in BackpackPlus's orange to yellow
					{
						Primitive = "TextLabel",
						Id = "S_Time",
						Props = {
							BackgroundTransparency = 1,
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
							RichText = true,
							Size = UDim2.fromScale(1, 0.38),
							Text = "30",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextWrapped = true,
						},
						Children = {
							{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(255, 115, 0), Color3.fromRGB(255, 213, 0)), Rotation = -90 } },
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 3 } },
						},
					},
					{
						Primitive = "TextLabel",
						Props = {
							Name = "InfoText",
							BackgroundTransparency = 1,
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
							RichText = true,
							Size = UDim2.fromScale(1, 0.17),
							Text = "seconds until you are moved to the lobby",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextWrapped = true,
						},
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 1.5 } },
						},
					},
					{
						Primitive = "TextLabel",
						Props = {
							Name = "HintText",
							BackgroundTransparency = 1,
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
							RichText = true,
							Size = UDim2.fromScale(1, 0.14),
							Text = "Move, click or press any key to stay",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextTransparency = 0.25,
							TextWrapped = true,
						},
						Children = {
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 1.5, Transparency = 0.25 } },
						},
					},
				},
			},
		},
	},
}

return _gui
