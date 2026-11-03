--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "SavedData",
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
				Control = "Stack",
				Id = "U_Toolbar",
				Direction = "Horizontal",
				Style = { "Buttons", "Bar" },
				Children = {
					{ Control = "IconButton", Id = "S_Refresh", Icon = "arrow-spin-clockwise", Style = { "Builder", Size = "ControlSmall" } },
					{ Control = "Dropdown", Id = "S_Section", Options = { "PluginSettings" }, Value = "PluginSettings", Grow = 1, Style = "Small" },
					{ Control = "IconButton", Id = "S_Import", Icon = "arrow-down-to-line", Style = { "Builder", Size = "ControlSmall" } },
					{ Control = "IconButton", Id = "S_Export", Icon = "arrow-up-from-line", Style = { "Builder", Size = "ControlSmall" } },
					{ Control = "IconButton", Id = "S_Remove", Icon = "trash-can", Style = { "Builder", Size = "ControlSmall" } },
				},
			},
			{ Control = "Divider" },
			{
				Control = "Scroll",
				Id = "U_Body",
				Style = "Overlay",
				Children = {
					{ Control = "Label", Id = "U_Data", Text = "", Style = { "Fixed", Font = "Hint" } },
				},
			},
			{
				Control = "EmptyState",
				Id = "U_Empty",
				Text = "Nothing is saved for this section yet.",
				Icon = "file-box",
				Visible = false,
			},
			{
				Control = "Footer",
				Children = {
					{ Control = "Label", Id = "U_Status", Text = "", Style = { "Small", "Dim" } },
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- Built into the gui root when needed, then destroyed once answered
		["PREFAB | ConfirmDialog"] = { Control = "Dialog", Title = "Are you sure?", ConfirmText = "Confirm", Danger = true },
	},
}

return _gui
