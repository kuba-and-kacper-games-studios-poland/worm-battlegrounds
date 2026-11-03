--[[
	Modules Configuration.
]]
--- @class Ume_Config_Modules
local _config = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- Default order in which core modules are loaded.
	LoadingOrder = {
		--[[ Ume ]]

		"Topic",
		"Network",
		"DoEvery",
		"Component",

		--[[ Ume Data ]]

		"Player",
		"Replicator",
		"Buff",
		"Statistic",

		--[[ Roblox ]]

		-- Low-level modules
		"Core",
		"Debounce",

		-- General-purpose modules
		"Team",
		"Sound",
		"Badge",
		"Group",
		"Haptic",
		"Policy",
		"Friends",
		"Favorite",
		"Platform",
		"Marketplace",
		"GlobalLeaderboard",

		-- World/Interactable modules
		"Tool",
		"Lighting",
		"Interact",
		"Leaderstats",
		"UserInterface",

		--[[ Admin Panel ]]

		"AdminPanel",
	},
}

return _config
