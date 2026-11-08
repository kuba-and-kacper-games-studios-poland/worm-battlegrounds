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
		[3530725503] = 255, -- HausBoxJeNejlepsi
		[1172242218] = 255, -- DefinitelyNotBaxtrix
		[9452952] = 255, -- HungryN00B
		[2781342822] = 255, -- LowSugarFries
		[2017751501] = 255, -- 3Dariuz
	},
}
return data
