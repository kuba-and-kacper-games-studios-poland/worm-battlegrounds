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
local boxes = {} --- @type { [string]: ImageButton }
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
	Picks a box: a weapon becomes the one the snail holds and aims (Combat_Select); a utility is used at once on the
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
	Makes one box per item in the player's loadout (the Bazooka's first) when it changed, and empty boxes (the
	design's "+") up to one per slot key, then refreshes them all.
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

	--[[ Building ]]

	for index: number = 1, math.max(#items, #_settings.SLOT_KEYS) do
		--[[ Local Variables ]]

		local itemId: string? = items[index]
		local row = if itemId then I.G_Arsenal.Get(itemId) else nil --- @type Arsenal_WeaponData?

		--[[ Cloning ]]

		local box: ImageButton = prefabs["BarSlot"]:Clone()

		--[[ Elements ]]

		local icon: ImageLabel = box:FindFirstChild("S_Icon")

		--[[ Applying ]]

		box.Name = itemId or "Empty"
		box.LayoutOrder = index
		box.Visible = true
		box:FindFirstChild("S_Name").Text = if row then row.Name else ""
		box:FindFirstChild("S_Key").Text = tostring(index)
		icon.Image = if row then row.Icon else ""
		if itemId and icon.Image == "" and I.G_Arsenal.HasModel(itemId) then
			Module._showModel(icon, I.G_Arsenal.GetModel(itemId))
		end
		box.Parent = elems["Slots"]

		--[[ Empty ]]

		-- An empty slot shows only the design's "+", in its dim outline
		if not itemId then
			box.Interactable = false
			box:FindFirstChild("S_Plus").Visible = true
			box:FindFirstChild("Background"):FindFirstChild("Stroke").ImageColor3 = box:GetAttribute("Look_EmptyStrokeColor")
			for _childIndex: number, name: string in ipairs({ "S_Icon", "S_Key", "S_Uses", "S_Name", "S_Turns" }) do
				box:FindFirstChild(name).Visible = false
			end
			continue
		end

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
	Shows each box's uses left, its cooldown (the icon darkened under the turns left) and whether it's the selected one
	(the design's white outline, from the box's Look_ attributes); the key numbers only on Desktop.
]]
function Module._refreshBoxes()
	--[[ Checks ]]

	-- Check if the loadout has arrived
	if not combatRep then
		return
	end

	--[[ Applying ]]

	for itemId: string, box: ImageButton in pairs(boxes) do
		local uses: number = combatRep:GetAttribute(`Uses_{itemId}`) or 0
		local cooldown: number = combatRep:GetAttribute(`Cooldown_{itemId}`) or 0
		local icon: ImageLabel = box:FindFirstChild("S_Icon")
		local model: ViewportFrame? = icon:FindFirstChild("S_Model")
		local turns: TextLabel = box:FindFirstChild("S_Turns")
		local iconColor: Color3 = if cooldown > 0 then box:GetAttribute("Look_CooldownIconColor") else Color3.new(1, 1, 1)
		box:FindFirstChild("S_Uses").Text = if uses < 0 then "" else `x{uses}`
		box:FindFirstChild("S_Key").Visible = I.Platform.Current == "Desktop"
		turns.Visible = cooldown > 0
		turns.Text = tostring(cooldown)
		icon.ImageColor3 = iconColor
		if model then
			model.ImageColor3 = iconColor
		end
		box:FindFirstChild("Background"):FindFirstChild("Stroke").ImageColor3 = box:GetAttribute(if itemId == selected then "Look_SelectedStrokeColor" else "Look_StrokeColor")
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
