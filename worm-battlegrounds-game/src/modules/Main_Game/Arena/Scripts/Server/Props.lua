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
local Cutter = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Cutter")) --- @type Arena_Cutter

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The loaded map's props still standing (Decor items with `Arena_Prop`)
local standing = {} --- @type { PVInstance }

-- Each standing prop's base height: its parts that start this low stand on the ground
local bases = {} --- @type { [PVInstance]: number }

-- Prop parts never touch snails, so their pieces keep plain box collisions for the fall
--- @type { [string]: any }
local SUBTRACT_OPTIONS = {
	SplitApart = true,
	CollisionFidelity = Enum.CollisionFidelity.Box,
	RenderFidelity = Enum.RenderFidelity.Automatic,
}

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

--- @class Arena_Server_Props
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Collect

--[[
	Takes the loaded map's props: every Model or part under its Decor with the `Arena_Prop` attribute, each moved back
	along Z until its front is PROP_BEHIND_GAP behind the plane (the testers, 2026-11-13: snails walked through trees
	that covered them), but never so far that its pivot leaves the ground (PROP_GROUND_MARGIN in from its back); one
	still too deep for that is flattened along Z until it fits.
]]
function Module.Collect()
	--[[ Data ]]

	local decor: Instance? = Loader.GetArenaFolder():FindFirstChild("Decor")
	local groundBack: number = Loader.GetGroundDepth().Min + _settings.PROP_GROUND_MARGIN

	--[[ Collecting ]]

	standing = {}
	bases = {}
	for _index: number, item: Instance in ipairs(if decor then decor:GetDescendants() else {}) do
		if item:GetAttribute("Arena_Prop") and (item:IsA("Model") or item:IsA("BasePart")) then
			local boxCFrame: CFrame
			local boxSize: Vector3
			boxCFrame, boxSize = Module._getBox(item)

			-- Back behind the snails, its pivot still on the ground
			local pivot: CFrame = item:GetPivot()
			local back: number = math.min(-(boxCFrame.Position.Z + boxSize.Z / 2 + _settings.PROP_BEHIND_GAP), 0)
			back = math.max(back, math.min(groundBack - pivot.Position.Z, 0))
			if back < 0 then
				item:PivotTo(pivot + Vector3.zAxis * back)
				boxCFrame, boxSize = Module._getBox(item)
			end

			-- Too deep to fit behind the snails on the ground: flattened, which the camera along −Z barely sees
			local pivotZ: number = item:GetPivot().Position.Z
			for _pass: number = 1, 3 do
				local front: number = boxCFrame.Position.Z + boxSize.Z / 2
				if front <= -_settings.PROP_BEHIND_GAP + 0.05 or pivotZ >= -_settings.PROP_BEHIND_GAP then
					break
				end
				Module._flatten(item, pivotZ, (-_settings.PROP_BEHIND_GAP - pivotZ) / (front - pivotZ))
				boxCFrame, boxSize = Module._getBox(item)
			end
			table.insert(standing, item)
			bases[item] = boxCFrame.Position.Y - boxSize.Y / 2
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	After a blast: cuts its hole through every standing prop it reaches and throws what the cut frees, and drops every
	prop whose ground is gone.
]]
function Module.Update(center: Vector3, radius: number)
	--[[ Checking ]]

	for index: number = #standing, 1, -1 do
		--[[ Local Variables ]]

		local prop: PVInstance = standing[index]
		local boxCFrame: CFrame
		local boxSize: Vector3
		boxCFrame, boxSize = Module._getBox(prop)

		--[[ Cutting ]]

		-- A prop of one part (a mesh) is thrown whole; a part-built one is cut, and what the cut frees flies off
		if Module._getGap(boxCFrame.Position, boxSize, center) <= radius then
			if not prop:IsA("Model") then
				table.remove(standing, index)
				Module._release(prop, Module._getPush(boxCFrame.Position, center))
				continue
			end
			Module._cut(prop, center, radius)
			if not Module._split(prop, center) then
				table.remove(standing, index)
				continue
			end
			boxCFrame, boxSize = Module._getBox(prop)
		end

		--[[ Dropping ]]

		-- What still stands falls whole once its ground is gone
		if not Module._isSupported(prop, boxCFrame, boxSize) then
			table.remove(standing, index)
			Module._release(prop, nil)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Cut

