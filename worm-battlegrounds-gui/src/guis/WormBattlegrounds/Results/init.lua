--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- MatchHud opens it at the end of a match, as I.UserInterface.UI["Results"]
	Name = "Results",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	--[[
		The end of a match: placings, what the player earned, the match stats, Rematch or back to the lobby.
		No close button: it can't be closed (PreventClosing, set after export)
	]]
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Match over",
		Close = false,
		Style = "Large",
		Children = {
			{ Control = "Label", Id = "S_Result", Text = "You placed 2nd!", Align = "Center", Style = "Title" },
			-- Every player's place, in team colours (PREFAB | Placing)
			{ Control = "Cells", Id = "U_Placings" },
			-- What the player earned
			{
				Control = "Box",
				Id = "U_Earned",
				Children = {
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Style = "Loose",
						Children = {
							{ Control = "Label", Text = "You earned", Style = "Heading" },
							{ Control = "Label", Id = "S_Coins", Text = "+50 coins", Style = { "Heading", "Coin" } },
							{ Control = "Label", Id = "S_Xp", Text = "+120 XP", Style = "Heading" },
							{
								Control = "Label",
								Id = "S_LevelUp",
								Text = "Level up! Level 13",
								Visible = false,
								Style = { "Heading", "Success" },
							},
						},
					},
				},
			},
			-- The player's match stats
			{
				Control = "Box",
				Id = "U_Stats",
				Children = {
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Style = "Loose",
						Children = {
							{ Control = "Label", Id = "S_Damage", Text = "Damage dealt: 340" },
							{ Control = "Label", Id = "S_Knockouts", Text = "Knockouts: 2" },
							{ Control = "Label", Id = "S_BestShot", Text = "Best shot: 95 with the Bazooka" },
						},
					},
				},
			},
			{
				Control = "Stack",
				Direction = "Horizontal",
				Fill = true,
				Style = "Buttons",
				Children = {
					-- Votes and the time left to vote are in its text
					{
						Control = "Button",
						Id = "S_Rematch",
						Text = "Rematch  2 / 4  0:15",
						Style = "Primary",
						Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonA" } },
					},
					{
						Control = "Button",
						Id = "S_Lobby",
						Text = "Back to lobby",
						Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" } },
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- One player's place, name in their team's colour, and the coins it paid
		["PREFAB | Placing"] = {
			Control = "Box",
			Parent = "U_Placings",
			Children = {
				{
					Control = "Stack",
					Direction = "Horizontal",
					Children = {
						{ Control = "Label", Id = "S_Place", Text = "1st", Style = "Heading" },
						{ Control = "Picture", Id = "S_Avatar", Style = "Avatar" },
						{ Control = "Label", Id = "S_Name", Text = "PlayerName", Grow = 1, Style = "Strong" },
						{ Control = "Label", Id = "S_Coins", Text = "+60 coins", Style = "Coin" },
					},
				},
			},
		},
	},
}

return _gui
