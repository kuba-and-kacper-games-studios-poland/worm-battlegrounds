--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AssetsPreload"

--- @type AssetsPreload_Settings
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Preloading ]]

	-- On a thread of its own, so nothing waits for the downloads
	task.spawn(Module._preload)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Preload

--[[
	Loads, in turn: everything in the game's guis (backgrounds, frames, icons, even in guis not open yet), the pictures
	the game's data and settings name for code to set later (item, weapon and crate icons), then the asset folder's
	models, textures, effects and animations (crates, weapons, skins, snails, the lobby stage).
]]
function Module._preload()
	--[[ Local Variables ]]

	local guis = {} --- @type { Instance }
	local ids = {} --- @type { string }
	local seen = {} --- @type { [any]: boolean }

	--[[ Gathering ]]

	for _name: string, gui: ScreenGui in pairs(I.UserInterface.UI) do
		table.insert(guis, gui)
	end
	Module._collectIds(I.G_Inventory.Items, ids, seen, _settings.SCAN_DEPTH)
	Module._collectIds(I.G_Arsenal.GetAll(), ids, seen, _settings.SCAN_DEPTH)
	Module._collectIds(I.G_Crates.GetAll(), ids, seen, _settings.SCAN_DEPTH)

	-- Marked as scanned, so the settings scan leaves them out
	for _index: number, moduleName: string in ipairs(_settings.SKIP_SETTINGS) do
		seen[I.Settings[moduleName]] = true
	end
	Module._collectIds(I.Settings, ids, seen, _settings.SCAN_DEPTH)

	--[[ Preloading ]]

	I.S.ContentProvider:PreloadAsync(guis)
	I.S.ContentProvider:PreloadAsync(ids)
	I.S.ContentProvider:PreloadAsync({ I.Dirs.Assets })
end

--%%%%%%%%%%%%%%%%%%%% Collect Ids

--[[
	Adds every asset id string in a table and the tables in it, down to `depth` levels, once each; a table already in
	`seen` is skipped.
]]
--- @param ids { string }
--- @param seen { [any]: boolean }
function Module._collectIds(value: any, ids, seen, depth: number)
	--[[ Checks ]]

	-- Check if it's a table not scanned yet, within the depth
	if type(value) ~= "table" or seen[value] or depth <= 0 then
		return
	end

	--[[ Collecting ]]

	seen[value] = true
	for _key: any, item: any in pairs(value) do
		if type(item) == "string" and string.match(item, _settings.ID_PATTERN) then
			if not seen[item] then
				seen[item] = true
				table.insert(ids, item)
			end
		else
			Module._collectIds(item, ids, seen, depth - 1)
		end
	end
end

return {
	_init = Module.Init,
	_start = Module.Start,
}
