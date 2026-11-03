--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Component"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local CollectionService = I.S.CollectionService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Registered ]]

--- @type { [string]: Component }
local registeredComponents = {}

--- @type { [string]: Component }
local registerOnLoadedComponents = {}

--- @type { [string]: ModuleScript }
local componentsModules = {}

--[[ Created ]]

--- @type { [Instance]: { [string]: Component } }
local createdComponents = {}

--- @type { [string]: { [Instance]: Component } }
local componentsByTag = {}

--- @type { [string]: { [string]: RBXScriptConnection } }
local componentsControlSignals = {}

--- @type { [Instance]: { [string]: RBXScriptConnection } }
local ancestryConnections = {}

--- @type { [Component]: boolean }
local initializedComponents = setmetatable({}, { __mode = "k" })

--[[ Signals ]]

--- @type { [string]: Component_TagSignals }
local tagSignals = {}

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

	I.OnStarted(I.Priority.Late, Module._initRegisteredComponents)
	if I.Env.IsClient then
		I.OnLoaded(I.Priority.Late, Module._registerSavedOnLoaded)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Component = {

		--[[ Control ]]

		Register = Module.Register,
		RegisterOnLoaded = Module.RegisterOnLoaded,
		Unregister = Module.Unregister,

		--[[ Methods ]]

		Get = Module.Get,
		GetAll = Module.GetAll,
		GetAddedSignal = Module.GetAddedSignal,
		GetRemovedSignal = Module.GetRemovedSignal,
		WaitFor = Module.WaitFor,
		IsRegistered = Module.IsRegistered,

		--[[ Private ]]

		_registeredComponents = registeredComponents,
		_componentsModules = componentsModules,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Init Registered Components

--[[
	Initially adds components to all currently tagged instances.
]]
function Module._initRegisteredComponents()
	for tag: string, _ in pairs(registeredComponents) do
		for _, instance: Instance in ipairs(CollectionService:GetTagged(tag)) do
			Module._trackInstance(instance, tag)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Register Saved All On Loaded

--[[
	Registers all components that were saved to be registered using `RegisterOnLoaded`.
]]
function Module._registerSavedOnLoaded()
	if not registerOnLoadedComponents then
		return
	end

	--[[ Registering ]]

	for tag: string, componentModule: ModuleScript in pairs(registerOnLoadedComponents) do
		Module.Register(tag, componentModule)
	end

	--[[ Cleaning ]]

	table.clear(registerOnLoadedComponents)
	registerOnLoadedComponents = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Instance Control

--%%%%%%%%%%%%%%%%%%%% Track Instance

--[[
	Builds the component when the instance sits under the class's allowed ancestors, and follows its ancestry
	when the class limits them.
]]
function Module._trackInstance(instance: Instance, tag: string)
	--[[ Data ]]

	local comp = registeredComponents[tag] --- @type Component?
	if not comp then
		return
	end

	--[[ Ancestry ]]

	-- Follow ancestry only for classes that limit where they build
	if (comp.Ancestors or comp.IgnoreAncestors) and not (ancestryConnections[instance] and ancestryConnections[instance][tag]) then
		-- Create the instance's connections on its first tracked tag
		if not ancestryConnections[instance] then
			ancestryConnections[instance] = {}
		end

		ancestryConnections[instance][tag] = instance.AncestryChanged:Connect(function()
			Module._refreshInstance(instance, tag)
		end)
	end

	--[[ Building ]]

	Module._refreshInstance(instance, tag)
end

--%%%%%%%%%%%%%%%%%%%% Untrack Instance

--[[
	Stops following the instance's ancestry for `tag` and destroys its component.
]]
function Module._untrackInstance(instance: Instance, tag: string)
	--[[ Disconnecting ]]

	-- Disconnect the ancestry connection when there is one
	if ancestryConnections[instance] and ancestryConnections[instance][tag] then
		ancestryConnections[instance][tag]:Disconnect()
		ancestryConnections[instance][tag] = nil

		-- Remove the instance entry once it has no connections left
		if next(ancestryConnections[instance]) == nil then
			ancestryConnections[instance] = nil
		end
	end

	--[[ Removing ]]

	Module._removeFromInstance(instance, tag)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Instance

--[[
	Builds or destroys the instance's component so it matches whether the instance is under the allowed ancestors.
]]
function Module._refreshInstance(instance: Instance, tag: string)
	--[[ Checks ]]

	-- Skip an instance that lost the tag
	if not instance:HasTag(tag) then
		return
	end

	--[[ Applying ]]

	if Module._isAllowed(instance, tag) then
		Module._addToInstance(instance, tag)
	else
		Module._removeFromInstance(instance, tag)
	end
end

--%%%%%%%%%%%%%%%%%%%% Add To Instance

--[[
	Creates new `tag` component for the `instance`.
]]
function Module._addToInstance(instance: Instance, tag: string)
	if not registeredComponents[tag] then
		warn(`[{_localName}::{script.Name}]: Component ({tag}) is not registered!`)
		return
	end

	if createdComponents[instance] and createdComponents[instance][tag] then
		return
	end

	--[[ Creating a new metatable ]]

	local comp = registeredComponents[tag] --- @type Component

	local success: boolean
	local result: any | string?
	success, result = pcall(comp.new, instance)

	-- Check if the component was created
	if not success then
		warn(`[{_localName}::{script.Name}]: Component ({tag}) failed to create! - ({result}) -`, instance)
		return
	end

	local instanceComp = result --- @type Component

	-- Saving
	if not createdComponents[instance] then
		createdComponents[instance] = {}
	end
	if not componentsByTag[tag] then
		componentsByTag[tag] = {}
	end

	createdComponents[instance][tag] = instanceComp
	componentsByTag[tag][instance] = instanceComp

	-- Init component in a separate thread to avoid delays
	task.spawn(function()
		-- Skip a component removed before it started
		if not createdComponents[instance] or createdComponents[instance][tag] ~= instanceComp then
			return
		end

		local initSuccess: boolean
		local initResult: any | string?
		initSuccess, initResult = pcall(instanceComp.Init, instanceComp)

		-- Check if the component initialized
		if not initSuccess then
			warn(`[{_localName}::{script.Name}]: Component ({tag}) failed to initialize! - ({initResult}) -`, instance)
			return
		end

		-- Skip the added signal when the component was destroyed while initializing
		if instanceComp._destroyed then
			return
		end

		initializedComponents[instanceComp] = true

		-- Fire the added signal when something listens to it
		if tagSignals[tag] then
			tagSignals[tag].Added:Fire(instanceComp)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Remove From Instance

--[[
	Removes `tag` component from the `instance`.
]]
function Module._removeFromInstance(instance: Instance, tag: string)
	if not createdComponents[instance] or not createdComponents[instance][tag] then
		return
	end

	local instanceComp = createdComponents[instance][tag] --- @type Component

	--[[ Publishing ]]

	-- Fire the removed signal for a component that finished initializing
	if initializedComponents[instanceComp] and tagSignals[tag] then
		tagSignals[tag].Removed:Fire(instanceComp)
	end

	--[[ Destroying ]]

	instanceComp._destroyed = true
	instanceComp:Destroy()
	createdComponents[instance][tag] = nil
	initializedComponents[instanceComp] = nil

	if componentsByTag[tag] then
		componentsByTag[tag][instance] = nil
	end

	--[[ Removing instance entry if empty ]]

	if next(createdComponents[instance]) == nil then
		createdComponents[instance] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Component Control

--%%%%%%%%%%%%%%%%%%%% Register

--[[
	Registers `componentModule` and adds it to all instances with the given tag, also listens for new or removed ones.
]]
--- @return boolean
function Module.Register(tag: string, componentModule: ModuleScript, overwriteModule: boolean?)
	--[[ Checks ]]

	if registeredComponents[tag] or componentsControlSignals[tag] then
		warn(`[{_localName}::{script.Name}]: Component ({tag}) is already registered!`)
		return false
	end

	if not componentModule:IsA("ModuleScript") then
		error(`[{_localName}::{script.Name}]: Invalid (componentModule) type. Expected (ModuleScript), got ({componentModule}: {typeof(componentModule)})!`, 2)
		return false
	end

	if componentsModules[tag] and not overwriteModule and componentsModules[tag] ~= componentModule then
		warn(`[{_localName}::{script.Name}]: Component ({tag}) cannot be overwritten in the current mode!`)
		return false
	end

	--[[ Saving Component ]]

	-- Saving component
	registeredComponents[tag] = require(componentModule)
	componentsModules[tag] = componentModule

	-- Updating command dicts
	if I.Modules.Initialized then
		I.AdminPanel_CommandBar.UpdateDictionary(`Component_ComponentName_{I.Env.Key}_All`, { tag })
		I.AdminPanel_CommandBar.UpdateDictionary(`Component_ComponentName_{I.Env.Key}_Registered`, { tag })
		I.AdminPanel_CommandBar.UpdateDictionary(`Component_ComponentName_{I.Env.Key}_Unregistered`, nil, { tag })
	end

	--[[ After Started ]]

	if I.Started then
		for _, instance: Instance in ipairs(CollectionService:GetTagged(tag)) do
			Module._trackInstance(instance, tag)
		end
	end

	--[[ Tag Signals ]]

	componentsControlSignals[tag] = {
		Added = nil,
		Removed = nil,
	}

	-- Instance Added signal
	componentsControlSignals[tag].Added = CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance: Instance)
		Module._trackInstance(instance, tag)
	end)

	-- Instance Removed signal
	componentsControlSignals[tag].Removed = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance: Instance)
		Module._untrackInstance(instance, tag)
	end)

	return true
