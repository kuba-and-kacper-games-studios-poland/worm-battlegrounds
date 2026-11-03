--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "PluginSettings",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 460, Height = 470 },

	--[[ Tree ]]

	-- A view of the Ume window (Plugin/Ume), which draws the header
	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Scroll",
				Style = { "Flush", "Overlay" },
				Children = {
					{
						Control = "Section",
						Text = "Toolbar",
						Children = {
							-- System shows the dark or light icons to match Studio's theme
							{ Control = "Segmented", Id = "U_IconTheme", Label = "Icons", Options = { "System", "Light", "Dark" }, Value = "System" },
							-- Off shows each tool's glyph alone, without its rounded tile
							{ Control = "Toggle", Id = "U_IconBackground", Label = "Icon background", Value = true },
						},
					},
					{
						Control = "Section",
						Text = "Scraper",
						Children = {
							{ Control = "Slider", Id = "U_EntryShadow", Label = "Entry background shadow", Value = 0.8, Min = 0, Max = 1, Step = 0.01, Format = "Percent" },
						},
					},
				},
			},
		},
	},
}

return _gui
