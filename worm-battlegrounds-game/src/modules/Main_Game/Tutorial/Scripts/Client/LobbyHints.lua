--[[
	Created By: 	Nari
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

	elems["Crates"] = I.UserInterface.UI[_settings.CRATES_GUI_NAME] --- @type ScreenGui
	elems["Weapons"] = I.UserInterface.UI[_settings.LOBBY_GUI_NAME]:FindFirstChild("U_Menu", true):FindFirstChild("S_Weapons", true) --- @type ImageButton
	elems["BuyOne"] = elems["Crates"]:FindFirstChild("U_BuyX1", true) --- @type ImageButton
	elems["Continue"] = elems["Crates"]:FindFirstChild("U_Continue", true) --- @type ImageButton
	elems["Close"] = elems["Crates"]:FindFirstChild("S_Close", true) --- @type ImageButton
	elems["Tap"] = elems["Crates"]:FindFirstChild("S_Tap", true) --- @type TextLabel
	elems["Viewport"] = elems["Crates"]:FindFirstChild("S_Viewport", true) --- @type ViewportFrame
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
	Runs the guide while a lobby step waits (the free crate, then equipping its weapons), and stops it once the
	tutorial is done or while the player is in a match.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local inLobby: boolean = not I.S.Players.LocalPlayer:GetAttribute("InMatch")
	local waiting: boolean = moduleRep ~= nil and (moduleRep:GetAttribute("CrateReady") == true or moduleRep:GetAttribute("EquipReady") == true)

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
	Lights what to press next: the Weapons button, then the crate's x1, the crate while it waits for its tap, Continue
	after the reels and the crates' close, then a loadout slot and, in the picker, each starter weapon not yet in. While
	the reels roll the hint shows alone.
]]
function Module._tick()
	--[[ Local Variables ]]

	local crateReady: boolean = moduleRep ~= nil and moduleRep:GetAttribute("CrateReady") == true
	local missing: string? = Module._getMissingWeapon()

	--[[ Showing ]]

	if elems["Crates"].Enabled then
		local step: string = if crateReady and I.Utils.IsGuiShown(elems["BuyOne"])
			then "OpenCrate"
			elseif not crateReady and I.Utils.IsGuiShown(elems["Continue"]) then "Continue"
			elseif not crateReady and I.Utils.IsGuiShown(elems["Close"]) then "CloseCrates"
			elseif I.Utils.IsGuiShown(elems["Tap"]) then "Tap"
			else "Opening"
		local targets = { OpenCrate = elems["BuyOne"], Continue = elems["Continue"], CloseCrates = elems["Close"] } --- @type { [string]: GuiObject }
		Spotlight.Show(_settings.HINTS[step], if step == "Tap" then Module._getCrateArea() else targets[step])
	elseif crateReady then
		Spotlight.Show(_settings.HINTS.Crate, elems["Weapons"])
	elseif elems["Picker"].Enabled and missing then
		local card: GuiObject? = elems["Items"]:FindFirstChild(missing, true)
		Spotlight.Show(string.format(_settings.HINTS.Pick, I.G_Inventory.Items[missing].Name), card)
	else
		Spotlight.Show(_settings.HINTS.Equip, Module._getFreeSlot())
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

--%%%%%%%%%%%%%%%%%%%% Get Crate Area

--[[
	Returns the screen area the crates waiting for their tap cover in the Crates gui's viewport, with the TAP TO OPEN
	line under them, or nil while the viewport has no crates.
]]
--- @return Rect?
function Module._getCrateArea()
	--[[ Local Variables ]]

	local viewport: ViewportFrame = elems["Viewport"]
	local camera: Camera? = viewport.CurrentCamera
	local world: WorldModel? = viewport:FindFirstChildWhichIsA("WorldModel")

	--[[ Checks ]]

	-- Check if the viewport holds the crates
	if not camera or not world then
		return nil
	end

	--[[ Local Variables ]]

	local size: Vector2 = viewport.AbsoluteSize
	local focal: number = 1 / math.tan(math.rad(camera.FieldOfView) / 2)
	local textCenter: Vector2 = elems["Tap"].AbsolutePosition + elems["Tap"].AbsoluteSize / 2
	local min: Vector2 = textCenter - elems["Tap"].TextBounds / 2
	local max: Vector2 = textCenter + elems["Tap"].TextBounds / 2

	--[[ Projecting ]]

	-- A viewport's camera reports a 1 × 1 view, so its own WorldToViewportPoint gets the width wrong
	--- @param model Instance
	for _index: number, model in ipairs(world:GetChildren()) do
		if model:IsA("Model") then
			local cframe: CFrame
			local extents: Vector3
			cframe, extents = model:GetBoundingBox()
			for corner: number = 0, 7 do
				local sign: Vector3 = Vector3.new(if corner % 2 == 0 then -1 else 1, if corner % 4 < 2 then -1 else 1, if corner < 4 then -1 else 1)
				local point: Vector3 = camera.CFrame:PointToObjectSpace(cframe * (extents / 2 * sign))
				local ndc: Vector2 = Vector2.new(point.X * size.Y / size.X, -point.Y) * focal / -point.Z
				local pixel: Vector2 = viewport.AbsolutePosition + (ndc + Vector2.one) / 2 * size
				min = min:Min(pixel)
				max = max:Max(pixel)
			end
		end
	end

	--[[ Returning ]]

	return Rect.new(min, max)
end

--%%%%%%%%%%%%%%%%%%%% Get Free Slot

--[[
	Returns the loadout slot to put the next starter weapon in: the first open slot that holds no starter weapon.
]]
--- @return GuiObject?
function Module._getFreeSlot()
	--[[ Checks ]]

	-- Check if the loadout has arrived
	if not loadoutRep then
		return nil
	end

	--[[ Finding ]]

	for slot: number = 1, loadoutRep:GetAttribute("Unlocked") or I.Settings["Loadout"].BASE_SLOTS do
		if not table.find(_settings.STARTER_WEAPONS, loadoutRep:GetAttribute(`Slot{slot}`) or "") then
			return elems["Loadout"]:FindFirstChild(`Slot{slot}`, true)
		end
	end

	--[[ Returning ]]

	return nil
end

return Module