end

--%%%%%%%%%%%%%%%%%%%% Register On Loaded

--[[
	**CLIENT** |
	Saves `componentModule` to be registered after player loads on the server.
]]
function Module.RegisterOnLoaded(tag: string, componentModule: ModuleScript)
	--[[ Server Check ]]

	if I.Env.IsServer then
		warn(`[{_localName}::{script.Name}]: (RegisterOnLoaded) can only be used on the Client!`)
		I.Component.Register(tag, componentModule)
		return
	end

	--[[ Checks ]]

	if not registerOnLoadedComponents then
		warn(`[{_localName}::{script.Name}]: (RegisterOnLoaded) cannot be used after the framework started!`)
		I.Component.Register(tag, componentModule)
		return
	end

	if registeredComponents[tag] or componentsControlSignals[tag] or componentsModules[tag] then
		warn(`[{_localName}::{script.Name}]: Component ({tag}) is already registered!`)
		return
	end

	if not componentModule:IsA("ModuleScript") then
		error(`[{_localName}::{script.Name}]: Invalid (componentModule) type. Expected (ModuleScript), got ({componentModule}: {typeof(componentModule)})!`, 2)
		return
	end

	--[[ Saving ]]

	registerOnLoadedComponents[tag] = componentModule
end

--%%%%%%%%%%%%%%%%%%%% Unregister

