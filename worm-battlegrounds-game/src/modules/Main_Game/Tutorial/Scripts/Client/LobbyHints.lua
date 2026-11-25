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

-- Whether the guide already opened the picker by itself, so closing it never brings it back
local autoOpened: boolean = false

--[[ Public Matches Hint ]]

-- The player's Statistic folder (their MatchesPlayed), the hint's loop, and when this lobby visit's hint shows from and until (os.clock); nil before it's planned for this visit
local statisticRep: Folder?
local publicConnection: RBXScriptConnection?
local publicFrom: number? = nil
local publicUntil: number? = nil
local publicShowing: boolean = false

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
	elems["BoardTitle"] = I.UserInterface.UI[_settings.BOARD_GUI_NAME]:FindFirstChild("ActiveLobbies", true):FindFirstChild("HeaderText") --- @type TextLabel
	elems["Rows"] = I.UserInterface.UI[_settings.BOARD_GUI_NAME]:FindFirstChild("U_Rows", true) --- @type ScrollingFrame

	--[[ Connections ]]

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refresh)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's Tutorial folder (which step waits) and Loadout folder (whether a starter weapon is in).
]]
function Module._connectReplicator()
	--[[ Data ]]

	moduleRep = I.Replicator.GetFolder(_localName)
	loadoutRep = I.Replicator.GetFolder("Loadout")
	statisticRep = I.Replicator.GetFolder("Statistic")

	--[[ Connections ]]

	if moduleRep then
		moduleRep.AttributeChanged:Connect(Module._refresh)
	end
	if loadoutRep then
		loadoutRep.AttributeChanged:Connect(Module._onLoadoutChanged)
	end
	if statisticRep then
		statisticRep:GetAttributeChangedSignal("MatchesPlayed"):Connect(Module._refresh)
	end
	Module._refresh()
	Module._onLoadoutChanged()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Runs the guide while the starter weapons wait for one to be equipped, and stops it once the tutorial is done or
	while the player is in a match. A loadout that already holds one finishes the step on arrival. Once it's done, each
	arrival in the lobby plans the public matches hint, until the player has played PUBLIC_HINT_MATCHES matches.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local inLobby: boolean = not I.S.Players.LocalPlayer:GetAttribute("InMatch")
	local waiting: boolean = moduleRep ~= nil and moduleRep:GetAttribute("EquipReady") == true

	--[[ Connections ]]

	if inLobby and waiting and not tickConnection then
		tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
		Module._onLoadoutChanged()
	elseif not (inLobby and waiting) and tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
		Spotlight.Hide()
	end

	--[[ Public Matches Hint ]]

	local done: boolean = moduleRep ~= nil and moduleRep:GetAttribute("Done") == true
	local played: number = if statisticRep then tonumber(statisticRep:GetAttribute("MatchesPlayed")) or 0 else 0
	local wanted: boolean = inLobby and done and statisticRep ~= nil and played < _settings.PUBLIC_HINT_MATCHES

	-- Once per lobby visit: leaving for a match plans the next one
	if not inLobby then
		publicFrom = nil
		publicUntil = nil
	elseif wanted and not publicFrom then
		publicFrom = os.clock() + _settings.PUBLIC_HINT_DELAY
		publicUntil = publicFrom + _settings.PUBLIC_HINT_SECONDS
	end
	if wanted and not publicConnection then
		publicConnection = I.S.RunService.Heartbeat:Connect(Module._tickPublic)
	elseif not wanted and publicConnection then
		Module._stopPublic()
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick Public

