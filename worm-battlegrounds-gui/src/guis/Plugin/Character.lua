--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "Character",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 600, Height = 460 },

	--[[ Tree ]]

	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Header",
				Id = "U_Header",
				Text = "Character",
				-- A blocky character in Character's green (ume-branding upload/logos/Character.png)
				Logo = "rbxassetid://138290763143779",
				Children = {
					{ Control = "IconButton", Id = "S_Me", Icon = "circle-person", Text = "My avatar", Style = "Builder" },
				},
			},
			{
				Control = "Stack",
				Direction = "Horizontal",
				Grow = 1,
				Style = "None",
				Props = { AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.fromScale(1, 0) },
				Children = {
					--[[ Preview: the character in 3D, the field that picks one and Insert ]]

					{
						Control = "Stack",
						Id = "U_Preview",
						Grow = 1,
						Style = { PaddingX = "L", PaddingY = "L", Gap = "M" },
						Props = { AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.fromScale(1, 1) },
						Children = {
							{ Control = "Viewport", Id = "S_Viewport" },
							{
								Control = "Stack",
								Direction = "Horizontal",
								Style = "Buttons",
								Children = {
									{ Control = "Input", Id = "S_Query", Icon = "person", Placeholder = "User ID, username or display name", Grow = 1 },
									{ Control = "Button", Id = "S_Insert", Text = "Insert", Style = "Primary", AutoWidth = true },
								},
							},
							-- Why a lookup or insert failed, or what was inserted; hidden while empty
							{ Control = "Label", Id = "S_Status", Text = "", Style = { "Small", "Dim" }, Visible = false },
						},
					},
					{ Control = "Divider", Direction = "Vertical" },

					--[[ History: the characters inserted last, newest first ]]

					{
						Control = "Stack",
						Id = "U_History",
						Style = "None",
						Props = { AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.new(0, 220, 1, 0) },
						Children = {
							{
								Control = "Stack",
								Direction = "Horizontal",
								Style = { PaddingX = "M", PaddingY = "S", Gap = "S" },
								Children = {
									{ Control = "Label", Id = "S_Title", Text = "Recent", Style = "Caption", Grow = 1 },
									{ Control = "IconButton", Id = "S_Clear", Icon = "trash-can", Style = { "Builder", "Small" } },
								},
							},
							{ Control = "Divider" },
							{ Control = "Scroll", Id = "U_List", Style = { "List", "Overlay" } },
							{
								Control = "EmptyState",
								Id = "S_Empty",
								Text = "Characters you insert show up here.",
								Icon = "clock",
								Visible = false,
							},
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One inserted character: its headshot, display name and username; the one in the preview is outlined
		["PREFAB | HistoryRow"] = {
			Control = "Thumb",
			Parent = "U_List",
			Text = "Character",
			Subtext = "@username",
			Image = "",
			Style = { "Row", Stroke = "Surface", StrokeThickness = "Thick" },
		},

		-- Built into the gui root when needed, then destroyed once answered
		["PREFAB | ConfirmDialog"] = {
			Control = "Dialog",
			Title = "Clear history?",
			Text = "Removes every character from the Recent list. Characters already in the place stay.",
			ConfirmText = "Clear",
			Danger = true,
		},
	},
}

return _gui