--[[
	Removes `tag` component from the game and all its connections.
]]
--- @return boolean
function Module.Unregister(tag: string)
	--[[ Checks ]]

	if not registeredComponents[tag] then
		warn(`[{_localName}::{script.Name}]: Component ({tag}) is not registered!`)
		return false
	end

	--[[ Removing From Registry ]]

	if componentsControlSignals[tag] then
		for _name: string, connection: RBXScriptConnection in pairs(componentsControlSignals[tag]) do
			if connection.Connected then
				connection:Disconnect()
			end
		end
	end

	-- Updating command dicts
	if I.Modules.Initialized then
		I.AdminPanel_CommandBar.UpdateDictionary(`Component_ComponentName_{I.Env.Key}_Registered`, nil, { tag })
		I.AdminPanel_CommandBar.UpdateDictionary(`Component_ComponentName_{I.Env.Key}_Unregistered`, { tag })
	end

	--[[ Removing From Instances ]]

	for _, instance: Instance in ipairs(CollectionService:GetTagged(tag)) do
		Module._untrackInstance(instance, tag)
	end

	-- Clearing registry
	registeredComponents[tag] = nil
	componentsControlSignals[tag] = nil

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns `tag` component table that was created for the `instance`.
]]
--- @return Component?
function Module.Get(instance: Instance, tag: string)
	if createdComponents[instance] and createdComponents[instance][tag] then
		return createdComponents[instance][tag]
	else
		return nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	Returns every live `tag` component.
]]
--- @return { Component }
function Module.GetAll(tag: string)
	--[[ Collecting ]]

	local all = {} --- @type { Component }

	for _instance: Instance, instanceComp in pairs(componentsByTag[tag] or {}) do
		table.insert(all, instanceComp)
	end

	--[[ Returning ]]

	return all
