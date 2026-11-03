--- @class TopBar_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Button

	-- Padding in pixels on each side of a button's content while it has a text
	BUTTON_PADDING = 12,

	-- Icon size as a share of the button's height
	ICON_SIZE = 0.6,

	-- The icon style of a button's gamepad key hint (Console's GAMEPAD_ICONS)
	KEY_HINT_STYLE = "Color",

	--%%%%%%%%%%%%%%%%%%%% Highlight

	-- The highlight's transparency while a button is hovered, and while it is pressed
	HOVER_TRANSPARENCY = 0.925,
	PRESS_TRANSPARENCY = 0.85,

	-- Hovering and pressing fade the highlight in; leaving and releasing fade it back out
	PRESS_TWEENINFO = TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
	RELEASE_TWEENINFO = TweenInfo.new(0.14, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
}

return _settings
