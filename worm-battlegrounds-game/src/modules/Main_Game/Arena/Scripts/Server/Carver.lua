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
local Debris = require(script.Parent:FindFirstChild("Debris")) --- @type Arena_Server_Debris

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [string]: any }
local SUBTRACT_OPTIONS = {
	SplitApart = true,
	CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
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

--- @class Arena_Server_Carver
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Carve

--[[
	Subtracts the blast's stepped cutter (Build Cutter) from every terrain part it touches, bedrock included. Returns
	the new pieces and the parts that touched a removed one: the places where the ground may have lost its support.
]]
--- @return { BasePart }
function Module.Carve(center: Vector3, radius: number)
	--[[ Data ]]

	local terrain: Folder? = Loader.GetTerrain()
	local bounds: BasePart? = Loader.GetBounds()
	if not terrain or not bounds then
		return {}
	end

	--[[ Local Variables ]]

	local seeds = {} --- @type { BasePart }
	local hits = {} --- @type { BasePart }
	local found = {} --- @type { [BasePart]: boolean }
	local cutter = Module.BuildCutter(center, radius, bounds.Position.Z, bounds.Size.Z + _settings.CARVE_DEPTH_MARGIN) --- @type { BasePart }

	--[[ Querying ]]

	-- Each part any of the cutter's boxes reaches, once
	for _boxIndex: number, box: BasePart in ipairs(cutter) do
		for _hitIndex: number, part: BasePart in ipairs(I.S.Workspace:GetPartsInPart(box, Loader.GetTerrainParams())) do
			if not found[part] then
				found[part] = true
				table.insert(hits, part)
			end
		end
	end

	--[[ Carving ]]

	for _index: number, part: BasePart in ipairs(hits) do
		-- Skip debris still falling
		if not part.Anchored then
			continue
		end

		local success: boolean
		local result: any | string?
		success, result = pcall(I.S.GeometryService.SubtractAsync, I.S.GeometryService, part, cutter, SUBTRACT_OPTIONS)
		if not success then
			warn(`[{_localName}::{script.Name}]: Could not carve ({part:GetFullName()})! - ({result})`)
			continue
		end

		-- The parts that leaned on this one may now hang in the air
		for _neighbourIndex: number, neighbour: BasePart in ipairs(Debris.GetContacts(part)) do
			table.insert(seeds, neighbour)
		end

		--- @param piece BasePart
		for _pieceIndex: number, piece in ipairs(result) do
			piece.Name = part.Name
			piece.CollisionGroup = part.CollisionGroup

			-- The cut faces take the piece's colour, not the cutter's
			piece.UsePartColor = true
			for attribute: string, value: any in pairs(part:GetAttributes()) do
				piece:SetAttribute(attribute, value)
			end
			piece.Parent = terrain
			table.insert(seeds, piece)
		end
		part:Destroy()
	end

	--[[ Cleaning ]]

	for _index: number, box: BasePart in ipairs(cutter) do
		box:Destroy()
	end

	--[[ Returning ]]

	return seeds
end

--%%%%%%%%%%%%%%%%%%%% Build Cutter

--[[
	Builds what a blast cuts away: every CARVE_CELL square of the plane whose center is within the radius, one box per
	row, each running `depth` studs along Z around `z`. The caller destroys the boxes.
]]
--- @return { BasePart }
function Module.BuildCutter(center: Vector3, radius: number, z: number, depth: number)
	--[[ Local Variables ]]

	local cell: number = _settings.CARVE_CELL
	local boxes = {} --- @type { BasePart }

	--[[ Building ]]

	for row: number = math.floor((center.Y - radius) / cell), math.floor((center.Y + radius) / cell) do
		-- The row's run of squares whose centers are in the circle
		local offset: number = (row + 0.5) * cell - center.Y
		if math.abs(offset) > radius then
			continue
		end
		local half: number = math.sqrt(radius ^ 2 - offset ^ 2)
		local first: number = math.ceil((center.X - half) / cell - 0.5)
		local last: number = math.floor((center.X + half) / cell - 0.5)
		if first > last then
			continue
		end

		table.insert(
			boxes,
			I.Create("Part")({
				Name = "Cutter",
				Size = Vector3.new((last - first + 1) * cell, cell, depth),
				CFrame = CFrame.new((first + last + 1) / 2 * cell, (row + 0.5) * cell, z),
				Anchored = true,
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,
				Transparency = 1,
				Parent = Loader.GetArenaFolder(),
			})
		)
	end

	--[[ Returning ]]

	return boxes
end

return Module
