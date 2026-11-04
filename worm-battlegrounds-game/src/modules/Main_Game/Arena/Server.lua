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
		GetDropZone = Module.GetDropZone,
		GetLiquid = Liquid.GetLiquid,
		GetLiquidKind = Liquid.GetLiquidKind,
		GetHazard = Module.GetHazard,
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

	--[[ Saving ]]

	carving = false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Drop Zone

--[[
	**SERVER** |
	Returns the loaded map's DropZone marker: the X range worms may land in, and the height they drop from (its top).
]]
--- @return BasePart?
function Module.GetDropZone()
	--[[ Data ]]

	local markers: Folder? = Loader.GetMarkers()
	local zone: Instance? = markers and markers:FindFirstChild("DropZone")

	--[[ Checks ]]

	-- Check if the map has a drop zone
	if not zone or not zone:IsA("BasePart") then
		warn(`[{_localName}::{script.Name}]: The loaded map has no DropZone marker!`)
		return nil
	end

	--[[ Returning ]]

	return zone
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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
