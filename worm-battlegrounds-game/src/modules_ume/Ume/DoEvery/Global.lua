--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "DoEvery"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = I.S.RunService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [string]: DoEvery_EventTable }
local registeredEvents = {}

--- @type { DoEvery_EventTable }
local eventList = {}

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
	------ INITIALIZATION ------
	----------------------------

	I.OnStarted(I.Priority.Default, Module._runRegisteredEvents)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.DoEvery = {

		--[[ Control ]]

		Every = Module.Every,

		--[[ Methods ]]

		Get = Module.Get,

		--[[ Private ]]

		_registeredEvents = registeredEvents,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Run Registered Events

--[[
	Creates a Heartbeat connection that updates registered events and fires each one once when its interval passed.
	Missed intervals after a long frame are counted in `ticks` instead of firing in a burst.
]]
function Module._runRegisteredEvents()
	--[[ Local Variables ]]

	local startedAt: number = os.clock()

	-- Measure the first elapsed time from when the loop starts
	--- @param delayTable DoEvery_EventTable
	for _, delayTable in ipairs(eventList) do
		delayTable.LastFiredAt = startedAt
	end

	--[[ Connecting ]]

	RunService.Heartbeat:Connect(function(deltaTime: number)
		for index: number = 1, #eventList do
			--[[ Counting ]]

			--- @type DoEvery_EventTable
			local delayTable = eventList[index]
			delayTable.CurrentTime += deltaTime

			-- Skip an interval that hasn't passed yet
			if delayTable.CurrentTime < delayTable.Interval then
				continue
			end

			--[[ Firing ]]

			local now: number = os.clock()
			local ticks: number = math.floor(delayTable.CurrentTime / delayTable.Interval)
			local elapsed: number = now - delayTable.LastFiredAt

			delayTable.CurrentTime -= ticks * delayTable.Interval
			delayTable.LastFiredAt = now
			delayTable.Signal:Fire(elapsed, ticks)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Every

--[[
	Runs `callback(elapsed, ticks)` every `interval` seconds, each call in a `pcall`, and returns the connection.
]]
--- @return Signal_Connection?
function Module.Every(interval: number, callback: (elapsed: number, ticks: number) -> (), phase: number?)
	--[[ Checks ]]

	-- Invalid callback
	if type(callback) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Invalid (callback) type. Expected (function), got ({callback}: {typeof(callback)})!`)
		return nil
	end

	--[[ Data ]]

	local signal = Module.Get(interval, phase) --- @type Signal?
	if not signal then
		return nil
	end

	--[[ Connecting ]]

	return signal:Connect(function(elapsed: number, ticks: number)
		local success: boolean
		local result: any | string?
		success, result = pcall(callback, elapsed, ticks)

		-- Warn when the callback errored
		if not success then
			warn(`[{_localName}::{script.Name}]: Callback every ({interval})s failed! - ({result})`)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns a signal that fires every given interval with `(elapsed, ticks)`.
	`phase` (0 to below `interval`) delays that signal's ticks by that many seconds, to spread heavy work across frames.
]]
--- @return Signal?
function Module.Get(interval: number, phase: number?)
	--[[ Checks ]]

	-- Interval is not a number
	if type(interval) ~= "number" then
		warn(`[{_localName}::{script.Name}]: Invalid (interval) type. Expected (number), got ({interval}: {typeof(interval)})!`)
		return
	end

	-- Interval is not positive
	if interval <= 0 then
		warn(`[{_localName}::{script.Name}]: Invalid (interval) value. Expected a number greater than 0, got ({interval})!`)
		return
	end

	-- Phase is outside of the interval
	if phase ~= nil and (type(phase) ~= "number" or phase < 0 or phase >= interval) then
		warn(`[{_localName}::{script.Name}]: Invalid (phase) value. Expected a number from 0 to below ({interval}), got ({phase})!`)
		return
	end

	--[[ Local Variables ]]

	local key: string = if phase and phase > 0 then `{interval}@{phase}` else `{interval}`

	-- Returning existing
	if registeredEvents[key] then
		return registeredEvents[key].Signal
	end

	--[[ Creating a new Signal ]]

	registeredEvents[key] = {
		Signal = I.Signal.new(),
		Interval = interval,
		CurrentTime = -(phase or 0),
		LastFiredAt = os.clock(),
	}
	table.insert(eventList, registeredEvents[key])

	--[[ Adding Command Dictionary Entry ]]

	if I.Modules.Initialized then
		I.AdminPanel_CommandBar.UpdateDictionary(`DoEvery_Intervals_{I.Env.Key}`, { key })
	end

	--[[ Returning ]]

	return registeredEvents[key].Signal
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
