--[[
	Created By: 	Nari
]]

local _localName: string = "ShopPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Diamond packs (name, diamonds, Robux) and game passes (name, benefits, Robux), as the wiki proposes them
--- @type { { string } }
local PACKS = {
	{ "Handful", "250", "99" },
	{ "Pouch", "500", "199" },
	{ "Bag", "1,000", "399" },
	{ "Chest", "1,500", "599" },
	{ "Vault", "2,500", "899" },
}
--- @type { { string } }
local PASSES = {
	{ "Slot 4", "Opens loadout slot 4", "149" },
	{ "Slot 5", "Opens loadout slot 5, after slot 4", "299" },
	{ "Double Coins", "Every coin reward from matches is doubled", "349" },
	{ "VIP", "A gold name and VIP tag in chat, an exclusive VIP snail skin, and one free skin crate every day", "199" },
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

--- @class UmeGui_Guis_WormBattlegrounds_Shop_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the 5 diamond packs and the 4 game passes.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local packs = {} --- @type { { [string]: any } }

	--[[ Packs ]]

	--- @param pack { string }
	for _index: number, pack in ipairs(PACKS) do
		table.insert(packs, { Text = pack[1], Subtext = `{pack[2]} diamonds` })
	end

	local builtPacks = preview.Fill("PREFAB | Pack", packs) --- @type { UmeGui_Subview }

	--- @param pack UmeGui_Subview
	for index: number, pack in ipairs(builtPacks) do
		pack:Get("S_Price").SetText(`{PACKS[index][3]} R$`)
	end

	--[[ Passes ]]

	local passes = preview.Fill("PREFAB | Pass", #PASSES) --- @type { UmeGui_Subview }

	--- @param pass UmeGui_Subview
	for index: number, pass in ipairs(passes) do
		pass:Get("S_Name").SetText(PASSES[index][1])
		pass:Get("S_Benefits").SetText(PASSES[index][2])
		pass:Get("S_Price").SetText(`{PASSES[index][3]} R$`)
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

return Module
