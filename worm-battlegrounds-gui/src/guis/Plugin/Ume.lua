--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "Ume",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 460, Height = 520 },

	--[[ Tree ]]

	-- The Ume window's frame: a header whose buttons switch between the views drawn under it (Plugin/SessionLock,
	-- Plugin/SavedData, Plugin/PluginSettings)
	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Header",
				Id = "U_Header",
				Text = "Ume",
				-- The round-petal ume blossom in ume violet (ume-branding upload/logos/Ume.png)
				Logo = "rbxassetid://122014786625150",
				Children = {
					{ Control = "IconButton", Id = "S_SessionLock", Icon = "lock-closed", Text = "Session Lock", Style = "Builder" },
					{ Control = "IconButton", Id = "S_SavedData", Icon = "file-box", Text = "Saved Data", Style = "Builder" },
					{ Control = "IconButton", Id = "S_Settings", Icon = "gear", Text = "Settings", Style = "Builder" },
				},
			},
		},
	},
}

return _gui
