--- @class Scaling_Settings
--- @field PRECISION number
--- @field ROUNDING Scaling_RoundingType
--- @field VALUES { [string]: Scaling_ValueDefinition }
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- Default BigNum precision used by all calculations.
	PRECISION = 6,

	-- Default rounding used when a value definition does not override it.
	ROUNDING = "None",

	-- Named dynamic values used by game systems.
	--- @type { [string]: Scaling_ValueDefinition }
	VALUES = {
		["Example"] = {
			Curve = "Exponential",
			Input = "Level",
			Base = 5,
			Growth = 1.71,
			Add = -1,
			Round = "Round",
		},
	},
}
return _settings