--[[
	Makes every JOIN on the board glow (Set Join Glow) with PUBLIC_HINT beside the board's title, between this visit's
	publicFrom and publicUntil, while no window covers the lobby; after its time it stops for this visit.
]]
function Module._tickPublic()
	--[[ Local Variables ]]

	local now: number = os.clock()

	--[[ Stopping ]]

	if not publicUntil or now > publicUntil then
		Module._stopPublic()
		return
	end

	--[[ Showing ]]

	if now >= (publicFrom or now) and not I.WidgetManager.GetCurrent() then
		publicShowing = true
		Spotlight.Show("", elems["BoardTitle"], "Public", "Beside", _settings.PUBLIC_HINT)
		Module._setJoinGlow(true)
	elseif publicShowing then
		publicShowing = false
		Spotlight.Hide()
		Module._setJoinGlow(false)
	end
end

--%%%%%%%%%%%%%%%%%%%% Stop Public

--[[
	Stops the public matches hint's loop and takes it down if it shows.
]]
function Module._stopPublic()
	--[[ Stopping ]]

	if publicConnection then
		publicConnection:Disconnect()
		publicConnection = nil
	end
	if publicShowing then
		publicShowing = false
		Spotlight.Hide()
		Module._setJoinGlow(false)
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Join Glow

--[[
	Pulses the glow round every JOIN on the board (its S_Glow), or hides them all.
]]
function Module._setJoinGlow(shown: boolean)
	--[[ Local Variables ]]

	local wave: number = 0.5 + 0.5 * math.sin(os.clock() * _settings.PUBLIC_GLOW_RATE)
	local low: number = _settings.PUBLIC_GLOW_TRANSPARENCY[1]
	local high: number = _settings.PUBLIC_GLOW_TRANSPARENCY[2]

	--[[ Applying ]]

	for _index: number, glow: Instance in ipairs(elems["Rows"]:GetDescendants()) do
		if glow.Name == "S_Glow" and glow:IsA("ImageLabel") then
			glow.ImageTransparency = if shown then low + (high - low) * wave else 1
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Points at what to press next (the owner, 2026-11-24: "PICK A WEAPON", one equip and that's it): in the picker the
	first starter weapon, else a free loadout slot. The picker opens by itself once, while no other window is open.
]]
function Module._tick()
	--[[ Local Variables ]]

	local slot: number? = Module._getFreeSlot()
	local slotButton: GuiObject? = if slot then elems["Loadout"]:FindFirstChild(`Slot{slot}`, true) else nil
	local card: GuiObject? = elems["Items"]:FindFirstChild(_settings.STARTER_WEAPONS[1], true)

	--[[ Showing ]]

	-- From the left, over the open lobby: above or below a slot or card sits its neighbour
	if elems["Picker"].Enabled and card then
		Spotlight.Show(_settings.HINTS.Pick, card, "Pick", "Left")
	elseif slotButton then
		Spotlight.Show(_settings.HINTS.Pick, slotButton, "Pick", "Left")
	end

	--[[ Opening ]]

	if slot and not autoOpened and not I.WidgetManager.GetCurrent() then
		autoOpened = true
		I.Loadout.OpenPicker(slot)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Loadout Changed

--[[
	Reports the equip step once a starter weapon is in the loadout; the server checks it and pays the tutorial's diamonds.
]]
function Module._onLoadoutChanged()
	--[[ Checks ]]

	-- Check if the equip step waits and a starter weapon is in
	if not moduleRep or not moduleRep:GetAttribute("EquipReady") or not Module._hasStarter() then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("Tutorial_Step", "Equipped")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Free Slot

--[[
	Returns the loadout slot to put a starter weapon in: the first open slot that holds no starter weapon.
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

--%%%%%%%%%%%%%%%%%%%% Has Starter

--[[
	Returns whether any starter weapon is in the loadout.
]]
--- @return boolean
function Module._hasStarter()
	--[[ Checks ]]

	-- Check if the loadout has arrived
	if not loadoutRep then
		return false
	end

	--[[ Finding ]]

	for slot: number = 1, I.Settings["Loadout"].MAX_SLOTS do
		if table.find(_settings.STARTER_WEAPONS, loadoutRep:GetAttribute(`Slot{slot}`) or "") then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

return Module
