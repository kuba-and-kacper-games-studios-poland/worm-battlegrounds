--- @class WidgetManager_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	UTILITY_WIDGETS = { "WidgetManager_Message", "WidgetManager_Confirmation" },

	--%%%%%%%%%%%%%%%%%%%% FOV Change

	BACKGROUND_FOV = true,
	FOV_INCREASE = 5,

	--%%%%%%%%%%%%%%%%%%%% Background Blur

	BACKGROUND_BLUR = true,
	BLUR_AMOUNT = 14,
	BLUR_WEIGHT = 999,
	BLUR_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0),

	--%%%%%%%%%%%%%%%%%%%% Background Dim

	BACKGROUND_DIM = true,
	DIM_TRANSPARENCY = 0.5,
	DIM_ORDER = -1,
	DIM_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0),
}
return _settings
