--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The server and every client cut with the same options, so their pieces match
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

--- @class Arena_Cutter
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Builds what a blast cuts away: every CARVE_CELL square of the plane whose center is within the radius, one box per
	row, each running `depth` studs along Z around `z`, in a folder. The caller destroys the boxes.
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
				Parent = parent,
			})
		)
	end

	--[[ Returning ]]

	return boxes
end

--%%%%%%%%%%%%%%%%%%%% Subtract

--[[
	Cuts the boxes out of a part (yields). Returns the pieces left, unparented, each taking the part's name, collision
	group, attributes and colour on its cut faces; nil and a warning when the cut fails.
]]
--- @param cutter { BasePart }
--- @return { BasePart }?
function Module.Subtract(part: BasePart, cutter)
	--[[ Cutting ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.GeometryService.SubtractAsync, I.S.GeometryService, part, cutter, SUBTRACT_OPTIONS)
	if not success then
		warn(`[{_localName}::{script.Name}]: Could not carve ({part:GetFullName()})! - ({result})`)
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
