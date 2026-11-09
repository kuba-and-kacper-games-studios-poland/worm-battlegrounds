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
	floor falls (Fall), except a ledge's biggest piece, which keeps floating.
]]
--- @param seeds { BasePart }
function Module.Drop(seeds)
	--[[ Local Variables ]]

	-- Each part walked, by the number of the search that walked it
	local visited = {} --- @type { [BasePart]: number }

	-- Each ledge's biggest cut-off group so far, which keeps floating, and its area on the plane
	local kept = {} --- @type { [number]: { BasePart } }
	local keptArea = {} --- @type { [number]: number }
	local falling = {} --- @type { { BasePart } }

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
				table.insert(falling, kept[ledge])
			end
			kept[ledge] = group
			keptArea[ledge] = area
		else
			table.insert(falling, group)
		end
	end

	--[[ Dropping ]]

	if #falling > 0 then
		Module._fall(falling)
	end
end

--%%%%%%%%%%%%%%%%%%%% Fall

--[[
	Drops groups cut loose straight down along the arena's plane, never turning: each falls by the game's gravity to
	where it first touches the terrain under it (lowest group first, so one above lands where the one under it will
	lie), or out of the arena. Every client draws the same fall from Arena_Fall.
]]
--- @param groups { { BasePart } }
function Module._fall(groups)
	--[[ Data ]]

	local bounds: BasePart = Loader.GetBounds()

	--[[ Local Variables ]]

	local killHeight: number = bounds.Position.Y - bounds.Size.Y / 2 - _settings.DEBRIS_KILL_DEPTH
	local drops = {} --- @type { number }

	--[[ Releasing ]]

	-- A falling piece is no longer part of its ledge (where it lands, it's ground like any other), and no query sees it
	-- while it falls: carves, contacts, the liquid and the other groups' landings pass it by
	--- @param group { BasePart }
	for _index: number, group in ipairs(groups) do
		for _partIndex: number, part: BasePart in ipairs(group) do
			part:SetAttribute("Arena_Floats", nil)
			part:SetAttribute("Arena_Ledge", nil)
			part.CanQuery = false
		end
	end

	--[[ Landing ]]

	table.sort(groups, function(a: { BasePart }, b: { BasePart }): boolean
		local lowA: Vector3 = getBox(a)
		local lowB: Vector3 = getBox(b)
		return lowA.Y < lowB.Y
	end)

	-- Each group stands where it will land for a moment, so the ones above land on it
	--- @param group { BasePart }
	for index: number, group in ipairs(groups) do
		drops[index] = Module._getDrop(group, killHeight)
		for _partIndex: number, part: BasePart in ipairs(group) do
			part.CFrame -= Vector3.yAxis * drops[index]
			part.CanQuery = true
		end
	end
	--- @param group { BasePart }
	for index: number, group in ipairs(groups) do
		for _partIndex: number, part: BasePart in ipairs(group) do
			part.CFrame += Vector3.yAxis * drops[index]
			part.CanQuery = false
		end
	end

	--[[ Falling ]]

	--- @param group { BasePart }
	for index: number, group in ipairs(groups) do
		fallingGroups += 1
		task.spawn(Module._watch, group, drops[index], killHeight)
	end
end

--%%%%%%%%%%%%%%%%%%%% Watch

--[[
	Moves a falling group down by the game's gravity each frame until it has dropped its distance, then leaves it where
	it landed and lets the liquid around it move; a group that fell out of the arena is removed. Either way the liquid
	looks again at where the group fell from, which is empty now.
]]
--- @param group { BasePart }
function Module._watch(group, drop: number, killHeight: number)
	--[[ Local Variables ]]

	local fromLow: Vector3
	local fromHigh: Vector3
	fromLow, fromHigh = getBox(group)
	local starts = {} --- @type { CFrame }
	for index: number, part: BasePart in ipairs(group) do
		starts[index] = part.CFrame
	end
	local started: number = I.S.Workspace:GetServerTimeNow()
	local fallen: number = 0

	--[[ Publishing ]]

	I.Network.FireAll("Arena_Fall", group, drop, started)

	--[[ Falling ]]

	while fallen < drop do
		I.S.RunService.Heartbeat:Wait()
		local elapsed: number = I.S.Workspace:GetServerTimeNow() - started
		fallen = math.min(0.5 * I.S.Workspace.Gravity * elapsed * elapsed, drop)
		for index: number, part: BasePart in ipairs(group) do
			part.CFrame = starts[index] - Vector3.yAxis * fallen
		end
	end

	--[[ Landing ]]

	if group[1].Position.Y <= killHeight + 0.01 then
		for _index: number, part: BasePart in ipairs(group) do
			part:Destroy()
		end
	else
		for _index: number, part: BasePart in ipairs(group) do
			part.CanQuery = true
		end
		local low: Vector3
		local high: Vector3
		low, high = getBox(group)
		Liquid.Refresh(low, high)
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

--%%%%%%%%%%%%%%%%%%%% Get Drop

--[[
	Returns how far a group falls straight down before one of its parts touches the terrain (a sweep of each part's
	shape), or far enough to leave the arena below `killHeight` when nothing is under it.
]]
--- @param group { BasePart }
--- @return number
function Module._getDrop(group, killHeight: number)
	--[[ Local Variables ]]

	local drop: number = group[1].Position.Y - killHeight
	local params: RaycastParams = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { Loader.GetTerrain() }

	--[[ Sweeping ]]

	for _index: number, part: BasePart in ipairs(group) do
		local hit: RaycastResult? = I.S.Workspace:Shapecast(part, Vector3.new(0, -drop, 0), params)
		if hit then
			drop = math.min(drop, hit.Distance)
		end
	end

	--[[ Returning ]]

	return math.max(drop, 0)
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
