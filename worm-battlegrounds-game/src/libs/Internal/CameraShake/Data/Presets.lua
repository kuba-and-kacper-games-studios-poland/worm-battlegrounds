--- @type CameraShake_Presets
local Presets = {

	--[[ One-Shot ]]

	["Bump"] = {
		Magnitude = 2.5,
		Roughness = 4,
		PositionInfluence = Vector3.new(0.15, 0.15, 0.15),
		RotationInfluence = Vector3.new(1, 1, 1),
	},

	["Explosion"] = {
		Magnitude = 5,
		Roughness = 10,
		PositionInfluence = Vector3.new(0.25, 0.25, 0.25),
		RotationInfluence = Vector3.new(4, 1, 1),
	},

	--[[ Sustained ]]

	["Earthquake"] = {
		Magnitude = 0.6,
		Roughness = 3.5,
		PositionInfluence = Vector3.new(0.25, 0.25, 0.25),
		RotationInfluence = Vector3.new(1, 1, 4),
	},

	["BadTrip"] = {
		Magnitude = 10,
		Roughness = 0.15,
		PositionInfluence = Vector3.new(0, 0, 0.15),
		RotationInfluence = Vector3.new(2, 1, 4),
	},

	["HandheldCamera"] = {
		Magnitude = 1,
		Roughness = 0.25,
		PositionInfluence = Vector3.new(0, 0, 0),
		RotationInfluence = Vector3.new(1, 0.5, 0.5),
	},

	["Vibration"] = {
		Magnitude = 0.4,
		Roughness = 20,
		PositionInfluence = Vector3.new(0, 0.15, 0),
		RotationInfluence = Vector3.new(1.25, 0, 4),
	},

	["RoughDriving"] = {
		Magnitude = 1,
		Roughness = 2,
		PositionInfluence = Vector3.new(0, 0, 0),
		RotationInfluence = Vector3.new(1, 1, 1),
	},
}

return Presets