--[[
	Subtracts the blast's stepped cutter (the terrain's) from every part of a prop it reaches, leaving the pieces in the
	prop.
]]
function Module._cut(prop: Model, center: Vector3, radius: number)
	--[[ Local Variables ]]

	local boxCFrame: CFrame
	local boxSize: Vector3
	boxCFrame, boxSize = prop:GetBoundingBox()

	--[[ Building ]]

	--- @type { BasePart }
	local boxes = Cutter.Build(center, radius, boxCFrame.Position.Z, boxSize.Magnitude + _settings.CARVE_DEPTH_MARGIN, Loader.GetArenaFolder())
	local cutter = Cutter.Merge(boxes) --- @type { BasePart }

	--[[ Cutting ]]

	for _index: number, part: Instance in ipairs(prop:GetDescendants()) do
		-- Skip what isn't a part, and parts the blast doesn't reach
		if not part:IsA("BasePart") or Module._getGap(part.Position, Module._getExtents(part) * 2, center) > radius then
			continue
		end

		-- A part wholly inside the blast is gone
		local offset: Vector3 = part.Position - center
		local half: Vector3 = Module._getExtents(part)
		if Vector2.new(math.abs(offset.X) + half.X, math.abs(offset.Y) + half.Y).Magnitude <= radius then
			part:Destroy()
			continue
		end

		local success: boolean
		local result: any | string?
		success, result = pcall(I.S.GeometryService.SubtractAsync, I.S.GeometryService, part, cutter, SUBTRACT_OPTIONS)
		if not success then
			warn(`[{_localName}::{script.Name}]: Could not cut ({part:GetFullName()})! - ({result})`)
			continue
		end

		--- @param piece BasePart
		for _pieceIndex: number, piece in ipairs(result) do
			piece.Name = part.Name

			-- The cut faces take the piece's colour, not the cutter's
			piece.UsePartColor = true
			piece.Anchored = true
			piece.CanCollide = false
			piece.CanTouch = false
			piece.CanQuery = false
			piece.Parent = part.Parent
		end
		part:Destroy()
	end

	--[[ Cleaning ]]

	for _index: number, box: BasePart in ipairs(boxes) do
		box:Destroy()
	end
	for _index: number, box: BasePart in ipairs(cutter) do
		box:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%% Split

