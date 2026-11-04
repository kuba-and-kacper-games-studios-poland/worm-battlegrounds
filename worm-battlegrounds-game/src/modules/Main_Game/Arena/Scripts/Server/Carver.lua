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
	Subtracts a cylinder along Z from every terrain part it touches, except indestructible ones. Returns the new
	pieces and the parts that touched a removed one: the places where the ground may have lost its support.
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
	local depth: number = bounds.Size.Z + _settings.CARVE_DEPTH_MARGIN

	--[[ Building ]]

	-- The cutter: a cylinder's axis is its X, turned to run along Z through the plane
	local cutter: Part = I.Create("Part")({
		Name = "Cutter",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(depth, radius * 2, radius * 2),
		CFrame = CFrame.new(center.X, center.Y, bounds.Position.Z) * CFrame.Angles(0, math.rad(90), 0),
		Anchored = true,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		Transparency = 1,
		Parent = Loader.GetArenaFolder(),
	})

	--[[ Carving ]]

	local hits = I.S.Workspace:GetPartsInPart(cutter, Loader.GetTerrainParams()) --- @type { BasePart }
	for _index: number, part: BasePart in ipairs(hits) do
		-- Skip indestructible ground and debris still falling
		if part:GetAttribute("Arena_Indestructible") or not part.Anchored then
			continue
		end

		local success: boolean
		local result: any | string?
		success, result = pcall(I.S.GeometryService.SubtractAsync, I.S.GeometryService, part, { cutter }, SUBTRACT_OPTIONS)
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

	cutter:Destroy()

	--[[ Returning ]]

	return seeds
end

return Module
