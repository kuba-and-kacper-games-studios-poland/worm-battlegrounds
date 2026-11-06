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

-- Each rarity's colour, as the Rarity module's looks have them (Base); game code writes it on the item's name
--- @type { [string]: Color3 }
local RARITY_COLORS = {
	Common = Color3.fromHex("CDD5DF"),
	Uncommon = Color3.fromHex("8CEB2E"),
	Rare = Color3.fromHex("26C6FF"),
	Epic = Color3.fromHex("A64DFF"),
	Legendary = Color3.fromHex("FFB51F"),
}

--[[ Screen ]]

-- The screen size the guis are laid out for, the Mobile boost and the PC floor, as ScreenScale's Settings
local DESIGN_HEIGHT: number = 1080
local DESIGN_WIDTH: number = 1920
local SMALL_SCREEN: number = 500
local MOBILE_BOOST: number = 1.3
local MIN_SCALE: number = 0.6

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
	Fills the grid with owned items on plain slots, each rarity in its colour, with its copies toward shiny.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local tiles = {} --- @type { { [string]: any } }

	--[[ Items ]]

	for index: number = 1, preview.Values.S_Items do
		local item = ITEMS[index] --- @type { string }
		table.insert(tiles, { Text = item[1], Subtext = item[3], Image = Module._getIcon(item[1]) })
	end

	local built = preview.Fill("PREFAB | ItemTile", tiles) --- @type { UmeGui_Subview }

	--- @param tile UmeGui_Subview
	for index: number, tile in ipairs(built) do
		local rarity: TextLabel = tile:Get("S_Rarity").Instance
		rarity.Text = ITEMS[index][2]
		rarity.TextColor3 = RARITY_COLORS[ITEMS[index][2]]
		tile:Get("S_Copies").SetText(ITEMS[index][4])
	end

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales every panel to the previewed screen as the game's modules do: its height over the design height (or its
	width over the design width on a narrower screen), bigger on short Mobile screens and never under the floor on
	others, times each panel's device scale.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local width: number = Workspace.CurrentCamera.ViewportSize.X

	-- A screen narrower than the layout scales by its width, so side-by-side panels still fit
	local scale: number = math.min(height / DESIGN_HEIGHT, width / DESIGN_WIDTH)

	-- Boost short touch screens so the buttons stay big enough to tap; anything else never shrinks below the floor
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	elseif preview.Device ~= "Mobile" then
		scale = math.max(scale, MIN_SCALE)
	end

	--[[ Applying ]]

	for _index: number, descendant: Instance in ipairs(preview.View.Root:GetDescendants()) do
		if descendant:IsA("UIScale") and descendant.Name == "S_ScreenScale" then
			-- Times the panel's scale for the previewed device (its Utils_PlatformScale tag), as ScreenScale does
			local deviceScale: number = descendant.Parent:GetAttribute(`Utils_{preview.Device}Scale`) or 0
			descendant.Scale = scale * (if deviceScale == 0 then 1 else deviceScale)
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
