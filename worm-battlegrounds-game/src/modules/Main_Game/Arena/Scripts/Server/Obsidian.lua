--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Loader = require(script.Parent:FindFirstChild("Loader")) --- @type Arena_Server_Loader

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

--- @class Arena_Server_Obsidian
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Builds the liquid grid's cells that turned to obsidian (indexes in ascending order) as terrain in the map's Terrain:
	each row's runs merge with the same run in the row below them into one OBSIDIAN part, as the liquid is drawn.
]]
--- @param cells { number }
function Module.Build(cells, cols: number, origin: Vector3, cell: number, depth: number)
	--[[ Local Variables ]]

	local open = {} --- @type { [number]: Arena_LiquidRect }
	local rects = {} --- @type { Arena_LiquidRect }
	local runStart: number = -1

	--[[ Merging ]]

	for position: number, index: number in ipairs(cells) do
		local nextIndex: number? = cells[position + 1]
		runStart = if runStart < 0 then index else runStart
		if nextIndex == index + 1 and index // cols == (index + 1) // cols then
			continue
		end
		local row: number = runStart // cols
		local key: number = (runStart % cols) * 8192 + index % cols
		local rect = open[key] --- @type Arena_LiquidRect?
		if rect and rect.Row + rect.Height == row then
			rect.Height += 1
		else
			rect = { Start = runStart % cols, Length = index - runStart + 1, Row = row, Height = 1, Kind = 0 }
			table.insert(rects, rect)
			open[key] = rect
		end
		runStart = -1
	end

	--[[ Building ]]

	--- @param rect Arena_LiquidRect
	for _index: number, rect in ipairs(rects) do
		I.Create("Part")({
			Name = "Obsidian",
			Size = Vector3.new(rect.Length * cell, rect.Height * cell, depth),
			CFrame = CFrame.new(origin + Vector3.new((rect.Start + rect.Length / 2) * cell, (rect.Row + rect.Height / 2) * cell, 0)),
			Color = _settings.OBSIDIAN_COLOR,
			Material = Enum.Material.SmoothPlastic,
			MaterialVariant = _settings.OBSIDIAN_VARIANT,
			Anchored = true,
			CollisionGroup = "Terrain",
			Parent = Loader.GetTerrain(),
		})
	end
end

return Module