end

--%%%%%%%%%%%%%%%%%%%% Get Added Signal

--[[
	Returns the signal that fires with a `tag` component once its `Init` finished.
]]
--- @return Signal
function Module.GetAddedSignal(tag: string)
	return Module._getTagSignals(tag).Added
end

--%%%%%%%%%%%%%%%%%%%% Get Removed Signal

--[[
	Returns the signal that fires with a `tag` component right before its `Destroy`.
]]
--- @return Signal
function Module.GetRemovedSignal(tag: string)
	return Module._getTagSignals(tag).Removed
end

--%%%%%%%%%%%%%%%%%%%% Wait For

--[[
	Returns the instance's `tag` component once it has initialized, or nil after `timeout` seconds.
]]
--- @return Component?
function Module.WaitFor(instance: Instance, tag: string, timeout: number?)
	--[[ Checks ]]

	-- Return a component that already finished initializing
	local existing = Module.Get(instance, tag) --- @type Component?
	if existing and initializedComponents[existing] then
		return existing
	end

	--[[ Local Variables ]]

	local callerThread: thread = coroutine.running()
	local finished: boolean = false
	local connection --- @type Signal_Connection

	--[[ Waiting ]]

	--- @param instanceComp Component
	connection = Module._getTagSignals(tag).Added:Connect(function(instanceComp)
		-- Skip components of other instances, and a timeout that already resumed
		if finished or instanceComp.Instance ~= instance then
			return
		end

		finished = true
		connection:Disconnect()
		task.spawn(callerThread, instanceComp)
	end)

	-- Give up after the timeout when one is set
	if timeout then
		task.delay(timeout, function()
			-- Skip the timeout after the component arrived
			if finished then
				return
			end

			finished = true
			connection:Disconnect()
			task.spawn(callerThread, nil)
		end)
	end

	--[[ Returning ]]

	return coroutine.yield()
end

--%%%%%%%%%%%%%%%%%%%% Is Registered

--[[
	Checks if component is registered by its `tag`.
]]
--- @return boolean
function Module.IsRegistered(tag: string)
	return registeredComponents[tag] ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Get Tag Signals

--[[
	Returns the tag's added and removed signals, created on first use.
]]
--- @return Component_TagSignals
function Module._getTagSignals(tag: string)
	--[[ Creating ]]

	-- Create the signals on first use
	if not tagSignals[tag] then
		tagSignals[tag] = {
			Added = I.Signal.new(),
			Removed = I.Signal.new(),
		}
	end

	--[[ Returning ]]

	return tagSignals[tag]
end

--%%%%%%%%%%%%%%%%%%%% Is Allowed

--[[
	Returns whether the instance sits under the class's `Ancestors` (when set) and outside its `IgnoreAncestors`.
]]
--- @return boolean
function Module._isAllowed(instance: Instance, tag: string)
	--[[ Data ]]

	local comp = registeredComponents[tag] --- @type Component

	--[[ Ignored Ancestors ]]

	--- @param root Instance
	for _, root in ipairs(comp.IgnoreAncestors or {}) do
		-- Skip an instance under an ignored ancestor
		if instance == root or instance:IsDescendantOf(root) then
			return false
		end
	end

	--[[ Allowed Ancestors ]]

	-- Allow anywhere when the class sets no ancestors
	if not comp.Ancestors then
		return true
	end

	--- @param root Instance
	for _, root in ipairs(comp.Ancestors) do
		-- Allow an instance under one of the ancestors
		if instance:IsDescendantOf(root) then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
