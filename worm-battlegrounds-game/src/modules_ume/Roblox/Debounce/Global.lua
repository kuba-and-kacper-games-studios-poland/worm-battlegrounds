--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Debounce"

--- @type Debounce_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[
    Table for storing local debounces.
]]
--- @type { [string]: number }
local localDebounces = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Debounce Table

--[[
	Returns the player's session cooldowns on the server, or the local cooldowns without a player and on the client.
	Returns nil when a player is passed on the server but isn't valid.
]]
--- @return { [string]: number }?
local function getDebounceTable(player: Player?)
	--[[ Checks ]]

	-- Use the local table on the client and without a player
	if not I.Env.IsServer or not player then
		return localDebounces
	end

	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Returning ]]

	return I.Player.Sessions[player].Data.Debounce.Active
end

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	----------- DATA -----------
	----------------------------

	if I.Env.IsServer then
		--- @type Player_ProfileData
		local _pt = I.Player.ProfileTemplate
		_pt["Debounce"] = {
			Active = {}, --- @type { [string]: number }
		}

		--- @type Player_SessionData
		local _st = I.Player.SessionTemplate
		_st["Debounce"] = {
			Active = {}, --- @type { [string]: number }
		}
	end

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createClearLoop()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network

	if I.Env.IsServer then
		I.Network.GetFunction("Debounce_IsActive", { "Player", "string" })
		I.Network.OnInvoke("Debounce_IsActive", function(player: Player, debounceName: string)
			return Module.IsActive(debounceName, player)
		end)

		I.Network.GetFunction("Debounce_GetTime", { "Player", "string" })
		I.Network.OnInvoke("Debounce_GetTime", function(player: Player, debounceName: string)
			return Module.GetTime(debounceName, player)
		end)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Debounce = {

		--[[ Control ]]

		Run = Module.Run,
		Clear = Module.Clear,

		--[[ Methods ]]

		IsActive = Module.IsActive,
		GetTime = Module.GetTime,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Clear Loop

--[[
	Creates loop that cleans all inactive local debounces.
]]
function Module._createClearLoop()
	I.DoEvery.Get(_settings.INACTIVE_CLEAR_DELAY):Connect(function()
		local timestamp: number = os.clock()

		for name: string, endTime: number in pairs(localDebounces) do
			local timeLeft: number = endTime - timestamp

			if 0 > timeLeft then
				localDebounces[name] = nil
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Starts the cooldown unless it is running, and returns whether it was running.
	The second value is the seconds left of a running cooldown, 0 otherwise.
]]
--- @return boolean
--- @return number
function Module.Run(debounceName: string | any, delay: number, player: Player?)
	--[[ Checks ]]

	-- Check if delay is a number
	if not delay or not tonumber(delay) then
		warn(`[{_localName}::{script.Name}]: Invalid (delay) type. Expected (number), got ({delay}: {typeof(delay)})!`)
		return false, 0
	end

	--[[ Data ]]

	--- @type { [string]: number }?
	local currentTable = getDebounceTable(player)

	-- Block while the player isn't valid
	if not currentTable then
		return true, 0
	end

	--[[ Local Variables ]]

	debounceName = `{debounceName}`
	local timestamp: number = os.clock()

	--[[ Existing Debounce ]]

	-- Check if the cooldown is still running
	if currentTable[debounceName] and currentTable[debounceName] >= timestamp then
		return true, currentTable[debounceName] - timestamp
	end

	--[[ Creating Debounce ]]

	currentTable[debounceName] = timestamp + delay

	--[[ Returning ]]

	return false, 0
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Ends a running cooldown early.
]]
function Module.Clear(debounceName: string | any, player: Player?)
	--[[ Data ]]

	--- @type { [string]: number }?
	local currentTable = getDebounceTable(player)
	if not currentTable then
		return
	end

	--[[ Clearing ]]

	currentTable[`{debounceName}`] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Active

--[[
	Returns whether the cooldown is running.
	Returns true when a player is passed on the server but isn't valid.
]]
--- @return boolean
function Module.IsActive(debounceName: string | any, player: Player?)
	--[[ Data ]]

	--- @type { [string]: number }?
	local currentTable = getDebounceTable(player)

	-- Block while the player isn't valid
	if not currentTable then
		return true
	end

	--[[ Local Variables ]]

	debounceName = `{debounceName}`
	local timestamp: number = os.clock()

	--[[ Checks ]]

	-- Check if the cooldown exists
	if not currentTable[debounceName] then
		return false
	end

	-- Clear a cooldown that ended
	if currentTable[debounceName] < timestamp then
		currentTable[debounceName] = nil
		return false
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Get Time

--[[
	Returns for how much longer the cooldown runs in seconds, 0 when it isn't running.
	Returns 0 when a player is passed on the server but isn't valid.
]]
--- @return number
function Module.GetTime(debounceName: string | any, player: Player?)
	--[[ Data ]]

	--- @type { [string]: number }?
	local currentTable = getDebounceTable(player)
	if not currentTable then
		return 0
	end

	--[[ Local Variables ]]

	debounceName = `{debounceName}`
	local timestamp: number = os.clock()

	--[[ Checks ]]

	-- Check if the cooldown exists
	if not currentTable[debounceName] then
		return 0
	end

	-- Clear a cooldown that ended
	if currentTable[debounceName] < timestamp then
		currentTable[debounceName] = nil
		return 0
	end

	--[[ Returning ]]

	return currentTable[debounceName] - timestamp
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
