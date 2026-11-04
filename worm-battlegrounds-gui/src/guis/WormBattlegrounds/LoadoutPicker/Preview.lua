--[[
	Created By: 	Nari
]]

local _localName: string = "LoadoutPickerPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Owned items: name, rarity, uses and cooldown, copies
--- @type { { string } }
local ITEMS = {
	{ "Grenade", "Common", "3 uses", "4 / 10" },
	{ "Shotgun", "Common", "2 uses", "10 / 10" },
	{ "Cluster bomb", "Uncommon", "2 uses · 1 turn cooldown", "1 / 10" },
	{ "Jetpack", "Rare", "1 use", "2 / 10" },
	{ "Airstrike", "Epic", "1 use · 3 turns cooldown", "1 / 10" },
	{ "Black hole grenade", "Legendary", "1 use", "1 / 10" },
}

--[[ Screen ]]

-- The screen height the guis are laid out for, and the boost on short Mobile screens, as ume's Settings module's
local DESIGN_HEIGHT: number = 1080
local SMALL_SCREEN: number = 500
local MOBILE_BOOST: number = 1.3

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

--- @class UmeGui_Guis_WormBattlegrounds_LoadoutPicker_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Items", Label = "Owned items", Value = 6, Min = 0, Max = 6, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the grid with owned items, each outlined in its rarity, with its copies toward shiny.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local tiles = {} --- @type { { [string]: any } }

	--[[ Items ]]

	for index: number = 1, preview.Values.S_Items do
		local item = ITEMS[index] --- @type { string }
		table.insert(tiles, { Text = item[1], Subtext = item[3], Image = Module._getIcon(item[1]), Style = item[2] })
	end

	local built = preview.Fill("PREFAB | ItemTile", tiles) --- @type { UmeGui_Subview }

	--- @param tile UmeGui_Subview
	for index: number, tile in ipairs(built) do
		tile:Get("S_Rarity").SetText(ITEMS[index][2])
		tile:Get("S_Copies").SetText(ITEMS[index][4])
	end

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales every panel to the previewed screen as the game's modules do: its height over the design height, bigger on
	short Mobile screens.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local scale: number = height / DESIGN_HEIGHT

	-- Boost short touch screens so the buttons stay big enough to tap
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	end

	--[[ Applying ]]

	for _index: number, descendant: Instance in ipairs(preview.View.Root:GetDescendants()) do
		if descendant:IsA("UIScale") and descendant.Name == "S_ScreenScale" then
			descendant.Scale = scale
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Icon

--[[
	Returns the gui kit's icon name for a weapon: "Black hole grenade" is "wb-black-hole-grenade".
]]
--- @return string
function Module._getIcon(weapon: string)
	return "wb-" .. string.lower((string.gsub(weapon, " ", "-")))
end

return Module
