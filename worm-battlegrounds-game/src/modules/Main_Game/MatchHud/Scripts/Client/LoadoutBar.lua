--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local combatRep: Folder?

--[[ Boxes ]]

-- The items in the bar, in order (the Bazooka first), and each one's box
local items = {} --- @type { string }
local boxes = {} --- @type { [string]: Frame }
local selected: string = "Bazooka"
local bound: boolean = false

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

--- @class MatchHud_Client_LoadoutBar
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Bar"] = gui:FindFirstChild("U_LoadoutBar") --- @type Frame
	elems["Slots"] = elems["Bar"]:FindFirstChild("U_Slots", true) --- @type Frame
	prefabs["BarSlot"] = elems["Slots"]:FindFirstChild("PREFAB | BarSlot") --- @type Frame

	--[[ Connections ]]

	elems["Bar"]:GetPropertyChangedSignal("Visible"):Connect(Module._bindKeys)
	I.Topic.Subscribe("Match_MyTurn", Module._onMyTurn)
	I.Topic.Subscribe("Platform_Changed", Module._refreshBoxes)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	Module._bindKeys()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's Combat folder: their loadout, uses and cooldowns.
]]
function Module._connectReplicator()
	--[[ Data ]]

	combatRep = I.Replicator.WaitForFolder("Combat")
	if not combatRep then
		return
	end

	--[[ Connections ]]

	combatRep.AttributeChanged:Connect(Module._rebuild)
	Module._rebuild()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Select

--[[
	Picks a box: a weapon becomes the one the worm holds and aims (Combat_Select); a utility is used at once on the
	player's turn (Combat_UseUtility), keeping the weapon in hand.
]]
function Module.Select(itemId: string)
	--[[ Checks ]]

	-- Check if the item is in the bar
	if not boxes[itemId] then
		return
	end

	--[[ Using ]]

	if I.G_Arsenal.IsUtility(itemId) then
		if I.Match.IsMyTurn() and I.Match.GetPhase() == "Turn" then
			I.Network.Fire("Combat_UseUtility", itemId)
		end
		return
	end

	--[[ Saving ]]

	selected = itemId
	I.Network.Fire("Combat_Select", itemId)

	--[[ Refreshing ]]

	Module._refreshBoxes()
end

--%%%%%%%%%%%%%%%%%%%% Rebuild

--[[
	Makes one box per item in the player's loadout (the Bazooka's first) when it changed, then refreshes them all.
]]
function Module._rebuild()
	--[[ Data ]]

	local slots: string = combatRep and combatRep:GetAttribute("Slots") or ""
	local newItems = { "Bazooka" } --- @type { string }
	for _index: number, itemId: string in ipairs(string.split(slots, ",")) do
		if itemId ~= "" and itemId ~= "Bazooka" then
			table.insert(newItems, itemId)
		end
	end

	--[[ Checks ]]

	-- Skip rebuilding when the loadout is the same
	if table.concat(newItems, ",") == table.concat(items, ",") then
		Module._refreshBoxes()
		return
	end

	--[[ Clearing ]]

	for _itemId: string, box: Frame in pairs(boxes) do
		box:Destroy()
	end
	items = newItems
	boxes = {}

	--[[ Building ]]

	for index: number, itemId: string in ipairs(items) do
		local box: Frame = prefabs["BarSlot"]:Clone()
		local button: ImageButton = box:FindFirstChild("Button")
		local icon: ImageLabel = box:FindFirstChild("S_Icon", true)
		local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData
		box.Name = itemId
		box.LayoutOrder = index
		box.Visible = true
		icon.Image = if row then row.Icon else ""
		box:FindFirstChild("S_Key", true).Text = tostring(index)
		box.Parent = elems["Slots"]
		boxes[itemId] = box
		I.Interact.OnPress(button, function()
			Module.Select(itemId)
		end)
	end

	--[[ Refreshing ]]

	if not boxes[selected] then
		selected = "Bazooka"
	end
	Module._refreshBoxes()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Boxes

--[[
	Shows each box's uses left, its cooldown and whether it's the selected one; the key hints only on Desktop.
]]
function Module._refreshBoxes()
	--[[ Checks ]]

	-- Check if the loadout has arrived
	if not combatRep then
		return
	end

	--[[ Applying ]]

	for itemId: string, box: Frame in pairs(boxes) do
		local uses: number = combatRep:GetAttribute(`Uses_{itemId}`) or 0
		local cooldown: number = combatRep:GetAttribute(`Cooldown_{itemId}`) or 0
		local cover: Frame = box:FindFirstChild("S_Cooldown", true)
		local body: Frame = box:FindFirstChild("Background", true):FindFirstChild("Body", true)
		box:FindFirstChild("S_Uses", true).Text = if uses < 0 then "" else `×{uses}`
		box:FindFirstChild("S_Key", true).Visible = I.Platform.Current == "Desktop"
		cover.Visible = cooldown > 0
		cover:FindFirstChild("S_Turns", true).Text = tostring(cooldown)
		body.BackgroundColor3 = if itemId == selected then _settings.SELECTED_COLOR else _settings.TILE_COLOR
		body.BackgroundTransparency = if itemId == selected then _settings.SELECTED_TRANSPARENCY else _settings.TILE_TRANSPARENCY
	end
end

--%%%%%%%%%%%%%%%%%%%% On My Turn

--[[
	At the start of the player's turn, holds the Bazooka again when the selected weapon has no uses left or cools down.
]]
function Module._onMyTurn(myTurn: boolean)
	--[[ Checks ]]

	-- Check if the turn is starting
	if not myTurn or not combatRep then
		return
	end

	--[[ Selecting ]]

	if (combatRep:GetAttribute(`Uses_{selected}`) or 0) == 0 or (combatRep:GetAttribute(`Cooldown_{selected}`) or 0) > 0 then
		selected = "Bazooka"
	end
	Module.Select(selected)
end

--%%%%%%%%%%%%%%%%%%%% Bind Keys

--[[
	Binds the box keys (1 to 6, LB and RB) while the bar shows, and unbinds them when it hides.
]]
function Module._bindKeys()
	--[[ Checks ]]

	-- Skip when nothing changes
	if elems["Bar"].Visible == bound then
		return
	end

	--[[ Binding ]]

	bound = elems["Bar"].Visible
	if bound then
		local keys = table.clone(_settings.SLOT_KEYS) --- @type { Enum.KeyCode }
		table.insert(keys, Enum.KeyCode.ButtonL1)
		table.insert(keys, Enum.KeyCode.ButtonR1)
		I.S.ContextActionService:BindActionAtPriority("MatchHud_Slots", Module._onKey, false, Enum.ContextActionPriority.High.Value, table.unpack(keys))
	else
		I.S.ContextActionService:UnbindAction("MatchHud_Slots")
	end
end

--%%%%%%%%%%%%%%%%%%%% On Key

--[[
	Picks the box a number key names, or steps to the previous or next box with LB and RB.
]]
--- @return Enum.ContextActionResult
function Module._onKey(_action: string, state: Enum.UserInputState, input: InputObject)
	--[[ Checks ]]

	-- Act on presses only
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Sink
	end

	--[[ Selecting ]]

	local index: number? = table.find(_settings.SLOT_KEYS, input.KeyCode)
	if not index then
		local step: number = if input.KeyCode == Enum.KeyCode.ButtonL1 then -1 else 1
		index = ((table.find(items, selected) or 1) - 1 + step) % #items + 1
	end
	if items[index] then
		Module.Select(items[index])
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Selected

--[[
	Returns the weapon the player holds.
]]
--- @return string
function Module.GetSelected()
	return selected
end

return Module
