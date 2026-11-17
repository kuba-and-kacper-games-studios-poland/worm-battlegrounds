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

local Loader = require(script.Parent:FindFirstChild("Loader")) --- @type Arena_Server_Loader
local Cutter = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Cutter")) --- @type Arena_Cutter
local PropCut = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("PropCut")) --- @type Arena_PropCut

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The loaded map's props still standing (Decor items with `Arena_Prop`)
local standing = {} --- @type { PVInstance }

-- Each standing prop's base height: its parts that start this low stand on the ground
local bases = {} --- @type { [PVInstance]: number }

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
	still too deep for that is flattened along Z until it fits. Each is marked with its base (`Arena_PropBase`), where
	every screen splits it when it cuts it itself.
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
			item:SetAttribute("Arena_PropBase", bases[item])
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Cut

--[[
	A blast's cut through the props, run alongside the terrain's: every part it reaches of every standing prop is cut
	at once with one cutter (the terrain's stepped shape), then in one frame each prop swaps its parts for the pieces
	still joined to its base and is marked with the carve's number (`Arena_Carve`). What the cut frees flies only on
	the screens, which cut the same hole and throw it themselves (Arena's client PropCarver): its new pieces are never
	shown here, and the prop's own parts in it are kept, unmoved, until every screen has faded them. A one-part prop
	(a mesh) the blast reaches is thrown whole the same way.
]]
function Module.Cut(center: Vector3, radius: number, carveId: number)
	--[[ Finding ]]

	local reached = {} --- @type { Model }
	local span: NumberRange? = nil
	for index: number = #standing, 1, -1 do
		local prop: PVInstance = standing[index]
		local boxCFrame: CFrame
		local boxSize: Vector3
		boxCFrame, boxSize = Module._getBox(prop)
		if PropCut.GetGap(boxCFrame.Position, boxSize, center) > radius then
			continue
		end
		if prop:IsA("Model") then
			table.insert(reached, prop)
			span = PropCut.GetSpan(boxCFrame, boxSize, span)
		else
			table.remove(standing, index)
			Module._keep({ prop })
		end
	end

	--[[ Checks ]]

	-- Check if the blast reaches a part-built prop
	if not span then
		return
	end

	--[[ Cutting ]]

	-- Every part of every prop at the same time, with one cutter long enough along Z for them all
	local boxes = Cutter.Build(center, radius, (span.Min + span.Max) / 2, span.Max - span.Min + _settings.CARVE_DEPTH_MARGIN, Loader.GetCutterFolder()) --- @type { BasePart }
	local cutter = Cutter.Merge(boxes) --- @type { BasePart }
	local pieces = {} --- @type { [BasePart]: { BasePart } }
	local running: number = 0
	for _index: number, prop: Model in ipairs(reached) do
		for _partIndex: number, part: Instance in ipairs(prop:GetDescendants()) do
			-- Skip what isn't a part, and parts the blast doesn't reach
			if not part:IsA("BasePart") or not PropCut.IsReached(part, center, radius) then
				continue
			end

			-- A part wholly inside the blast is gone
			if PropCut.IsInside(part, center, radius) then
				pieces[part] = {}
				continue
			end

			running += 1
			task.spawn(function()
				pieces[part] = Cutter.Subtract(part, cutter, true)
				running -= 1
			end)
		end
	end
	while running > 0 do
		task.wait()
	end
	Cutter.Release(boxes, cutter)

	--[[ Swapping ]]

	for _index: number, prop: Model in ipairs(reached) do
		Module._swap(prop, pieces, carveId)
	end
end

--%%%%%%%%%%%%%%%%%%%% Drop

--[[
	After a carve: drops every standing prop whose ground is gone, straight down: with the ground cut loose under it
	(as far as that falls), else onto the terrain under it, or out of the arena. Every screen draws the fall
	(Arena_PropFall); here the prop stays where it stood until every screen has faded it, then it's removed.
]]
--- @param falls { Arena_Fall }
function Module.Drop(falls)
	--[[ Dropping ]]

	for index: number = #standing, 1, -1 do
		--[[ Local Variables ]]

		local prop: PVInstance = standing[index]
		local boxCFrame: CFrame
		local boxSize: Vector3
		boxCFrame, boxSize = Module._getBox(prop)

		--[[ Checks ]]

		-- Check if its ground is still there
		if Module._isSupported(prop, boxCFrame, boxSize) then
			continue
		end

		--[[ Falling ]]

		local drop: number
		local started: number
		drop, started = Module._getDrop(prop, boxCFrame, boxSize, falls)
		table.remove(standing, index)
		I.Network.FireAll("Arena_PropFall", prop, drop, started)
		task.delay(Module._getKeepTime(), function()
			prop:Destroy()
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Swap

--[[
	Puts a cut prop's new state in place in one frame: the pieces still joined to its base go where their parts were,
	the parts they replace go, and what the cut frees leaves the prop (its new pieces never shown, its own parts kept
	until faded). A prop with nothing left standing is removed; one still standing is marked with the carve's number.
]]
--- @param pieces { [BasePart]: { BasePart } }
function Module._swap(prop: Model, pieces, carveId: number)
	--[[ Local Variables ]]

	-- The prop's parts after the cut, the parts the cut replaced, and where each new piece goes
	local parts = {} --- @type { BasePart }
	local cut = {} --- @type { BasePart }
	local homes = {} --- @type { [BasePart]: Instance }
	for _index: number, part: Instance in ipairs(prop:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end
		--- @type { BasePart }?
		local partPieces = pieces[part]
		if not partPieces then
			table.insert(parts, part)
			continue
		end
		table.insert(cut, part)
		for _pieceIndex: number, piece: BasePart in ipairs(partPieces) do
			homes[piece] = part.Parent
			table.insert(parts, piece)
		end
	end

	--[[ Splitting ]]

	local kept = {} --- @type { BasePart }
	local thrown = {} --- @type { { BasePart } }
	kept, thrown = PropCut.Split(parts, bases[prop])

	--[[ Swapping ]]

	-- Every new piece that stands is in before any part goes
	for _index: number, piece: BasePart in ipairs(kept) do
		if homes[piece] then
			piece.Anchored = true
			piece.CanCollide = false
			piece.CanTouch = false
			piece.CanQuery = false
			piece.Parent = homes[piece]
		end
	end
	for _index: number, part: BasePart in ipairs(cut) do
		part:Destroy()
	end

	--[[ Throwing ]]

	local thrownParts = {} --- @type { BasePart }
	--- @param members { BasePart }
	for _index: number, members in ipairs(thrown) do
		for _memberIndex: number, member: BasePart in ipairs(members) do
			if homes[member] then
				member:Destroy()
			else
				table.insert(thrownParts, member)
			end
		end
	end
	if #thrownParts > 0 then
		Module._keep(thrownParts)
	end

	--[[ Saving ]]

	if #kept == 0 then
		table.remove(standing, table.find(standing, prop))
		prop:Destroy()
		return
	end
	prop:SetAttribute("Arena_Carve", carveId)
end

--%%%%%%%%%%%%%%%%%%%% Keep

--[[
	Takes a prop's parts that a blast threw out of the props, unmoved (in the arena's folder), until every screen has
	drawn them flying and faded them out, then removes them.
]]
--- @param parts { BasePart }
function Module._keep(parts)
	--[[ Moving ]]

	for _index: number, part: BasePart in ipairs(parts) do
		part.Parent = Loader.GetArenaFolder()
	end

	--[[ Removing ]]

	task.delay(Module._getKeepTime(), function()
		for _index: number, part: BasePart in ipairs(parts) do
			part:Destroy()
		end
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

--%%%%%%%%%%%%%%%%%%%% Get Drop

--[[
	Returns how far a prop whose ground is gone falls and the server time its fall starts: with the ground cut loose
	right under its base when there is some (as far as that ground falls, from when it started), else down onto the
	terrain under its base, or to DEBRIS_KILL_DEPTH below the arena, from now.
]]
--- @param falls { Arena_Fall }
--- @return number
--- @return number
function Module._getDrop(prop: PVInstance, boxCFrame: CFrame, boxSize: Vector3, falls)
	--[[ Local Variables ]]

	local pivot: Vector3 = prop:GetPivot().Position
	local base: Vector3 = Vector3.new(pivot.X, boxCFrame.Position.Y - boxSize.Y / 2 + 0.5, pivot.Z)
	local reach: number = _settings.PROP_SUPPORT_DEPTH + 0.5
	local now: number = I.S.Workspace:GetServerTimeNow()

	--[[ Riding ]]

	--- @param fall Arena_Fall
	for _index: number, fall in ipairs(falls) do
		-- Where its parts stood before they started to fall
		local elapsed: number = now - fall.Started
		local fallen: number = math.min(0.5 * I.S.Workspace.Gravity * elapsed * elapsed, fall.Drop)
		for _partIndex: number, part: BasePart in ipairs(fall.Parts) do
			local half: Vector3 = part.ExtentsSize / 2
			local offset: Vector3 = base - (part.Position + Vector3.yAxis * fallen)
			if math.abs(offset.X) <= half.X and math.abs(offset.Z) <= half.Z and offset.Y + half.Y >= 0 and offset.Y - half.Y <= reach then
				return fall.Drop, fall.Started
			end
		end
	end

	--[[ Casting ]]

	local bounds: BasePart = Loader.GetBounds()
	local floor: number = bounds.Position.Y - bounds.Size.Y / 2 - _settings.DEBRIS_KILL_DEPTH
	local params: RaycastParams = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { Loader.GetTerrain() }
	local hit: RaycastResult? = I.S.Workspace:Raycast(base, Vector3.new(0, floor - base.Y, 0), params)

	--[[ Returning ]]

	return math.max((if hit then hit.Distance else base.Y - floor) - 0.5, 0), now
end

--%%%%%%%%%%%%%%%%%%%% Get Keep Time

--[[
	Returns how long a prop or prop part that fell or was thrown stays here: until every screen has faded it out
	(PROP_FADE_DELAY, then the fade), plus PROP_REMOVE_MARGIN for the screens that started it late.
]]
--- @return number
function Module._getKeepTime()
	return _settings.PROP_FADE_DELAY + _settings.PROP_FADE_TWEENINFO.Time + _settings.PROP_REMOVE_MARGIN
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

return Module
