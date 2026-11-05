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

	--[[ Combat ]]

	-- A short tick when the local player fires
	["Combat_Fire"] = {
		Mode = "Haptic",
		Type = Enum.HapticEffectType.Custom,
		Looped = false,

		Position = Vector3.zero,
		Radius = 1,
		WaveformKeys = {
			FloatCurveKey.new(0, 0.6, Enum.KeyInterpolationMode.Linear),
			FloatCurveKey.new(60, 0, Enum.KeyInterpolationMode.Linear),
		},
	},

	-- A small or far blast
	["Combat_BlastSmall"] = {
		Mode = "Haptic",
		Type = Enum.HapticEffectType.Custom,
		Looped = false,

		Position = Vector3.zero,
		Radius = 1,
		WaveformKeys = {
			FloatCurveKey.new(0, 0.5, Enum.KeyInterpolationMode.Linear),
			FloatCurveKey.new(150, 0, Enum.KeyInterpolationMode.Linear),
		},
	},

	-- A big blast close to the view: a hard thump that rumbles out
	["Combat_BlastBig"] = {
		Mode = "Haptic",
		Type = Enum.HapticEffectType.Custom,
		Looped = false,

		Position = Vector3.zero,
		Radius = 1,
		WaveformKeys = {
			FloatCurveKey.new(0, 1, Enum.KeyInterpolationMode.Linear),
			FloatCurveKey.new(120, 0.6, Enum.KeyInterpolationMode.Linear),
			FloatCurveKey.new(350, 0, Enum.KeyInterpolationMode.Linear),
		},
	},

	-- The local player's own worm is hurt
	["Combat_Hurt"] = {
		Mode = "Haptic",
		Type = Enum.HapticEffectType.Custom,
		Looped = false,

		Position = Vector3.zero,
		Radius = 1,
		WaveformKeys = {
			FloatCurveKey.new(0, 1, Enum.KeyInterpolationMode.Linear),
			FloatCurveKey.new(200, 0.8, Enum.KeyInterpolationMode.Linear),
			FloatCurveKey.new(450, 0, Enum.KeyInterpolationMode.Linear),
		},
	},
}
return data
