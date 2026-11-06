--- @class Party_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Party

	-- The most players in one party
	MAX_PARTY = 4,

	-- How long an invite stays open, in seconds
	INVITE_SECONDS = 30,

	--%%%%%%%%%%%%%%%%%%%% Gui

	GUI_NAME = "Party",

	-- The box that lists who can be invited, and the box an invited player answers
	INVITE_GUI_NAME = "PartyInvite",
	INVITED_GUI_NAME = "PartyInvited",
}

return _settings
