--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "LightingManager",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 320, Height = 480 },

	--[[ Tree ]]

	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Header",
				Id = "U_Header",
				Text = "Lighting Manager",
				-- A sun in Lighting's amber (ume-branding upload/logos/LightingManager.png)
				Logo = "rbxassetid://137997376374716",
				Children = {
					{ Control = "IconButton", Id = "S_Lighting", Icon = "sun", Text = "Lighting", Style = "Builder" },
					{ Control = "IconButton", Id = "S_Sky", Icon = "cloud", Text = "Sky", Style = "Builder" },
				},
			},
			{
				Primitive = "Frame",
				Id = "U_Pages",
				Grow = 1,
				Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 0) },
				Children = {
					--[[ Lighting ]]

					{
						Control = "Panel",
						Id = "U_LightingPage",
						Children = {
							{
								Control = "Stack",
								Id = "U_Toolbar",
								Style = "Bar",
								Children = {
									-- Selected while picking a preset also puts its Sky on Lighting
									{
										Control = "Stack",
										Direction = "Horizontal",
										Fill = true,
										Style = "Buttons",
										Children = {
											{ Control = "IconButton", Id = "S_ApplySky", Icon = "cloud", Text = "Apply sky", Style = { "Builder", "Wide" } },
										},
									},
									{ Control = "Segmented", Id = "S_View", Options = { "Local", "Global", "Presets" }, Value = "Local", Style = "Small" },
									{ Control = "Input", Id = "S_Search", Icon = "magnifying-glass", Placeholder = "Search presets", Style = "Small" },
								},
							},
							{ Control = "Divider" },

							--[[ Local ]]

							{ Control = "Scroll", Id = "U_LocalList", Style = { "Tight", "Overlay" } },

							--[[ Global ]]

							{ Control = "Scroll", Id = "U_GlobalList", Style = { "Tight", "Overlay" }, Visible = false },
							{
								Control = "EmptyState",
								Id = "U_GlobalEmpty",
								Text = "No saved presets yet. Right-click a local preset and pick Save to global.",
								Icon = "file-box",
								Visible = false,
							},

							--[[ Presets: one section per category, built by the tool ]]

							{ Control = "Scroll", Id = "U_PresetList", Style = { "Flush", "Overlay" }, Visible = false },

							--[[ Footer, on the Local view ]]

							{
								Control = "Footer",
								Id = "U_Footer",
								Children = {
									{ Control = "Button", Id = "U_New", Text = "New preset", Style = "Primary" },
								},
							},
						},
					},

					--[[ Sky: one section per category, built by the tool ]]

					{
						Control = "Panel",
						Id = "U_SkyPage",
						Visible = false,
						Children = {
							{ Control = "Scroll", Id = "U_SkyList", Style = { "Flush", "Overlay" } },
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- Built into the gui root while Lighting has no __config; only Initialize answers it
		["PREFAB | Setup"] = {
			Control = "Dialog",
			Title = "Lighting is not set up",
			Text = "This place has no lighting presets yet. Initialize saves the current Lighting as the Default preset in Lighting.__config.",
			ConfirmText = "Initialize",
			Dismissible = false,
		},

		-- Built into the gui root when needed, then destroyed once answered
		["PREFAB | NewPreset"] = {
			Control = "Dialog",
			Title = "New preset",
			Text = "The current lighting is stored in Lighting.Presets.",
			Input = "",
			Placeholder = "Preset name",
			ConfirmText = "Create",
			Children = {
				{ Control = "Segmented", Id = "S_Start", Label = "Start from", Options = { "Copy", "Empty" }, Value = "Copy" },
			},
		},
		["PREFAB | ConfirmDialog"] = { Control = "Dialog", Title = "Are you sure?", ConfirmText = "Confirm", Danger = true },
		-- Opened from a saved preset's menu, holding its current name
		["PREFAB | RenamePreset"] = { Control = "Dialog", Title = "Rename preset", Input = "", Placeholder = "Preset name", ConfirmText = "Rename" },
		-- Opened from a row's menu; the tool fills the chips with Auto and every landscape
		["PREFAB | Background"] = {
			Control = "Dialog",
			Title = "Background",
			Text = "The landscape this preset's row shows. Auto picks one from the preset's name.",
			ConfirmText = "Apply",
			Children = {
				{ Control = "Chips", Id = "S_Landscape", Options = { "Auto" }, Value = "Auto" },
			},
		},

		-- One category of the plugin's presets in the Presets list
		["PREFAB | Category"] = { Control = "Section", Text = "Category", Count = 0, Parent = "U_PresetList" },

		-- One preset in a list: its Id and instances over a scene the tool draws from its lighting; the active one is outlined
		["PREFAB | PresetRow"] = { Control = "Thumb", Text = "Preset", Subtext = "", Style = "Banner" },

		-- One category of skies on the Sky page, holding a grid of them
		["PREFAB | SkyCategory"] = { Control = "Section", Text = "Category", Count = 0, Parent = "U_SkyList" },
		["PREFAB | SkyGrid"] = { Control = "Grid", Style = "Tight" },
		-- One sky: its front face under its name; the one Lighting shows is outlined
		["PREFAB | Sky"] = { Control = "Thumb", Text = "Sky", Image = "" },
	},
}

return _gui
