--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "UmeGuiTool",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 300, Height = 620 },

	--[[ Tree ]]

	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Scroll",
				Style = { "Flush", "Overlay" },
				Children = {
					-- Its count is how many guis the list shows
					{
						Control = "Section",
						Id = "U_Guis",
						Text = "Guis",
						Count = 0,
						Children = {
							-- Folders under ServerStorage.UmeGui.Guis
							{ Control = "Dropdown", Id = "U_Category", Label = "Category", Options = {}, Placeholder = "Select a category" },
							-- What the guis are drawn on: the list shows the category's guis of this kind
							{
								Control = "Segmented",
								Id = "U_Kind",
								Label = "Kind",
								Options = { "Default", "Surface", "Billboard", "Prompt" },
								Value = "Default",
							},
							{ Control = "Input", Id = "U_Search", Icon = "magnifying-glass", Placeholder = "Search guis" },
							-- One row per gui (PREFAB | GuiRow), the previewed one selected; scrolls past six rows
							{ Control = "ListBox", Id = "U_List" },
							{ Control = "Label", Id = "U_Empty", Text = "No guis of this kind here.", Align = "Center", Visible = false, Style = { "Small", "Dim" } },
						},
					},
					{
						Control = "Section",
						Text = "Reload",
						Children = {
							{ Control = "Toggle", Id = "U_Live", Label = "Live reload", Value = true },
							{
								Control = "Stack",
								Direction = "Horizontal",
								Fill = true,
								Style = "Buttons",
								Children = {
									{ Control = "Button", Id = "U_Refresh", Text = "Refresh" },
									{ Control = "Button", Id = "U_Clear", Text = "Clear" },
								},
							},
						},
					},
					{
						Control = "Section",
						Text = "Sound",
						Children = {
							-- How loud the previewed gui's button sounds play
							{ Control = "Slider", Id = "U_Volume", Label = "Volume", Value = 1, Min = 0, Max = 1, Step = 0.05, Format = "Percent" },
						},
					},
					-- Hidden while the selected gui has no part, devices or modes to switch and no settings
					{
						Control = "Section",
						Id = "U_PreviewSection",
						Text = "Preview",
						Visible = false,
						Children = {
							-- Shown for Surface guis: the part the preview draws the gui on
							{
								Control = "Stack",
								Id = "U_Surface",
								Visible = false,
								Children = {
									{ Control = "VectorInput", Id = "S_PartSize", Label = "Part size", Value = Vector3.new(8, 4.5, 0.5) },
									{
										Control = "Dropdown",
										Id = "S_Face",
										Label = "Face",
										Options = { "Front", "Back", "Left", "Right", "Top", "Bottom" },
										Value = "Front",
									},
								},
							},
							-- Shown only for guis that support more than one device; the Device switch is built in here
							{ Control = "Stack", Id = "U_Device" },
							-- Shown only for guis whose Modes list both Night and Light
							{ Control = "Segmented", Id = "U_Mode", Label = "Mode", Options = { "Night", "Light" }, Value = "Night" },
							-- The selected gui's own settings (its Preview module) are built in here
							{ Control = "Stack", Id = "U_Settings" },
						},
					},
				},
			},
			{
				Control = "Footer",
				Children = {
					{ Control = "Button", Id = "U_Export", Text = "Export to StarterGui", Style = "Primary" },
					{ Control = "Label", Id = "U_Status", Text = "", Visible = false, Style = { "Small", "Dim" } },
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One gui in the list
		["PREFAB | GuiRow"] = { Control = "ListItem", Parent = "U_List", Text = "Gui" },

		-- Shown over the whole widget while the place has no ServerStorage.UmeGui
		["PREFAB | Missing"] = {
			Control = "Dialog",
			Title = "UmeGui is missing",
			Text = "This tool previews the guis in ServerStorage.UmeGui, and this place has none. Sync the game's gui folder (a copy of ume-gui) into the place, or install the plugin's copy of UmeGui to start without one.",
			ConfirmText = "Install UmeGui",
			Dismissible = false,
		},
	},
}

return _gui
