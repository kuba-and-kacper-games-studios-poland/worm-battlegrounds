--[[
	The spatial queries the game's code asks Workspace (Raycast, Spherecast, Shapecast, GetPartsInPart,
	GetPartBoundsInRadius / InBox), PhysicsService's collision groups and GeometryService's SubtractAsync, for the
	game's arena: axis-aligned blocks, carved pieces (unions of rectangles on the X/Y plane, as the stepped cutter makes
	them) and balls (snails). Turned blocks are seen as their bounding box; the arena's are all props, which no query
	sees. Queries follow Roblox's rules: CanQuery, RespectCanCollide, collision groups, Include/Exclude filters, and a
	cast ignores what it starts inside.
]]

local datatypes = require("./datatypes")
local instance = require("./instance")

local v3 = datatypes.v3
local NIL = instance.NIL
local abs = math.abs
local sqrt = math.sqrt
local min = math.min
local max = math.max
local floor = math.floor
local huge = math.huge

local world = {}

local CELL: number = 8
local EPSILON: number = 1e-7
-- Overlap queries only count a real overlap, not parts that meet at a face (as Roblox's)
local OVERLAP: number = 1e-4

local workspaceRoot = nil
local dirty: boolean = true
local entries = {} -- { part, kind ("rect" | "ball"), a, b, c, d, z0, z1 }
local buckets = {} -- cell key -> { entry }
local stamp: number = 0

world.Stats = { Rebuilds = 0, Queries = 0 }

function world.SetWorkspace(root)
	workspaceRoot = root
	dirty = true
end

instance.onGeometry = function()
	dirty = true
end

--%%%%%%%%%%%%%%%%%%%% Collision groups

local groups = { Default = true }
local noCollide = {} -- "a|b" -> true

local PhysicsService = {}
function PhysicsService.RegisterCollisionGroup(_self, name: string)
	groups[name] = true
end
function PhysicsService.IsCollisionGroupRegistered(_self, name: string): boolean
	return groups[name] == true
end
function PhysicsService.CollisionGroupSetCollidable(_self, a: string, b: string, collidable: boolean)
	noCollide[a .. "|" .. b] = not collidable or nil
	noCollide[b .. "|" .. a] = not collidable or nil
end
function PhysicsService.CollisionGroupsAreCollidable(_self, a: string, b: string): boolean
	return not noCollide[a .. "|" .. b]
end
function PhysicsService.GetRegisteredCollisionGroups()
	local list = {}
	for name in groups do
		table.insert(list, { name = name })
	end
	return list
end
world.PhysicsService = PhysicsService

--%%%%%%%%%%%%%%%%%%%% Params

local ParamsMeta = {}
ParamsMeta.__index = ParamsMeta
local function newParams()
	return setmetatable({
		FilterType = datatypes.Enum.RaycastFilterType.Exclude,
		FilterDescendantsInstances = {},
		CollisionGroup = "Default",
		RespectCanCollide = false,
		IgnoreWater = false,
		BruteForceAllSlow = false,
		MaxParts = 0,
	}, ParamsMeta)
end
function ParamsMeta:AddToFilter(value)
	local list = self.FilterDescendantsInstances
	if type(value) == "table" and not rawget(value, "_isInstance") then
		for _, inst in value do
			table.insert(list, inst)
		end
	else
		table.insert(list, value)
	end
	self.FilterDescendantsInstances = list
end
world.RaycastParams = { new = newParams }
world.OverlapParams = { new = newParams }

--%%%%%%%%%%%%%%%%%%%% Shapes

--[[
	The shapes a part takes in the world: a ball, or the rectangles (x0, y0, x1, y1) of a block or a carved union, all
	running z0 to z1 along Z.
]]
local function getShapes(part, out)
	local props = part._props
	local cframe = props.CFrame
	local size = props.Size
	local cx, cy, cz = cframe._x, cframe._y, cframe._z
	if props.Shape and props.Shape.Name == "Ball" then
		table.insert(out, { part, "ball", cx, cy, cz, min(size.X, size.Y, size.Z) / 2 })
		return out
	end
	local extents = if datatypes.IsAxisAligned(cframe) then size else instance.RotatedExtents(cframe, size)
	local z0, z1 = cz - extents.Z / 2, cz + extents.Z / 2
	local rects = rawget(part, "_rects")
	if rects then
		for _, rect in rects do
			table.insert(out, { part, "rect", cx + rect[1], cy + rect[2], cx + rect[3], cy + rect[4], z0, z1 })
		end
	else
		table.insert(out, { part, "rect", cx - extents.X / 2, cy - extents.Y / 2, cx + extents.X / 2, cy + extents.Y / 2, z0, z1 })
	end
	return out
end
world.GetShapes = getShapes

local function shapeBox(entry)
	if entry[2] == "ball" then
		local r = entry[6]
		return entry[3] - r, entry[4] - r, entry[3] + r, entry[4] + r
	end
	return entry[3], entry[4], entry[5], entry[6]
end

--%%%%%%%%%%%%%%%%%%%% Index

local function rebuild()
	dirty = false
	world.Stats.Rebuilds += 1
	entries = {}
	buckets = {}
	local function visit(inst)
		for _, child in inst._children do
			if child._class.Lineage.BasePart and child._props.CanQuery then
				getShapes(child, entries)
			end
			if #child._children > 0 then
				visit(child)
			end
		end
	end
	visit(workspaceRoot)
	for _, entry in entries do
		local x0, y0, x1, y1 = shapeBox(entry)
		for gx = floor(x0 / CELL), floor(x1 / CELL) do
			for gy = floor(y0 / CELL), floor(y1 / CELL) do
				local key = gx * 100003 + gy
				local bucket = buckets[key]
				if not bucket then
					bucket = {}
					buckets[key] = bucket
				end
				table.insert(bucket, entry)
			end
		end
	end
end

local function filterFor(params)
	-- Answers whether a part passes the params, remembering each part's answer for this query
	local group = params.CollisionGroup or "Default"
	local respect = params.RespectCanCollide
	local include = params.FilterType == datatypes.Enum.RaycastFilterType.Include
	local listed = {}
	for _, inst in params.FilterDescendantsInstances or {} do
		if inst ~= nil then
			listed[inst] = true
		end
	end
	local memo = {}
	return function(part): boolean
		local known = memo[part]
		if known ~= nil then
			return known
		end
		local props = part._props
		local pass = true
		if respect and not props.CanCollide then
			pass = false
		elseif noCollide[group .. "|" .. props.CollisionGroup] then
			pass = false
		else
			local inList = false
			local current = part
			while current ~= nil and current ~= NIL do
				if listed[current] then
					inList = true
					break
				end
				current = current._props.Parent
			end
			pass = if include then inList else not inList
		end
		memo[part] = pass
		return pass
	end
end

local function candidates(x0, y0, x1, y1)
	if dirty then
		rebuild()
	end
	stamp += 1
	world.Stats.Queries += 1
	local found = {}
	for gx = floor(x0 / CELL), floor(x1 / CELL) do
		for gy = floor(y0 / CELL), floor(y1 / CELL) do
			local bucket = buckets[gx * 100003 + gy]
			if bucket then
				for _, entry in bucket do
					if entry.stamp ~= stamp then
						entry.stamp = stamp
						table.insert(found, entry)
					end
				end
			end
		end
	end
	return found
end

local function result(part, px, py, pz, nx, ny, nz, distance)
	return {
		Instance = part,
		Position = v3(px, py, pz),
		Normal = v3(nx, ny, nz),
		Distance = distance,
		Material = part._props.Material,
	}
end

--%%%%%%%%%%%%%%%%%%%% Sweeps

-- The first t in [0, 1] where a point moving (ox, oy) + t (dx, dy) enters a box, with the face's normal; nil when it
-- misses or starts inside (the caller skips boxes it starts inside)
local function slab2(ox, oy, dx, dy, x0, y0, x1, y1)
	local tEnter, tExit = -huge, huge
	local nx, ny = 0, 0
	-- Touching an edge or a face counts, as Roblox's casts count it
	if abs(dx) < EPSILON then
		if ox < x0 or ox > x1 then
			return nil
		end
	else
		local ta, tb = (x0 - ox) / dx, (x1 - ox) / dx
		local n = -1
		if ta > tb then
			ta, tb = tb, ta
			n = 1
		end
		if ta > tEnter then
			tEnter, nx, ny = ta, n, 0
		end
		tExit = min(tExit, tb)
	end
	if abs(dy) < EPSILON then
		if oy < y0 or oy > y1 then
			return nil
		end
	else
		local ta, tb = (y0 - oy) / dy, (y1 - oy) / dy
		local n = -1
		if ta > tb then
			ta, tb = tb, ta
			n = 1
		end
		if ta > tEnter then
			tEnter, nx, ny = ta, 0, n
		end
		tExit = min(tExit, tb)
	end
	if tEnter > tExit or tEnter < 0 or tEnter > 1 then
		return nil
	end
	return tEnter, nx, ny
end

-- The first t in [0, 1] where a point moving along (dx, dy) comes within r of (cx, cy); nil when it misses
local function circleHit(ox, oy, dx, dy, cx, cy, r)
	local fx, fy = ox - cx, oy - cy
	local a = dx * dx + dy * dy
	if a < EPSILON * EPSILON then
		return nil
	end
	local b = fx * dx + fy * dy
	local c = fx * fx + fy * fy - r * r
	local disc = b * b - a * c
	if disc < 0 then
		return nil
	end
	local t = (-b - sqrt(disc)) / a
	if t < 0 or t > 1 then
		return nil
	end
	return t
end

-- A circle of radius r swept along (dx, dy) against a rectangle: t, normal, contact point
local function sweepCircleRect(ox, oy, dx, dy, r, x0, y0, x1, y1)
	local best, bnx, bny, bpx, bpy = nil, 0, 0, 0, 0
	-- Its sides, widened by r
	local t, nx, ny = slab2(ox, oy, dx, dy, x0 - r, y0, x1 + r, y1)
	if t and nx ~= 0 then
		best, bnx, bny = t, nx, 0
		bpx, bpy = (if nx < 0 then x0 else x1), oy + dy * t
	end
	t, nx, ny = slab2(ox, oy, dx, dy, x0, y0 - r, x1, y1 + r)
	if t and ny ~= 0 and (best == nil or t < best) then
		best, bnx, bny = t, 0, ny
		bpx, bpy = ox + dx * t, (if ny < 0 then y0 else y1)
	end
	-- Its corners
	for _, corner in { { x0, y0 }, { x1, y0 }, { x0, y1 }, { x1, y1 } } do
		local tc = circleHit(ox, oy, dx, dy, corner[1], corner[2], r)
		if tc and (best == nil or tc < best) then
			local hx, hy = ox + dx * tc, oy + dy * tc
			-- Only where the side tests can't see it: beside the corner on both axes
			if (hx < x0 or hx > x1) and (hy < y0 or hy > y1) then
				local len = sqrt((hx - corner[1]) ^ 2 + (hy - corner[2]) ^ 2)
				best = tc
				bnx, bny = (hx - corner[1]) / len, (hy - corner[2]) / len
				bpx, bpy = corner[1], corner[2]
			end
		end
	end
	return best, bnx, bny, bpx, bpy
end

local function distanceToRect(px, py, x0, y0, x1, y1)
	local dx = max(x0 - px, 0, px - x1)
	local dy = max(y0 - py, 0, py - y1)
	return sqrt(dx * dx + dy * dy)
end

--[[
	Sweeps a ball of `radius` (0 for a ray) from `origin` along `direction` and returns the first hit, as Roblox's
	Raycast and Spherecast do. Everything is on the X/Y plane; a part counts when the ball's Z is within its depth.
]]
local function sweep(origin, radius: number, direction, params)
	local ox, oy, oz = origin.X, origin.Y, origin.Z
	local dx, dy, dz = direction.X, direction.Y, direction.Z
	local length = sqrt(dx * dx + dy * dy + dz * dz)
	if length < EPSILON then
		return nil
	end
	if abs(dz) > 1e-6 then
		-- shortcut: casts leave the plane nowhere in the game; a ray along Z only checks where it starts
		dz = 0
	end
	local passes = filterFor(params or newParams())
	local list = candidates(min(ox, ox + dx) - radius, min(oy, oy + dy) - radius, max(ox, ox + dx) + radius, max(oy, oy + dy) + radius)
	local bestT, bestHit = huge, nil
	for _, entry in list do
		local part = entry[1]
		if entry[2] == "rect" then
			-- How much of the ball reaches into the part's depth
			local depthGap = max(entry[7] - oz, 0, oz - entry[8])
			if depthGap > radius or (radius == 0 and depthGap > 0) then
				continue
			end
			local r = if radius > 0 then sqrt(radius * radius - depthGap * depthGap) else 0
			local x0, y0, x1, y1 = entry[3], entry[4], entry[5], entry[6]
			-- What it starts inside, it never hits
			if r > 0 then
				if distanceToRect(ox, oy, x0, y0, x1, y1) < r - 1e-6 then
					continue
				end
			elseif ox > x0 and ox < x1 and oy > y0 and oy < y1 then
				continue
			end
			if not passes(part) then
				continue
			end
			local t, nx, ny, px, py
			if r > 0 then
				t, nx, ny, px, py = sweepCircleRect(ox, oy, dx, dy, r, x0, y0, x1, y1)
			else
				t, nx, ny = slab2(ox, oy, dx, dy, x0, y0, x1, y1)
				if t then
					px, py = ox + dx * t, oy + dy * t
				end
			end
			if t and t < bestT then
				bestT = t
				bestHit = { part, px, py, nx, ny }
			end
		else
			local cx, cy, cz, br = entry[3], entry[4], entry[5], entry[6]
			local depthGap = abs(cz - oz)
			local reach = radius + br
			if depthGap >= reach then
				continue
			end
			local planar = sqrt(reach * reach - depthGap * depthGap)
			if (ox - cx) ^ 2 + (oy - cy) ^ 2 < planar * planar - 1e-6 then
				continue
			end
			if not passes(part) then
				continue
			end
			local t = circleHit(ox, oy, dx, dy, cx, cy, planar)
			if t and t < bestT then
				local hx, hy = ox + dx * t, oy + dy * t
				local len = sqrt((hx - cx) ^ 2 + (hy - cy) ^ 2)
				local nx, ny = (hx - cx) / len, (hy - cy) / len
				bestT = t
				bestHit = { part, cx + nx * br, cy + ny * br, nx, ny }
			end
		end
	end
	if not bestHit then
		return nil
	end
	return result(bestHit[1], bestHit[2], bestHit[3], oz, bestHit[4], bestHit[5], 0, bestT * length)
end

--%%%%%%%%%%%%%%%%%%%% Workspace queries

local queries = {}

function queries.Raycast(_self, origin, direction, params)
	return sweep(origin, 0, direction, params)
end

function queries.Spherecast(_self, origin, radius: number, direction, params)
	return sweep(origin, radius, direction, params)
end

function queries.Blockcast(_self, cframe, size, direction, params)
	local probe = instance.New("Part")
	probe._props.CFrame = cframe
	probe._props.Size = size
	return queries.Shapecast(_self, probe, direction, params)
end

--[[
	Sweeps a part's own shape along a direction (Debris drops carved pieces with it): each of its rectangles against
	every part's, as boxes sliding past each other.
]]
function queries.Shapecast(_self, part, direction, params)
	if part._props.Shape and part._props.Shape.Name == "Ball" then
		return sweep(part._props.CFrame.Position, part._props.Size.X / 2, direction, params)
	end
	local dx, dy = direction.X, direction.Y
	local length = sqrt(dx * dx + dy * dy)
	if length < EPSILON then
		return nil
	end
	local passes = filterFor(params or newParams())
	local own = getShapes(part, {})
	local bestT, bestHit = huge, nil
	for _, mine in own do
		local ax0, ay0, ax1, ay1 = mine[3], mine[4], mine[5], mine[6]
		local hx, hy = (ax1 - ax0) / 2, (ay1 - ay0) / 2
		local ox, oy = ax0 + hx, ay0 + hy
		local list = candidates(min(ax0, ax0 + dx), min(ay0, ay0 + dy), max(ax1, ax1 + dx), max(ay1, ay1 + dy))
		for _, entry in list do
			local other = entry[1]
			if other == part or entry[2] ~= "rect" then
				continue
			end
			if entry[8] <= mine[7] or entry[7] >= mine[8] then
				continue
			end
			local x0, y0, x1, y1 = entry[3] - hx, entry[4] - hy, entry[5] + hx, entry[6] + hy
			-- What it starts overlapping, it never hits
			if ox > x0 + 1e-6 and ox < x1 - 1e-6 and oy > y0 + 1e-6 and oy < y1 - 1e-6 then
				continue
			end
			if not passes(other) then
				continue
			end
			local t, nx, ny = slab2(ox, oy, dx, dy, x0, y0, x1, y1)
			if t and t < bestT then
				bestT = t
				bestHit = { other, ox + dx * t - nx * hx, oy + dy * t - ny * hy, nx, ny }
			end
		end
	end
	if not bestHit then
		return nil
	end
	return result(bestHit[1], bestHit[2], bestHit[3], part._props.CFrame._z, bestHit[4], bestHit[5], 0, bestT * length)
end

local function overlapping(a, b): boolean
	-- Two shapes overlap when they share more than a face
	if a[2] == "rect" and b[2] == "rect" then
		return a[3] < b[5] - OVERLAP and b[3] < a[5] - OVERLAP and a[4] < b[6] - OVERLAP and b[4] < a[6] - OVERLAP and a[7] < b[8] - OVERLAP and b[7] < a[8] - OVERLAP
	end
	if a[2] == "ball" and b[2] == "ball" then
		local r = a[6] + b[6] - OVERLAP
		return (a[3] - b[3]) ^ 2 + (a[4] - b[4]) ^ 2 + (a[5] - b[5]) ^ 2 < r * r
	end
	local ball, rect = if a[2] == "ball" then a else b, if a[2] == "ball" then b else a
	local gapZ = max(rect[7] - ball[5], 0, ball[5] - rect[8])
	local planar = distanceToRect(ball[3], ball[4], rect[3], rect[4], rect[5], rect[6])
	return planar * planar + gapZ * gapZ < (ball[6] - OVERLAP) ^ 2
end

local function overlapQuery(shapes, params, boundsOnly: boolean)
	local passes = filterFor(params or newParams())
	local seen = {}
	local found = {}
	for _, shape in shapes do
		local x0, y0, x1, y1 = shapeBox(shape)
		for _, entry in candidates(x0, y0, x1, y1) do
			local part = entry[1]
			if seen[part] then
				continue
			end
			local hit
			if boundsOnly then
				local ex0, ey0, ex1, ey1 = shapeBox(entry)
				local z0, z1 = if entry[2] == "ball" then entry[5] - entry[6] else entry[7], if entry[2] == "ball" then entry[5] + entry[6] else entry[8]
				local sz0, sz1 = if shape[2] == "ball" then shape[5] - shape[6] else shape[7], if shape[2] == "ball" then shape[5] + shape[6] else shape[8]
				hit = ex0 <= x1 and x0 <= ex1 and ey0 <= y1 and y0 <= ey1 and z0 <= sz1 and sz0 <= z1
			else
				hit = overlapping(shape, entry)
			end
			if hit and passes(part) then
				seen[part] = true
				table.insert(found, part)
			end
		end
	end
	return found
end

function queries.GetPartsInPart(_self, part, params)
	return overlapQuery(getShapes(part, {}), params, false)
end

function queries.GetPartBoundsInRadius(_self, position, radius: number, params)
	return overlapQuery({ { nil, "ball", position.X, position.Y, position.Z, radius } }, params, true)
end

function queries.GetPartBoundsInBox(_self, cframe, size, params)
	local cx, cy, cz = cframe._x, cframe._y, cframe._z
	local extents = if datatypes.IsAxisAligned(cframe) then size else instance.RotatedExtents(cframe, size)
	return overlapQuery({ { nil, "rect", cx - extents.X / 2, cy - extents.Y / 2, cx + extents.X / 2, cy + extents.Y / 2, cz - extents.Z / 2, cz + extents.Z / 2 } }, params, true)
end

world.Queries = queries

--%%%%%%%%%%%%%%%%%%%% Subtract

local function subtractRect(a, b, out)
	-- a minus b (both x0, y0, x1, y1): the strips of a around b
	if b[1] >= a[3] or b[3] <= a[1] or b[2] >= a[4] or b[4] <= a[2] then
		table.insert(out, a)
		return
	end
	if b[2] > a[2] then
		table.insert(out, { a[1], a[2], a[3], b[2] })
	end
	if b[4] < a[4] then
		table.insert(out, { a[1], b[4], a[3], a[4] })
	end
	local y0, y1 = max(a[2], b[2]), min(a[4], b[4])
	if b[1] > a[1] then
		table.insert(out, { a[1], y0, b[1], y1 })
	end
	if b[3] < a[3] then
		table.insert(out, { b[3], y0, a[3], y1 })
	end
end

local function merge(rects)
	-- Joins rectangles that share a whole side, until none do
	local changed = true
	while changed do
		changed = false
		for i = 1, #rects do
			local a = rects[i]
			for j = i + 1, #rects do
				local b = rects[j]
				local joined = nil
				if abs(a[2] - b[2]) < 1e-6 and abs(a[4] - b[4]) < 1e-6 and (abs(a[3] - b[1]) < 1e-6 or abs(b[3] - a[1]) < 1e-6) then
					joined = { min(a[1], b[1]), a[2], max(a[3], b[3]), a[4] }
				elseif abs(a[1] - b[1]) < 1e-6 and abs(a[3] - b[3]) < 1e-6 and (abs(a[4] - b[2]) < 1e-6 or abs(b[4] - a[2]) < 1e-6) then
					joined = { a[1], min(a[2], b[2]), a[3], max(a[4], b[4]) }
				end
				if joined then
					rects[i] = joined
					table.remove(rects, j)
					changed = true
					break
				end
			end
			if changed then
				break
			end
		end
	end
	return rects
end

local function touching(a, b): boolean
	-- Joined along a side, not only at a corner
	local overlapX = min(a[3], b[3]) - max(a[1], b[1])
	local overlapY = min(a[4], b[4]) - max(a[2], b[2])
	return (overlapX > 1e-6 and overlapY > -1e-6) or (overlapY > 1e-6 and overlapX > -1e-6)
end

--[[
	Cuts boxes out of a part, as GeometryService:SubtractAsync with SplitApart: one union per piece left, each made of
	the rectangles that hold together, at its bounding box, with the part's look and settings.
]]
local function subtractAsync(_self, part, cutters, _options)
	local props = part._props
	local cframe = props.CFrame
	local size = props.Size
	local cx, cy = cframe._x, cframe._y
	local rects = {}
	for _, rect in rawget(part, "_rects") or { { -size.X / 2, -size.Y / 2, size.X / 2, size.Y / 2 } } do
		table.insert(rects, { cx + rect[1], cy + rect[2], cx + rect[3], cy + rect[4] })
	end
	for _, cutter in cutters do
		local cc = cutter._props.CFrame
		local cs = cutter._props.Size
		local box = { cc._x - cs.X / 2, cc._y - cs.Y / 2, cc._x + cs.X / 2, cc._y + cs.Y / 2 }
		local left = {}
		for _, rect in rects do
			subtractRect(rect, box, left)
		end
		rects = left
	end
	-- Drop slivers float error leaves
	local kept = {}
	for _, rect in rects do
		if rect[3] - rect[1] > 1e-4 and rect[4] - rect[2] > 1e-4 then
			table.insert(kept, rect)
		end
	end
	rects = merge(kept)

	-- The pieces: rectangles that hold together
	local pieceOf = {}
	local pieces = {}
	for i in rects do
		if pieceOf[i] then
			continue
		end
		local piece = { i }
		pieceOf[i] = piece
		local head = 1
		while head <= #piece do
			local current = rects[piece[head]]
			head += 1
			for j, other in rects do
				if not pieceOf[j] and touching(current, other) then
					pieceOf[j] = piece
					table.insert(piece, j)
				end
			end
		end
		table.insert(pieces, piece)
	end

	local results = {}
	for _, piece in pieces do
		local x0, y0, x1, y1 = huge, huge, -huge, -huge
		for _, index in piece do
			local rect = rects[index]
			x0, y0, x1, y1 = min(x0, rect[1]), min(y0, rect[2]), max(x1, rect[3]), max(y1, rect[4])
		end
		local mx, my = (x0 + x1) / 2, (y0 + y1) / 2
		local localRects = {}
		for _, index in piece do
			local rect = rects[index]
			table.insert(localRects, { rect[1] - mx, rect[2] - my, rect[3] - mx, rect[4] - my })
		end
		local union = instance.New("UnionOperation")
		for key, value in props do
			if key ~= "Parent" and key ~= "Name" and union._class.Defaults[key] ~= nil then
				union._props[key] = value
			end
		end
		union._props.Name = props.Name
		union._props.CFrame = datatypes.cf(mx, my, cframe._z, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		union._props.Size = v3(x1 - x0, y1 - y0, size.Z)
		rawset(union, "_rects", localRects)
		table.insert(results, union)
	end
	return results
end

world.GeometryService = { SubtractAsync = subtractAsync }

return world
