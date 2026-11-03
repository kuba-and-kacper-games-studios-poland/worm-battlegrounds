--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "GuiResize",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 280, Height = 420 },

	--[[ Tree ]]

	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Header",
				Text = "Resize",
				-- A double arrow in Resize's blue (ume-branding upload/logos/GuiResize.png)
				Logo = "rbxassetid://108078079406945",
				Children = {
					{
						Control = "Label",
						Id = "U_Count",
						Text = "",
						Style = { "Small", "Dim" },
						Props = { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1) },
					},
				},
			},
			-- Class rows are built from the templates
			{ Control = "Scroll", Id = "U_List", Style = { "List", "Overlay" } },
			{
				Control = "EmptyState",
				Id = "U_Empty",
				Text = "No resizable classes were found.",
				Icon = "frame-corners",
				Visible = false,
			},
			{
				Control = "Footer",
				Children = {
					{ Control = "Segmented", Id = "U_Mode", Options = { "Scale", "Offset" }, Value = "Scale", Style = "Small" },
					{ Control = "Button", Id = "U_Resize", Text = "Resize Selected", Disabled = true, Style = { "Primary", "Small" } },
					{ Control = "Label", Id = "U_Status", Text = "", Align = "Center", Visible = false, Style = { "Small", "Dim" } },
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One class; its properties are built into it the first time it opens
		["PREFAB | Class"] = { Control = "CheckItem", Parent = "U_List", Text = "Class" },
		-- One property of a class; it holds no details, so clicking anywhere on it toggles the property
		["PREFAB | Property"] = { Control = "CheckItem", Text = "Property", Style = { "Small", ShowChevron = false, DetailsPaddingBottom = "None" } },
	},
}

return _gui
