--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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
local boxes = {} --- @type { [string]: ImageButton }
local selected: string = "Bazooka"
local bound: boolean = false

-- The boxes cooling down at their last refresh, so the one whose cooldown just ended flashes
local cooling = {} --- @type { [string]: boolean }

-- The last weapon held, which the snail takes back after using a utility it held
local lastWeapon: string = "Bazooka"

-- The utility box the pad's LB and RB rest on (they pass utilities without using them; Y uses it), nil on the held weapon
local padCursor: string? = nil

-- The player's snail whose jetpack fuel the Jetpack box shows
local watchedSnail: Model? = nil

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
	prefabs["BarSlot"] = elems["Slots"]:FindFirstChild("PREFAB | BarSlot") --- @type ImageButton

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
	Picks a box: the snail holds that item (Combat_Select). A weapon is aimed and fired; a utility (a Medkit, a potion)
	waits in the snail's hands until a press on the screen uses it (Use Held) (the owner, 2026-11-15), except those in
	USE_ON_SELECT (the Jetpack), used at once when they're ready.
]]
function Module.Select(itemId: string)
	--[[ Checks ]]

	-- Check if the item is in the bar
	if not boxes[itemId] then
		return
	end

	--[[ Saving ]]

	selected = itemId
	padCursor = nil
	if not I.G_Arsenal.IsUtility(itemId) then
		lastWeapon = itemId
	end
	I.Network.Fire("Combat_Select", itemId)

	--[[ Refreshing ]]

	Module._refreshBoxes()

	--[[ Using ]]

	if _settings.USE_ON_SELECT[itemId] then
		Module.UseHeld()
	end
end

--%%%%%%%%%%%%%%%%%%%% Use Held

--[[
	Uses the utility the snail holds on the player's turn (Combat_UseUtility), then hands it back the weapon it held
	before, or the Bazooka when that weapon has no uses left or cools down.
]]
function Module.UseHeld()
	--[[ Checks ]]

	-- Check if the snail holds a utility it may use now
	if not I.G_Arsenal.IsUtility(selected) or not Module.IsReady(selected) or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
		return
	end

	--[[ Using ]]

	I.Network.Fire("Combat_UseUtility", selected)
	Module.Select(if Module.IsReady(lastWeapon) then lastWeapon else "Bazooka")
end

--%%%%%%%%%%%%%%%%%%%% Rebuild

