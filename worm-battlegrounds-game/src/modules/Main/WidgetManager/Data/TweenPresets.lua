--- @class WidgetManager_TweenPresets
--- @type { [string]: WidgetManager_TweenPreset }
local data = {
	["Default"] = {
		Info = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		PreTranslate = function(widget: Frame)
			widget.Position = UDim2.fromScale(0.5, 0.47)
		end,
		PostTranslate = { Position = UDim2.fromScale(0.5, 0.5) },
	},
	["Rise"] = {
		Info = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		PreTranslate = function(widget: Frame)
			widget.Position = UDim2.fromScale(0.5, 0.58)
		end,
		PostTranslate = { Position = UDim2.fromScale(0.5, 0.5) },
	},
}
return data
