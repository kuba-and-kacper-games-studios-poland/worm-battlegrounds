--- @class Lighting_Tweens
--- @type { [string]: TweenInfo }
local data = {
	["Fast"] = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
	["Medium"] = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
	["Slow"] = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
}
return data
