--[[
	Created By: 	Nari
]]

local _localName: string = "LoadoutPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Items in the 5 slots, with their rarity
--- @type { { string } }
local ITEMS = {
	{ "Grenade", "Common" },
	{ "Shotgun", "Uncommon" },
	{ "Jetpack", "Rare" },
	{ "Airstrike", "Epic" },
	{ "Black hole grenade", "Legendary" },
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

-- The screen size the guis are laid out for, and the boost on short Mobile screens, as ume's Settings module's
local DESIGN_HEIGHT: number = 1080
local DESIGN_WIDTH: number = 1920
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

--- @class UmeGui_Guis_WormBattlegrounds_Loadout_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Unlocked", Label = "Unlocked slots", Value = 3, Min = 3, Max = 5, Step = 1 },
		{ Control = "Slider", Id = "S_Emotes", Label = "Owned emotes", Value = 3, Min = 1, Max = 9, Step = 1 },
		{ Control = "Toggle", Id = "S_Shiny", Label = "First item shiny", Value = true },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the 5 slots, locking those past the unlocked count, each name in its rarity's colour, and the row of owned
	emotes.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local slotItems = {} --- @type { { [string]: any } }

	--[[ Slots ]]

	--- @param item { string }
	for _index: number, item in ipairs(ITEMS) do
		table.insert(slotItems, { Text = item[1], Image = Module._getIcon(item[1]), Style = "Square" })
	end

	local slots = preview.Fill("PREFAB | Slot", slotItems) --- @type { UmeGui_Subview }

	--- @param slot UmeGui_Subview
	for index: number, slot in ipairs(slots) do
		local name: TextLabel = slot.Root.Instance:FindFirstChild("S_Name", true)
		name.TextColor3 = RARITY_COLORS[ITEMS[index][2]]
		slot:Get("S_Lock").Instance.Visible = index > preview.Values.S_Unlocked
		slot:Get("S_Price").SetText(if index == 4 then "2,500 coins or 149 R$" else "6,000 coins or 299 R$")
		slot:Get("S_Shiny").Instance.Visible = index == 1 and preview.Values.S_Shiny
	end

	--[[ Emotes ]]

	preview.Fill("PREFAB | Emote", preview.Values.S_Emotes)

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales every panel to the previewed screen as the game's modules do: its height over the design height (or its
	width over the design width on a narrower screen), bigger on short Mobile screens, times each panel's device scale.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local width: number = Workspace.CurrentCamera.ViewportSize.X

	-- A screen narrower than the layout scales by its width, so side-by-side panels still fit
	local scale: number = math.min(height / DESIGN_HEIGHT, width / DESIGN_WIDTH)

	-- Boost short touch screens so the buttons stay big enough to tap
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
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
