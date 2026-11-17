--[[
	Created By: 	HungryN00B
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class Arena_PropCut
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Extents

--[[
	Returns half the size of the world-aligned box around a part, however it's turned.
]]
--- @return Vector3
function Module.GetExtents(part: BasePart)
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
function Module.GetGap(position: Vector3, size: Vector3, center: Vector3)
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
function Module.GetPush(position: Vector3, center: Vector3)
	--[[ Local Variables ]]

	local away: Vector3 = Vector3.new(position.X - center.X, position.Y - center.Y, 0)
	local direction: Vector3 = if away.Magnitude > 0.01 then away.Unit else Vector3.yAxis

	--[[ Returning ]]

	return (direction + Vector3.yAxis * 0.5) * _settings.PROP_KNOCK_SPEED
end

--%%%%%%%%%%%%%%%%%%%% Get Span

--[[
	Returns the stretch along Z a prop cutter has to run through to cut right through a prop's box, grown from the
	span of the props before it: the same cutter serves every prop a blast reaches.
]]
--- @return NumberRange
function Module.GetSpan(boxCFrame: CFrame, boxSize: Vector3, span: NumberRange?)
	--[[ Local Variables ]]

	local reach: number = boxSize.Magnitude / 2
	local low: number = boxCFrame.Position.Z - reach
	local high: number = boxCFrame.Position.Z + reach

	--[[ Returning ]]

	if span then
		return NumberRange.new(math.min(span.Min, low), math.max(span.Max, high))
	end
	return NumberRange.new(low, high)
end

--%%%%%%%%%%%%%%%%%%%% Is Reached

--[[
	Returns whether a blast reaches a prop's part, by the part's box on the plane.
]]
--- @return boolean
function Module.IsReached(part: BasePart, center: Vector3, radius: number)
	return Module.GetGap(part.Position, Module.GetExtents(part) * 2, center) <= radius
end

--%%%%%%%%%%%%%%%%%%%% Is Inside

--[[
	Returns whether a prop's part lies wholly inside a blast, so it's gone rather than cut.
]]
--- @return boolean
function Module.IsInside(part: BasePart, center: Vector3, radius: number)
	--[[ Local Variables ]]

	local offset: Vector3 = part.Position - center
	local half: Vector3 = Module.GetExtents(part)

	--[[ Returning ]]

	return Vector2.new(math.abs(offset.X) + half.X, math.abs(offset.Y) + half.Y).Magnitude <= radius
end

--%%%%%%%%%%%%%%%%%%%% Split

--[[
	Splits a prop's parts after a cut into groups of touching parts (boxes within CONTACT_MARGIN): the groups that
	still reach its base (a part starting at most PROP_BASE_HEIGHT above it) stand, every other group is thrown.
	Returns the standing parts and the thrown groups.
]]
--- @param parts { BasePart }
--- @return { BasePart }
--- @return { { BasePart } }
function Module.Split(parts, base: number)
	--[[ Local Variables ]]

	local boxes = {} --- @type { [BasePart]: { Vector3 } }
	local grouped = {} --- @type { [BasePart]: boolean }
	local standing = {} --- @type { BasePart }
	local thrown = {} --- @type { { BasePart } }
	local top: number = base + _settings.PROP_BASE_HEIGHT
	for _index: number, part: BasePart in ipairs(parts) do
		local half: Vector3 = Module.GetExtents(part)
		boxes[part] = { part.Position - half, part.Position + half }
	end

	--[[ Grouping ]]

	-- Each group grows from a part to every part whose box touches one already in it
	for _index: number, start: BasePart in ipairs(parts) do
		if grouped[start] then
			continue
		end
		local members = { start } --- @type { BasePart }
		local cursor: number = 1
		local grounded: boolean = false
		grouped[start] = true
		while cursor <= #members do
			local current: BasePart = members[cursor]
			cursor += 1
			grounded = grounded or boxes[current][1].Y <= top
			for _otherIndex: number, other: BasePart in ipairs(parts) do
				if not grouped[other] and Module._isTouching(boxes[current], boxes[other]) then
					grouped[other] = true
					table.insert(members, other)
				end
			end
		end

		--[[ Sorting ]]

		if grounded then
			table.move(members, 1, #members, #standing + 1, standing)
		else
			table.insert(thrown, members)
		end
	end

	--[[ Returning ]]

	return standing, thrown
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
