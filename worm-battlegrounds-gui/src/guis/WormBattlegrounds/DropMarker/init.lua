--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		A template: Match clones it over each snail's landing spot in the drop phase (the player's own follows their
		pointer until placed), a map pin in its colour with its picture and name (Primitive nodes in the SnailTag's look,
		2026-11-17), its tip on a small target: the aim crosshair's ring and a dot on the spot. Every dark outline is as
		thick as the name's (0.07 of its 38 px text, about 2.7 px at design size: the owner, 2026-11-25), scaled to its
		frame so it grows with the billboard
	]]
	Name = "DropMarker",
	Kind = "Billboard",
	-- The billboard's size at design scale, scaled with the screen by code
	Preview = { Width = 150, Height = 222 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Marker",
		Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(150, 222) },
		Children = {
			-- Set with the billboard's size by ScreenScale
			{ Primitive = "UIScale", Id = "S_ScreenScale" },
			--[[
				The landing target, centred on the spot (190 of the 222 down, where the pin's tip is): the aim crosshair's
				ring (a dark line under a line in the snail's colour, S_RingLine) and a dot on the spot, popped in by code
				(S_TargetScale) when the spot is placed
			]]
			{
				Primitive = "Frame",
				Id = "S_Target",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.8559),
					Size = UDim2.fromScale(0.42, 0.42),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					ZIndex = 1,
				},
				Children = {
					{ Primitive = "UIScale", Id = "S_TargetScale" },
					{
						Primitive = "Frame",
						Props = {
							Name = "RingOutline",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 1,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
							{
								Primitive = "UIStroke",
								Props = {
									BorderStrokePosition = Enum.BorderStrokePosition.Center,
									Color = Color3.fromRGB(20, 14, 10),
									StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
									Thickness = 0.165,
								},
							},
						},
					},
					{
						Primitive = "Frame",
						Props = {
							Name = "Ring",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 2,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
							{
								Primitive = "UIStroke",
								Id = "S_RingLine",
								Props = {
									BorderStrokePosition = Enum.BorderStrokePosition.Center,
									Color = Color3.fromRGB(255, 84, 84),
									StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
									Thickness = 0.08,
								},
							},
						},
					},
					{
						Primitive = "Frame",
						Id = "S_Dot",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 84, 84),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.14, 0.14),
							ZIndex = 3,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
							{
								Primitive = "UIStroke",
								Props = { Color = Color3.fromRGB(20, 14, 10), StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.3 },
							},
						},
					},
				},
			},
			-- The pin, which code drops onto its spot (its Position) when it's placed or moved; its tip is its frame's bottom middle, on the target's middle
			{
				Primitive = "Frame",
				Id = "S_Drop",
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.8559),
					Size = UDim2.fromScale(1, 0.8559),
					ZIndex = 2,
				},
				Children = {
					-- The player's name, in their colour
					{
						Primitive = "TextLabel",
						Id = "S_Name",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0),
							Size = UDim2.fromScale(1.2, 0.2),
							ZIndex = 5,
							Text = "PlayerName",
							TextColor3 = Color3.fromRGB(255, 84, 84),
							TextSize = 30,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize } },
						},
					},
					-- The pin's point: a square turned 45°, its top half under the head
					{
						Primitive = "Frame",
						Id = "S_Point",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 84, 84),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.85),
							Rotation = 45,
							Size = UDim2.fromScale(0.27, 0.27),
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
							ZIndex = 2,
						},
						Children = {
							{
								Primitive = "UIStroke",
								Props = { Color = Color3.fromRGB(20, 14, 10), StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.066 },
							},
						},
					},
					-- The pin's head in the player's colour, their picture in it
					{
						Primitive = "Frame",
						Id = "S_Head",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 84, 84),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.55),
							Size = UDim2.fromScale(0.62, 0.62),
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
							ZIndex = 3,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
							{
								Primitive = "UIStroke",
								Props = { Color = Color3.fromRGB(20, 14, 10), StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.029 },
							},
							{
								Primitive = "ImageLabel",
								Id = "S_Avatar",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(40, 40, 58),
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.8, 0.8),
									ZIndex = 4,
									Image = "rbxassetid://119874218679833",
									ScaleType = Enum.ScaleType.Crop,
								},
								Attributes = { _ImageName = "964_8__Frame__PlayerIcon_image" },
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
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
