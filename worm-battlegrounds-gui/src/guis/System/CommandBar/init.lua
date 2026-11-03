--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: ume's AdminPanel module finds it as I.UserInterface.UI["CommandBar"]
	Name = "CommandBar",
	Theme = "System",
	-- Hidden until the command bar opens, over every other gui
	Screen = { DisplayOrder = 9999, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- The console and the MouseLockFix that frees the mouse while it shows. Plain instances that hold every value
	-- themselves: one near-black panel with a hairline border, monospaced text, and no outlines or titles. The panel
	-- and its border each carry a UIGradient, off here, that a style turns on
	Root = {
		Primitive = "Folder",
		Children = {
			-- The console, above the bottom edge: the output, then the input under a hairline. 1.5 times larger on Mobile
			{
				Primitive = "Frame",
				Id = "U_CommandBar",
				Tags = { Utils_PlatformScale = { Utils_ConsoleScale = 1, Utils_DesktopScale = 1, Utils_MobileScale = 1.5, Utils_VRScale = 1 } },
				Props = {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = Color3.fromRGB(14, 14, 16),
					BackgroundTransparency = 0.1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.85),
					Size = UDim2.fromScale(0.5, 0.25),
				},
				Children = {
					{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 3 } },
					{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 12) } },
					{
						Primitive = "UIStroke",
						Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 },
						Children = {
							{ Primitive = "UIGradient", Props = { Enabled = false, Rotation = -90 } },
						},
					},
					{ Primitive = "UIGradient", Props = { Enabled = false, Rotation = -90 } },

					--[[ Header ]]

					-- The header along the top, 40 px tall: grabbing it drags the console, kept on screen. A bare transparent
					-- button under the close button, with a dim title on the close button's line
					{
						Primitive = "ImageButton",
						Id = "S_Header",
						Props = {
							AutoButtonColor = false,
							BackgroundTransparency = 1,
							Image = "",
							ImageTransparency = 1,
							Size = UDim2.new(1, 0, 0, 40),
						},
						Children = {
							{
								Primitive = "TextLabel",
								Props = {
									Name = "Title",
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundTransparency = 1,
									FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
									Position = UDim2.fromOffset(14, 20),
									RichText = true,
									Size = UDim2.new(1, -60, 0, 18),
									Text = "Commands",
									TextColor3 = Color3.fromRGB(183, 183, 184),
									TextScaled = true,
									TextSize = 15,
									TextXAlignment = Enum.TextXAlignment.Left,
								},
								Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 15 } } },
							},
						},
					},
					-- The hairline under the header
					{
						Primitive = "Frame",
						Props = {
							Name = "HeaderDivider",
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 0.92,
							BorderSizePixel = 0,
							Position = UDim2.new(0.5, 0, 0, 40),
							Size = UDim2.new(1, 0, 0, 1),
						},
					},

					--[[ Output ]]

					-- The output lines between the header and the input hairline, whatever the console's size, scrolling once
					-- they fill it; Command clones PREFAB | OutputFrame into it
					{
						Primitive = "ScrollingFrame",
						Id = "S_OutputScrollingFrame",
						Props = {
							Active = true,
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							CanvasSize = UDim2.fromScale(0, 0),
							ElasticBehavior = Enum.ElasticBehavior.Never,
							Position = UDim2.fromOffset(14, 48),
							ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
							ScrollBarImageTransparency = 0.75,
							ScrollBarThickness = 3,
							ScrollingDirection = Enum.ScrollingDirection.Y,
							Size = UDim2.new(1, -28, 1, -108),
							VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
						},
						Children = {
							{ Primitive = "UIListLayout", Props = { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder } },
							{ Primitive = "UIPadding", Props = { PaddingRight = UDim.new(0, 8) } },
						},
					},
					-- Closes the command bar: a dimmed X in the top right corner, centred on the header's line and drawn over it.
					-- The container places it; the button is centred in it, so its hover and click scale grow from the middle
					{
						Primitive = "Frame",
						Props = {
							Name = "CloseButtonContainer",
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -12, 0, 12),
							Size = UDim2.fromOffset(16, 16),
							ZIndex = 2,
						},
						Children = {
							{
								Primitive = "ImageButton",
								Id = "S_CloseButton",
								Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.9, Utils_HoverScale = 1.1 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "rbxassetid://99947214964059",
									ImageTransparency = 0.5,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(1, 1),
								},
							},
						},
					},

					--[[ Input ]]

					-- The hairline over the input, a fixed 54 px up from the bottom
					{
						Primitive = "Frame",
						Props = {
							Name = "Divider",
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 0.92,
							BorderSizePixel = 0,
							Position = UDim2.new(0.5, 0, 1, -54),
							Size = UDim2.new(1, 0, 0, 1),
						},
					},
					-- The typing area and the execute button: the bottom 54 px, under the hairline, at any size (ZIndex 2,
					-- so the suggestions that rise from it draw over the output)
					{
						Primitive = "Frame",
						Props = { Name = "Bottom", AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 54), ZIndex = 2 },
						Children = {
							-- The typing area: one line 26 px tall, 14 px in from the left. Command places the caret (at 0.9
							-- of its height, just under the text) and the suggestions in it from the measured text
							{
								Primitive = "Frame",
								Props = {
									Name = "InputContainer",
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.new(0, 14, 0.5, 0),
									Size = UDim2.new(1, -54, 0, 26),
								},
								Children = {
									-- The autocomplete list, rising from just above the input at the end of the typed text;
									-- Command sizes and moves the background with it and clones PREFAB | SuggestionText and
									-- PREFAB | SuggestionSeparator into it
									{
										Primitive = "Frame",
										Props = { Name = "Suggestions", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromScale(2, 1) },
										Children = {
											{
												Primitive = "Frame",
												Id = "S_SuggestionsContainer",
												Props = {
													AnchorPoint = Vector2.new(0, 1),
													AutomaticSize = Enum.AutomaticSize.X,
													BackgroundTransparency = 1,
													Position = UDim2.fromOffset(0, -14),
													Size = UDim2.fromScale(0, 1),
													ZIndex = 10,
												},
												Children = {
													{
														Primitive = "UIListLayout",
														Props = { HorizontalFlex = Enum.UIFlexAlignment.Fill, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom },
													},
												},
											},
											{
												Primitive = "Frame",
												Id = "S_SuggestionsContainerBackground",
												Props = {
													AnchorPoint = Vector2.new(0, 1),
													AutomaticSize = Enum.AutomaticSize.X,
													BackgroundColor3 = Color3.fromRGB(24, 24, 28),
													BorderSizePixel = 0,
													Position = UDim2.fromOffset(0, -14),
													Size = UDim2.fromScale(0.2, 1),
													ZIndex = 9,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
													{ Primitive = "UIStroke", Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 } },
												},
											},
										},
									},
									-- The blinking caret, an underscore about one character wide; Command places it after the
									-- text left of the cursor (S_CursorPosBox)
									{
										Primitive = "Frame",
										Id = "S_Cursor",
										Props = { AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.fromOffset(10, 2), ZIndex = 3 },
									},
									-- Five text boxes laid over each other in one font and size, so Command can measure and
									-- highlight the typed text: S_InputBox takes the typing (its own text is clear), S_DisplayBox
									-- shows it colored, S_SelectionBox the selection; S_CursorPosBox and S_SuggestionPosBox are clear
									-- and only measured. A clipping Frame, not a CanvasGroup, so the text stays sharp
									{
										Primitive = "Frame",
										Props = {
											Name = "TextBoxesContainer",
											AnchorPoint = Vector2.new(0, 0.5),
											BackgroundTransparency = 1,
											ClipsDescendants = true,
											Position = UDim2.fromScale(0.001, 0.5),
											Size = UDim2.fromScale(1, 1),
										},
										Children = {
											{
												Primitive = "TextBox",
												Id = "S_SuggestionPosBox",
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													AutomaticSize = Enum.AutomaticSize.X,
													BackgroundTransparency = 1,
													ClearTextOnFocus = false,
													FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium),
													Interactable = false,
													PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
													Position = UDim2.fromScale(0, 0.5),
													RichText = true,
													Size = UDim2.fromScale(1, 0.7),
													Text = "/alias arg1 arg2",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextEditable = false,
													TextScaled = true,
													TextSize = 17,
													TextTransparency = 1,
													TextTruncate = Enum.TextTruncate.SplitWord,
													TextXAlignment = Enum.TextXAlignment.Left,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 17 } },
													{ Primitive = "UIPadding", Props = { PaddingLeft = UDim.new(0.005, 0), PaddingRight = UDim.new(0.005, 0) } },
												},
											},
											{
												Primitive = "TextBox",
												Id = "S_InputBox",
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													AutomaticSize = Enum.AutomaticSize.X,
													BackgroundTransparency = 1,
													ClearTextOnFocus = false,
													FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium),
													PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
													Position = UDim2.fromScale(0, 0.5),
													RichText = true,
													Size = UDim2.fromScale(1, 0.7),
													Text = "/alias arg1 arg2",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextScaled = true,
													TextSize = 17,
													TextTransparency = 1,
													TextTruncate = Enum.TextTruncate.SplitWord,
													TextXAlignment = Enum.TextXAlignment.Left,
													ZIndex = 2,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 17 } },
													{ Primitive = "UIPadding", Props = { PaddingLeft = UDim.new(0.005, 0), PaddingRight = UDim.new(0.005, 0) } },
												},
											},
											{
												Primitive = "TextBox",
												Id = "S_DisplayBox",
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													AutomaticSize = Enum.AutomaticSize.X,
													BackgroundTransparency = 1,
													ClearTextOnFocus = false,
													FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium),
													Interactable = false,
													PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
													Position = UDim2.fromScale(0, 0.5),
													RichText = true,
													Size = UDim2.fromScale(1, 0.7),
													Text = "/alias arg1 arg2",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextEditable = false,
													TextScaled = true,
													TextSize = 17,
													TextTruncate = Enum.TextTruncate.SplitWord,
													TextXAlignment = Enum.TextXAlignment.Left,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 17 } },
													{ Primitive = "UIPadding", Props = { PaddingLeft = UDim.new(0.005, 0), PaddingRight = UDim.new(0.005, 0) } },
												},
											},
											{
												Primitive = "TextBox",
												Id = "S_CursorPosBox",
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													AutomaticSize = Enum.AutomaticSize.X,
													BackgroundTransparency = 1,
													ClearTextOnFocus = false,
													FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium),
													Interactable = false,
													PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
													Position = UDim2.fromScale(0, 0.5),
													RichText = true,
													Size = UDim2.fromScale(1, 0.7),
													Text = "/alias arg1 arg2",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextEditable = false,
													TextScaled = true,
													TextSize = 17,
													TextTransparency = 1,
													TextTruncate = Enum.TextTruncate.SplitWord,
													TextXAlignment = Enum.TextXAlignment.Left,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 17 } },
													{ Primitive = "UIPadding", Props = { PaddingLeft = UDim.new(0.005, 0), PaddingRight = UDim.new(0.005, 0) } },
												},
											},
											{
												Primitive = "TextBox",
												Id = "S_SelectionBox",
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													AutomaticSize = Enum.AutomaticSize.X,
													BackgroundTransparency = 1,
													ClearTextOnFocus = false,
													FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium),
													Interactable = false,
													PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
													Position = UDim2.fromScale(0, 0.5),
													RichText = true,
													Size = UDim2.fromScale(1, 0.7),
													Text = "",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextEditable = false,
													TextScaled = true,
													TextSize = 17,
													TextTruncate = Enum.TextTruncate.SplitWord,
													TextXAlignment = Enum.TextXAlignment.Left,
													ZIndex = 2,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 17 } },
													{ Primitive = "UIPadding", Props = { PaddingLeft = UDim.new(0.005, 0), PaddingRight = UDim.new(0.005, 0) } },
												},
											},
										},
									},
								},
							},
							-- Runs the typed command: a dimmed > at the input's right end, centred in its container like the close button
							{
								Primitive = "Frame",
								Props = {
									Name = "ExecuteButtonContainer",
									AnchorPoint = Vector2.new(1, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.new(1, -14, 0.5, 0),
									Size = UDim2.fromOffset(18, 18),
								},
								Children = {
									{
										Primitive = "ImageButton",
										Id = "S_ExecuteButton",
										Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.9, Utils_HoverScale = 1.1 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											AutoButtonColor = false,
											BackgroundTransparency = 1,
											Image = "rbxassetid://99734108657425",
											ImageTransparency = 0.4,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromScale(1, 1),
										},
									},
								},
							},
						},
					},

					--[[ Edge Glow ]]

					-- The glow near the pointer that shows an edge can be grabbed: a short white bar laid on an edge, its ends
					-- fading out, or a ring as round as the panel's corners whose gradient lights only the corner's curve.
					-- Hidden (transparency 1) until a driver lights one
					{
						Primitive = "Frame",
						Props = { Name = "EdgeGlow", BackgroundTransparency = 1, Interactable = false, Size = UDim2.fromScale(1, 1), ZIndex = 4 },
						Children = {
							{
								Primitive = "Frame",
								Props = {
									Name = "Segment",
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Size = UDim2.fromOffset(60, 1.5),
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
									{
										Primitive = "UIGradient",
										Props = {
											Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0), NumberSequenceKeypoint.new(0.7, 0), NumberSequenceKeypoint.new(1, 1) }),
										},
									},
								},
							},
							{
								Primitive = "Frame",
								Props = { Name = "Corner", BackgroundTransparency = 1, Size = UDim2.fromOffset(24, 24) },
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 12) } },
									{
										Primitive = "UIStroke",
										Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Thickness = 1.5, Transparency = 1 },
										Children = {
											{
												Primitive = "UIGradient",
												Props = {
													Transparency = NumberSequence.new({
														NumberSequenceKeypoint.new(0, 0),
														NumberSequenceKeypoint.new(0.19, 0),
														NumberSequenceKeypoint.new(0.27, 1),
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

					--[[ Resize ]]

					-- Grab strips along every edge and corner that resize the console: bare transparent buttons over everything
					-- else, shown on Desktop only (Utils_HideOnPlatform). Their frame reaches 10 px past each edge, so a press
					-- just outside the panel grabs too: an edge strip is 16 px thick (6 px inside), a corner 24 px (14 inside)
					{
						Primitive = "Frame",
						Tags = { Utils_HideOnPlatform = { Utils_ConsoleVisibility = false, Utils_MobileVisibility = false, Utils_VRVisibility = false } },
						Props = {
							Name = "ResizeHandles",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.new(1, 20, 1, 20),
							ZIndex = 5,
						},
						Children = {
							{
								Primitive = "ImageButton",
								Id = "S_ResizeTop",
								Props = {
									AnchorPoint = Vector2.new(0, 0),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "",
									ImageTransparency = 1,
									Position = UDim2.fromOffset(24, 0),
									Size = UDim2.new(1, -48, 0, 16),
								},
							},
							{
								Primitive = "ImageButton",
								Id = "S_ResizeBottom",
								Props = {
									AnchorPoint = Vector2.new(0, 1),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "",
									ImageTransparency = 1,
									Position = UDim2.new(0, 24, 1, 0),
									Size = UDim2.new(1, -48, 0, 16),
								},
							},
							{
								Primitive = "ImageButton",
								Id = "S_ResizeLeft",
								Props = {
									AnchorPoint = Vector2.new(0, 0),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "",
									ImageTransparency = 1,
									Position = UDim2.fromOffset(0, 24),
									Size = UDim2.new(0, 16, 1, -48),
								},
							},
							{
								Primitive = "ImageButton",
								Id = "S_ResizeRight",
								Props = {
									AnchorPoint = Vector2.new(1, 0),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "",
									ImageTransparency = 1,
									Position = UDim2.new(1, 0, 0, 24),
									Size = UDim2.new(0, 16, 1, -48),
								},
							},
							{
								Primitive = "ImageButton",
								Id = "S_ResizeTopLeft",
								Props = {
									AnchorPoint = Vector2.new(0, 0),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "",
									ImageTransparency = 1,
									Position = UDim2.fromScale(0, 0),
									Size = UDim2.fromOffset(24, 24),
								},
							},
							{
								Primitive = "ImageButton",
								Id = "S_ResizeTopRight",
								Props = {
									AnchorPoint = Vector2.new(1, 0),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "",
									ImageTransparency = 1,
									Position = UDim2.fromScale(1, 0),
									Size = UDim2.fromOffset(24, 24),
								},
							},
							{
								Primitive = "ImageButton",
								Id = "S_ResizeBottomLeft",
								Props = {
									AnchorPoint = Vector2.new(0, 1),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "",
									ImageTransparency = 1,
									Position = UDim2.fromScale(0, 1),
									Size = UDim2.fromOffset(24, 24),
								},
							},
							{
								Primitive = "ImageButton",
								Id = "S_ResizeBottomRight",
								Props = {
									AnchorPoint = Vector2.new(1, 1),
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Image = "",
									ImageTransparency = 1,
									Position = UDim2.fromScale(1, 1),
									Size = UDim2.fromOffset(24, 24),
								},
							},
						},
					},
				},
			},
			-- A modal button that frees the mouse from shift lock while the command bar is open
			{ Primitive = "ImageButton", Props = { Name = "MouseLockFix", AutoButtonColor = false, BackgroundTransparency = 1, ImageTransparency = 1, Interactable = false, Modal = true, Selectable = false } },
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One output line, as wide as the output and as tall as its wrapped text; Command writes its rich text
		["PREFAB | OutputFrame"] = {
			Primitive = "Frame",
			Props = { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0) },
			Children = {
				{
					Primitive = "TextLabel",
					Props = {
						Name = "OutputText",
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular),
						LineHeight = 1.1,
						RichText = true,
						Size = UDim2.fromScale(1, 0),
						Text = "Example output.",
						TextColor3 = Color3.fromRGB(225, 225, 230),
						TextScaled = true,
						TextSize = 16,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 16 } } },
				},
				{ Primitive = "UIListLayout", Props = { SortOrder = Enum.SortOrder.LayoutOrder } },
			},
		},
		-- One autocomplete entry, a row as tall as the input line; the selected one is colored
		["PREFAB | SuggestionText"] = {
			Primitive = "TextLabel",
			Props = {
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium),
				RichText = true,
				Size = UDim2.fromScale(0, 1),
				Text = "suggestion",
				TextColor3 = Color3.fromRGB(225, 225, 230),
				TextScaled = true,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,
			},
			Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 16 } }, { Primitive = "UIPadding", Props = { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) } } },
		},
		-- A hairline between suggestions of different kinds (commands, arguments)
		["PREFAB | SuggestionSeparator"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 5) },
			Children = {
				{
					Primitive = "Frame",
					Props = {
						Name = "Background",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.9,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -16, 0, 1),
					},
				},
			},
		},
	},
}

return _gui