--[[
	Makes one box per item in the player's loadout (the Bazooka's first) when it changed, and no empty ones (the owner,
	2026-11-24: "remove any slots from the bottom bar that are not occupied"), then refreshes them all.
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

	for _index: number, child: Instance in ipairs(elems["Slots"]:GetChildren()) do
		if child.Name ~= prefabs["BarSlot"].Name and child:IsA("ImageButton") then
			child:Destroy()
		end
	end
	items = newItems
	boxes = {}
	cooling = {}

	--[[ Building ]]

	for index: number, itemId: string in ipairs(items) do
		--[[ Local Variables ]]

		local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData?

		--[[ Cloning ]]

		local box: ImageButton = prefabs["BarSlot"]:Clone()

		--[[ Elements ]]

		local icon: ImageLabel = box:FindFirstChild("S_Icon")

		--[[ Applying ]]

		box.Name = itemId
		box.LayoutOrder = index
		box.Visible = true
		box:FindFirstChild("S_Name").Text = if row then row.Name else ""
		box:FindFirstChild("S_Key").Text = tostring(index)
		icon.Image = if row then row.Icon else ""
		if icon.Image == "" and I.G_Arsenal.HasModel(itemId) then
			Module._showModel(icon, I.G_Arsenal.GetModel(itemId))
		end
		box.Parent = elems["Slots"]

		--[[ Connections ]]

		boxes[itemId] = box
		I.Interact.OnPress(box, function()
			Module.Select(itemId)
		end)
	end

	--[[ Refreshing ]]

	if not boxes[selected] then
		selected = "Bazooka"
	end
	padCursor = nil
	Module._refreshBoxes()
end

--%%%%%%%%%%%%%%%%%%%% Show Model

--[[
	Shows a weapon's model in a box's icon, for a weapon with no icon picture: a ViewportFrame (`S_Model`) over the
	icon, the model side-on with its muzzle to the right, framed to fit.
]]
function Module._showModel(icon: ImageLabel, model: Model)
	--[[ Building ]]

	local viewport: ViewportFrame = I.Create("ViewportFrame")({
		Name = "S_Model",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = icon,
	})
	local camera: Camera = I.Create("Camera")({
		FieldOfView = _settings.MODEL_FOV,
		Parent = viewport,
	})
	local clone: Model = model:Clone()
	clone:PivotTo(CFrame.lookAlong(Vector3.zero, Vector3.xAxis))
	clone.Parent = viewport
	viewport.CurrentCamera = camera

	--[[ Framing ]]

	local boxCFrame: CFrame
	local boxSize: Vector3
	boxCFrame, boxSize = clone:GetBoundingBox()
	local reach: number = math.max(boxSize.X, boxSize.Y, boxSize.Z) / 2
	local distance: number = reach / math.tan(math.rad(_settings.MODEL_FOV / 2)) * _settings.MODEL_PADDING
	camera.CFrame = CFrame.lookAt(boxCFrame.Position + _settings.MODEL_VIEW_DIRECTION.Unit * distance, boxCFrame.Position)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Boxes

--[[
	Shows each box's uses left, its Shiny foil or Golden rim (Combat's Variant_<ItemId>), its cooldown (Draw Cooldown), a lock over one used up for the
	rest of the match (darkened the same way; the Jetpack only once its fuel is gone too, its box showing the fuel left
	meanwhile, and a turn's cooldown while it rests after flying) and whether it's the selected one (the design's white outline, from the box's Look_ attributes; the
	pad's utility box instead while LB or RB rest there, with its Y hint); the key numbers only on Desktop.
]]
function Module._refreshBoxes()
	--[[ Checks ]]

	-- Check if the loadout has arrived
	if not combatRep then
		return
	end

	--[[ Local Variables ]]

	local picked: string = padCursor or selected
	local mine: Model? = I.Snails.GetMine()
	local fuel: number? = if mine then mine:GetAttribute("JetpackFuel") else nil
	local resting: boolean = mine ~= nil and mine:GetAttribute("JetpackRest") == true

	--[[ Applying ]]

	for itemId: string, box: ImageButton in pairs(boxes) do
		box:FindFirstChild("S_UseHint"):SetAttribute("Console_HintHidden", itemId ~= padCursor)
		local uses: number = combatRep:GetAttribute(`Uses_{itemId}`) or 0
		local fueled: boolean = itemId == "Jetpack" and fuel ~= nil and fuel > 0
		local cooldown: number = if fueled and resting then 1 else combatRep:GetAttribute(`Cooldown_{itemId}`) or 0
		local total: number = if fueled and resting then 1 else I.G_Arsenal.Get(itemId).Cooldown or cooldown
		local locked: boolean = uses == 0 and not fueled
		local icon: ImageLabel = box:FindFirstChild("S_Icon")
		local model: ViewportFrame? = icon:FindFirstChild("S_Model")
		local iconColor: Color3 = if cooldown > 0 or locked then box:GetAttribute("Look_CooldownIconColor") else Color3.new(1, 1, 1)
		local iconFade: number = if cooldown > 0 or locked then box:GetAttribute("Look_CooldownIconTransparency") else 0
		box:FindFirstChild("S_Uses").Text = if fueled then `{math.ceil((fuel or 0) / I.Settings["SnailControl"].JETPACK_FUEL * 100)}%` elseif uses < 0 then "" else `{uses} left`
		box:FindFirstChild("S_Key").Visible = I.Platform.Current == "Desktop"
		box:FindFirstChild("S_Lock").Visible = locked
		local variant: string = combatRep:GetAttribute(`Variant_{itemId}`) or ""
		local background: Frame = box:FindFirstChild("Background")
		background:FindFirstChild("S_Foil").Visible = variant == "Shiny"
		background:FindFirstChild("S_Gold").Visible = variant == "Golden"
		Module._drawCooldown(itemId, box, if locked then 0 else math.min(cooldown, total), total)
		icon.ImageColor3 = iconColor
		icon.ImageTransparency = iconFade
		if model then
			model.ImageColor3 = iconColor
			model.ImageTransparency = iconFade
		end
		background:FindFirstChild("Stroke").ImageColor3 = box:GetAttribute(if itemId == picked then "Look_SelectedStrokeColor" else "Look_StrokeColor")
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw Cooldown

--[[
	Draws a box's cooldown: the turns left in a round badge in the uses pill's corner (the pill hidden meanwhile, its name kept),
	and its card filled from the bottom with the share of the total already waited (S_Charge, its top edge brighter); the
	card flashes white as a cooldown ends. A box at 0 turns left shows none of it.
]]
function Module._drawCooldown(itemId: string, box: ImageButton, turnsLeft: number, total: number)
	--[[ Elements ]]

	local charge: ImageLabel = box:FindFirstChild("Background"):FindFirstChild("S_Charge")
	local turns: TextLabel = box:FindFirstChild("S_Turns")
	local label: TextLabel = box:FindFirstChild("S_TurnsLabel")
	local uses: TextLabel = box:FindFirstChild("S_Uses")
	local flash: ImageLabel = box:FindFirstChild("S_ReadyFlash")

	--[[ Local Variables ]]

	local isCooling: boolean = turnsLeft > 0
	local waited: number = if isCooling then 1 - turnsLeft / total else 0
	local edge: number = math.max(waited - _settings.COOLDOWN_CHARGE_EDGE, 0.001)

	--[[ Applying ]]

	turns.Visible = isCooling
	turns.Text = tostring(turnsLeft)
	label.Visible = false
	uses.Visible = uses.Text ~= "" and not isCooling
	charge.Visible = waited > 0
	if waited > 0 then
		charge.UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, _settings.COOLDOWN_CHARGE_BODY),
			NumberSequenceKeypoint.new(edge, _settings.COOLDOWN_CHARGE_BODY),
			NumberSequenceKeypoint.new(edge + 0.001, 0),
			NumberSequenceKeypoint.new(waited, 0),
			NumberSequenceKeypoint.new(math.min(waited + 0.001, 0.999), 1),
			NumberSequenceKeypoint.new(1, 1),
		})
	end

	--[[ Flashing ]]

	-- The cooldown just ended: the card flashes white and fades
	if cooling[itemId] and not isCooling then
		flash.ImageTransparency = _settings.READY_FLASH_TRANSPARENCY
		local Flash_TweenGoal = { ImageTransparency = 1 }
		local Flash_Tween: Tween = I.S.TweenService:Create(flash, _settings.READY_FLASH_TWEENINFO, Flash_TweenGoal)
		Flash_Tween:Play()
	end
	cooling[itemId] = isCooling
