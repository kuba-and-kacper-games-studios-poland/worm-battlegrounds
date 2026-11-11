--[[
	Created By: 	HungryN00B
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Atmosphere"

--- @type Atmosphere_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local arenaFolder: Instance?

--[[ Shape ]]

-- The liquid's rectangles as last read, the bottom of the lowest, and when they were read
local rects = {} --- @type { Atmosphere_LiquidRect }
local floorY: number = math.huge
local readAt: number = -math.huge

-- How far past an edge still counts as beside it, in studs (under the liquid's half-stud cell)
local EDGE_GAP: number = 0.1

local random: Random = Random.new()

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

--- @class Atmosphere_Client_Liquids
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Instance?)
	--[[ Folders ]]

	arenaFolder = folder
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Reads the arena's liquid rectangles again (Arena draws them as parts with an Arena_Liquid attribute), unless the
	last read is fresh.
]]
function Module._refresh()
	--[[ Checks ]]

	-- Skip while the last read is fresh
	if os.clock() - readAt < _settings.LIQUID_REFRESH then
		return
	end

	--[[ Data ]]

	local liquidFolder: Instance? = if arenaFolder then arenaFolder:FindFirstChild("Liquid") else nil

	--[[ Reading ]]

	readAt = os.clock()
	rects = {}
	floorY = math.huge
	for _index: number, part: Instance in ipairs(if liquidFolder then liquidFolder:GetChildren() else {}) do
		local kind: string? = part:GetAttribute("Arena_Liquid")
		if not kind or not part:IsA("BasePart") then
			continue
		end
		local position: Vector3 = part.Position
		local half: Vector3 = part.Size / 2
		table.insert(rects, {
			MinX = position.X - half.X,
			MaxX = position.X + half.X,
			MinY = position.Y - half.Y,
			MaxY = position.Y + half.Y,
			Kind = kind,
			Color = part.Color,
		})
		floorY = math.min(floorY, position.Y - half.Y)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Crossing

--[[
	Returns the height of the first liquid surface something passes going down at `x` from `fromY` to `toY`, and the
	rectangle it's the top of; nil when it passes none.
]]
--- @return number?
--- @return Atmosphere_LiquidRect?
function Module.GetCrossing(x: number, fromY: number, toY: number)
	--[[ Refreshing ]]

	Module._refresh()

	--[[ Finding ]]

	local best = nil --- @type Atmosphere_LiquidRect?
	--- @param rect Atmosphere_LiquidRect
	for _index: number, rect in ipairs(rects) do
		if x < rect.MinX or x > rect.MaxX or rect.MaxY > fromY or rect.MaxY < toY then
			continue
		end
		if (not best or rect.MaxY > best.MaxY) and Module._isSurface(x, rect.MaxY) then
			best = rect
		end
	end

	--[[ Returning ]]

	return if best then best.MaxY else nil, best
end

--%%%%%%%%%%%%%%%%%%%% Get Surface Spot

--[[
	Returns a random spot on the open surface of a liquid (picked by width, so a wide sea gets more than a step of it)
	and the liquid's colour; nil when that liquid has no open surface.
]]
--- @return Vector3?
--- @return Color3?
function Module.GetSurfaceSpot(kind: string)
	--[[ Refreshing ]]

	Module._refresh()

	--[[ Local Variables ]]

	local candidates = {} --- @type { Atmosphere_LiquidRect }
	local total: number = 0
	--- @param rect Atmosphere_LiquidRect
	for _index: number, rect in ipairs(rects) do
		if rect.Kind == kind then
			table.insert(candidates, rect)
			total += rect.MaxX - rect.MinX
		end
	end

	--[[ Picking ]]

	for _attempt: number = 1, 4 do
		local pick: number = random:NextNumber(0, total)
		--- @param rect Atmosphere_LiquidRect
		for _index: number, rect in ipairs(candidates) do
			pick -= rect.MaxX - rect.MinX
			if pick > 0 then
				continue
			end
			local x: number = random:NextNumber(rect.MinX, rect.MaxX)
			if Module._isSurface(x, rect.MaxY) then
				return Vector3.new(x, rect.MaxY, 0), rect.Color
			end
			break
		end
	end

	--[[ Returning ]]

	return nil, nil
end

--%%%%%%%%%%%%%%%%%%%% Get Kind

--[[
	Returns the liquid at a position ("Water", "Lava"), or nil when there is none.
]]
--- @return string?
function Module.GetKind(position: Vector3)
	--[[ Refreshing ]]

	Module._refresh()

	--[[ Returning ]]

	local rect = Module._getRectAt(position.X, position.Y) --- @type Atmosphere_LiquidRect?
	return if rect then rect.Kind else nil
end

--%%%%%%%%%%%%%%%%%%%% Is Deep

--[[
	Whether the liquid under a surface at `x` runs unbroken down to the map's floor: the sea, which Snails splashes as
	it knocks a snail out, rather than a pond.
]]
--- @return boolean
function Module.IsDeep(x: number, y: number)
	--[[ Refreshing ]]

	Module._refresh()

	--[[ Following ]]

	local bottom: number = y
	local rect = Module._getRectAt(x, bottom - EDGE_GAP) --- @type Atmosphere_LiquidRect?
	while rect do
		bottom = rect.MinY
		rect = Module._getRectAt(x, bottom - EDGE_GAP)
	end

	--[[ Returning ]]

	return bottom <= floorY + EDGE_GAP
end

--%%%%%%%%%%%%%%%%%%%% Is Surface

--[[
	Whether a liquid top at `x`, `y` is open to the air: no liquid sits right above it.
]]
--- @return boolean
function Module._isSurface(x: number, y: number)
	return Module._getRectAt(x, y + EDGE_GAP) == nil
end

--%%%%%%%%%%%%%%%%%%%% Get Rect At

--[[
	Returns the liquid rectangle holding a point, or nil when it's in none.
]]
--- @return Atmosphere_LiquidRect?
function Module._getRectAt(x: number, y: number)
	--[[ Finding ]]

	--- @param rect Atmosphere_LiquidRect
	for _index: number, rect in ipairs(rects) do
		if x >= rect.MinX and x <= rect.MaxX and y >= rect.MinY and y <= rect.MaxY then
			return rect
		end
	end

	--[[ Returning ]]

	return nil
end

return Module
