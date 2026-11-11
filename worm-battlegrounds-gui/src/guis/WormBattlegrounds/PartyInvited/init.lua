--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- Party opens it when the player is invited, and writes who asked, as I.UserInterface.UI["PartyInvited"]
	Name = "PartyInvited",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Who invited the player, then Join party (the one yellow) or No thanks; closing it says no
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Party invite",
		Style = "Small",
		Children = {
			{
				Control = "Stack",
				Direction = "Horizontal",
				Align = "Center",
				Children = {
					{ Control = "Picture", Id = "S_Avatar", Style = "AvatarLarge" },
					{ Control = "Label", Id = "S_Text", Text = "PlayerName invited you to their party!", Grow = 1, Style = "Strong" },
				},
			},
			{
				Control = "Stack",
				Direction = "Horizontal",
				Fill = true,
				Style = "Buttons",
				Children = {
					{
						Control = "Button",
						Id = "S_Accept",
						Text = "Join party",
						Style = { "Primary", "Large" },
						Hint = "Confirm",
						Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonA" } },
					},
					{
						Control = "Button",
						Id = "S_Decline",
						Text = "No thanks",
						Style = { "Danger", "Large" },
						Hint = "Decline",
						Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonX" } },
					},
				},
			},
		},
	},
}

return _gui