end

--%%%%%%%%%%%%%%%%%%%% On My Turn

--[[
	At the start of the player's turn, follows their snail's jetpack fuel, and holds the Bazooka again when the selected
	weapon has no uses left or cools down.
]]
function Module._onMyTurn(myTurn: boolean)
	--[[ Checks ]]

	-- Check if the turn is starting
	if not myTurn or not combatRep then
		return
	end

	--[[ Watching ]]

	-- The Jetpack box shows the fuel left in the player's snail as it burns
	local mine: Model? = I.Snails.GetMine()
	if mine and mine ~= watchedSnail then
		watchedSnail = mine
		mine:GetAttributeChangedSignal("JetpackFuel"):Connect(Module._refreshBoxes)
		mine:GetAttributeChangedSignal("JetpackRest"):Connect(Module._refreshBoxes)
	end

	--[[ Selecting ]]

	padCursor = nil
	if (combatRep:GetAttribute(`Uses_{selected}`) or 0) == 0 or (combatRep:GetAttribute(`Cooldown_{selected}`) or 0) > 0 then
		selected = "Bazooka"
	end
	Module.Select(selected)
end

--%%%%%%%%%%%%%%%%%%%% Bind Keys

--[[
	Binds the box keys (1 to 6) and the pad's buttons (the Console module's WeaponPrevious, WeaponNext and UseUtility)
	while the bar shows, and unbinds them when it hides.
]]
function Module._bindKeys()
	--[[ Checks ]]

	-- Skip when nothing changes
	if elems["Bar"].Visible == bound then
		return
	end

	--[[ Binding ]]

	bound = elems["Bar"].Visible
	padCursor = nil
	if bound then
		I.S.ContextActionService:BindActionAtPriority("MatchHud_Slots", Module._onKey, false, Enum.ContextActionPriority.High.Value, table.unpack(_settings.SLOT_KEYS))
		I.Console.Bind("WeaponPrevious", Module._onStep)
		I.Console.Bind("WeaponNext", Module._onStep)
		I.Console.Bind("UseUtility", Module._onUse)
	else
		I.S.ContextActionService:UnbindAction("MatchHud_Slots")
		I.Console.Unbind("WeaponPrevious")
		I.Console.Unbind("WeaponNext")
		I.Console.Unbind("UseUtility")
	end
