--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A chunky bar with its label above (stamina, power, health)
	Default = { Gap = "XS", Font = "Body", TextSize = "Small", Text = "Text", BarHeight = 18, Radius = "Small" },

	--[[ Bars ]]

	Stamina = { Fill = "Stamina" },
	Power = { Fill = "Power" },
	Health = { Fill = "Health" },
}

return _styles
