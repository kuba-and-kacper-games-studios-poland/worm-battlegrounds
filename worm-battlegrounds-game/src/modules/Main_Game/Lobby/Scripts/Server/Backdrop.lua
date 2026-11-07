--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lobby"

--- @type Lobby_Settings
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

--- @class Lobby_Server_Backdrop
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(worldFolder: Folder)
	--[[ Building ]]

	Module._build(worldFolder)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Copies BACKDROP_MAP (its Terrain and Decor, its liquid markers filled with still liquid, and its Bounds) to
	BACKDROP_ORIGIN, for every client's bot match behind the lobby.
]]
function Module._build(worldFolder: Folder)
	--[[ Data ]]

	local arenas: Instance? = I.Dirs.SAssets:FindFirstChild("Arenas")
	local mapId: string = _settings.BACKDROP_MAP
	local template: Instance? = arenas and arenas:FindFirstChild(mapId)

	--[[ Checks ]]

	-- Check if the map's template is in the place
	if not template or not template:FindFirstChild("Terrain") or not template:FindFirstChild("Markers") then
		warn(`[{_localName}::{script.Name}]: Map ({mapId}) has no template in SAssets.Arenas - no backdrop!`)
		return
	end

	--[[ Local Variables ]]

	local offset: CFrame = CFrame.new(_settings.BACKDROP_ORIGIN)
	local backdrop: Model = I.Create("Model")({
		Name = _settings.BACKDROP_NAME,
		ModelStreamingMode = Enum.ModelStreamingMode.Persistent,
	})
	backdrop:SetAttribute("MapId", mapId)

	--[[ Terrain And Decor ]]

	-- Only the terrain answers the clients' raycasts: the bots stand on it and their shots hit it
	for _index: number, folderName: string in ipairs({ "Terrain", "Decor" }) do
		local folder: Instance? = template:FindFirstChild(folderName)
		if not folder then
			continue
		end
		local copy: Instance = folder:Clone()
		for _partIndex: number, part: Instance in ipairs(copy:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = folderName == "Terrain"
				part.CFrame = offset * part.CFrame
			end
		end
		copy.Parent = backdrop
	end

	--[[ Markers ]]

	for _index: number, marker: Instance in ipairs(template:FindFirstChild("Markers"):GetChildren()) do
		-- Skip markers that are neither the play area nor a liquid
		local liquid: string? = marker:GetAttribute("Arena_Liquid")
		if not marker:IsA("BasePart") or (marker.Name ~= "Bounds" and not _settings.BACKDROP_LIQUID_COLORS[liquid]) then
			continue
		end

		I.Create("Part")({
			Name = if liquid then liquid else "Bounds",
			Size = marker.Size,
			CFrame = offset * marker.CFrame,
			Anchored = true,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			CastShadow = false,
			Material = Enum.Material.SmoothPlastic,
			Color = if liquid then _settings.BACKDROP_LIQUID_COLORS[liquid] else Color3.new(),
			Transparency = if liquid then _settings.BACKDROP_LIQUID_TRANSPARENCY[liquid] else 1,
			Parent = backdrop,
		})
	end

	--[[ Saving ]]

	backdrop.Parent = worldFolder
end

return Module
