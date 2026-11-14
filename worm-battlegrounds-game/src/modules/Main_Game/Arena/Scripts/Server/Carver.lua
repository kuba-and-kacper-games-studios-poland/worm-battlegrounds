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
local Cutter = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Cutter")) --- @type Arena_Cutter

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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Carve

--[[
	Subtracts the blast's stepped cutter from every terrain part it touches, bedrock included, all at once, then swaps
	every part for its pieces in one frame (each piece marked with the carve's number, `Arena_Carve`). Returns the new
	pieces and the parts that touched a removed one: the places where the ground may have lost its support.
]]
--- @return { BasePart }
function Module.Carve(center: Vector3, radius: number, carveId: number)
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
	local pieces = {} --- @type { [BasePart]: { BasePart } }
	local cutter = Cutter.Build(center, radius, bounds.Position.Z, bounds.Size.Z + _settings.CARVE_DEPTH_MARGIN, Loader.GetArenaFolder()) --- @type { BasePart }

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

	-- Every part is cut at the same time with one merged cutter, so the hole is ready in one go rather than a part a frame
	local merged = if #hits > 0 then Cutter.Merge(cutter) else cutter --- @type { BasePart }
	local running: number = #hits
	for _index: number, part: BasePart in ipairs(hits) do
		task.spawn(function()
			pieces[part] = Cutter.Subtract(part, merged)
			running -= 1
		end)
	end
	while running > 0 do
		task.wait()
	end

	--[[ Swapping ]]

	-- Every piece is in before any part goes, so clients never see a gap
	--- @param partPieces { BasePart }
	for _part: BasePart, partPieces in pairs(pieces) do
		--- @param piece BasePart
		for _pieceIndex: number, piece in ipairs(partPieces) do
			piece:SetAttribute("Arena_Carve", carveId)
			piece.Parent = terrain
			table.insert(seeds, piece)
		end
	end
	--- @param _partPieces { BasePart }
	for part: BasePart, _partPieces in pairs(pieces) do
		-- The parts that leaned on this one may now hang in the air
		for _neighbourIndex: number, neighbour: BasePart in ipairs(Debris.GetContacts(part)) do
			if not pieces[neighbour] then
				table.insert(seeds, neighbour)
			end
		end
		part:Destroy()
	end

	--[[ Cleaning ]]

	for _index: number, box: BasePart in ipairs(cutter) do
		box:Destroy()
	end
	for _index: number, box: BasePart in ipairs(merged) do
		box:Destroy()
	end

	--[[ Returning ]]

	return seeds
end

return Module
