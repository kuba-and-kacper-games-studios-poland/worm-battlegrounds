--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tutorial"

--- @type Tutorial_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Spotlight = require(script.Parent:FindFirstChild("Spotlight")) --- @type Tutorial_Client_Spotlight

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleRep: Folder?
local loadoutRep: Folder?
local tickConnection: RBXScriptConnection?

-- The starter weapons the guide already opened the picker for, so closing it never brings it back
local autoOpened = {} --- @type { [string]: boolean }

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

--- @class Tutorial_Client_LobbyHints
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	elems["Loadout"] = I.UserInterface.UI[_settings.LOADOUT_GUI_NAME] --- @type ScreenGui
	elems["Picker"] = I.UserInterface.UI[_settings.PICKER_GUI_NAME] --- @type ScreenGui
	elems["Items"] = elems["Picker"]:FindFirstChild("U_Items", true) --- @type ScrollingFrame

	--[[ Connections ]]

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refresh)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's Tutorial folder (which step waits) and Loadout folder (whether the starter weapons are in).
]]
function Module._connectReplicator()
	--[[ Data ]]

	moduleRep = I.Replicator.GetFolder(_localName)
	loadoutRep = I.Replicator.GetFolder("Loadout")

	--[[ Connections ]]

	if moduleRep then
		moduleRep.AttributeChanged:Connect(Module._refresh)
	end
	if loadoutRep then
		loadoutRep.AttributeChanged:Connect(Module._onLoadoutChanged)
	end
	Module._refresh()
	Module._onLoadoutChanged()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Runs the guide while the starter weapons wait to be equipped, and stops it once the tutorial is done or while the
	player is in a match.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local inLobby: boolean = not I.S.Players.LocalPlayer:GetAttribute("InMatch")
	local waiting: boolean = moduleRep ~= nil and moduleRep:GetAttribute("EquipReady") == true

	--[[ Connections ]]

	if inLobby and waiting and not tickConnection then
		tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
	elseif not (inLobby and waiting) and tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
		Spotlight.Hide()
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Points at what to press next: a loadout slot and, in the picker, each starter weapon not yet in. The picker opens by
	itself once for each starter weapon, while no other window is open.
]]
function Module._tick()
	--[[ Local Variables ]]

	local missing: string? = Module._getMissingWeapon()
	local slot: number? = Module._getFreeSlot()

	--[[ Showing ]]

	if elems["Picker"].Enabled and missing then
		local card: GuiObject? = elems["Items"]:FindFirstChild(missing, true)
		Spotlight.Show(string.format(_settings.HINTS.Pick, I.G_Inventory.Items[missing].Name), card, "Pick")
		return
	end
	Spotlight.Show(_settings.HINTS.Equip, if slot then elems["Loadout"]:FindFirstChild(`Slot{slot}`, true) else nil, "Equip")

	--[[ Opening ]]

	if missing and slot and not autoOpened[missing] and not I.WidgetManager.GetCurrent() then
		autoOpened[missing] = true
		I.Loadout.OpenPicker(slot)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Loadout Changed

--[[
	Reports the equip step once both starter weapons are in the loadout; the server checks it.
]]
function Module._onLoadoutChanged()
	--[[ Checks ]]

	-- Check if the equip step waits and both starter weapons are in
	if not moduleRep or not moduleRep:GetAttribute("EquipReady") or Module._getMissingWeapon() then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("Tutorial_Step", "Equipped")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Missing Weapon

--[[
	Returns the first starter weapon not in the loadout yet, or nil when both are in.
]]
--- @return string?
function Module._getMissingWeapon()
	--[[ Checks ]]

	-- Check if the loadout has arrived
	if not loadoutRep then
		return nil
	end

	--[[ Finding ]]

	for _index: number, itemId: string in ipairs(_settings.STARTER_WEAPONS) do
		local equipped: boolean = false
		for slot: number = 1, I.Settings["Loadout"].MAX_SLOTS do
			equipped = equipped or loadoutRep:GetAttribute(`Slot{slot}`) == itemId
		end
		if not equipped then
			return itemId
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Free Slot

--[[
	Returns the loadout slot to put the next starter weapon in: the first open slot that holds no starter weapon.
]]
--- @return number?
function Module._getFreeSlot()
	--[[ Checks ]]

	-- Check if the loadout has arrived
	if not loadoutRep then
		return nil
	end

	--[[ Finding ]]

	for slot: number = 1, loadoutRep:GetAttribute("Unlocked") or I.Settings["Loadout"].BASE_SLOTS do
		if not table.find(_settings.STARTER_WEAPONS, loadoutRep:GetAttribute(`Slot{slot}`) or "") then
			return slot
		end
	end

	--[[ Returning ]]

	return nil
end

return Module
