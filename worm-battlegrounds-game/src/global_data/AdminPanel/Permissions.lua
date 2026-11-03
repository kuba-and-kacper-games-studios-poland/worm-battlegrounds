--- @class AdminPanel_Permissions
---
--- # Groups #
---
--- @field Groups { string }
---
--- # Levels #
---
--- @field GlobalLevel number
--- @field DashboardLevel number
--- @field CustomLevels { [number]: number }
local data = {

	--[[ Groups ]]

	-- Default groupId used for getting player permission level.
	Groups = { "Default" },

	--[[ Levels ]]

	-- Permission level required to use global commands.
	GlobalLevel = 255,

	-- Permission level required to open the dashboard.
	DashboardLevel = 255,

	-- Custom set permissions levels.
	CustomLevels = {
		[4771447297] = 255, -- nyaridev
		[858175623] = 255, -- ShideUwU
		[11800077333] = 255, -- viridianscape
	},
}
return data
