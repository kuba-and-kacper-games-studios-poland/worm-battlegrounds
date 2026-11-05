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

--%%%%%%%%%%%%%%%%%%%% Drop

--[[
	Walks the terrain from each seed through the parts it touches. A group that reaches no indestructible part is
	welded together and falls.
]]
--- @param seeds { BasePart }
function Module.Drop(seeds)
	--[[ Local Variables ]]

	-- Each part walked, by the number of the search that walked it
	local visited = {} --- @type { [BasePart]: number }

	--[[ Searching ]]

	for index: number, seed: BasePart in ipairs(seeds) do
		-- Skip parts already walked, carved away, or already falling
		if visited[seed] or not seed.Parent or not seed.Anchored then
			continue
		end

		local group: { BasePart }
		local grounded: boolean
		group, grounded = Module._getGroup(seed, visited, index)
		if not grounded then
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

	for index: number, part: BasePart in ipairs(group) do
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
	falls far below the arena is removed.
]]
--- @param group { BasePart }
function Module._watch(group, root: BasePart)
	--[[ Data ]]

	local bounds: BasePart = Loader.GetBounds()

	--[[ Local Variables ]]

	local killHeight: number = bounds.Position.Y - bounds.Size.Y / 2 - _settings.DEBRIS_KILL_DEPTH
	local started: number = os.clock()
	local slowSince: number? = nil

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

		local low: Vector3 = root.Position
		local high: Vector3 = root.Position
		for _index: number, part: BasePart in ipairs(group) do
			part.Anchored = true
			local weld: Instance? = part:FindFirstChild("ArenaWeld")
			if weld then
				weld:Destroy()
			end
			local reach: Vector3 = Vector3.one * part.Size.Magnitude / 2
			low = low:Min(part.Position - reach)
			high = high:Max(part.Position + reach)
		end
		Liquid.Refresh(low, high)
		break
	end

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
	Collects the parts connected to a start part, stopping early once it reaches indestructible ground, the search
	limit, or a part an earlier search walked (an earlier floating group would hold this part too, so that search
	ended on the ground). A whole group stays up too when its floating parts (`Arena_Floats`) cover at least
	FLOAT_MIN_AREA on the plane. Returns the parts found and whether they are held up.
]]
--- @param visited { [BasePart]: number }
--- @return { BasePart }
--- @return boolean
function Module._getGroup(start: BasePart, visited, search: number)
	--[[ Local Variables ]]

	local group = {} --- @type { BasePart }
	local queue = { start } --- @type { BasePart }
	local head: number = 1
	local floatArea: number = 0
	visited[start] = search

	--[[ Searching ]]

	while head <= #queue do
		local part: BasePart = queue[head]
		head += 1
		table.insert(group, part)
		if part:GetAttribute("Arena_Indestructible") or #group >= _settings.SUPPORT_SEARCH_LIMIT then
			return group, true
		end
		if part:GetAttribute("Arena_Floats") then
			floatArea += part.Size.X * part.Size.Y
		end
		for _index: number, contact: BasePart in ipairs(Module.GetContacts(part)) do
			if visited[contact] and visited[contact] ~= search then
				return group, true
			end
			if not visited[contact] then
				visited[contact] = search
				table.insert(queue, contact)
			end
		end
	end

	--[[ Returning ]]

	return group, floatArea >= _settings.FLOAT_MIN_AREA
end

return Module
