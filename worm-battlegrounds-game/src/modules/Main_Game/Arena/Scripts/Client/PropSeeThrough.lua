--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local PropBoxes = require(script.Parent:FindFirstChild("PropBoxes")) --- @type Arena_Client_PropBoxes

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local snailsFolder: Instance

--[[ Props ]]

--[[
	How see-through each faded prop is now, and its box's version when that was put on its parts, so the pieces that
	turn up in it since (the server's, this screen's own) take it too
]]
local amounts = {} --- @type { [Model]: number }
local applied = {} --- @type { [Model]: number }

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

--- @class Arena_Client_PropSeeThrough
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Local Variables ]]

	snailsFolder = I.Dirs.UmeWorkspace:WaitForChild("Snails")

	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Each frame, eases every prop a snail stands inside (on the plane, in front of it) toward PROP_SEE_THROUGH and every
	other faded prop back, so a snail is never lost behind a tree, a bush or a cactus. The props' boxes come from
	PropBoxes, read again only after a prop changes. Does nothing with no snails and no faded prop.
]]
function Module._step(deltaTime: number)
	--[[ Checks ]]

	-- Check if there's a snail to show or a prop to bring back
	local snails = snailsFolder:GetChildren() --- @type { Instance }
	if #snails == 0 and next(amounts) == nil then
		return
	end

	--[[ Local Variables ]]

	local boxes = PropBoxes.Get() --- @type { [PVInstance]: Arena_PropBox }
	local spots = {} --- @type { Vector3 }
	for _index: number, snail: Instance in ipairs(snails) do
		local root: BasePart? = snail:IsA("Model") and snail.PrimaryPart
		if root and not snail:GetAttribute("Ghost") then
			table.insert(spots, root.Position)
		end
	end
	local margin: number = _settings.PROP_SEE_THROUGH_MARGIN
	local stepAmount: number = deltaTime * _settings.PROP_SEE_THROUGH_SPEED

	--[[ Fading ]]

	--- @param box Arena_PropBox
	for prop: PVInstance, box in pairs(boxes) do
		if not prop:IsA("Model") then
			continue
		end
		local low: Vector3 = box.CFrame.Position - box.Size / 2
		local high: Vector3 = box.CFrame.Position + box.Size / 2
		local inside: boolean = false
		for _index: number, spot: Vector3 in ipairs(spots) do
			if spot.X >= low.X - margin and spot.X <= high.X + margin and spot.Y >= low.Y - margin and spot.Y <= high.Y + margin then
				inside = true
				break
			end
		end
		local current: number = amounts[prop] or 0
		local target: number = if inside then _settings.PROP_SEE_THROUGH else 0

		-- A faded prop whose parts changed takes its amount again
		if current == target and (current == 0 or applied[prop] == box.Version) then
			continue
		end
		local amount: number = if current < target then math.min(current + stepAmount, target) else math.max(current - stepAmount, target)
		amounts[prop] = if amount > 0 then amount else nil
		applied[prop] = if amount > 0 then box.Version else nil
		Module._apply(prop, amount)
	end

	--[[ Cleaning ]]

	-- A prop gone from the arena (blasted, fallen, or a new map) is forgotten
	for prop: Model in pairs(amounts) do
		if not boxes[prop] then
			amounts[prop] = nil
			applied[prop] = nil
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Makes a prop's parts this see-through on this screen only, leaving parts the client's carvers hid (fully) alone.
]]
function Module._apply(prop: Model, amount: number)
	--[[ Applying ]]

	for _index: number, part: Instance in ipairs(prop:GetDescendants()) do
		if part:IsA("BasePart") and part.LocalTransparencyModifier < 1 then
			part.LocalTransparencyModifier = amount
		end
	end
end

return Module
