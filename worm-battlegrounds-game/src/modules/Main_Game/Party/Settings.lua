--- @class Party_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Party

	-- The most players in one party, and the most cards one column of the panel holds (a bigger custom lobby takes two)
	MAX_PARTY = 4,
	COLUMN_CARDS = 4,

	-- How far right of the first column the second one stands, in card widths
	SECOND_COLUMN_X = 1.3,

	-- How long an invite stays open, in seconds
	INVITE_SECONDS = 30,

	--%%%%%%%%%%%%%%%%%%%% Gui

	GUI_NAME = "Party",

	-- The box that lists who can be invited, and the box an invited player answers
	INVITE_GUI_NAME = "PartyInvite",
	INVITED_GUI_NAME = "PartyInvited",

	-- The custom lobby's window, opened from a free place while the column lists a custom lobby
	CUSTOM_GUI_NAME = "CustomLobby",
}

return _settings
