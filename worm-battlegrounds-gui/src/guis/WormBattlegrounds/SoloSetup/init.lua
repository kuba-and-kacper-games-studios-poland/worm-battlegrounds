--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- MatchBoard draws it on WidgetManager_Opened as I.UserInterface.UI["SoloSetup"]
	Name = "SoloSetup",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Play solo: a 1v1 against a bot at the picked difficulty; only a win pays
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Play solo",
		Style = "Small",
		Children = {
			{
				Control = "Label",
				Text = "Pick how well the bot plays. Only a win pays coins.",
				Align = "Center",
				Style = "Dim",
			},
			-- One slot per difficulty, the bot's picture over it: the picked one is selected, its Subtext the coins a win pays
			{
				Control = "Stack",
				Direction = "Horizontal",
				Align = "Center",
				Style = "Loose",
				Children = {
					{ Control = "Item", Id = "S_Easy", Text = "Easy", Subtext = "Win: 20 coins", Image = "wb-bot", Style = "Difficulty" },
					{ Control = "Item", Id = "S_Medium", Text = "Medium", Subtext = "Win: 35 coins", Image = "wb-bot", Style = "Difficulty" },
					{ Control = "Item", Id = "S_Hard", Text = "Hard", Subtext = "Win: 60 coins", Image = "wb-bot", Style = "Difficulty" },
				},
			},
			{
				Control = "Button",
				Id = "S_Start",
				Text = "Start",
				Style = "Primary",
				Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonA" } },
			},
		},
	},
}

return _gui
