--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local arenaFolder: Instance
local snailsFolder: Instance

--[[ Props ]]

-- Each prop in the loaded arena with its box on the plane (min X, min Y, max X, max Y) and how see-through it is now
local boxes = {} --- @type { [Model]: { number } }
local amounts = {} --- @type { [Model]: number }
local boxesReadAt: number = 0

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

function Module.Start(forArena: Instance)
	--[[ Local Variables ]]

	arenaFolder = forArena
	snailsFolder = I.Dirs.UmeWorkspace:WaitForChild("Snails")

	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Each frame, eases every prop a snail stands inside (on the plane, in front of it) toward PROP_SEE_THROUGH and every
	other faded prop back, so a snail is never lost behind a tree, a bush or a cactus. Does nothing with no snails and
	no faded prop.
]]
function Module._step(deltaTime: number)
	--[[ Checks ]]

	-- Check if there's a snail to show or a prop to bring back
	local snails = snailsFolder:GetChildren() --- @type { Instance }
	if #snails == 0 and next(amounts) == nil then
		return
	end

	--[[ Local Variables ]]

	local now: number = os.clock()
	if now - boxesReadAt >= _settings.PROP_SEE_THROUGH_REFRESH then
		boxesReadAt = now
		Module._readBoxes()
	end
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

	for prop: Model, box: { number } in pairs(boxes) do
		local inside: boolean = false
		for _index: number, spot: Vector3 in ipairs(spots) do
			if spot.X >= box[1] - margin and spot.X <= box[3] + margin and spot.Y >= box[2] - margin and spot.Y <= box[4] + margin then
				inside = true
				break
			end
		end
		local current: number = amounts[prop] or 0
		local target: number = if inside then _settings.PROP_SEE_THROUGH else 0
		if current == target then
			continue
		end
		local amount: number = if current < target then math.min(current + stepAmount, target) else math.max(current - stepAmount, target)
		amounts[prop] = if amount > 0 then amount else nil
		Module._apply(prop, amount)
	end

	--[[ Cleaning ]]

	-- A prop gone from the arena (blasted, or a new map) is forgotten
	for prop: Model in pairs(amounts) do
		if not boxes[prop] then
			amounts[prop] = nil
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Read Boxes

--[[
	Finds the loaded arena's props again and reads each one's box on the plane: props move back at load, fall and lose
	pieces to blasts.
]]
function Module._readBoxes()
	--[[ Reading ]]

	boxes = {}
	local decor: Instance? = arenaFolder:FindFirstChild("Decor")
	for _index: number, prop: Instance in ipairs(if decor then decor:GetDescendants() else {}) do
		if prop:IsA("Model") and prop:GetAttribute("Arena_Prop") then
			local boxCFrame: CFrame
			local boxSize: Vector3
			boxCFrame, boxSize = prop:GetBoundingBox()
			local low: Vector3 = boxCFrame.Position - boxSize / 2
			local high: Vector3 = boxCFrame.Position + boxSize / 2
			boxes[prop] = { low.X, low.Y, high.X, high.Y }
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Makes a prop's parts this see-through on this screen only, leaving parts the client's carver hid (fully) alone.
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
