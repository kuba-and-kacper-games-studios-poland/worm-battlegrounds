--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name. The admin tools' second window, next to the CommandBar: Ctrl + ] opens it (ume's
	-- AdminPanel module)
	Name = "Dashboard",
	Theme = "System",
	-- Hidden until the AdminPanel module opens it, under the CommandBar
	Screen = { DisplayOrder = 9990, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- One panel in the CommandBar's look: a near-black panel with a hairline border, a header with the title and a
	-- close X, and an empty body. The panel and its border each carry a UIGradient, off here, that a style turns on. A
	-- driver fills the body from the prefabs below: the rail, the player list, and every player's and module's panel
	Root = {
		Primitive = "Frame",
		Id = "U_Dashboard",
		Tags = { Utils_PlatformScale = { Utils_ConsoleScale = 1, Utils_DesktopScale = 1, Utils_MobileScale = 0.75, Utils_VRScale = 1 } },
		Props = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(14, 14, 16),
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(760, 480),
		},
		Children = {
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

			-- The top 44 px, with the title: a bare transparent button, so a driver can drag the panel by it
			{
				Primitive = "ImageButton",
				Id = "S_Header",
				Props = { AutoButtonColor = false, BackgroundTransparency = 1, Image = "", ImageTransparency = 1, Size = UDim2.new(1, 0, 0, 44) },
				Children = {
					{
						Primitive = "TextLabel",
						Props = {
							Name = "Title",
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
							Position = UDim2.fromOffset(16, 22),
							RichText = true,
							Size = UDim2.fromOffset(90, 18),
							Text = "Dashboard",
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
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.92,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 44),
					Size = UDim2.new(1, 0, 0, 1),
				},
			},
			-- Closes the dashboard: the CommandBar's dimmed X, centred on the header's line and drawn over it
			{
				Primitive = "Frame",
				Props = {
					Name = "CloseButtonContainer",
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -14, 0, 22),
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

			--[[ Body ]]

			-- Everything under the header. Empty: a driver fills it from the prefabs below (the rail, the player list,
			-- hairlines, and the content area a panel is shown in)
			{
				Primitive = "Frame",
				Id = "S_Body",
				Props = { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 45), Size = UDim2.new(1, 0, 1, -45) },
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

			-- Grab strips along every edge and corner that resize the panel: bare transparent buttons over everything
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

	--[[ Templates ]]

	Templates = {
		-- One player in the list: the headshot, the display name over the username, and a "You" badge on the viewer's
		-- own row. A driver fills the row's background and shows its accent bar while it is the selected one
		["PREFAB | PlayerRow"] = {
			Primitive = "ImageButton",
			Tags = { Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "" } },
			Props = {
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Image = "",
				ImageTransparency = 1,
				Size = UDim2.new(1, 0, 0, 46),
			},
			Children = {
				{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
				{
					Primitive = "Frame",
					Id = "S_SelectedBar",
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.fromOffset(3, 20),
						Visible = false,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
					},
				},
				{
					Primitive = "ImageLabel",
					Id = "S_Headshot",
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(40, 40, 44),
						Image = "",
						Position = UDim2.new(0, 10, 0.5, 0),
						Size = UDim2.fromOffset(30, 30),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_DisplayName",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
						Position = UDim2.fromOffset(50, 7),
						RichText = true,
						Size = UDim2.new(1, -96, 0, 18),
						Text = "Player",
						TextColor3 = Color3.fromRGB(230, 230, 234),
						TextScaled = true,
						TextSize = 14,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
				{
					Primitive = "TextLabel",
					Id = "S_Username",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
						Position = UDim2.fromOffset(50, 25),
						RichText = true,
						Size = UDim2.new(1, -96, 0, 14),
						Text = "@player",
						TextColor3 = Color3.fromRGB(150, 150, 156),
						TextScaled = true,
						TextSize = 12,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 12 } } },
				},
				{
					Primitive = "Frame",
					Id = "S_YouBadge",
					Props = {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.88,
						Position = UDim2.new(1, -8, 0.5, 0),
						Size = UDim2.fromOffset(34, 18),
						Visible = false,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
						{
							Primitive = "TextLabel",
							Props = {
								Name = "Label",
								BackgroundTransparency = 1,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
								RichText = true,
								Size = UDim2.fromScale(1, 1),
								Text = "You",
								TextColor3 = Color3.fromRGB(230, 230, 234),
								TextScaled = true,
								TextSize = 11,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 11 } } },
						},
					},
				},
			},
		},
		-- A switch (a perk, or a game setting): its name, and a dot that a driver lights with the accent, with the
		-- button's fill and outline, while it is on. Its grid (or, in a module's section, its driver) sizes the root, a
		-- bare container; the button, S_Button, is centred in it, so its press scale grows from the middle and never
		-- moves the layout
		["PREFAB | ToggleButton"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1 },
			Children = {
				{
					Primitive = "ImageButton",
					Id = "S_Button",
					Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.96, Utils_HoverScale = 1.03 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.95,
						Image = "",
						ImageTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
						{ Primitive = "UIStroke", Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.92 } },
						{
							Primitive = "TextLabel",
							Id = "S_Label",
							Props = {
								BackgroundTransparency = 1,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
								Position = UDim2.fromOffset(12, 0),
								RichText = true,
								Size = UDim2.new(1, -36, 1, 0),
								Text = "Toggle",
								TextColor3 = Color3.fromRGB(200, 200, 206),
								TextScaled = true,
								TextSize = 14,
								TextTruncate = Enum.TextTruncate.AtEnd,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
						},
						{
							Primitive = "Frame",
							Id = "S_State",
							Props = {
								AnchorPoint = Vector2.new(1, 0.5),
								BackgroundColor3 = Color3.fromRGB(80, 80, 86),
								Position = UDim2.new(1, -12, 0.5, 0),
								Size = UDim2.fromOffset(8, 8),
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
							},
						},
					},
				},
			},
		},
		-- A one-off action: its name centred. A driver tints the name red for one that can't be undone. Its grid (or, in
		-- a module's section, its driver) sizes the root, a bare container, with the button (S_Button) centred in it
		["PREFAB | ActionButton"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1 },
			Children = {
				{
					Primitive = "ImageButton",
					Id = "S_Button",
					Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.96, Utils_HoverScale = 1.03 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.95,
						Image = "",
						ImageTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
						{ Primitive = "UIStroke", Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.92 } },
						{
							Primitive = "TextLabel",
							Id = "S_Label",
							Props = {
								BackgroundTransparency = 1,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
								Position = UDim2.fromOffset(8, 0),
								RichText = true,
								Size = UDim2.new(1, -16, 1, 0),
								Text = "Action",
								TextColor3 = Color3.fromRGB(200, 200, 206),
								TextScaled = true,
								TextSize = 14,
								TextTruncate = Enum.TextTruncate.AtEnd,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
						},
					},
				},
			},
		},
		-- One item to give: its icon (a swatch until it has an image) over its name. A driver outlines the picked one
		-- with the accent. Its grid sizes the root, a bare container, with the button (S_Button) centred in it
		["PREFAB | ItemTile"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1 },
			Children = {
				{
					Primitive = "ImageButton",
					Id = "S_Button",
					Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.95,
						Image = "",
						ImageTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 10) } },
						{ Primitive = "UIStroke", Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.92 } },
						{
							Primitive = "ImageLabel",
							Id = "S_Icon",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0),
								BackgroundColor3 = Color3.fromRGB(60, 60, 66),
								Image = "",
								Position = UDim2.new(0.5, 0, 0, 10),
								Size = UDim2.fromOffset(42, 42),
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
							},
						},
						{
							Primitive = "TextLabel",
							Id = "S_Name",
							Props = {
								AnchorPoint = Vector2.new(0.5, 1),
								BackgroundTransparency = 1,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
								Position = UDim2.new(0.5, 0, 1, -9),
								RichText = true,
								Size = UDim2.new(1, -12, 0, 16),
								Text = "Item",
								TextColor3 = Color3.fromRGB(200, 200, 206),
								TextScaled = true,
								TextSize = 13,
								TextTruncate = Enum.TextTruncate.AtEnd,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 13 } } },
						},
					},
				},
			},
		},
		-- One section of a module's panel: its title in capitals over its blocks, which flow left to right and wrap.
		-- A driver sizes each block: buttons and switches sit four to a row, sliders, inputs, choices and info lines take
		-- a row each
		["PREFAB | Section"] = {
			Primitive = "Frame",
			Props = { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0) },
			Children = {
				{ Primitive = "UIListLayout", Props = { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder } },
				{
					Primitive = "TextLabel",
					Id = "S_Title",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
						LayoutOrder = 1,
						RichText = true,
						Size = UDim2.new(1, 0, 0, 14),
						Text = "SECTION",
						TextColor3 = Color3.fromRGB(120, 120, 126),
						TextScaled = true,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 12 } } },
				},
				{
					Primitive = "Frame",
					Id = "S_Blocks",
					Props = { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromScale(1, 0) },
					Children = {
						{
							Primitive = "UIListLayout",
							Props = { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Wraps = true },
						},
					},
				},
			},
		},
		-- A number to drag: its name and its value over a track. A driver moves the fill (in the accent) and the knob to
		-- the value; S_Track, a bare transparent button over the track, takes the drag
		["PREFAB | SliderRow"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44) },
			Children = {
				{
					Primitive = "TextLabel",
					Id = "S_Label",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
						RichText = true,
						Size = UDim2.new(1, -90, 0, 18),
						Text = "Slider",
						TextColor3 = Color3.fromRGB(200, 200, 206),
						TextScaled = true,
						TextSize = 14,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
				{
					Primitive = "TextLabel",
					Id = "S_Value",
					Props = {
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
						Position = UDim2.fromScale(1, 0),
						RichText = true,
						Size = UDim2.fromOffset(90, 18),
						Text = "0",
						TextColor3 = Color3.fromRGB(230, 230, 234),
						TextScaled = true,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Right,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
				{
					Primitive = "ImageButton",
					Id = "S_Track",
					Props = {
						AnchorPoint = Vector2.new(0, 1),
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						Image = "",
						ImageTransparency = 1,
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.new(1, 0, 0, 20),
					},
					Children = {
						{
							Primitive = "Frame",
							Props = {
								Name = "Rail",
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 0.9,
								BorderSizePixel = 0,
								Position = UDim2.fromScale(0, 0.5),
								Size = UDim2.new(1, 0, 0, 4),
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
								{
									Primitive = "Frame",
									Id = "S_Fill",
									Props = { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.fromScale(0.5, 1) },
									Children = {
										{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
									},
								},
							},
						},
						{
							Primitive = "Frame",
							Id = "S_Knob",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(240, 240, 244),
								BorderSizePixel = 0,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromOffset(14, 14),
								ZIndex = 2,
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
							},
						},
					},
				},
			},
		},
		-- A value to type and send: its name, a field, and the button that sends it (centred in its container, so its
		-- press scale never moves the row)
		["PREFAB | InputRow"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34) },
			Children = {
				{
					Primitive = "TextLabel",
					Id = "S_Label",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
						RichText = true,
						Size = UDim2.fromScale(0.32, 1),
						Text = "Input",
						TextColor3 = Color3.fromRGB(200, 200, 206),
						TextScaled = true,
						TextSize = 14,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
				{
					Primitive = "Frame",
					Props = {
						Name = "FieldBox",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.95,
						Position = UDim2.new(0.32, 8, 0, 0),
						Size = UDim2.new(0.68, -108, 1, 0),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
						{ Primitive = "UIStroke", Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.92 } },
						{
							Primitive = "TextBox",
							Id = "S_Field",
							Props = {
								BackgroundTransparency = 1,
								ClearTextOnFocus = false,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
								PlaceholderColor3 = Color3.fromRGB(120, 120, 126),
								PlaceholderText = "",
								Position = UDim2.fromOffset(10, 0),
								RichText = true,
								Size = UDim2.new(1, -20, 1, 0),
								Text = "",
								TextColor3 = Color3.fromRGB(230, 230, 234),
								TextScaled = true,
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
						},
					},
				},
				{
					Primitive = "Frame",
					Props = { Name = "SendContainer", AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 92, 1, 0) },
					Children = {
						{
							Primitive = "ImageButton",
							Id = "S_Send",
							Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								AutoButtonColor = false,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 0.9,
								Image = "",
								ImageTransparency = 1,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
								{
									Primitive = "TextLabel",
									Id = "S_SendLabel",
									Props = {
										BackgroundTransparency = 1,
										FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
										RichText = true,
										Size = UDim2.fromScale(1, 1),
										Text = "Send",
										TextColor3 = Color3.fromRGB(230, 230, 234),
										TextScaled = true,
										TextSize = 14,
									},
									Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
								},
							},
						},
					},
				},
			},
		},
		-- One of several options to pick: its name and a row of pills (PREFAB | ChoiceOption) in S_Options, which wraps
		-- onto more lines in a narrow panel, the picked one filled with the accent
		["PREFAB | ChoiceRow"] = {
			Primitive = "Frame",
			Props = { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30) },
			Children = {
				{
					Primitive = "TextLabel",
					Id = "S_Label",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
						RichText = true,
						Size = UDim2.new(0.32, 0, 0, 30),
						Text = "Choice",
						TextColor3 = Color3.fromRGB(200, 200, 206),
						TextScaled = true,
						TextSize = 14,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
				{
					Primitive = "Frame",
					Id = "S_Options",
					Props = { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.new(0.32, 8, 0, 0), Size = UDim2.new(0.68, -8, 0, 30) },
					Children = {
						{
							Primitive = "UIListLayout",
							Props = { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Wraps = true },
						},
					},
				},
			},
		},
		-- One option pill: a bare container (a driver sizes it to its text) with the button, S_Button, centred in it
		["PREFAB | ChoiceOption"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.fromOffset(72, 30) },
			Children = {
				{
					Primitive = "ImageButton",
					Id = "S_Button",
					Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.95,
						Image = "",
						ImageTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
						{
							Primitive = "TextLabel",
							Id = "S_Label",
							Props = {
								BackgroundTransparency = 1,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
								RichText = true,
								Size = UDim2.fromScale(1, 1),
								Text = "Option",
								TextColor3 = Color3.fromRGB(200, 200, 206),
								TextScaled = true,
								TextSize = 14,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
						},
					},
				},
			},
		},
		-- A read-only line: what it shows on the left, dimmed, and its value on the right
		["PREFAB | InfoRow"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22) },
			Children = {
				{
					Primitive = "TextLabel",
					Id = "S_Label",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
						RichText = true,
						Size = UDim2.new(1, -120, 1, 0),
						Text = "Info",
						TextColor3 = Color3.fromRGB(150, 150, 156),
						TextScaled = true,
						TextSize = 14,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
				{
					Primitive = "TextLabel",
					Id = "S_Value",
					Props = {
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
						Position = UDim2.fromScale(1, 0),
						RichText = true,
						Size = UDim2.new(0, 120, 1, 0),
						Text = "",
						TextColor3 = Color3.fromRGB(230, 230, 234),
						TextScaled = true,
						TextSize = 14,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Right,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
			},
		},

		--[[ Body ]]

		-- A searchable list: a search box over S_List (player rows), and a line shown when the search hides every row. A
		-- driver sizes and places it
		["PREFAB | ListColumn"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.new(0, 220, 1, 0) },
			Children = {
				{
					Primitive = "Frame",
					Props = {
						Name = "SearchBox",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.95,
						Position = UDim2.fromOffset(12, 12),
						Size = UDim2.new(1, -24, 0, 32),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
						{ Primitive = "UIStroke", Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.92 } },
						{
							Primitive = "TextBox",
							Id = "S_Search",
							Props = {
								BackgroundTransparency = 1,
								ClearTextOnFocus = false,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
								PlaceholderColor3 = Color3.fromRGB(120, 120, 126),
								PlaceholderText = "Search",
								Position = UDim2.fromOffset(10, 0),
								RichText = true,
								Size = UDim2.new(1, -20, 1, 0),
								Text = "",
								TextColor3 = Color3.fromRGB(230, 230, 234),
								TextScaled = true,
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
						},
					},
				},
				{
					Primitive = "ScrollingFrame",
					Id = "S_List",
					Props = {
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						CanvasSize = UDim2.fromScale(0, 0),
						Position = UDim2.fromOffset(8, 52),
						ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
						ScrollBarImageTransparency = 0.75,
						ScrollBarThickness = 3,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						Size = UDim2.new(1, -16, 1, -60),
						VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
					},
					Children = {
						{ Primitive = "UIListLayout", Props = { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Empty",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
						Position = UDim2.fromOffset(14, 62),
						RichText = true,
						Size = UDim2.new(1, -28, 0, 18),
						Text = "Nothing matches",
						TextColor3 = Color3.fromRGB(120, 120, 126),
						TextScaled = true,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						Visible = false,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 13 } } },
				},
			},
		},
		-- A hairline between parts of the body (white at 0.92), which a driver sizes: 1 px wide or 1 px tall
		["PREFAB | Divider"] = {
			Primitive = "Frame",
			Props = { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92, BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, 0) },
		},
		-- Where a panel is shown: its header (PREFAB | PanelHeader), then its sections, 18 px apart and padded 16 px. A
		-- driver sizes and places it
		["PREFAB | Content"] = {
			Primitive = "ScrollingFrame",
			Props = {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromScale(0, 0),
				ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
				ScrollBarImageTransparency = 0.75,
				ScrollBarThickness = 3,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				Size = UDim2.fromScale(1, 1),
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			},
			Children = {
				{
					Primitive = "UIPadding",
					Props = { PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 18), PaddingTop = UDim.new(0, 16) },
				},
				{ Primitive = "UIListLayout", Props = { Padding = UDim.new(0, 18), SortOrder = Enum.SortOrder.LayoutOrder } },
			},
		},
		-- A panel's header: its icon (a player's round headshot, a module's swatch with its initial, S_Letter, until it has
		-- an image), its name, what it is for, and a rich-text stats line a player's panel fills
		["PREFAB | PanelHeader"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56) },
			Children = {
				{
					Primitive = "ImageLabel",
					Id = "S_Icon",
					Props = { BackgroundColor3 = Color3.fromRGB(60, 60, 66), Image = "", Size = UDim2.fromOffset(56, 56) },
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 12) } },
						{
							Primitive = "TextLabel",
							Id = "S_Letter",
							Props = {
								BackgroundTransparency = 1,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.ExtraBold),
								RichText = true,
								Size = UDim2.fromScale(1, 1),
								Text = "",
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextScaled = true,
								TextSize = 26,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 26 } } },
						},
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Name",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
						Position = UDim2.fromOffset(70, 2),
						RichText = true,
						Size = UDim2.new(1, -70, 0, 22),
						Text = "Panel",
						TextColor3 = Color3.fromRGB(240, 240, 244),
						TextScaled = true,
						TextSize = 19,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 19 } } },
				},
				{
					Primitive = "TextLabel",
					Id = "S_Description",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
						Position = UDim2.fromOffset(70, 24),
						RichText = true,
						Size = UDim2.new(1, -70, 0, 16),
						Text = "",
						TextColor3 = Color3.fromRGB(150, 150, 156),
						TextScaled = true,
						TextSize = 14,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
				{
					Primitive = "TextLabel",
					Id = "S_Stats",
					Props = {
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
						Position = UDim2.fromOffset(70, 42),
						RichText = true,
						Size = UDim2.new(1, -70, 0, 16),
						Text = "",
						TextColor3 = Color3.fromRGB(120, 120, 126),
						TextScaled = true,
						TextSize = 13,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 13 } } },
				},
			},
		},
		-- A column of icon buttons down the left edge, 56 px wide (PREFAB | RailButton clones and short hairlines)
		["PREFAB | Rail"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.new(0, 56, 1, 0) },
			Children = {
				{ Primitive = "UIPadding", Props = { PaddingTop = UDim.new(0, 10) } },
				{ Primitive = "UIListLayout", Props = { HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder } },
			},
		},
		-- One icon in the rail: a 40 px container with S_Button centred in it holding S_Icon (a swatch with its page's
		-- initial, S_Letter, until it has an image), and S_SelectedBar at the rail's edge while it is the picked one
		["PREFAB | RailButton"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.fromOffset(40, 40) },
			Children = {
				{
					Primitive = "Frame",
					Id = "S_SelectedBar",
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.new(0, -8, 0.5, 0),
						Size = UDim2.fromOffset(3, 20),
						Visible = false,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
					},
				},
				{
					Primitive = "ImageButton",
					Id = "S_Button",
					Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.06 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Image = "",
						ImageTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 10) } },
						{
							Primitive = "ImageLabel",
							Id = "S_Icon",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(60, 60, 66),
								Image = "",
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromOffset(28, 28),
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
								{
									Primitive = "TextLabel",
									Id = "S_Letter",
									Props = {
										BackgroundTransparency = 1,
										FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.ExtraBold),
										RichText = true,
										Size = UDim2.fromScale(1, 1),
										Text = "",
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextScaled = true,
										TextSize = 15,
									},
									Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 15 } } },
								},
							},
						},
					},
				},
			},
		},
		-- The Give block of a player's panel: the items, five to a row (PREFAB | ItemTile), and a bar to give the picked
		-- one: how many, the Give button (filled with the accent) and a line saying what it gives or gave
		["PREFAB | GiveBlock"] = {
			Primitive = "Frame",
			Props = { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0) },
			Children = {
				{ Primitive = "UIListLayout", Props = { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder } },
				{
					Primitive = "Frame",
					Id = "S_Items",
					Props = { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1, 0) },
					Children = {
						{ Primitive = "UIGridLayout", Props = { CellPadding = UDim2.fromOffset(8, 8), CellSize = UDim2.fromOffset(92, 86), SortOrder = Enum.SortOrder.LayoutOrder } },
					},
				},
				{
					Primitive = "Frame",
					Props = { Name = "GiveBar", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 34) },
					Children = {
						{
							Primitive = "UIListLayout",
							Props = { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center },
						},
						{
							Primitive = "Frame",
							Props = { Name = "AmountBox", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.95, LayoutOrder = 1, Size = UDim2.new(0, 92, 1, 0) },
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
								{ Primitive = "UIStroke", Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.92 } },
								{
									Primitive = "TextBox",
									Id = "S_Amount",
									Props = {
										BackgroundTransparency = 1,
										ClearTextOnFocus = false,
										FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
										PlaceholderColor3 = Color3.fromRGB(120, 120, 126),
										PlaceholderText = "Amount",
										RichText = true,
										Size = UDim2.fromScale(1, 1),
										Text = "1",
										TextColor3 = Color3.fromRGB(230, 230, 234),
										TextScaled = true,
										TextSize = 14,
									},
									Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
								},
							},
						},
						{
							Primitive = "Frame",
							Props = { Name = "GiveContainer", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.new(0, 92, 1, 0) },
							Children = {
								{
									Primitive = "ImageButton",
									Id = "S_Give",
									Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.04 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
									Props = {
										AnchorPoint = Vector2.new(0.5, 0.5),
										AutoButtonColor = false,
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										Image = "",
										ImageTransparency = 1,
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.fromScale(1, 1),
									},
									Children = {
										{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
										{
											Primitive = "TextLabel",
											Id = "S_GiveLabel",
											Props = {
												BackgroundTransparency = 1,
												FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
												RichText = true,
												Size = UDim2.fromScale(1, 1),
												Text = "Give",
												TextColor3 = Color3.fromRGB(14, 14, 16),
												TextScaled = true,
												TextSize = 14,
											},
											Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
										},
									},
								},
							},
						},
						{
							Primitive = "TextLabel",
							Id = "S_GiveHint",
							Props = {
								BackgroundTransparency = 1,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
								LayoutOrder = 3,
								RichText = true,
								Size = UDim2.new(1, -200, 1, 0),
								Text = "Pick an item to give",
								TextColor3 = Color3.fromRGB(150, 150, 156),
								TextScaled = true,
								TextSize = 13,
								TextTruncate = Enum.TextTruncate.AtEnd,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 13 } } },
						},
					},
				},
			},
		},
		-- The search page: a search box across the top, over what it finds in groups (PREFAB | Section clones whose blocks
		-- are PREFAB | LauncherTile clones), and a line shown when nothing matches
		["PREFAB | Launcher"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) },
			Children = {
				{
					Primitive = "Frame",
					Props = {
						Name = "SearchBox",
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.95,
						Position = UDim2.new(0.5, 0, 0, 16),
						Size = UDim2.new(1, -48, 0, 40),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 10) } },
						{ Primitive = "UIStroke", Props = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.92 } },
						{
							Primitive = "ImageLabel",
							Props = {
								Name = "SearchIcon",
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = 1,
								Image = "rbxassetid://70531937773504",
								ImageColor3 = Color3.fromRGB(150, 150, 156),
								Position = UDim2.new(0, 14, 0.5, 0),
								Size = UDim2.fromOffset(18, 18),
							},
						},
						{
							Primitive = "TextBox",
							Id = "S_Search",
							Props = {
								BackgroundTransparency = 1,
								ClearTextOnFocus = false,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
								PlaceholderColor3 = Color3.fromRGB(120, 120, 126),
								PlaceholderText = "Search players and modules",
								Position = UDim2.fromOffset(42, 0),
								RichText = true,
								Size = UDim2.new(1, -56, 1, 0),
								Text = "",
								TextColor3 = Color3.fromRGB(230, 230, 234),
								TextScaled = true,
								TextSize = 15,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 15 } } },
						},
					},
				},
				{
					Primitive = "ScrollingFrame",
					Id = "S_Results",
					Props = {
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						CanvasSize = UDim2.fromScale(0, 0),
						Position = UDim2.fromOffset(0, 72),
						ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
						ScrollBarImageTransparency = 0.75,
						ScrollBarThickness = 3,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						Size = UDim2.new(1, 0, 1, -72),
						VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
					},
					Children = {
						{ Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 24), PaddingRight = UDim.new(0, 24) } },
						{ Primitive = "UIListLayout", Props = { Padding = UDim.new(0, 18), SortOrder = Enum.SortOrder.LayoutOrder } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Empty",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
						Position = UDim2.new(0.5, 0, 0, 96),
						RichText = true,
						Size = UDim2.new(1, -48, 0, 18),
						Text = "Nothing matches",
						TextColor3 = Color3.fromRGB(120, 120, 126),
						TextScaled = true,
						TextSize = 14,
						Visible = false,
					},
					Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 14 } } },
				},
			},
		},
		-- One page in the search, like an icon on a desktop: a 96 × 96 px container with S_Button centred in it, holding
		-- S_Icon (a 52 px headshot, image, or swatch with its initial, S_Letter) over S_Name
		["PREFAB | LauncherTile"] = {
			Primitive = "Frame",
			Props = { BackgroundTransparency = 1, Size = UDim2.fromOffset(96, 96) },
			Children = {
				{
					Primitive = "ImageButton",
					Id = "S_Button",
					Tags = { Utils_ButtonScale = { Utils_ClickScale = 0.95, Utils_HoverScale = 1.05 }, Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" } },
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Image = "",
						ImageTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 12) } },
						{
							Primitive = "ImageLabel",
							Id = "S_Icon",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0),
								BackgroundColor3 = Color3.fromRGB(60, 60, 66),
								Image = "",
								Position = UDim2.new(0.5, 0, 0, 8),
								Size = UDim2.fromOffset(52, 52),
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 14) } },
								{
									Primitive = "TextLabel",
									Id = "S_Letter",
									Props = {
										BackgroundTransparency = 1,
										FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.ExtraBold),
										RichText = true,
										Size = UDim2.fromScale(1, 1),
										Text = "",
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextScaled = true,
										TextSize = 24,
									},
									Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 24 } } },
								},
							},
						},
						{
							Primitive = "TextLabel",
							Id = "S_Name",
							Props = {
								AnchorPoint = Vector2.new(0.5, 1),
								BackgroundTransparency = 1,
								FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
								Position = UDim2.new(0.5, 0, 1, -8),
								RichText = true,
								Size = UDim2.new(1, -8, 0, 16),
								Text = "Page",
								TextColor3 = Color3.fromRGB(200, 200, 206),
								TextScaled = true,
								TextSize = 13,
								TextTruncate = Enum.TextTruncate.AtEnd,
							},
							Children = { { Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 13 } } },
						},
					},
				},
			},
		},
	},
}

return _gui
