--[[
	Created By: 	Nari
]]

local _localName: string = "CrateOpenPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Results of a 10-pack: name and rarity
--- @type { { string } }
local RESULTS = {
	{ "Grenade", "Common" },
	{ "Shotgun", "Common" },
	{ "Cluster bomb", "Uncommon" },
	{ "Grenade", "Common" },
	{ "Jetpack", "Rare" },
	{ "Shotgun", "Common" },
	{ "Airstrike", "Epic" },
	{ "Grenade", "Common" },
	{ "Cluster bomb", "Uncommon" },
	{ "Black hole grenade", "Legendary" },
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

--- @class UmeGui_Guis_WormBattlegrounds_CrateOpen_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Segmented", Id = "S_Step", Label = "Step", Options = { "Crate", "One", "Ten" }, Value = "One" },
		{ Control = "Toggle", Id = "S_Shiny", Label = "Turned shiny", Value = false },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the closed crate, one result, or the 10 results of a 10-pack.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local step: string = preview.Values.S_Step
	local cards = {} --- @type { { [string]: any } }

	--[[ Stage ]]

	preview.View:Get("U_Stage", "S_Crate").Instance.Visible = step == "Crate"
	preview.View:Get("U_Stage", "S_Card").Instance.Visible = step == "One"
	preview.View:Get("U_Stage", "S_Shiny").Instance.Visible = preview.Values.S_Shiny
	preview.View:Get("U_Stage").Instance.Visible = step ~= "Ten"
	preview.View:Get("U_Cards").Instance.Visible = step == "Ten"

	--[[ Ten ]]

	for index: number = 1, if step == "Ten" then #RESULTS else 0 do
		table.insert(cards, {
			Text = RESULTS[index][1],
			Subtext = RESULTS[index][2],
			Image = Module._getIcon(RESULTS[index][1]),
			Style = RESULTS[index][2],
		})
	end
	preview.Fill("PREFAB | ResultCard", cards)

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
