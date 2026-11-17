--[[
	Created By: 	HungryN00B
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local arenaFolder: Instance
local decor: Instance? = nil
local decorConnections = {} --- @type { RBXScriptConnection }

--[[ Props ]]

-- Each prop on this screen with its box, and the props that changed since their box was read
local boxes = {} --- @type { [PVInstance]: Arena_PropBox }
local changed = {} --- @type { [PVInstance]: boolean }

-- Props no longer standing on this screen (thrown whole or fallen), left out until they're removed
local gone = {} --- @type { [PVInstance]: boolean }

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

--- @class Arena_Client_PropBoxes
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Instance)
	--[[ Local Variables ]]

	arenaFolder = folder

	--[[ Connections ]]

	arenaFolder.ChildAdded:Connect(Module._onChildAdded)
	local current: Instance? = arenaFolder:FindFirstChild("Decor")
	if current then
		Module._onChildAdded(current)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% On Child Added

--[[
	A new map's Decor: every prop in it is read at the next Get, and the props are watched as they change.
]]
function Module._onChildAdded(child: Instance)
	--[[ Checks ]]

	-- Check if this is the map's Decor
	if child.Name ~= "Decor" then
		return
	end

	--[[ Clearing ]]

	for _index: number, connection: RBXScriptConnection in ipairs(decorConnections) do
		connection:Disconnect()
	end
	decor = child
	boxes = {}
	changed = {}
	gone = {}

	--[[ Connections ]]

	decorConnections = {
		child.DescendantAdded:Connect(Module._onChanged),
		child.DescendantRemoving:Connect(Module._onRemoving),
	}
	for _index: number, item: Instance in ipairs(child:GetDescendants()) do
		Module._onChanged(item)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Changed

--[[
	Something turned up in a prop (the server's pieces, this screen's own), so its box is read again.
]]
function Module._onChanged(item: Instance)
	--[[ Data ]]

	local prop: PVInstance? = Module.GetProp(item)

	--[[ Saving ]]

	if prop then
		changed[prop] = true
	end
end

--%%%%%%%%%%%%%%%%%%%% On Removing

--[[
	A prop going is forgotten; a part leaving one changes its box.
]]
function Module._onRemoving(item: Instance)
	--[[ Data ]]

	local prop: PVInstance? = Module.GetProp(item)
	if not prop then
		return
	end

	--[[ Saving ]]

	if prop == item then
		boxes[prop] = nil
		changed[prop] = nil
		gone[prop] = nil
	else
		changed[prop] = true
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Forget

--[[
	Leaves a prop out from now on: it was thrown whole or fell on this screen, so it no longer stands.
]]
function Module.Forget(prop: PVInstance)
	--[[ Saving ]]

	gone[prop] = true
	boxes[prop] = nil
	changed[prop] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns every prop standing on this screen with its box, reading again only the boxes of props that changed
	since the last call (each such box's Version goes up). The table is this handler's own: read it, never change it.
]]
--- @return { [PVInstance]: Arena_PropBox }
function Module.Get()
	--[[ Reading ]]

	for prop: PVInstance in pairs(changed) do
		if gone[prop] or not decor or not prop:IsDescendantOf(decor) then
			continue
		end
		local boxCFrame: CFrame
		local boxSize: Vector3
		if prop:IsA("BasePart") then
			boxCFrame, boxSize = prop.CFrame, prop.Size
		else
			boxCFrame, boxSize = prop:GetBoundingBox()
		end
		--- @type Arena_PropBox?
		local old = boxes[prop]
		boxes[prop] = { CFrame = boxCFrame, Size = boxSize, Version = if old then old.Version + 1 else 1 }
	end
	table.clear(changed)

	--[[ Returning ]]

	return boxes
end

--%%%%%%%%%%%%%%%%%%%% Get Prop

--[[
	Returns the prop (an `Arena_Prop` Model or part in the map's Decor) an instance is or is in, nil when none.
]]
--- @return PVInstance?
function Module.GetProp(item: Instance)
	--[[ Local Variables ]]

	local current: Instance? = item

	--[[ Searching ]]

	while current and current ~= decor and current ~= arenaFolder do
		if current:GetAttribute("Arena_Prop") and (current:IsA("Model") or current:IsA("BasePart")) then
			return current
		end
		current = current.Parent
	end

	--[[ Returning ]]

	return nil
end

return Module
