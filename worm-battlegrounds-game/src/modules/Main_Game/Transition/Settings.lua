--- @class Transition_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The teleport card ume's teleports clone into PlayerGui, by the gui name they're passed
	GUI_NAME = "TeleportGui",

	-- How the card slides down over the screen before a teleport (shorter than the gui's GuiAnimDuration)
	WIPE_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

return _settings
