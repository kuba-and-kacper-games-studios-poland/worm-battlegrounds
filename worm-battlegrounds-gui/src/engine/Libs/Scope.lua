--[[
	Created By: 	Nari
]]

local _localName: string = "Scope"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local CollectionService: CollectionService = game:GetService("CollectionService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Roots ]]

local roots = {} --- @type { [Instance]: RBXScriptConnection }

--[[ Tags ]]

local listeners = {} --- @type { [string]: { Added: { (instance: Instance) -> () }, Removed: { (instance: Instance) -> () } } }
local tracked = {} --- @type { [string]: { [Instance]: boolean } }

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

--- @class UmeGui_Libs_Scope
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	Brings a gui into the scope: its tagged instances are handed to the listeners now and while it lives.
]]
function Module.Add(root: Instance)
	--[[ Checks ]]

	-- Skip roots that are already bound
	if roots[root] then
		return
	end

	--[[ Saving ]]

	roots[root] = root.Destroying:Connect(function()
		Module.Remove(root)
	end)

	--[[ Entering ]]

	local instances = root:GetDescendants() --- @type { Instance }
	table.insert(instances, root)

	for tag: string in pairs(listeners) do
		for _index: number, instance: Instance in ipairs(instances) do
			if instance:HasTag(tag) then
				Module._enter(instance, tag)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Remove

--[[
	Takes a gui out of the scope and hands its tracked instances to the removed listeners.
]]
function Module.Remove(root: Instance)
	--[[ Checks ]]

	-- Skip roots that are not bound
	if not roots[root] then
		return
	end

	--[[ Clearing ]]

	roots[root]:Disconnect()
	roots[root] = nil

	--[[ Leaving ]]

	for tag: string, instances: { [Instance]: boolean } in pairs(tracked) do
		for instance: Instance in pairs(table.clone(instances)) do
			if instance == root or instance:IsDescendantOf(root) then
				Module._leave(instance, tag)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Enter

--[[
	Tracks a tagged instance and calls the tag's added listeners once.
]]
function Module._enter(instance: Instance, tag: string)
	--[[ Checks ]]

	-- Skip instances that are already tracked
	if tracked[tag][instance] then
		return
	end

	--[[ Tracking ]]

	tracked[tag][instance] = true

	--[[ Calling ]]

	-- Run now: Component expects Init to run before the tool wires the view
	for _index: number, callback: (instance: Instance) -> () in ipairs(table.clone(listeners[tag].Added)) do
		callback(instance)
	end
end

--%%%%%%%%%%%%%%%%%%%% Leave

--[[
	Forgets a tracked instance and calls the tag's removed listeners once.
]]
function Module._leave(instance: Instance, tag: string)
	--[[ Checks ]]

	-- Skip instances that are not tracked
	if not tracked[tag][instance] then
		return
	end

	--[[ Tracking ]]

	tracked[tag][instance] = nil

	--[[ Calling ]]

	for _index: number, callback: (instance: Instance) -> () in ipairs(table.clone(listeners[tag].Removed)) do
		callback(instance)
	end
end

--%%%%%%%%%%%%%%%%%%%% Listen

--[[
	Starts following a tag the first time something listens to it. Place-wide tag changes only count inside the scope.
]]
function Module._listen(tag: string)
	--[[ Checks ]]

	-- Only listen once per tag
	if listeners[tag] then
		return
	end

	--[[ Saving ]]

	listeners[tag] = { Added = {}, Removed = {} }
	tracked[tag] = {}

	--[[ Connections ]]

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance: Instance)
		if Module.Contains(instance) then
			Module._enter(instance, tag)
		end
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance: Instance)
		Module._leave(instance, tag)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Connect

--[[
	Adds a listener to a tag and returns a connection that removes it.
]]
--- @return { Disconnect: (self: any) -> () }
function Module._connect(tag: string, kind: string, callback: (instance: Instance) -> ())
	--[[ Saving ]]

	Module._listen(tag)
	local callbacks = listeners[tag][kind] --- @type { (instance: Instance) -> () }
	table.insert(callbacks, callback)

	--[[ Returning ]]

	return {
		Disconnect = function()
			local index: number? = table.find(callbacks, callback)
			if index then
				table.remove(callbacks, index)
			end
		end,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Contains

--[[
	Returns whether an instance is a bound root or inside one.
]]
--- @return boolean
function Module.Contains(instance: Instance)
	for root: Instance in pairs(roots) do
		if instance == root or instance:IsDescendantOf(root) then
			return true
		end
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Collection Service

--[[
	Stand-in for `CollectionService` with the methods the mirrored Utils call, seen through the scope.
]]
Module.CollectionService = {
	GetTagged = function(_self, tag: string): { Instance }
		--[[ Data ]]

		local instances = {} --- @type { Instance }
		Module._listen(tag)

		--[[ Filtering ]]

		-- Returned instances count as tracked, so binding a root later does not hand them over twice
		for _index: number, instance: Instance in ipairs(CollectionService:GetTagged(tag)) do
			if Module.Contains(instance) then
				tracked[tag][instance] = true
				table.insert(instances, instance)
			end
		end

		--[[ Returning ]]

		return instances
	end,

	GetInstanceAddedSignal = function(_self, tag: string)
		return {
			Connect = function(_signal, callback: (instance: Instance) -> ())
				return Module._connect(tag, "Added", callback)
			end,
		}
	end,

	GetInstanceRemovedSignal = function(_self, tag: string)
		return {
			Connect = function(_signal, callback: (instance: Instance) -> ())
				return Module._connect(tag, "Removed", callback)
			end,
		}
	end,
}

return Module