--[[
	Keeps the groups of touching parts that still reach the prop's base, and throws every other group away from the
	blast. Returns whether anything still stands; a prop with nothing left is removed.
]]
--- @return boolean
function Module._split(prop: Model, center: Vector3)
	--[[ Local Variables ]]

	local parts = {} --- @type { BasePart }
	local boxes = {} --- @type { [BasePart]: { Vector3 } }
	local groupOf = {} --- @type { [BasePart]: number }
	local groups = {} --- @type { { BasePart } }
	for _index: number, part: Instance in ipairs(prop:GetDescendants()) do
		if part:IsA("BasePart") then
			local half: Vector3 = Module._getExtents(part)
			table.insert(parts, part)
			boxes[part] = { part.Position - half, part.Position + half }
		end
	end

	--[[ Grouping ]]

	-- Each group grows from a part to every part whose box touches one already in it
	for _index: number, start: BasePart in ipairs(parts) do
		if groupOf[start] then
			continue
		end
		local members = { start } --- @type { BasePart }
		local cursor: number = 1
		groupOf[start] = #groups + 1
		while cursor <= #members do
			local current: BasePart = members[cursor]
			cursor += 1
			for _otherIndex: number, other: BasePart in ipairs(parts) do
				if not groupOf[other] and Module._isTouching(boxes[current], boxes[other]) then
					groupOf[other] = groupOf[start]
					table.insert(members, other)
				end
			end
		end
		table.insert(groups, members)
	end

	--[[ Throwing ]]

	local base: number = bases[prop] + _settings.PROP_BASE_HEIGHT
	local stands: boolean = false
	--- @param members { BasePart }
	for _index: number, members in ipairs(groups) do
		local grounded: boolean = false
		for _memberIndex: number, member: BasePart in ipairs(members) do
			grounded = grounded or boxes[member][1].Y <= base
		end
		if grounded then
			stands = true
			continue
		end

		-- A group cut off from the base flies away from the blast as one piece
		local piece: Model = I.Create("Model")({ Name = `{prop.Name}Piece`, Parent = prop.Parent })
		local middle: Vector3 = Vector3.zero
		for _memberIndex: number, member: BasePart in ipairs(members) do
			member.Parent = piece
			middle += member.Position
		end
		Module._release(piece, Module._getPush(middle / #members, center))
	end

	--[[ Cleaning ]]

	if not stands then
		prop:Destroy()
	end

	--[[ Returning ]]

	return stands
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Welds a prop together and lets it fall with the server's physics (thrown at `push` when a blast hit it), then fades
	it out and removes it.
]]
function Module._release(prop: PVInstance, push: Vector3?)
	--[[ Local Variables ]]

	local parts = {} --- @type { BasePart }
	for _index: number, item: Instance in ipairs(if prop:IsA("BasePart") then { prop } else prop:GetDescendants()) do
		if item:IsA("BasePart") then
			table.insert(parts, item)
		end
	end
	local root: BasePart? = parts[1]
	if not root then
		return
	end

	--[[ Welding ]]

	for index: number, part: BasePart in ipairs(parts) do
		if index > 1 then
			I.Create("WeldConstraint")({
				Name = "PropWeld",
				Part0 = root,
				Part1 = part,
				Parent = part,
			})
		end
	end

	--[[ Releasing ]]

	for _index: number, part: BasePart in ipairs(parts) do
		part.Anchored = false
		part.CanCollide = true
	end
	root:SetNetworkOwner(nil)
	if push then
		root.AssemblyLinearVelocity = push
		root.AssemblyAngularVelocity = Vector3.new(0, 0, (math.random() - 0.5) * 2 * _settings.PROP_KNOCK_SPIN)
	end

	--[[ Fading ]]

	task.delay(_settings.PROP_FADE_DELAY, function()
		for _index: number, part: BasePart in ipairs(parts) do
			local Fade_TweenGoal = { Transparency = 1 }
			local Fade_Tween: Tween = I.S.TweenService:Create(part, _settings.PROP_FADE_TWEENINFO, Fade_TweenGoal)
			Fade_Tween:Play()
		end
		task.wait(_settings.PROP_FADE_TWEENINFO.Time)
		prop:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Flatten

--[[
	Flattens a prop along Z about its pivot by a scale: each part's distance from the pivot and its depth along Z
	shrink by it. A turned block becomes the block closest to its squashed shape, its edge pointing least along Z kept
	exactly, so from the front it stays as wide as it was.
]]
function Module._flatten(prop: PVInstance, pivotZ: number, scale: number)
	--[[ Local Variables ]]

	local squash: Vector3 = Vector3.new(1, 1, scale)

	--[[ Applying ]]

	--- @param part Instance
	for _index: number, part in ipairs(if prop:IsA("BasePart") then { prop } else prop:GetDescendants()) do
		if part:IsA("BasePart") then
			local cframe: CFrame = part.CFrame
			local edges = { cframe.RightVector * part.Size.X * squash, cframe.UpVector * part.Size.Y * squash, cframe.LookVector * part.Size.Z * squash } --- @type { Vector3 }
			table.sort(edges, function(a: Vector3, b: Vector3)
				return math.abs(a.Unit.Z) < math.abs(b.Unit.Z)
			end)

			-- The squashed edges made square again, keeping the first one's direction (a QR step)
			local first: Vector3 = edges[1].Unit
			local second: Vector3 = edges[2] - first * edges[2]:Dot(first)
			local third: Vector3 = first:Cross(second.Unit)
			part.Size = Vector3.new(edges[1].Magnitude, second.Magnitude, math.abs(edges[3]:Dot(third)))
			part.CFrame = CFrame.fromMatrix(cframe.Position + Vector3.zAxis * (cframe.Position.Z - pivotZ) * (scale - 1), first, second.Unit, third)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Box

--[[
	Returns a prop's bounding box.
]]
--- @return CFrame
--- @return Vector3
function Module._getBox(prop: PVInstance)
	--[[ Returning ]]

	if prop:IsA("Model") then
		return prop:GetBoundingBox()
	end
	return prop.CFrame, prop.Size
end

--%%%%%%%%%%%%%%%%%%%% Get Extents

--[[
	Returns half the size of the world-aligned box around a part, however it's turned.
]]
--- @return Vector3
function Module._getExtents(part: BasePart)
	--[[ Local Variables ]]

	local cframe: CFrame = part.CFrame
	local half: Vector3 = part.Size / 2

	--[[ Returning ]]

	return Vector3.new(
		math.abs(cframe.XVector.X) * half.X + math.abs(cframe.YVector.X) * half.Y + math.abs(cframe.ZVector.X) * half.Z,
		math.abs(cframe.XVector.Y) * half.X + math.abs(cframe.YVector.Y) * half.Y + math.abs(cframe.ZVector.Y) * half.Z,
		math.abs(cframe.XVector.Z) * half.X + math.abs(cframe.YVector.Z) * half.Y + math.abs(cframe.ZVector.Z) * half.Z
	)
end

--%%%%%%%%%%%%%%%%%%%% Get Gap

--[[
	Returns how far a blast's center is from a box of `size` at `position`, on the plane (0 inside it).
]]
--- @return number
function Module._getGap(position: Vector3, size: Vector3, center: Vector3)
	--[[ Local Variables ]]

	local offset: Vector3 = position - center

	--[[ Returning ]]

	return Vector2.new(math.max(math.abs(offset.X) - size.X / 2, 0), math.max(math.abs(offset.Y) - size.Y / 2, 0)).Magnitude
end

--%%%%%%%%%%%%%%%%%%%% Get Push

--[[
	Returns the velocity a blast at `center` throws something at `position` with: away from it and up.
]]
--- @return Vector3
function Module._getPush(position: Vector3, center: Vector3)
	--[[ Local Variables ]]

	local away: Vector3 = Vector3.new(position.X - center.X, position.Y - center.Y, 0)
	local direction: Vector3 = if away.Magnitude > 0.01 then away.Unit else Vector3.yAxis

	--[[ Returning ]]

	return (direction + Vector3.yAxis * 0.5) * _settings.PROP_KNOCK_SPEED
end

--%%%%%%%%%%%%%%%%%%%% Is Supported

--[[
	Returns whether anchored terrain is right under a prop's base, within PROP_SUPPORT_DEPTH: under its pivot (a
	part-built prop's trunk; a one-part prop's middle), so a tree leaning out over a drop still stands.
]]
--- @return boolean
function Module._isSupported(prop: PVInstance, boxCFrame: CFrame, boxSize: Vector3)
	--[[ Local Variables ]]

	local params: RaycastParams = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { Loader.GetTerrain() }
	local pivot: Vector3 = prop:GetPivot().Position
	local base: Vector3 = Vector3.new(pivot.X, boxCFrame.Position.Y - boxSize.Y / 2 + 0.5, pivot.Z)

	--[[ Returning ]]

	local hit: RaycastResult? = I.S.Workspace:Raycast(base, Vector3.new(0, -(_settings.PROP_SUPPORT_DEPTH + 0.5), 0), params)
	return hit ~= nil and hit.Instance.Anchored
end

--%%%%%%%%%%%%%%%%%%%% Is Touching

--[[
	Returns whether two boxes (their lowest and highest corners) overlap or sit within CONTACT_MARGIN of each other.
]]
--- @param a { Vector3 }
--- @param b { Vector3 }
--- @return boolean
function Module._isTouching(a, b)
	--[[ Local Variables ]]

	local margin: number = _settings.CONTACT_MARGIN

	--[[ Returning ]]

	return a[1].X - margin <= b[2].X and b[1].X - margin <= a[2].X and a[1].Y - margin <= b[2].Y and b[1].Y - margin <= a[2].Y and a[1].Z - margin <= b[2].Z and b[1].Z - margin <= a[2].Z
end

return Module
