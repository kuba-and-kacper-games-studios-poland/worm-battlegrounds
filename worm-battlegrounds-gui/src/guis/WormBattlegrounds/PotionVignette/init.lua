--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Snails module tints it and fades it in while the player's snail is under a potion on their own turn
	Name = "PotionVignette",
	Screen = { DisplayOrder = -5, Enabled = false, IgnoreGuiInset = true, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	-- Four soft edges, white (code tints them), each fading out toward the middle of the screen along its gradient
	Root = {
		Primitive = "Frame",
		Id = "U_Vignette",
		Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
		Children = {
			{
				Primitive = "Frame",
				Id = "S_Top",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.fromScale(1, 0.3),
				},
				Children = {
					{
						Primitive = "UIGradient",
						Props = {
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.5),
								NumberSequenceKeypoint.new(0.45, 0.85),
								NumberSequenceKeypoint.new(1, 1),
							}),
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Id = "S_Bottom",
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 1),
					Size = UDim2.fromScale(1, 0.3),
				},
				Children = {
					{
						Primitive = "UIGradient",
						Props = {
							Rotation = 270,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.5),
								NumberSequenceKeypoint.new(0.45, 0.85),
								NumberSequenceKeypoint.new(1, 1),
							}),
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Id = "S_Left",
				Props = {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromScale(0.2, 1),
				},
				Children = {
					{
						Primitive = "UIGradient",
						Props = {
							Rotation = 0,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.5),
								NumberSequenceKeypoint.new(0.45, 0.85),
								NumberSequenceKeypoint.new(1, 1),
							}),
						},
					},
				},
			},
			{
				Primitive = "Frame",
				Id = "S_Right",
				Props = {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(1, 0.5),
					Size = UDim2.fromScale(0.2, 1),
				},
				Children = {
					{
						Primitive = "UIGradient",
						Props = {
							Rotation = 180,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.5),
								NumberSequenceKeypoint.new(0.45, 0.85),
								NumberSequenceKeypoint.new(1, 1),
							}),
						},
					},
				},
			},
		},
	},
}

return _gui
