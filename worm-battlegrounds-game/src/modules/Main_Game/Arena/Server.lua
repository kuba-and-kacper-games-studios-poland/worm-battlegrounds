--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Loader = require(_scripts:FindFirstChild("Server"):FindFirstChild("Loader")) --- @type Arena_Server_Loader
local Carver = require(_scripts:FindFirstChild("Server"):FindFirstChild("Carver")) --- @type Arena_Server_Carver
local Debris = require(_scripts:FindFirstChild("Server"):FindFirstChild("Debris")) --- @type Arena_Server_Debris
local Liquid = require(_scripts:FindFirstChild("Server"):FindFirstChild("Liquid")) --- @type Arena_Server_Liquid
local Props = require(_scripts:FindFirstChild("Server"):FindFirstChild("Props")) --- @type Arena_Server_Props

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local carving: boolean = false

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Loader.Init()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic

	I.Topic.Register("Arena_Loaded", { "string" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Arena = {

		--[[ Control ]]

		Load = Module.Load,
		Carve = Module.Carve,
		RaiseLiquid = Liquid.RaiseLiquid,

		--[[ Methods ]]

		GetBounds = Loader.GetBounds,
		GetMarkers = Loader.GetMarkers,
		GetPlane = Loader.GetPlane,
		GetLandSpots = Module.GetLandSpots,
		GetLiquid = Liquid.GetLiquid,
		GetLiquidKind = Liquid.GetLiquidKind,
		GetHazard = Module.GetHazard,
		IsFree = Module.IsFree,
		IsSettled = Debris.IsSettled,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Load

--[[
	**SERVER** |
	Replaces the arena with a fresh copy of a map's template and fills its liquids, then publishes Arena_Loaded.
]]
--- @return boolean
function Module.Load(mapId: string)
	--[[ Loading ]]

	if not Loader.Load(mapId) then
		return false
	end
	Props.Collect()
	Liquid.Build()

	--[[ Publishing ]]

	I.Topic.Publish("Arena_Loaded", mapId)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Carve

--[[
	**SERVER** |
	Cuts a round hole through the terrain, lets the liquid flow into it and drops what no longer touches the ground.
	Carves run one at a time, in the order they were asked for.
]]
function Module.Carve(center: Vector3, radius: number)
	--[[ Checks ]]

	-- Check if the radius cuts anything
	if radius <= 0 then
		return
	end

	--[[ Waiting ]]

	-- Each carve swaps parts, so the next one waits until this one is done
	while carving do
		task.wait()
	end
	carving = true

	--[[ Carving ]]

	local seeds = Carver.Carve(center, radius) --- @type { BasePart }
	Liquid.Refresh(center - Vector3.new(radius, radius, 0), center + Vector3.new(radius, radius, 0))
	Debris.Drop(seeds)
	Props.Update(center, radius)

	--[[ Saving ]]

	carving = false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Land Spots

--[[
	**SERVER** |
	Returns `count` random spots where a ball of `radius` stands on top of the terrain on any storey (under a floating
	ledge too), out of liquid, kept LAND_SPOT_GAP studs apart while there's room (closer when there isn't). Empty when
	the map has no such ground.
]]
--- @return { Vector3 }
function Module.GetLandSpots(count: number, radius: number)
	--[[ Data ]]

	local bounds: BasePart? = Loader.GetBounds()
	local terrain: Folder? = Loader.GetTerrain()
	if not bounds or not terrain then
		return {}
	end

	--[[ Local Variables ]]

	local params: RaycastParams = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { terrain }
	local top: number = bounds.Position.Y + bounds.Size.Y / 2
	local bottom: number = bounds.Position.Y - bounds.Size.Y / 2
	local left: number = bounds.Position.X - bounds.Size.X / 2 + radius
	local right: number = bounds.Position.X + bounds.Size.X / 2 - radius
	local candidates = {} --- @type { Vector3 }

	--[[ Finding ]]

	-- Every flat enough top under each step with room for the ball, on every storey
	for x: number = left, right, _settings.LAND_SPOT_STEP do
		local y: number = top
		while y > bottom do
			--[[ Casting ]]

			local hit: RaycastResult? = I.S.Workspace:Raycast(Vector3.new(x, y, bounds.Position.Z), Vector3.new(0, bottom - y, 0), params)

			--[[ Checks ]]

			-- Check if there's land left under this point
			if not hit then
				break
			end

			--[[ Saving ]]

			local spot: Vector3 = hit.Position + Vector3.new(0, radius + 0.1, 0)
			if hit.Normal.Y >= _settings.LAND_SPOT_MIN_NORMAL and Module.IsFree(spot, radius) then
				table.insert(candidates, spot)
			end

			-- Go on from just under it: a ray skips the part it starts in, and a top under more land isn't free
			y = hit.Position.Y - 0.05
		end
	end

	--[[ Picking ]]

	local random: Random = Random.new()
	random:Shuffle(candidates)
	local spots = {} --- @type { Vector3 }
	local skipped = {} --- @type { Vector3 }
	for _index: number, candidate: Vector3 in ipairs(candidates) do
		if #spots >= count then
			break
		end
		local tooClose: boolean = false
		for _spotIndex: number, spot: Vector3 in ipairs(spots) do
			if (spot - candidate).Magnitude < _settings.LAND_SPOT_GAP then
				tooClose = true
				break
			end
		end
		table.insert(if tooClose then skipped else spots, candidate)
	end

	-- Fills what the gap left out from the closer ones
	for _index: number, candidate: Vector3 in ipairs(skipped) do
		if #spots >= count then
			break
		end
		table.insert(spots, candidate)
	end

	--[[ Returning ]]

	return spots
end

--%%%%%%%%%%%%%%%%%%%% Get Hazard

--[[
	**SERVER** |
	Returns what knocks out a worm at a position: "Water" or "Lava" in liquid, "Bounds" beside or below the play
	area, or nil when it's safe there.
]]
--- @return string?
function Module.GetHazard(position: Vector3)
	--[[ Data ]]

	local bounds: BasePart? = Loader.GetBounds()
	if not bounds then
		return nil
	end

	--[[ Local Variables ]]

	local inside: Vector3 = bounds.CFrame:PointToObjectSpace(position)

	--[[ Returning ]]

	if math.abs(inside.X) > bounds.Size.X / 2 or inside.Y < -bounds.Size.Y / 2 then
		return "Bounds"
	end
	return Liquid.GetLiquid(position)
end

--%%%%%%%%%%%%%%%%%%%% Is Free

--[[
	**SERVER** |
	Returns whether a ball of `radius` fits at a position: inside the play area, out of liquid and touching no terrain.
]]
--- @return boolean
function Module.IsFree(position: Vector3, radius: number)
	--[[ Data ]]

	local bounds: BasePart? = Loader.GetBounds()
	if not bounds then
		return false
	end

	--[[ Local Variables ]]

	local inside: Vector3 = bounds.CFrame:PointToObjectSpace(position)

	--[[ Checks ]]

	-- Check if the ball is inside the play area
	if math.abs(inside.X) > bounds.Size.X / 2 - radius or math.abs(inside.Y) > bounds.Size.Y / 2 - radius then
		return false
	end

	-- Check if the ball is out of liquid
	if Liquid.GetLiquid(position) then
		return false
	end

	--[[ Returning ]]

	return #I.S.Workspace:GetPartBoundsInRadius(position, radius, Loader.GetTerrainParams()) == 0
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
