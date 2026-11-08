--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Loader = require(script.Parent:FindFirstChild("Loader")) --- @type Arena_Server_Loader
local Liquid = require(script.Parent:FindFirstChild("Liquid")) --- @type Arena_Server_Liquid

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local fallingGroups: number = 0

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Box

--[[
	Returns the corners of a box around every part of a group, with room for each part's turn.
]]
--- @param group { BasePart }
--- @return Vector3, Vector3
local function getBox(group)
	--[[ Local Variables ]]

	local low: Vector3 = group[1].Position
	local high: Vector3 = group[1].Position

	--[[ Measuring ]]

	for _index: number, part: BasePart in ipairs(group) do
		local reach: Vector3 = Vector3.one * part.Size.Magnitude / 2
		low = low:Min(part.Position - reach)
		high = high:Max(part.Position + reach)
	end

	--[[ Returning ]]

	return low, high
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

--- @class Arena_Server_Debris
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Label Ledges

--[[
	**SERVER** |
	Numbers the loaded map's floating ledges: every group of touching `Arena_Floats` parts gets its own `Arena_Ledge`,
	which carved pieces keep, so a carve knows which pieces were one ledge.
]]
function Module.LabelLedges()
	--[[ Local Variables ]]

	local ledges: number = 0

	--[[ Labelling ]]

	for _index: number, part: Instance in ipairs(Loader.GetTerrain():GetDescendants()) do
		-- Skip ground, and ledge parts already numbered
		if not part:IsA("BasePart") or not part:GetAttribute("Arena_Floats") or part:GetAttribute("Arena_Ledge") then
			continue
		end

		ledges += 1
		part:SetAttribute("Arena_Ledge", ledges)
		local queue = { part } --- @type { BasePart }
		local head: number = 1
		while head <= #queue do
			local current: BasePart = queue[head]
			head += 1
			for _contactIndex: number, contact: BasePart in ipairs(Module.GetContacts(current)) do
				if contact:GetAttribute("Arena_Floats") and not contact:GetAttribute("Arena_Ledge") then
					contact:SetAttribute("Arena_Ledge", ledges)
					table.insert(queue, contact)
				end
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Drop

--[[
	Walks the terrain from each seed through the parts it touches. A group that reaches no bedrock standing on the
	floor is welded together and falls, except a ledge's biggest piece, which keeps floating.
]]
--- @param seeds { BasePart }
function Module.Drop(seeds)
	--[[ Local Variables ]]

	-- Each part walked, by the number of the search that walked it
	local visited = {} --- @type { [BasePart]: number }

	-- Each ledge's biggest cut-off group so far, which keeps floating, and its area on the plane
	local kept = {} --- @type { [number]: { BasePart } }
	local keptArea = {} --- @type { [number]: number }

	--[[ Searching ]]

	for index: number, seed: BasePart in ipairs(seeds) do
		-- Skip parts already walked, carved away, or already falling
		if visited[seed] or not seed.Parent or not seed.Anchored then
			continue
		end

		local group: { BasePart }
		local held: boolean
		local ledge: number?
		local area: number
		group, held, ledge, area = Module._getGroup(seed, visited, index)
		if held then
			continue
		end

		-- Ground cut loose falls, and so does every piece of a ledge but its biggest
		if ledge and area > (keptArea[ledge] or 0) then
			if kept[ledge] then
				Module._fall(kept[ledge])
			end
			kept[ledge] = group
			keptArea[ledge] = area
		else
			Module._fall(group)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Fall

--[[
	Welds a group to its first part, lets it fall with the server's physics and watches it land.
]]
--- @param group { BasePart }
function Module._fall(group)
	--[[ Local Variables ]]

	local root: BasePart = group[1]

	--[[ Welding ]]

	-- A falling piece is no longer part of its ledge: where it lands, it's ground like any other

	for index: number, part: BasePart in ipairs(group) do
		part:SetAttribute("Arena_Floats", nil)
		part:SetAttribute("Arena_Ledge", nil)
		if index > 1 then
			I.Create("WeldConstraint")({
				Name = "ArenaWeld",
				Part0 = root,
				Part1 = part,
				Parent = part,
			})
		end
	end

	--[[ Releasing ]]

	for _index: number, part: BasePart in ipairs(group) do
		part.Anchored = false
	end
	root:SetNetworkOwner(nil)
	fallingGroups += 1
	task.spawn(Module._watch, group, root)
end

--%%%%%%%%%%%%%%%%%%%% Watch

