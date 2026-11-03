--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The prompt style ume's Interact draws with it (Interact_Style), and the exported BillboardGui's name
	Name = "Default",
	-- The look of a ProximityPrompt
	Kind = "Prompt",
	-- The input mappings it draws keys with: ume's Interact Mappings (Roblox's own textures)
	Mappings = "Default",
	-- The inputs a prompt shows: a keyboard key, a gamepad button, the touch hand
	Devices = { "Desktop", "Console", "Mobile" },
	-- Example size for the Gui tool's preview: the card with the example texts
	Preview = { Width = 200, Height = 72 },

	--[[ Tree ]]

	-- Roblox's default ProximityPrompt at rest, built as Roblox's own sample builds it (the ProximityPromptStyle docs):
	-- plain instances with Roblox's defaults, and only the values Roblox sets. Its Preview module plays the prompt's
	-- hold, trigger and release in the Gui tool
	Root = {
		Primitive = "Frame",
		Id = "U_Prompt",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) },
		Children = {
			-- The card: as wide as the key square and the texts, centred along the top
			{
				Primitive = "Frame",
				Id = "S_Frame",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.new(0.07, 0.07, 0.07),
					BackgroundTransparency = 0.2,
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.fromScale(0, 1),
				},
				Children = {
					{ Primitive = "UICorner" },
					{
						Primitive = "UIListLayout",
						Id = "S_ListLayout",
						Props = { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder },
					},
					-- 15 after the texts with an object name, 24 without
					{ Primitive = "UIPadding", Id = "S_Padding", Props = { PaddingRight = UDim.new(0, 15) } },

					--[[ Input ]]

					{
						Primitive = "Frame",
						Id = "S_InputFrame",
						Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), SizeConstraint = Enum.SizeConstraint.RelativeYY },
						Children = {
							{
								Primitive = "Frame",
								Id = "S_ResizeableInputFrame",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(1, 1),
								},
								Children = {
									{ Primitive = "UIScale", Id = "S_InputFrameScaler" },
									-- The circle behind the key, in a Frame's own grey
									{
										Primitive = "Frame",
										Id = "S_RoundFrame",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 0.5,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromOffset(48, 48),
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.5, 0) } },
										},
									},
									{
										Primitive = "ImageLabel",
										Id = "S_ButtonImage",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											Image = "rbxasset://textures/ui/Controls/key_single.png",
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromOffset(28, 30),
										},
									},
									-- A keyboard key's symbol (Backspace, Shift), drawn over the key cap instead of its text
									{
										Primitive = "ImageLabel",
										Id = "S_ButtonIcon",
										Visible = false,
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromOffset(36, 36),
										},
									},
									{
										Primitive = "TextLabel",
										Id = "S_ButtonText",
										Props = {
											AutoLocalize = false,
											BackgroundTransparency = 1,
											FontFace = Font.fromEnum(Enum.Font.GothamMedium),
											Position = UDim2.fromOffset(0, -1),
											Size = UDim2.fromScale(1, 1),
											Text = "E",
											TextColor3 = Color3.new(1, 1, 1),
											TextSize = 14,
											TextXAlignment = Enum.TextXAlignment.Center,
										},
									},

									-- The hold ring, shown only while a hold is under way (its clear halves would still draw a pixel's
									-- edge): two clipped halves of a radial fill, each turned by its gradient as the hold goes on
									{
										Primitive = "Frame",
										Id = "S_CircularProgressBar",
										Visible = false,
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromOffset(58, 58),
										},
										Children = {
											{
												Primitive = "Frame",
												Props = { Name = "LeftGradient", BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.fromScale(0.5, 1) },
												Children = {
													{
														Primitive = "ImageLabel",
														Id = "S_LeftImage",
														Props = {
															BackgroundTransparency = 1,
															Image = "rbxasset://textures/ui/Controls/RadialFill.png",
															Size = UDim2.fromScale(2, 1),
														},
														Children = {
															{
																Primitive = "UIGradient",
																Id = "S_LeftGradient",
																Props = {
																	Rotation = 180,
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 0),
																		NumberSequenceKeypoint.new(0.4999, 0),
																		NumberSequenceKeypoint.new(0.5, 1),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "RightGradient",
													BackgroundTransparency = 1,
													ClipsDescendants = true,
													Position = UDim2.fromScale(0.5, 0),
													Size = UDim2.fromScale(0.5, 1),
												},
												Children = {
													{
														Primitive = "ImageLabel",
														Id = "S_RightImage",
														Props = {
															BackgroundTransparency = 1,
															Image = "rbxasset://textures/ui/Controls/RadialFill.png",
															Position = UDim2.fromScale(-1, 0),
															Size = UDim2.fromScale(2, 1),
														},
														Children = {
															{
																Primitive = "UIGradient",
																Id = "S_RightGradient",
																Props = {
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 0),
																		NumberSequenceKeypoint.new(0.4999, 0),
																		NumberSequenceKeypoint.new(0.5, 1),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
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
					},

					--[[ Texts ]]

					-- Both texts at the left of the text frame, as wide as they are: the object's name 10 px above the middle,
					-- the action 9 px below it (in the middle without an object name)
					{
						Primitive = "Frame",
						Id = "S_TextFrame",
						Props = { AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Size = UDim2.fromScale(0, 1) },
						Children = {
							{
								Primitive = "TextLabel",
								Id = "S_ActionText",
								Props = {
									AutomaticSize = Enum.AutomaticSize.X,
									BackgroundTransparency = 1,
									FontFace = Font.fromEnum(Enum.Font.GothamMedium),
									Position = UDim2.fromOffset(0, 9),
									Size = UDim2.fromScale(0, 1),
									Text = "Open",
									TextColor3 = Color3.new(1, 1, 1),
									TextSize = 19,
									TextXAlignment = Enum.TextXAlignment.Left,
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_ObjectText",
								Props = {
									AutomaticSize = Enum.AutomaticSize.X,
									BackgroundTransparency = 1,
									FontFace = Font.fromEnum(Enum.Font.GothamMedium),
									Position = UDim2.fromOffset(0, -10),
									Size = UDim2.fromScale(0, 1),
									Text = "Chest",
									TextColor3 = Color3.new(0.7, 0.7, 0.7),
									TextSize = 14,
									TextXAlignment = Enum.TextXAlignment.Left,
								},
							},
						},
					},
				},
			},

			-- Takes clicks and touches on the whole prompt, as clickable and touch prompts do
			{
				Primitive = "ImageButton",
				Id = "S_InteractButton",
				Props = { BackgroundTransparency = 1, ImageTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
			},
		},
	},
}

return _gui
