--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "Sync",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 340, Height = 420 },

	--[[ Tree ]]

	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Header",
				Id = "U_Header",
				Text = "Sync",
				-- The ume blossom in ume-sync's violet (ume-branding upload/logos/Sync.png)
				Logo = "rbxassetid://121242004316954",
				Children = {
					{ Control = "IconButton", Id = "S_Projects", Icon = "folders", Text = "Projects", Style = "Builder" },
					{ Control = "IconButton", Id = "S_Settings", Icon = "gear", Text = "Settings", Style = "Builder" },
				},
			},
			{
				Primitive = "Frame",
				Id = "U_Pages",
				Grow = 1,
				Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 0) },
				Children = {
					--[[ Projects ]]

					{
						Control = "Panel",
						Id = "U_ProjectsPage",
						Children = {
							{
								Control = "Stack",
								Style = "Bar",
								Children = {
									-- The ume-sync app on this machine
									{ Control = "Card", Id = "U_Hub", Caption = "ume-sync app", Text = "127.0.0.1", Status = "Looking for it", StatusTone = "TextDim", Style = "Filled" },
								},
							},

							-- One row per project, built by the tool
							{ Control = "Scroll", Id = "U_List", Style = { "Tight", "Overlay" } },
							{
								Control = "EmptyState",
								Id = "U_Empty",
								Text = "No projects yet. Add a project folder in the ume-sync app.",
								Icon = "folders",
								Visible = false,
							},
							{
								Control = "Footer",
								Id = "U_Footer",
								Children = {
									{ Control = "Label", Id = "S_Hint", Text = "", Style = { "Small", "Dim" }, Grow = 1 },
									{ Control = "Toggle", Id = "S_AutoConnect", Label = "Auto-connect", Value = false, Visible = false },
								},
							},
						},
					},

					--[[ Review ]]

					-- Shown while a connect waits for the files' changes to be accepted; the tool fills it in
					{
						Control = "Panel",
						Id = "U_ReviewPage",
						Visible = false,
						Children = {
							{
								Control = "Stack",
								Style = "Bar",
								Children = {
									{
										Control = "Card",
										Id = "U_Review",
										Caption = "Changed since the last sync",
										Text = "Project",
										Status = "0 files",
										StatusTone = "TextDim",
										Style = "Filled",
										Children = {
											-- Lines the files add and remove, and how many files are added, changed and removed
											{
												Control = "Stack",
												Direction = "Horizontal",
												Style = "Snug",
												Children = {
													{ Control = "Label", Id = "S_Added", Text = "+0", Style = { "Strong", "Success" } },
													{ Control = "Label", Id = "S_Removed", Text = "−0", Style = { "Strong", "Danger" } },
													{ Control = "Label", Id = "S_Kinds", Text = "", Align = "Right", Style = { "Small", "Dim" }, Grow = 1 },
												},
											},
											{ Control = "Label", Id = "S_Notes", Text = "", Style = { "Small", "Dim" } },
										},
									},
								},
							},

							-- One row per changed file, built by the tool; inset like the card above, so rows line up with it
							{ Control = "Scroll", Id = "U_Files", Style = { "List", "Inset", "Overlay" } },
							{
								Control = "Footer",
								Id = "U_ReviewFooter",
								Children = {
									{
										Control = "Stack",
										Direction = "Horizontal",
										Style = "Buttons",
										Children = {
											{ Control = "Label", Id = "S_Hint", Text = "Nothing changes until you sync.", Style = { "Small", "Dim" }, Grow = 1 },
											{ Control = "Button", Id = "S_Abort", Text = "Abort", AutoWidth = true, Style = "Small" },
											{ Control = "Button", Id = "S_Sync", Text = "Sync", AutoWidth = true, Style = { "Small", "Primary" } },
										},
									},
								},
							},
						},
					},

					--[[ Settings ]]

					{
						Control = "Panel",
						Id = "U_SettingsPage",
						Visible = false,
						Children = {
							{
								Control = "Scroll",
								Style = { "Flush", "Overlay" },
								Children = {
									{
										Control = "Section",
										Text = "Connection",
										Children = {
											{ Control = "Input", Id = "U_Port", Label = "App port", Value = 34880, Numeric = true },
											{
												Control = "Label",
												Text = "The port the ume-sync app listens on (its config.toml). Change it here only after changing it there.",
												Style = { "Small", "Dim" },
											},
										},
									},
									{
										Control = "Section",
										Text = "Agents",
										Children = {
											{ Control = "Toggle", Id = "U_AllowAgents", Label = "Let agents control this Studio", Value = true },
											{
												Control = "Label",
												Text = "AI agents using the ume-sync app's MCP tools can connect and disconnect projects here and answer their reviews. Each thing they do is printed to the output.",
												Style = { "Small", "Dim" },
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
	},

	--[[ Templates ]]

	Templates = {
		-- One project: its name, its state and what can be done with it
		["PREFAB | ProjectRow"] = { Control = "ListCard", Text = "Project", Subtext = "", Parent = "U_List" },

		-- One changed file in the review: its service's icon, name, path, lines added and removed, and whether it is new or gone
		["PREFAB | FileRow"] = { Control = "FileRow", Text = "File", Subtext = "", Parent = "U_Files" },

		-- Closes a review list that was cut short
		["PREFAB | MoreFiles"] = { Control = "Label", Text = "", Align = "Center", Style = { "Small", "Dim" }, Parent = "U_Files" },

		-- Asks before something that affects collaborators, such as taking over the folders they sync
		["PREFAB | ConfirmDialog"] = { Control = "Dialog", Title = "Are you sure?", ConfirmText = "Confirm", Danger = true },

		-- A project's errors or other details
		["PREFAB | Details"] = {
			Control = "Dialog",
			Title = "Details",
			Text = "",
			ConfirmText = "Close",
			Dismissible = false,
			Children = {
				{ Control = "Label", Id = "S_Details", Text = "", Style = { "Small", "Fixed" } },
			},
		},
	},
}

return _gui
