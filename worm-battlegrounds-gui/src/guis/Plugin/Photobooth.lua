--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "Photobooth",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 360, Height = 640 },

	--[[ Tree ]]

	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Header",
				Id = "U_Header",
				Text = "Photobooth",
				-- A camera in Photobooth's orange (ume-branding upload/logos/Photobooth.png)
				Logo = "rbxassetid://75947878651264",
				Children = {
					{ Control = "IconButton", Id = "S_Overlay", Icon = "frame-corners", Style = "Builder" },
					{ Control = "IconButton", Id = "S_BoothOn", Icon = "photo-camera", Style = "Builder" },
				},
			},
			{
				Control = "Tabs",
				Id = "U_Tabs",
				Options = { "Models", "Settings" },
				Value = "Models",
				Children = {
					--[[ Models ]]

					{
						Control = "Panel",
						Children = {
							{
								Control = "Stack",
								Id = "U_Views",
								Style = { "Snug", "Bar" },
								Children = {
									{
										Control = "Stack",
										Direction = "Horizontal",
										Fill = true,
										Style = "Buttons",
										Children = {
											{ Control = "Button", Id = "S_Front", Text = "Front", Style = "Small" },
											{ Control = "Button", Id = "S_Side", Text = "Side", Style = "Small" },
											{ Control = "Button", Id = "S_Top", Text = "Top", Style = "Small" },
										},
									},
									{ Control = "Slider", Id = "S_Yaw", Label = "Yaw", Value = -145, Min = -180, Max = 180, Step = 1, Format = "{}°" },
									{ Control = "Slider", Id = "S_Pitch", Label = "Pitch", Value = 20, Min = -90, Max = 90, Step = 1, Format = "{}°" },
									{ Control = "Slider", Id = "S_Zoom", Label = "Zoom", Value = 100, Min = 25, Max = 400, Step = 1, Format = "{}%" },
								},
							},
							{ Control = "Divider" },
							{
								Control = "Scroll",
								Id = "U_ModelsBody",
								Style = "Overlay",
								Children = {
									{ Control = "Grid", Id = "U_Models", MinCellWidth = 150 },
								},
							},
							{
								Control = "EmptyState",
								Id = "U_Empty",
								Text = "Select models in the Explorer, then press Import selected.",
								Icon = "arrow-up-from-line",
								Visible = false,
							},
							{
								Control = "Footer",
								Children = {
									{
										Control = "Stack",
										Direction = "Horizontal",
										Style = "Buttons",
										Children = {
											{ Control = "Button", Id = "U_Import", Text = "Import selected", Grow = 1 },
											{ Control = "Button", Id = "U_Export", Text = "Export all", Style = "Primary", Grow = 1 },
											{ Control = "IconButton", Id = "U_Clear", Icon = "trash-can", Style = { "Builder", Size = "Control" } },
										},
									},
								},
							},
						},
					},

					--[[ Settings ]]

					{
						Control = "Panel",
						Children = {
							{
								Control = "Tabs",
								Id = "U_SettingsTabs",
								Options = { "Baseplate", "Model", "Camera", "Export" },
								Value = "Baseplate",
								Shared = 2,
								Children = {
									--[[ Presets, for every page ]]

									{
										Control = "Stack",
										Id = "U_Presets",
										Direction = "Horizontal",
										Style = { "Buttons", "Bar" },
										Children = {
											{ Control = "Dropdown", Id = "S_Picker", Options = { "Default" }, Value = "Default", Grow = 1 },
											{ Control = "IconButton", Id = "S_Save", Icon = "floppy-disk", Style = { "Builder", Size = "Control" } },
											{ Control = "IconButton", Id = "S_SaveAs", Icon = "plus-large", Style = { "Builder", Size = "Control" } },
										},
									},
									{ Control = "Divider" },

									--[[ Baseplate ]]

									{
										Control = "Scroll",
										Style = { "Flush", "Overlay" },
										Children = {
											{
												Control = "Section",
												Text = "Floor",
												Children = {
													{ Control = "Dropdown", Id = "U_Preset", Label = "Look", Options = { "Texture" }, Value = "Texture" },
													{ Control = "Dropdown", Id = "U_Material", Label = "Material", Options = { "Plastic" }, Value = "Plastic" },
													{ Control = "Input", Id = "U_CustomTexture", Label = "Texture", Value = "rbxassetid://6372755229", Placeholder = "rbxassetid:// or id" },
													{ Control = "Slider", Id = "U_TextureTransparency", Label = "Texture transparency", Value = 0.8, Min = 0, Max = 1, Step = 0.05, Format = "Percent" },
													{ Control = "Slider", Id = "U_BaseplateSize", Label = "Size", Value = 64, Min = 16, Max = 512, Step = 4, Format = "{} studs" },
													{ Control = "VectorInput", Id = "U_Position", Label = "Position", Value = Vector3.new(2000, 0, 2000) },
												},
											},
											{
												Control = "Section",
												Id = "U_Colors",
												Text = "Colors",
												Children = {
													{ Control = "ColorPicker", Id = "S_Baseplate", Label = "Baseplate", Value = Color3.fromRGB(91, 91, 91), Inputs = true },
													{ Control = "ColorPicker", Id = "S_Texture", Label = "Texture", Value = Color3.new(0, 0, 0), Inputs = true },
												},
											},
										},
									},

									--[[ Model ]]

									{
										Control = "Scroll",
										Style = "Overlay",
										Children = {
											{ Control = "VectorInput", Id = "U_ModelOffset", Label = "Offset", Value = Vector3.zero },
										},
									},

									--[[ Camera ]]

									{
										Control = "Scroll",
										Style = { "Flush", "Overlay" },
										Children = {
											{
												Control = "Section",
												Text = "View",
												Children = {
													{ Control = "Slider", Id = "U_Fill", Label = "Fill", Value = 80, Min = 10, Max = 100, Step = 1, Format = "{}%" },
													{ Control = "Slider", Id = "U_Yaw", Label = "Yaw", Value = -145, Min = -180, Max = 180, Step = 1, Format = "{}°" },
													{ Control = "Slider", Id = "U_Pitch", Label = "Pitch", Value = 20, Min = -80, Max = 80, Step = 1, Format = "{}°" },
													{ Control = "Dropdown", Id = "U_OrbitMode", Label = "Orbit", Options = { "Model center" }, Value = "Model center" },
												},
											},
											{
												Control = "Section",
												Id = "U_Random",
												Text = "Random",
												Children = {
													{ Control = "Toggle", Id = "S_Enabled", Label = "Vary each export", Value = false },
													{ Control = "RangeSlider", Id = "S_Yaw", Label = "Yaw", Value = NumberRange.new(-30, 30), Min = -180, Max = 180, Step = 1, Format = "{}°" },
													{ Control = "RangeSlider", Id = "S_Pitch", Label = "Pitch", Value = NumberRange.new(-10, 10), Min = -80, Max = 80, Step = 1, Format = "{}°" },
													{ Control = "RangeSlider", Id = "S_Zoom", Label = "Zoom", Value = NumberRange.new(90, 110), Min = 50, Max = 200, Step = 1, Format = "{}%" },
												},
											},
										},
									},

									--[[ Export ]]

									{
										Control = "Scroll",
										Style = "Overlay",
										Children = {
											{
												Control = "Stack",
												Direction = "Horizontal",
												Fill = true,
												Style = "Buttons",
												Children = {
													{ Control = "Dropdown", Id = "U_ExportSize", Label = "Image size", Options = { "1024" }, Value = "1024" },
													{ Control = "Dropdown", Id = "U_AspectRatio", Label = "Aspect ratio", Options = { "1:1" }, Value = "1:1" },
												},
											},
											{ Control = "Toggle", Id = "U_IncludeSky", Label = "Include sky", Value = true },
											{ Control = "Toggle", Id = "U_IncludeBaseplate", Label = "Include baseplate", Value = true },
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

	--[[ Templates ]]

	Templates = {
		-- Built into the gui root when needed, then destroyed once answered
		["PREFAB | ConfirmDialog"] = { Control = "Dialog", Title = "Are you sure?", ConfirmText = "Confirm", Danger = true },
		["PREFAB | NameDialog"] = { Control = "Dialog", Title = "Name", Input = "", ConfirmText = "Save" },

		["PREFAB | ModelTile"] = {
			Control = "Tile",
			Parent = "U_Models",
			Text = "Model",
			Subtext = "Default view",
			LeftActions = { { Id = "Remove", Icon = "trash-can" } },
			RightActions = {
				{ Id = "Save", Icon = "floppy-disk" },
				{ Id = "Reset", Icon = "arrow-spin-counter-clockwise" },
			},
		},
	},
}

return _gui
