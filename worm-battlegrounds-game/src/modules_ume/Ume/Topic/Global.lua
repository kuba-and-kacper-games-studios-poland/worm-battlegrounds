--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Topic"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [string]: Signal }
local registeredTopics = {}

--- @type { [string]: Validate_ArgumentSchema }
local topicArgTypes = {}

--- @type { [string]: { Validate_SchemaSpec } }
local topicSpecs = {}

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
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Topic = {

		--[[ Control ]]

		Register = Module.Register,
		Subscribe = Module.Subscribe,
		SubscribeOnce = Module.SubscribeOnce,
		Publish = Module.Publish,

		--[[ Methods ]]

		Wait = Module.Wait,
		IsRegistered = Module.IsRegistered,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Register

--[[
	Registers and returns signal that will fire when a topic with the same name is published.
]]
--- @param argTypes Validate_ArgumentSchema?
--- @return Signal?
function Module.Register(topicName: string, argTypes)
	--[[ Checks ]]

	-- Invalid topic name
	if not topicName or type(topicName) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (topicName) type. Expected (string), got ({topicName}: {typeof(topicName)})!`)
		return nil
	end

	-- Invalid argument types
	if argTypes and type(argTypes) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (argTypes) type. Expected (table), got ({argTypes}: {typeof(argTypes)})!`)
		return nil
	end

	--[[ Validating Argument Types ]]

	if argTypes then
		local success: boolean, result: string = I.Validate.Types(argTypes)

		-- Returning if invalid
		if not success then
			warn(`[{_localName}::{script.Name}]: Passed argument types for topic ({topicName}) are invalid! - ({result})`)
			warn("Types:", argTypes)
			return nil
		end
	end

	--[[ Returning Existing ]]

	if registeredTopics[topicName] then
		if not argTypes then
			warn(`[{_localName}::{script.Name}]: Topic ({topicName}) is already registered!`)
		else
			warn(`[{_localName}::{script.Name}]: Topic ({topicName}) is already registered! Arguments types won't be updated!`)
		end

		return registeredTopics[topicName]
	end

	--[[ Creating & Saving ]]

	registeredTopics[topicName] = I.Signal.new()
	topicArgTypes[topicName] = argTypes
	topicSpecs[topicName] = if argTypes then I.Validate.Compile(argTypes) else nil

	--[[ Returning ]]

	return registeredTopics[topicName]
end

--%%%%%%%%%%%%%%%%%%%% Subscribe

--[[
	Connects `callback` to execute when the signal with `topicName` is fired.
]]
--- @param callback function
--- @return Signal_Connection?
function Module.Subscribe(topicName: string, callback)
	--[[ Checks ]]

	-- Invalid topic name
	if not topicName or type(topicName) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (topicName) type. Expected (string), got ({topicName}: {typeof(topicName)})!`)
		return nil
	end

	-- Invalid callback
	if not callback or type(callback) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Invalid (callback) type. Expected (function), got ({callback}: {typeof(callback)})!`)
		return nil
	end

	-- Topic is not registered
	if not registeredTopics[topicName] then
		warn(`[{_localName}::{script.Name}]: Topic ({topicName}) is not registered!`)
		return nil
	end

	--[[ Connecting ]]

	return registeredTopics[topicName]:Connect(callback)
end

--%%%%%%%%%%%%%%%%%%%% Subscribe Once

--[[
	Connects `callback` to run on the next publish of `topicName` only.
]]
--- @param callback function
--- @return Signal_Connection?
function Module.SubscribeOnce(topicName: string, callback)
	--[[ Checks ]]

	-- Invalid topic name
	if not topicName or type(topicName) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (topicName) type. Expected (string), got ({topicName}: {typeof(topicName)})!`)
		return nil
	end

	-- Invalid callback
	if not callback or type(callback) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Invalid (callback) type. Expected (function), got ({callback}: {typeof(callback)})!`)
		return nil
	end

	-- Topic is not registered
	if not registeredTopics[topicName] then
		warn(`[{_localName}::{script.Name}]: Topic ({topicName}) is not registered!`)
		return nil
	end

	--[[ Connecting ]]

	return registeredTopics[topicName]:Once(callback)
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Fires signal associated with the `topicName`.
]]
function Module.Publish(topicName: string, ...: any)
	--[[ Checks ]]

	-- Invalid topic name
	if not topicName or type(topicName) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (topicName) type. Expected (string), got ({topicName}: {typeof(topicName)})!`)
		return nil
	end

	-- Topic is not registered
	if not registeredTopics[topicName] then
		warn(`[{_localName}::{script.Name}]: Topic ({topicName}) is not registered!`)
		return
	end

	--[[ Validating Arguments Types ]]

	if topicSpecs[topicName] then
		local packed = table.pack(...) --- @type { any }
		local success: boolean
		local result: string?
		success, result = I.Validate.CompiledArgs(packed, topicSpecs[topicName])

		-- Returning if invalid
		if not success then
			warn(`[{_localName}::{script.Name}]: Passed arguments for topic ({topicName}) are invalid! - ({result})`)
			warn("Arguments:", packed, "Types:", topicArgTypes[topicName])
			return
		end
	end

	--[[ Publishing ]]

	registeredTopics[topicName]:Fire(...)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Wait

--[[
	Yields until `topicName` is next published and returns its arguments, or returns nothing once `timeout` seconds pass.
]]
--- @return ...any
function Module.Wait(topicName: string, timeout: number?)
	--[[ Checks ]]

	-- Invalid topic name
	if not topicName or type(topicName) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (topicName) type. Expected (string), got ({topicName}: {typeof(topicName)})!`)
		return nil
	end

	-- Topic is not registered
	if not registeredTopics[topicName] then
		warn(`[{_localName}::{script.Name}]: Topic ({topicName}) is not registered!`)
		return nil
	end

	-- Wait without a timeout
	if not timeout then
		return registeredTopics[topicName]:Wait()
	end

	--[[ Local Variables ]]

	local callerThread: thread = coroutine.running()
	local finished: boolean = false
	local connection --- @type Signal_Connection

	--[[ Connecting ]]

	connection = registeredTopics[topicName]:Connect(function(...: any)
		-- Skip a publish after the timeout
		if finished then
			return
		end

		finished = true
		connection:Disconnect()
		task.spawn(callerThread, ...)
	end)

	--[[ Timeout ]]

	task.delay(timeout, function()
		-- Skip the timeout after a publish
		if finished then
			return
		end

		finished = true
		connection:Disconnect()
		task.spawn(callerThread)
	end)

	--[[ Returning ]]

	return coroutine.yield()
end

--%%%%%%%%%%%%%%%%%%%% Is Registered

--[[
	Returns whether a topic with the given `topicName` is registered.
]]
--- @return boolean
function Module.IsRegistered(topicName: string)
	--[[ Checks ]]

	-- Invalid topic name
	if not topicName or type(topicName) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (topicName) type. Expected (string), got ({topicName}: {typeof(topicName)})!`)
		return false
	end

	--[[ Returning ]]

	return registeredTopics[topicName] ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
