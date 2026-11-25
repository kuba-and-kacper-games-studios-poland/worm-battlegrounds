--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Tutorial module turns it on and places the ring, the arrow and the hint, as I.UserInterface.UI["TutorialHint"]
	Name = "TutorialHint",
	-- Over every other gui but the teleport card, across the whole screen, so the arrow lines up with world and gui spots
	Screen = { DisplayOrder = 50, Enabled = false, IgnoreGuiInset = true, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			--[[
				The ring round a spot in the world (the drop's lit spot): a soft white circle that pulses, over a faint
				light; nothing else on the screen is darkened or blocked (the owner, 2026-11-24: subtle, no gold square)
			]]
			{
				Primitive = "Frame",
				Id = "U_Spotlight",
				Props = {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.88,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(120, 120),
					Visible = false,
				},
				Children = {
					{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
					{
						Primitive = "Frame",
						Id = "S_Ring",
						Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
							{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(255, 255, 255), Thickness = 3, Transparency = 0.15 } },
						},
					},
				},
			},
			--[[
				The red arrow pointing down at the target (code turns it over to point up, and bobs it): the snail tag's own
				turn arrow (SnailTag's S_Arrow picture), its tip the bottom middle (the anchor)
			]]
			{
				Primitive = "Frame",
				Id = "U_Arrow",
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(48, 60),
					Visible = false,
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					{
						Primitive = "ImageLabel",
						Id = "S_Image",
						Props = {
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Size = UDim2.fromScale(1, 1),
							Image = "rbxassetid://107929925047000",
							ScaleType = Enum.ScaleType.Fit,
						},
					},
				},
			},
			--[[
				The swipe: a touch point that slides and fades under "Drag to aim", showing the drag (the owner,
				2026-11-24: "cool swiping circle animation"); code moves it
			]]
			{
				Primitive = "Frame",
				Id = "U_Swipe",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.2,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(40, 40),
					Visible = false,
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
					{ Primitive = "UIStroke", Id = "S_SwipeGlow", Props = { Color = Color3.fromRGB(255, 255, 255), Thickness = 8, Transparency = 0.7 } },
				},
			},
			--[[
				The hint: two or three words in the HUD's own text (the turn banner's white heavy italic with its black
				outline, the title weight), no panel (the owner, 2026-11-24: "more subtle"), bigger than YOUR TURN! so it
				reads as its own line; code places it by the arrow
			]]
			{
				Primitive = "Frame",
				Id = "U_Hint",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.25),
					Size = UDim2.fromOffset(900, 58),
					Visible = false,
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					{
						Primitive = "TextLabel",
						Id = "S_Text",
						Props = {
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Size = UDim2.fromScale(1, 1),
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							RichText = true,
							Text = "Click to land",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextSize = 48,
							TextWrapped = true,
						},
						Tags = { TextCase_Upper = {} },
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 48 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.06 } },
						},
					},
					-- A smaller line under the hint saying how, for the player's device ("Walk with A and D"), hidden without one (2026-11-25)
					{
						Primitive = "TextLabel",
						Id = "S_Tip",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.new(0.5, 0, 1, 4),
							Size = UDim2.fromScale(1, 0.55),
							Visible = false,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							RichText = true,
							Text = "Walk with A and D",
							TextColor3 = Color3.fromRGB(235, 235, 240),
							TextScaled = true,
							TextSize = 28,
							TextWrapped = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 28 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
						},
					},
				},
			},
		},
	},
}

return _gui
