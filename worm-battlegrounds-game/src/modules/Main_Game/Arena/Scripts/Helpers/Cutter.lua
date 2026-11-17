--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[
	The server and every client cut with the same shapes, so their pieces match; a client's pieces never collide or
	answer queries, so they skip the precise collision the server's need (several times faster to cut)
]]
--- @type { [string]: any }
local SUBTRACT_OPTIONS = {
	SplitApart = true,
	CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
	RenderFidelity = Enum.RenderFidelity.Automatic,
}

--- @type { [string]: any }
local SHOWN_OPTIONS = {
	SplitApart = true,
	CollisionFidelity = Enum.CollisionFidelity.Box,
	RenderFidelity = Enum.RenderFidelity.Automatic,
}

--- @type { [string]: any }
local MERGE_OPTIONS = {
	CollisionFidelity = Enum.CollisionFidelity.Box,
}

-- Boxes free for the next cutter (each side keeps its own), so a blast moves a few parts instead of making new ones
local spare = {} --- @type { BasePart }

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

--- @class Arena_Cutter
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Builds what a blast cuts away: every CARVE_CELL square of the plane whose center is within the radius, one box per
	row, each running `depth` studs along Z around `z`, in a folder (queries need them in the Workspace). The boxes come
	from the spare ones when there are some; the caller hands them back with Release.
]]
--- @return { BasePart }
function Module.Build(center: Vector3, radius: number, z: number, depth: number, parent: Instance)
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

		local box: BasePart = table.remove(spare) or I.Create("Part")({
			Name = "Cutter",
			Anchored = true,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			Transparency = 1,
		})
		box.Size = Vector3.new((last - first + 1) * cell, cell, depth)
		box.CFrame = CFrame.new((first + last + 1) / 2 * cell, (row + 0.5) * cell, z)
		if box.Parent ~= parent then
			box.Parent = parent
		end
		table.insert(boxes, box)
	end

	--[[ Returning ]]

	return boxes
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Hands a cutter's boxes back for the next blast, and removes the part they were merged into (Merge), when it's not
	the boxes themselves.
]]
--- @param boxes { BasePart }
--- @param cutter { BasePart }
function Module.Release(boxes, cutter)
	--[[ Cleaning ]]

	if cutter ~= boxes then
		for _index: number, part: BasePart in ipairs(cutter) do
			part:Destroy()
		end
	end

	--[[ Saving ]]

	table.move(boxes, 1, #boxes, #spare + 1, spare)
end

--%%%%%%%%%%%%%%%%%%%% Merge

--[[
	Merges a cutter's boxes into one part (yields), left out of the Workspace (GeometryService cuts parts anywhere, and
	a parented one would replicate its mesh to every player): cutting with one part is several times faster than with a
	box per row (measured 2026-11-13: a 14-stud blast over 36 parts, 0.86 s down to 0.32 s). Returns it in a list, as
	Subtract takes; the boxes themselves when they can't be merged (a single box, or no UnionAsync, as in the PC gym's
	engine). The caller hands both to Release.
]]
--- @param boxes { BasePart }
--- @return { BasePart }
function Module.Merge(boxes)
	--[[ Checks ]]

	-- Check if there's anything to merge
	if #boxes < 2 then
		return boxes
	end

	--[[ Merging ]]

	local success: boolean
	local result: any | string?
	-- Looked up inside the pcall: the gym's GeometryService has no UnionAsync at all
	success, result = pcall(function()
		return I.S.GeometryService:UnionAsync(boxes[1], { table.unpack(boxes, 2) }, MERGE_OPTIONS)
	end)
	if not success or not result or not result[1] then
		return boxes
	end

	--[[ Returning ]]

	local merged: BasePart = result[1]
	return { merged }
end

--%%%%%%%%%%%%%%%%%%%% Subtract

--[[
	Cuts the cutter out of a part (yields), with precise collision unless `shownOnly` (a client's pieces, which never
	collide). Returns the pieces left, unparented, each taking the part's name, collision group, attributes and colour
	on its cut faces; nil when the cut fails, with a warning on the server. A client tries once more first
	(CUT_RETRY_SECONDS): a piece the server just cut may not have its shape there yet, and its pieces follow anyway.
]]
--- @param cutter { BasePart }
--- @return { BasePart }?
function Module.Subtract(part: BasePart, cutter, shownOnly: boolean?)
	--[[ Local Variables ]]

	local options = if shownOnly then SHOWN_OPTIONS else SUBTRACT_OPTIONS --- @type { [string]: any }

	--[[ Cutting ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.GeometryService.SubtractAsync, I.S.GeometryService, part, cutter, options)
	if not success and I.Env.IsClient then
		task.wait(_settings.CUT_RETRY_SECONDS)
		success, result = pcall(I.S.GeometryService.SubtractAsync, I.S.GeometryService, part, cutter, options)
	end

	--[[ Checks ]]

	-- Check if the cut worked (a client's own prediction fails quietly: the server's pieces show the hole)
	if not success then
		if not I.Env.IsClient then
			warn(`[{_localName}::{script.Name}]: Could not carve ({part:GetFullName()})! - ({result})`)
		end
		return nil
	end

	--[[ Copying ]]

	--- @param piece BasePart
	for _index: number, piece in ipairs(result) do
		piece.Name = part.Name
		piece.CollisionGroup = part.CollisionGroup

		-- The cut faces take the piece's colour, not the cutter's
		piece.UsePartColor = true
		for attribute: string, value: any in pairs(part:GetAttributes()) do
			piece:SetAttribute(attribute, value)
		end
	end

	--[[ Returning ]]

	return result
end

return Module
