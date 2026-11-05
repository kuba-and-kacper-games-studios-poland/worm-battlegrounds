--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tutorial"

--- @type Tutorial_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui
local moduleRep: Folder?
local loadoutRep: Folder?

-- What the arrow points at while it shows
local target: GuiObject?
local followConnection: RBXScriptConnection?

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

	moduleGui = I.UserInterface.UI[_settings.HINT_GUI_NAME]
	elems["Text"] = moduleGui:FindFirstChild("S_Text", true) --- @type TextLabel
	elems["HintArrow"] = moduleGui:FindFirstChild("S_Arrow", true) --- @type ImageLabel
	elems["Pointer"] = I.UserInterface.UI[_settings.LOBBY_GUI_NAME]:FindFirstChild("U_Pointer", true) --- @type Frame
	elems["Arrow"] = elems["Pointer"]:FindFirstChild("S_Arrow", true) --- @type ImageLabel
	elems["Slots"] = I.UserInterface.UI[_settings.LOADOUT_GUI_NAME]:FindFirstChild("U_Slots", true) --- @type Frame

	--[[ Applying ]]

	elems["HintArrow"].Visible = false
	elems["Arrow"].AnchorPoint = Vector2.new(0.5, 1)

	--[[ Connections ]]

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refresh)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the equip step while it waits: the hint and an arrow over the loadout (the free crate has the Crates button's
	badge instead); nothing once the tutorial is done, or while the player is in a match.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local inLobby: boolean = not I.S.Players.LocalPlayer:GetAttribute("InMatch")
	local hint: string? = nil
	target = nil
	if inLobby and moduleRep and moduleRep:GetAttribute("EquipReady") then
		hint = "Equip"
		target = elems["Slots"]
	end

	--[[ Applying ]]

	moduleGui.Enabled = hint ~= nil
	elems["Text"].Text = if hint then _settings.HINTS[hint] else ""
	elems["Arrow"].Visible = target ~= nil

	--[[ Following ]]

	if target and not followConnection then
		followConnection = I.S.RunService.RenderStepped:Connect(Module._follow)
	elseif not target and followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Follow

--[[
	Keeps the arrow over the middle of the top edge of what it points at.
]]
function Module._follow()
	--[[ Checks ]]

	-- Check if there's a target
	if not target then
		return
	end

	--[[ Applying ]]

	local offset: Vector2 = target.AbsolutePosition + Vector2.new(target.AbsoluteSize.X / 2, 0) - elems["Pointer"].AbsolutePosition
	elems["Arrow"].Position = UDim2.fromOffset(offset.X, offset.Y)
end

--%%%%%%%%%%%%%%%%%%%% On Loadout Changed

--[[
	Reports the equip step once both starter weapons are in the loadout; the server checks it.
]]
function Module._onLoadoutChanged()
	--[[ Checks ]]

	-- Check if the equip step waits
	if not moduleRep or not moduleRep:GetAttribute("EquipReady") or not loadoutRep then
		return
	end

	--[[ Local Variables ]]

	local equipped = {} --- @type { string }
	for slot: number = 1, I.Settings["Loadout"].MAX_SLOTS do
		table.insert(equipped, loadoutRep:GetAttribute(`Slot{slot}`) or "")
	end

	--[[ Checks ]]

	-- Check if both starter weapons are in
	for _index: number, itemId: string in ipairs(_settings.STARTER_WEAPONS) do
		if not table.find(equipped, itemId) then
			return
		end
	end

	--[[ Sending ]]

	I.Network.Fire("Tutorial_Step", "Equipped")
end

return Module
