--- @type Haptic_Presets
local data = {
	--[[
		["Example"] = {
			Mode = "Haptic",
			Type = Enum.HapticEffectType.Custom,
			Looped = false,
			Duration = 1,

			Position = Vector3.zero,
			Radius = 1,
			WaveformKeys = {
				FloatCurveKey.new(0, 0, Enum.KeyInterpolationMode.Linear),
				FloatCurveKey.new(50, 1, Enum.KeyInterpolationMode.Linear),
				FloatCurveKey.new(100, 0, Enum.KeyInterpolationMode.Linear),
			},

			SoundParams = {
				Name = "Example",
				Volume = 0.5,
				SoundGroup = "SFX",
			},
		},
	]]

	["Default"] = {
		Mode = "Haptic",
		Type = Enum.HapticEffectType.Custom,
		Looped = false,

		Position = Vector3.zero,
		Radius = 1,
		WaveformKeys = {
			FloatCurveKey.new(0, 0, Enum.KeyInterpolationMode.Linear),
			FloatCurveKey.new(50, 1, Enum.KeyInterpolationMode.Linear),
			FloatCurveKey.new(100, 0, Enum.KeyInterpolationMode.Linear),
		},
	},
}
return data
