--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Tutorial module turns it on and places the hole and the panel, as I.UserInterface.UI["TutorialHint"]
	Name = "TutorialHint",
	-- Over every other gui but the teleport card, across the whole screen, so the hole lines up with world and gui spots
	Screen = { DisplayOrder = 50, Enabled = false, IgnoreGuiInset = true, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			--[[
				The spotlight: a lighter rounded square over what to press, whose huge dark outline blacks out the rest
				of the screen; the gold ring inside it pulses
			]]
			{
				Primitive = "Frame",
				Id = "U_Spotlight",
				Props = {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.88,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(160, 160),
					Visible = false,
				},
				Children = {
					{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 18) } },
					{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(8, 8, 14), Thickness = 4000, Transparency = 0.3 } },
					{
						Primitive = "Frame",
						Id = "S_Ring",
						Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 18) } },
							{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(255, 215, 110), Thickness = 3, Transparency = 0.2 } },
						},
					},
				},
			},
			-- The blockers around the hole, placed by code: presses there never reach the world or the guis under them
			{
				Primitive = "Folder",
				Id = "U_Blockers",
				Children = {
					{ Primitive = "Frame", Props = { Name = "Top", Active = true, BackgroundTransparency = 1, BorderSizePixel = 0 } },
					{ Primitive = "Frame", Props = { Name = "Bottom", Active = true, BackgroundTransparency = 1, BorderSizePixel = 0 } },
					{ Primitive = "Frame", Props = { Name = "Left", Active = true, BackgroundTransparency = 1, BorderSizePixel = 0 } },
					{ Primitive = "Frame", Props = { Name = "Right", Active = true, BackgroundTransparency = 1, BorderSizePixel = 0 } },
				},
			},
			--[[
				The hint: the confirmation dialog's dark panel (25, 25, 35) with its dark outer line and grey inner line,
				the gold title and the text; code sets the text's and the panel's heights and places it by the hole
			]]
			{
				Primitive = "Frame",
				Id = "U_Hint",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(25, 25, 35),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.2),
					Size = UDim2.fromOffset(620, 112),
					Visible = false,
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 16) } },
					{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
					{
						Primitive = "UIStroke",
						Tags = { Utils_UIStroke = {} },
						Props = {
							Name = "UIStroke_Inner",
							BorderStrokePosition = Enum.BorderStrokePosition.Inner,
							Color = Color3.fromRGB(130, 130, 130),
							Thickness = 3,
						},
					},
					{
						Primitive = "TextLabel",
						Id = "S_Title",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromOffset(310, 14),
							Size = UDim2.new(1, -48, 0, 26),
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							RichText = true,
							Text = "TUTORIAL",
							TextColor3 = Color3.fromRGB(255, 215, 110),
							TextScaled = true,
							TextSize = 26,
							TextWrapped = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 26 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.0833 } },
						},
					},
					{
						Primitive = "TextLabel",
						Id = "S_Text",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromOffset(310, 46),
							Size = UDim2.new(1, -48, 0, 48),
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							RichText = true,
							Text = "Point at the bot, hold the mouse button to charge, let go to fire",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextSize = 32,
							TextWrapped = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 32 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.0833 } },
						},
					},
				},
			},
		},
	},
}

return _gui
