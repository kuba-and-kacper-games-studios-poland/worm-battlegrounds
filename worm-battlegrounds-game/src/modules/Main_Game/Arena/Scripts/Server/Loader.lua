--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local arenaFolder: Folder
local terrainFolder: Folder?
local markersFolder: Folder?
local boundsPart: BasePart?
local planeAttachment: Attachment?

--- @type OverlapParams
local terrainParams = OverlapParams.new()

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

--- @class Arena_Server_Loader
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Building ]]

	arenaFolder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})
	terrainParams.FilterType = Enum.RaycastFilterType.Include
	terrainParams.FilterDescendantsInstances = {}

	--[[ Collision Groups ]]

	for name: string in pairs(_settings.COLLISION_GROUPS) do
		if not I.S.PhysicsService:IsCollisionGroupRegistered(name) then
			I.S.PhysicsService:RegisterCollisionGroup(name)
		end
	end

	--- @param ignored { string }
	for name: string, ignored in pairs(_settings.COLLISION_GROUPS) do
		for _index: number, other: string in ipairs(ignored) do
			I.S.PhysicsService:CollisionGroupSetCollidable(name, other, false)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Load

--[[
	Clears the arena and clones a map's template into it: its Terrain, Decor and Markers. Markers are hidden and
	never collide or block queries, terrain joins the Terrain collision group, and a plane part is placed at the
	bounds for worms and projectiles to keep to.
]]
--- @return boolean
function Module.Load(mapId: string)
	--[[ Data ]]

	local arenas: Instance? = I.Dirs.SAssets:FindFirstChild("Arenas")
	local template: Instance? = arenas and arenas:FindFirstChild(mapId)

	--[[ Checks ]]

	-- Check if the map has a template
	if not template then
		warn(`[{_localName}::{script.Name}]: Map ({mapId}) has no template in SAssets.Arenas!`)
		return false
	end

	-- Check if the template has terrain, markers and bounds
	local markers: Instance? = template:FindFirstChild("Markers")
	if not template:FindFirstChild("Terrain") or not markers or not markers:FindFirstChild("Bounds") then
		warn(`[{_localName}::{script.Name}]: Map ({mapId}) template needs Terrain, Markers and Markers.Bounds!`)
		return false
	end

	--[[ Clearing ]]

	arenaFolder:ClearAllChildren()

	--[[ Cloning ]]

	for _index: number, child: Instance in ipairs(template:GetChildren()) do
		child:Clone().Parent = arenaFolder
	end
	terrainFolder = arenaFolder:FindFirstChild("Terrain")
	markersFolder = arenaFolder:FindFirstChild("Markers")
	boundsPart = markersFolder:FindFirstChild("Bounds")

	--[[ Applying ]]

	for _index: number, marker: Instance in ipairs(markersFolder:GetDescendants()) do
		if marker:IsA("BasePart") then
			marker.Anchored = true
			marker.Transparency = 1
			marker.CanCollide = false
			marker.CanQuery = false
			marker.CanTouch = false
		end
	end
	for _index: number, part: Instance in ipairs(terrainFolder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CollisionGroup = "Terrain"
		end
	end
	terrainParams.FilterDescendantsInstances = { terrainFolder }

	--[[ Plane ]]

	local planePart: Part = I.Create("Part")({
		Name = "Plane",
		Size = Vector3.one,
		CFrame = CFrame.new(boundsPart.Position),
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Parent = arenaFolder,
	})

	-- A PlaneConstraint keeps things on the plane through its Attachment0's axis, which points along Z here
	planeAttachment = I.Create("Attachment")({
		Name = "Plane",
		CFrame = CFrame.fromMatrix(Vector3.zero, Vector3.zAxis, Vector3.yAxis),
		Parent = planePart,
	})

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Bounds

--[[
	Returns the loaded map's Bounds marker: the play area, and the extent of its liquid grid.
]]
--- @return BasePart?
function Module.GetBounds()
	return boundsPart
end

--%%%%%%%%%%%%%%%%%%%% Get Plane

--[[
	Returns the attachment worms and projectiles keep to the plane with, as their PlaneConstraint's Attachment0.
]]
--- @return Attachment?
function Module.GetPlane()
	return planeAttachment
end

--%%%%%%%%%%%%%%%%%%%% Get Arena Folder

--[[
	Returns Workspace.Ume.Arena, where the arena's parts and helpers live.
]]
--- @return Folder
function Module.GetArenaFolder()
	return arenaFolder
end

--%%%%%%%%%%%%%%%%%%%% Get Terrain

--[[
	Returns the loaded map's Terrain folder, where carved pieces and landed debris go too.
]]
--- @return Folder?
function Module.GetTerrain()
	return terrainFolder
end

--%%%%%%%%%%%%%%%%%%%% Get Markers

--[[
	Returns the loaded map's Markers folder (Bounds, DropZone, liquids).
]]
--- @return Folder?
function Module.GetMarkers()
	return markersFolder
end

--%%%%%%%%%%%%%%%%%%%% Get Terrain Params

--[[
	Returns overlap params that only see the terrain.
]]
--- @return OverlapParams
function Module.GetTerrainParams()
	return terrainParams
end

return Module
