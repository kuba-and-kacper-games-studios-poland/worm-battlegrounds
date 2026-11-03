--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Network"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local helpers = require(_scripts:FindFirstChild("helpers")) --- @type Network_Helpers

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [string]: Network_RemoteStats }
local remoteStats = {}
local statsStartedAt: number = os.clock()

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

--- @class Network_Global_Stats
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Record

--[[
	Studio: counts one call and its estimated payload size for a remote.
]]
function Module.Record(name: string, direction: string, ...: any)
	--[[ Checks ]]

	-- Collect stats only in Studio
	if not I.Env.IsStudio then
		return
	end

	--[[ Data ]]

	-- Create the remote's entry on its first call
	if not remoteStats[name] then
		remoteStats[name] = { In = 0, Out = 0, InBytes = 0, OutBytes = 0 }
	end

	--- @type Network_RemoteStats
	local entry = remoteStats[name]

	--[[ Counting ]]

	entry[direction] += 1
	entry[`{direction}Bytes`] += helpers.EstimateSize(table.pack(...))
end

--%%%%%%%%%%%%%%%%%%%% Reset

--[[
	Clears the collected stats.
]]
function Module.Reset()
	--[[ Clearing ]]

	table.clear(remoteStats)
	statsStartedAt = os.clock()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the collected stats per remote and the seconds since they were last reset.
]]
--- @return { [string]: Network_RemoteStats }
--- @return number
function Module.Get()
	return remoteStats, os.clock() - statsStartedAt
end

return Module
