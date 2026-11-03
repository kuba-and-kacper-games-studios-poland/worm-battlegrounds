--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Network"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local TOP_REMOTES_SHOWN = 15

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class Network_CommandBar_Global
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the commands that show and reset this side's network stats.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Stats

	--[[
		Lists the busiest remotes since the last reset.
	]]
	--- @return boolean
	--- @return string
	local function stats()
		--[[ Checks ]]

		-- Check if stats are collected on this side
		if not I.Env.IsStudio then
			return false, "Network stats are only collected in Studio"
		end

		--[[ Data ]]

		local remoteStats --- @type { [string]: Network_RemoteStats }
		local elapsed: number
		remoteStats, elapsed = I.Network._getStats()

		--[[ Sorting ]]

		local names = {} --- @type { string }
		for name: string in pairs(remoteStats) do
			table.insert(names, name)
		end

		table.sort(names, function(a: string, b: string)
			return remoteStats[a].In + remoteStats[a].Out > remoteStats[b].In + remoteStats[b].Out
		end)

		--[[ Formatting ]]

		local lines = { `Network stats over $|cr$|{string.format("%.1f", elapsed)}s#| ({I.Env.Key})` } --- @type { string }

		for index: number = 1, math.min(#names, TOP_REMOTES_SHOWN) do
			--- @type Network_RemoteStats
			local entry = remoteStats[names[index]]

			table.insert(lines, `$|cr$|{names[index]}#| in {entry.In} (~{entry.InBytes} B) · out {entry.Out} (~{entry.OutBytes} B)`)
		end

		-- Say so when nothing was sent yet
		if #names == 0 then
			table.insert(lines, "No remote traffic yet")
		end

		--[[ Returning ]]

		return true, table.concat(lines, "\n")
	end

	--%%%%%%%%%%%%%%%%%%%% Reset

	--[[
		Clears this side's network stats.
	]]
	--- @return boolean
	--- @return string
	local function reset()
		--[[ Resetting ]]

		I.Network._resetStats()

		--[[ Returning ]]

		return true, `Network stats reset ({I.Env.Key})`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		{
			Aliases = { "stats" },
			PermissionLevel = 255,
			Callback = stats,
		},
		{
			Aliases = { "reset" },
			PermissionLevel = 255,
			Callback = reset,
		},
	}

	--[[ Client ]]

	if I.Env.IsClient then
		I.AdminPanel_CommandBar.Register("Network_Client", {
			Aliases = { "network" },
			PermissionLevel = 255,

			Variants = variants,
		})
	end

	--[[ Server ]]

	if I.Env.IsServer then
		I.AdminPanel_CommandBar.Register("Network_Server", {
			Aliases = { "s_network" },
			PermissionLevel = 255,

			Variants = variants,
		})
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
