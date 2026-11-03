--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "SavedDataTransfer",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 360, Height = 420 },

	--[[ Tree ]]

	Root = {
		Control = "Panel",
		Children = {
			-- The round-petal ume blossom of the Ume window this belongs to (ume-branding upload/logos/Ume.png)
			{ Control = "Header", Id = "U_Header", Text = "Export", Logo = "rbxassetid://122014786625150" },
			{
				Control = "Scroll",
				Style = "Overlay",
				Children = {
					{ Control = "Label", Id = "U_Message", Text = "", Style = "Dim" },
					{ Control = "Stack", Id = "U_Rows", Style = "Snug" },
				},
			},
			{
				Control = "Footer",
				Children = {
					{ Control = "Segmented", Id = "U_Mode", Label = "Import mode", Options = { "Append", "Overwrite" }, Value = "Append" },
					{ Control = "Label", Id = "U_Status", Text = "", Style = { "Small", "Dim" } },
					{
						Control = "Stack",
						Direction = "Horizontal",
						Fill = true,
						Style = "Buttons",
						Children = {
							{ Control = "Button", Id = "U_Secondary", Text = "Add files" },
							{ Control = "Button", Id = "U_Primary", Text = "Import", Style = "Primary" },
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One export part, with a button that saves it to a file
		["PREFAB | PartRow"] = { Control = "ListCard", Parent = "U_Rows", Text = "Part", Subtext = "Not saved", Actions = { "Save" } },
		-- One import part or file
		["PREFAB | FileRow"] = { Control = "ListCard", Parent = "U_Rows", Text = "Part", Subtext = "Missing", Style = "Subtle" },
	},
}

return _gui
