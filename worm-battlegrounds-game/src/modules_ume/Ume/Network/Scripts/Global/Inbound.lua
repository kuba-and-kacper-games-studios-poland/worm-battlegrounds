--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Network"

--- @type Network_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local helpers = require(_scripts:FindFirstChild("helpers")) --- @type Network_Helpers
local Stats = require(_scripts:FindFirstChild("Global"):FindFirstChild("Stats")) --- @type Network_Global_Stats

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Remotes ]]

--- @type { [string]: Validate_ArgumentSchema }
local remoteArgTypes = {}

--- @type { [string]: { Validate_SchemaSpec } }
local remoteSpecs = {}

--- @type { [string]: Network_RemoteOptions }
local remoteOptions = {}

--[[ Players ]]

--- @type { [Player]: { [string]: Network_RateWindow } }
local rateWindows = {}

--- @type { [Player]: { [string]: Network_RejectWarn } }
local rejectWarns = {}

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

--- @class Network_Global_Inbound
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param argTypesTable { [string]: Validate_ArgumentSchema }
--- @param specsTable { [string]: { Validate_SchemaSpec } }
--- @param optionsTable { [string]: Network_RemoteOptions }
function Module.Init(argTypesTable, specsTable, optionsTable)
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	remoteArgTypes = argTypesTable
	remoteSpecs = specsTable
	remoteOptions = optionsTable

	if I.Env.IsServer then
		I.S.Players.PlayerRemoving:Connect(Module._clearPlayer)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Clear Player

--[[
	Removes the rate limit and warn state kept for a player who left.
]]
function Module._clearPlayer(player: Player)
	--[[ Clearing ]]

	rateWindows[player] = nil
	rejectWarns[player] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Accept

--[[
	Runs the rate limit (server), the safety scan (server) and the argument types on one inbound call.
]]
--- @return boolean
function Module.Accept(remoteType: string, name: string, ...: any)
	--[[ Server ]]

	if I.Env.IsServer then
		local player: Player = (...)

		-- Check if the player is within the remote's rate limit
		if not Module._isWithinRateLimit(player, name) then
			Module._warnRejected(player, remoteType, name, "went over the rate limit", ...)
			return false
		end

		-- Check if the payload passes the safety scan
		if not helpers.ValidateRemoteArgs(...) then
			Module._warnRejected(player, remoteType, name, "passed unsafe arguments", ...)
			return false
		end
	end

	--[[ Argument Types ]]

	if remoteSpecs[name] then
		local packed = table.pack(...) --- @type { any }
		local success: boolean
		local result: string?
		success, result = I.Validate.CompiledArgs(packed, remoteSpecs[name])

		-- Check if the payload matches the argument types
		if not success then
			if I.Env.IsServer then
				Module._warnRejected((...), remoteType, name, `passed invalid arguments - ({result})`, ...)
			else
				warn(`[{_localName}::{script.Name}]: Server passed invalid arguments to {remoteType} ({name})! - ({result})`)
				warn("Arguments:", packed, "Types:", remoteArgTypes[name])
			end

			return false
		end
	end

	--[[ Stats ]]

	Stats.Record(name, "In", ...)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Warn Rejected

--[[
	Warns about a rejected inbound call at most once per `REJECT_WARN_INTERVAL` per player and remote.
]]
function Module._warnRejected(player: Player, remoteType: string, name: string, reason: string, ...: any)
	--[[ Local Variables ]]

	local now: number = os.clock()

	-- Create the player's warn state on their first rejected call
	if not rejectWarns[player] then
		rejectWarns[player] = {}
	end

	local state = rejectWarns[player][name] --- @type Network_RejectWarn?

	--[[ Throttling ]]

	-- Count the call instead of warning inside the interval
	if state and now - state.Last < _settings.REJECT_WARN_INTERVAL then
		state.Dropped += 1
		return
	end

	local dropped: number = state and state.Dropped or 0
	rejectWarns[player][name] = { Last = now, Dropped = 0 }

	--[[ Warning ]]

	local droppedText: string = if dropped > 0 then ` ({dropped} more dropped since the last warn)` else ""
	warn(`[{_localName}::{script.Name}]: Player ({player}) {reason} on {remoteType} ({name})!{droppedText}`)

	-- Studio: Show the payload
	if I.Env.IsStudio then
		warn("Arguments:", table.pack(...), "Types:", remoteArgTypes[name])
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Within Rate Limit

--[[
	Counts one inbound call against the remote's per-player limit and returns whether it is still allowed.
]]
--- @return boolean
function Module._isWithinRateLimit(player: Player, name: string)
	--[[ Data ]]

	--- @type Network_RemoteOptions?
	local options = remoteOptions[name]

	--[[ Checks ]]

	-- Allow every call on a remote without a limit
	if not options or not options.RateLimit then
		return true
	end

	--[[ Local Variables ]]

	local now: number = os.clock()
	local period: number = options.Per or 1

	-- Create the player's windows on their first limited call
	if not rateWindows[player] then
		rateWindows[player] = {}
	end

	local window = rateWindows[player][name] --- @type Network_RateWindow?

	--[[ Counting ]]

	-- Start a new window when the last one ended
	if not window or now - window.Start >= period then
		rateWindows[player][name] = { Start = now, Count = 1 }
		return true
	end

	window.Count += 1

	--[[ Returning ]]

	return window.Count <= options.RateLimit
end

return Module
