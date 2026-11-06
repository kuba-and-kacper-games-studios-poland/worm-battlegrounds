--[[
	Created By: 	Nari
]]

local _localName: string = "CratesPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The 4 crates: name, coin price, diamond price (nil when it doesn't take that currency)
--- @type { { [string]: any } }
local CRATES = {
	{ Name = "Weapon crate", Coins = 100 },
	{ Name = "Premium crate", Diamonds = 250 },
	{ Name = "Utility crate", Coins = 100, Diamonds = 200 },
	{ Name = "Skin crate", Coins = 100, Diamonds = 50 },
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

--- @class UmeGui_Guis_WormBattlegrounds_Crates_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Toggle", Id = "S_Tutorial", Label = "Tutorial crate", Value = false },
		{ Control = "Toggle", Id = "S_Vip", Label = "VIP (free skin crate)", Value = false },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the 4 crate cards with their prices, shows the tutorial crate in place of the list, and the VIP badge.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Tutorial ]]

	preview.View:Get("U_TutorialCrate").Instance.Visible = preview.Values.S_Tutorial
	preview.View:Get("U_CrateList").Instance.Visible = not preview.Values.S_Tutorial

	--[[ Cards ]]

	local cards = preview.Fill("PREFAB | CrateCard", #CRATES) --- @type { UmeGui_Subview }

	--- @param card UmeGui_Subview
	for index: number, card in ipairs(cards) do
		local crate = CRATES[index] --- @type { [string]: any }
		card:Get("S_Name").SetText(crate.Name)
		card:Get("S_PayCoins").Instance.Visible = crate.Coins ~= nil
		card:Get("S_PayCoins").SetText(`{crate.Coins} coins`)
		card:Get("S_PayDiamonds").Instance.Visible = crate.Diamonds ~= nil
		card:Get("S_PayDiamonds").SetText(`{crate.Diamonds} diamonds`)
		card:Get("S_Free").Instance.Visible = preview.Values.S_Vip and crate.Name == "Skin crate"
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