end

--%%%%%%%%%%%%%%%%%%%% On Key

--[[
	Picks the box a number key names.
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
	if index and items[index] then
		Module.Select(items[index])
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%% On Step

--[[
	LB and RB: step to the previous or next box. A weapon is picked at once; a utility only gets the pad's cursor, so
	stepping past it never takes it out, and Y puts it in the snail's hands (On Use), for RT to use.
]]
--- @return Enum.ContextActionResult
function Module._onStep(action: string, state: Enum.UserInputState, _input: InputObject)
	--[[ Checks ]]

	-- Act on presses only
	if state ~= Enum.UserInputState.Begin or #items == 0 then
		return Enum.ContextActionResult.Sink
	end

	--[[ Local Variables ]]

	local step: number = if action == "WeaponPrevious" then -1 else 1
	local index: number = ((table.find(items, padCursor or selected) or 1) - 1 + step) % #items + 1
	local itemId: string = items[index]

	--[[ Selecting ]]

	if I.G_Arsenal.IsUtility(itemId) then
		padCursor = itemId
		Module._refreshBoxes()
	else
		padCursor = nil
		Module.Select(itemId)
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%% On Use

--[[
	Y: puts the utility the pad's cursor rests on in the snail's hands; RT then uses it (Aim, Use Held).
]]
--- @return Enum.ContextActionResult
function Module._onUse(_action: string, state: Enum.UserInputState, _input: InputObject)
	--[[ Checks ]]

	-- Act on presses with the cursor on a utility
	if state ~= Enum.UserInputState.Begin or not padCursor then
		return Enum.ContextActionResult.Sink
	end

	--[[ Using ]]

	Module.Select(padCursor)

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

--%%%%%%%%%%%%%%%%%%%% Is Ready

--[[
	Returns whether a weapon can be fired now: it has uses left and isn't cooling down.
]]
--- @return boolean
function Module.IsReady(itemId: string)
	return combatRep ~= nil and (combatRep:GetAttribute(`Uses_{itemId}`) or 0) ~= 0 and (combatRep:GetAttribute(`Cooldown_{itemId}`) or 0) <= 0
end

return Module
