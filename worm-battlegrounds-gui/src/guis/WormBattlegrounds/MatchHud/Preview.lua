--[[
	Created By: 	Nari
]]

local _localName: string = "MatchHudPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Knockouts for the kill feed
--- @type { string }
local FEED = {
	"Bax knocked out Ninja with the Black hole grenade",
	"Ninja knocked out Pip with the Shotgun",
	"Pip fell into the water",
}

-- Weapons in the loadout bar's slots, in order
--- @type { string }
local SLOT_WEAPONS = { "Grenade", "Shotgun", "Jetpack", "Airstrike", "Black hole grenade" }

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

--- @class UmeGui_Guis_WormBattlegrounds_MatchHud_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{
			Control = "Segmented",
			Id = "S_Phase",
			Label = "Phase",
			Options = { "Waiting", "Drop", "Turn", "Out" },
			Value = "Turn",
		},
		{ Control = "Toggle", Id = "S_MyTurn", Label = "My turn", Value = true },
		{ Control = "Slider", Id = "S_Slots", Label = "Loadout slots", Value = 3, Min = 3, Max = 5, Step = 1 },
		{ Control = "Slider", Id = "S_Feed", Label = "Kill feed lines", Value = 2, Min = 0, Max = 3, Step = 1 },
		{ Control = "Toggle", Id = "S_Wheel", Label = "Emote wheel open", Value = false },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the blocks of the picked phase, the loadout bar (its second slot cooling down), the kill feed and the emote wheel.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local view = preview.View --- @type UmeGui_View
	local phase: string = preview.Values.S_Phase
	local turn: boolean = phase == "Turn"
	local myTurn: boolean = turn and preview.Values.S_MyTurn

	--[[ Phases ]]

	view:Get("U_Waiting").Instance.Visible = phase == "Waiting"
	view:Get("U_Drop").Instance.Visible = phase == "Drop"
	view:Get("U_KnockedOut").Instance.Visible = phase == "Out"
	view:Get("U_Turn").Instance.Visible = turn
	view:Get("U_Turn", "S_Banner").Instance.Visible = preview.Values.S_MyTurn
	view:Get("U_Stamina").Instance.Visible = myTurn
	view:Get("U_Power").Instance.Visible = myTurn
	view:Get("U_LoadoutBar").Instance.Visible = phase ~= "Waiting"
	view:Get("U_EmoteWheel").Instance.Visible = preview.Values.S_Wheel

	--[[ Loadout Bar ]]

	local slotItems = {} --- @type { { [string]: any } }

	for index: number = 1, preview.Values.S_Slots do
		table.insert(slotItems, { Image = Module._getIcon(SLOT_WEAPONS[index]) })
	end

	local slots = preview.Fill("PREFAB | BarSlot", slotItems) --- @type { UmeGui_Subview }

	--- @param slot UmeGui_Subview
	for index: number, slot in ipairs(slots) do
		slot:Get("S_Key").SetText(tostring(index))
		slot:Get("S_Cooldown").Instance.Visible = index == 2
	end

	--[[ Kill Feed ]]

	local lines = preview.Fill("PREFAB | FeedLine", preview.Values.S_Feed) --- @type { UmeGui_Subview }

	--- @param line UmeGui_Subview
	for index: number, line in ipairs(lines) do
		line.Root.SetText(FEED[index])
	end

	--[[ Emote Wheel ]]

	Module._placeWheel(preview.Fill("PREFAB | WheelEmote", 9))

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Place Wheel

--[[
	Places the emotes on a circle around the wheel's middle, the first at the top, as MatchHud does.
]]
--- @param emotes { UmeGui_Subview }
function Module._placeWheel(emotes)
	--[[ Placing ]]

	--- @param emote UmeGui_Subview
	for index: number, emote in ipairs(emotes) do
		local angle: number = (index - 1) / #emotes * math.pi * 2
		emote.Root.Instance.Position = UDim2.fromScale(0.5 + math.sin(angle) * 0.4, 0.5 - math.cos(angle) * 0.4)
	end
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
