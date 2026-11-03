--[[
	Created By: 	Nari
]]

local _localName: string = "Component"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local Scope = require(script.Parent:FindFirstChild("Scope")) --- @type UmeGui_Libs_Scope

-- Only tagged instances inside guis UmeGui binds; the place's own guis stay static
local CollectionService = Scope.CollectionService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local registeredComponents = {} --- @type { [string]: UmeGui_ComponentClass }
local createdComponents = {} --- @type { [Instance]: { [string]: UmeGui_ComponentObject } }

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

--- @class UmeGui_Libs_Component
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Register

--[[
	Registers a framework-style component class for a tag, attaches it to tagged instances in bound guis, and follows later tag changes.
]]
--- @return boolean
function Module.Register(tag: string, componentModule: ModuleScript)
	--[[ Checks ]]

	-- Check if the tag is already taken
	if registeredComponents[tag] then
		warn(`[{_localName}]: Component ({tag}) is already registered!`)
		return false
	end

	--[[ Saving ]]

	registeredComponents[tag] = require(componentModule)

	--[[ Existing ]]

	for _index: number, instance: Instance in ipairs(CollectionService:GetTagged(tag)) do
		Module._addToInstance(instance, tag)
	end

	--[[ Connections ]]

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance: Instance)
		Module._addToInstance(instance, tag)
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance: Instance)
		Module._removeFromInstance(instance, tag)
	end)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Add To Instance

--[[
	Creates the tag's component for an instance and runs its Init right away.
]]
function Module._addToInstance(instance: Instance, tag: string)
	--[[ Data ]]

	local created = createdComponents[instance] --- @type { [string]: UmeGui_ComponentObject }?

	--[[ Checks ]]

	-- Skip instances that already have this component
	if created and created[tag] then
		return
	end

	--[[ Creating ]]

	local component = registeredComponents[tag].new(instance) --- @type UmeGui_ComponentObject
	createdComponents[instance] = created or {}
	createdComponents[instance][tag] = component

	--[[ Initializing ]]

	-- Run now: a deferred Init is lost when a rebuilt gui replaces this one in the same frame
	local success: boolean
	local result: any | string?
	success, result = pcall(component.Init, component)

	-- Warn when the component failed to start
	if not success then
		warn(`[{_localName}]: ({tag}) failed to init on ({instance:GetFullName()}): {result}`)
	end
end

--%%%%%%%%%%%%%%%%%%%% Remove From Instance

--[[
	Destroys the tag's component on an instance and forgets the instance once it has none left.
]]
function Module._removeFromInstance(instance: Instance, tag: string)
	--[[ Data ]]

	local created = createdComponents[instance] --- @type { [string]: UmeGui_ComponentObject }?

	--[[ Checks ]]

	-- Skip instances without this component
	if not created or not created[tag] then
		return
	end

	--[[ Destroying ]]

	created[tag]._destroyed = true
	created[tag]:Destroy()
	created[tag] = nil

	--[[ Clearing ]]

	-- Forget the instance once its last component is gone
	if next(created) == nil then
		createdComponents[instance] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the tag's component on an instance.
]]
--- @return UmeGui_ComponentObject?
function Module.Get(instance: Instance, tag: string)
	--[[ Data ]]

	local created = createdComponents[instance] --- @type { [string]: UmeGui_ComponentObject }?

	--[[ Returning ]]

	return created and created[tag]
end

--%%%%%%%%%%%%%%%%%%%% Is Registered

--[[
	Returns whether a component class is registered for the tag.
]]
--- @return boolean
function Module.IsRegistered(tag: string)
	return registeredComponents[tag] ~= nil
end

return Module