--[[
	Waits until a falling group lands, then anchors it where it lies and lets the liquid around it move. A group that
	falls far below the arena is removed. Either way the liquid looks again at where the group fell from, which is
	empty now.
]]
--- @param group { BasePart }
function Module._watch(group, root: BasePart)
	--[[ Data ]]

	local bounds: BasePart = Loader.GetBounds()

	--[[ Local Variables ]]

	local killHeight: number = bounds.Position.Y - bounds.Size.Y / 2 - _settings.DEBRIS_KILL_DEPTH
	local started: number = os.clock()
	local slowSince: number? = nil
	local fromLow: Vector3
	local fromHigh: Vector3
	fromLow, fromHigh = getBox(group)

	--[[ Watching ]]

	while root.Parent do
		task.wait()

		-- Fell out of the arena
		if root.Position.Y < killHeight then
			for _index: number, part: BasePart in ipairs(group) do
				part:Destroy()
			end
			break
		end

		if root.AssemblyLinearVelocity.Magnitude < _settings.SETTLE_SPEED then
			slowSince = slowSince or os.clock()
		else
			slowSince = nil
		end
		local landed: boolean = (slowSince ~= nil and os.clock() - slowSince >= _settings.SETTLE_HOLD) or os.clock() - started >= _settings.DEBRIS_SETTLE_TIME
		if not landed then
			continue
		end

		--[[ Anchoring ]]

		for _index: number, part: BasePart in ipairs(group) do
			part.Anchored = true
			local weld: Instance? = part:FindFirstChild("ArenaWeld")
			if weld then
				weld:Destroy()
			end
		end
		local low: Vector3
		local high: Vector3
		low, high = getBox(group)
		Liquid.Refresh(low, high)
		break
	end

	--[[ Clearing ]]

	-- Where it hung is open now: without this the liquid kept treating it as ground
	Liquid.Refresh(fromLow, fromHigh)

	--[[ Saving ]]

	fallingGroups -= 1
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Contacts

--[[
	Returns the anchored terrain parts touching a part. It asks with a slightly bigger copy, since overlap queries miss
	parts that only meet at a face.
]]
--- @return { BasePart }
function Module.GetContacts(part: BasePart)
	--[[ Local Variables ]]

	local contacts = {} --- @type { BasePart }
	local probe: BasePart = part:Clone()

	--[[ Building ]]

	probe:ClearAllChildren()
	probe.Size += Vector3.one * _settings.CONTACT_MARGIN * 2
	probe.Anchored = true
	probe.CanCollide = false
	probe.CanQuery = false
	probe.Transparency = 1
	probe.Parent = Loader.GetArenaFolder()

	--[[ Querying ]]

	for _index: number, hit: BasePart in ipairs(I.S.Workspace:GetPartsInPart(probe, Loader.GetTerrainParams())) do
		if hit ~= part and hit.Anchored then
			table.insert(contacts, hit)
		end
	end
	probe:Destroy()

	--[[ Returning ]]

	return contacts
end

--%%%%%%%%%%%%%%%%%%%% Is Settled

--[[
	**SERVER** |
	Returns whether no carved-off debris is still falling.
]]
--- @return boolean
function Module.IsSettled()
	return fallingGroups == 0
end

--%%%%%%%%%%%%%%%%%%%% Get Group

--[[
	Collects the parts connected to a start part, stopping early once it reaches ground (bedrock, Arena_Indestructible,
	whose bottom still reaches the map's floor) or a part an earlier search walked (an earlier floating group would hold
	this part too, so that search ended on the ground). Returns the parts found, whether the ground holds them up, the
	ledge they belong to (`Arena_Ledge`) and the area its parts cover on the plane. A group past the search limit counts
	as held when it's ground, and as its ledge's biggest piece when it's a ledge.
]]
--- @param visited { [BasePart]: number }
--- @return { BasePart }
--- @return boolean
--- @return number?
--- @return number
function Module._getGroup(start: BasePart, visited, search: number)
	--[[ Local Variables ]]

	local group = {} --- @type { BasePart }
	local queue = { start } --- @type { BasePart }
	local head: number = 1
	local floatArea: number = 0
	local ledge: number? = nil
	local groundHeight: number = Loader.GetFloor() + _settings.CONTACT_MARGIN
	visited[start] = search

	--[[ Searching ]]

	while head <= #queue do
		local part: BasePart = queue[head]
		head += 1
		table.insert(group, part)
		local onFloor: boolean = part:GetAttribute("Arena_Indestructible") == true and part.ExtentsCFrame.Y - part.ExtentsSize.Y / 2 <= groundHeight
		if onFloor then
			return group, true, nil, 0
		end
		if part:GetAttribute("Arena_Floats") then
			floatArea += part.Size.X * part.Size.Y
			ledge = ledge or part:GetAttribute("Arena_Ledge")
		end
		if #group >= _settings.SUPPORT_SEARCH_LIMIT then
			return group, ledge == nil, ledge, math.huge
		end
		for _index: number, contact: BasePart in ipairs(Module.GetContacts(part)) do
			if visited[contact] and visited[contact] ~= search then
				return group, true, nil, 0
			end
			if not visited[contact] then
				visited[contact] = search
				table.insert(queue, contact)
			end
		end
	end

	--[[ Returning ]]

	return group, false, ledge, floatArea
end

return Module
