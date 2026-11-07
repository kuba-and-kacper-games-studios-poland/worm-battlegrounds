--- @class Transition_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The teleport card ume's teleports clone into PlayerGui, by the gui name they're passed
	GUI_NAME = "TeleportGui",

	-- How the card slides down over the screen before a teleport (shorter than the gui's GuiAnimDuration)
	WIPE_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Teleports

	-- How many times a teleport that fails on the way is tried again, and the seconds between tries
	TELEPORT_RETRIES = 2,
	TELEPORT_RETRY_DELAY = 2,

	-- The failures worth trying again; any other drops the card at once
	--- @type { Enum.TeleportResult }
	TELEPORT_RETRY_RESULTS = { Enum.TeleportResult.Failure, Enum.TeleportResult.Flooded },

	-- What a player is told when their teleport failed for good
	TELEPORT_FAILED_MESSAGE = "Couldn't get you there. Try again!",
}

return _settings
