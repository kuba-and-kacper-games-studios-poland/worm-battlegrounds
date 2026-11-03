--[[
    Created By:     Nari
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

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

--- @class Utils_GuiVisibility
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch

--[[
	Calls `callback` with whether `instance` is shown, right away and each time that changes, following reparents.
	Shown means every GuiObject from `instance` up is `Visible` and every LayerCollector above it is `Enabled`.
]]
--- @return Utils_GuiVisibilityConnection
function Module.Watch(instance: Instance, callback: (enabled: boolean) -> ())
	--[[ Local Variables ]]

	local ancestorConnections = {} --- @type { RBXScriptConnection }
	local ancestryConnection: RBXScriptConnection
	local lastEnabled: boolean? = nil

	--%%%%%%%%%%%%%%%%%%%% Update

	--[[
		Calls `callback` when the shown state changed.
	]]
	local function update()
		--[[ Checks ]]

		local enabled: boolean = Module.IsShown(instance)

		-- Skip when the shown state didn't change
		if enabled == lastEnabled then
			return
		end

		--[[ Calling ]]

		lastEnabled = enabled
		callback(enabled)
	end

	--%%%%%%%%%%%%%%%%%%%% Clear Ancestors

	--[[
		Disconnects the listeners on the ancestors.
	]]
	local function clearAncestors()
		--[[ Disconnecting ]]

		for _, connection: RBXScriptConnection in ipairs(ancestorConnections) do
			connection:Disconnect()
		end

		table.clear(ancestorConnections)
	end

	--%%%%%%%%%%%%%%%%%%%% Connect Ancestors

	--[[
		Listens to `Visible` and `Enabled` on the current ancestors, replacing the previous listeners.
	]]
	local function connectAncestors()
		--[[ Clearing ]]

		clearAncestors()

		--[[ Connecting ]]

		local current: Instance? = instance

		while current do
			if current:IsA("GuiObject") then
				table.insert(ancestorConnections, current:GetPropertyChangedSignal("Visible"):Connect(update))
			elseif current:IsA("LayerCollector") then
				table.insert(ancestorConnections, current:GetPropertyChangedSignal("Enabled"):Connect(update))
			end

			current = current.Parent
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Disconnect

	--[[
		Stops watching `instance`.
	]]
	local function disconnect()
		--[[ Disconnecting ]]

		ancestryConnection:Disconnect()
		clearAncestors()
	end

	--[[ Connections ]]

	ancestryConnection = instance.AncestryChanged:Connect(function()
		connectAncestors()
		update()
	end)

	connectAncestors()
	update()

	--[[ Returning ]]

	return { Disconnect = disconnect }
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Shown

--[[
	Returns whether every GuiObject from `instance` up is `Visible` and every LayerCollector above it is `Enabled`.
]]
--- @return boolean
function Module.IsShown(instance: Instance)
	--[[ Checking ]]

	local current: Instance? = instance

	while current do
		-- Stop at a hidden GuiObject
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end

		-- Stop at a disabled LayerCollector
		if current:IsA("LayerCollector") and not current.Enabled then
			return false
		end

		current = current.Parent
	end

	--[[ Returning ]]

	return true
end

return Module
