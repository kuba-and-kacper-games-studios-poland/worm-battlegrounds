--[[
	Created By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		A template: the lobby's stage clones it over each empty pod, a copy of the party column's "+" card (its slanted
		dark card, grey outline and grey "+"), small and faded into the scene, that opens the party invite when pressed
		(the owner, 2026-11-24: "like this but even more realistic and faded and smaller")
	]]
	Name = "InviteBubble",
	Kind = "Billboard",
	-- The billboard's size in studs on the stage (BillboardGui Size 1.7 × 1.25 studs), the party card's 150 × 110
	Preview = { Width = 150, Height = 110 },

	--[[ Tree ]]

	Root = {
		Primitive = "ImageButton",
		Id = "U_Invite",
		Props = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Image = "",
			ImageTransparency = 1,
		},
		Attributes = {
			ClickSound_Name = "Button_Click",
			ClickSound_SoundGroup = "UI",
			HoverSound_Name = "Button_Hover",
			HoverSound_SoundGroup = "UI",
			Utils_ClickScale = 0.92,
			Utils_HoverScale = 1.08,
			Utils_ScaleAnimation = "Bouncy",
		},
		Tags = { ["Utils_ButtonScale"] = {}, ["Utils_ButtonSound"] = {} },
		Children = {
			-- The party card's look, faded (its pictures 0.35 see-through)
			{
				Primitive = "Frame",
				Props = {
					Name = "Background",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 0,
					Position = UDim2.fromScale(-0.0068, -0.0455),
					Size = UDim2.fromScale(1.0136, 1.0909),
				},
				Children = {
					{
						Primitive = "ImageLabel",
						Props = {
							Name = "Main",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 0,
							Position = UDim2.fromScale(0.0067, 0.0417),
							Size = UDim2.fromScale(0.9866, 0.9167),
							ZIndex = 1,
							Image = "rbxassetid://105496868178643",
							ImageColor3 = Color3.fromRGB(25, 25, 35),
							ImageTransparency = 0.35,
							ScaleType = Enum.ScaleType.Fit,
						},
					},
					{
						Primitive = "ImageLabel",
						Props = {
							Name = "Stroke2",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 1,
							Size = UDim2.fromScale(1, 1),
							ZIndex = 2,
							Image = "rbxassetid://135099115433268",
							ImageColor3 = Color3.fromRGB(25, 25, 35),
							ImageTransparency = 0.35,
							ScaleType = Enum.ScaleType.Fit,
						},
					},
					{
						Primitive = "ImageLabel",
						Props = {
							Name = "Stroke",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 2,
							Position = UDim2.fromScale(0.0132, 0.0167),
							Size = UDim2.fromScale(0.9737, 0.9667),
							ZIndex = 3,
							Image = "rbxassetid://135321142049024",
							ImageColor3 = Color3.fromRGB(130, 130, 130),
							ImageTransparency = 0.35,
							ScaleType = Enum.ScaleType.Fit,
						},
					},
				},
			},
			{
				Primitive = "TextLabel",
				Props = {
					Name = "Plus",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.2, 0.5364),
					ZIndex = 4,
					Text = "+",
					TextColor3 = Color3.fromRGB(154, 154, 154),
					TextTransparency = 0.2,
					TextSize = 40,
					FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.ExtraBold, Enum.FontStyle.Italic),
					RichText = true,
					TextScaled = true,
					TextWrapped = true,
				},
				Children = {
					{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
				},
			},
		},
	},
}

return _gui
