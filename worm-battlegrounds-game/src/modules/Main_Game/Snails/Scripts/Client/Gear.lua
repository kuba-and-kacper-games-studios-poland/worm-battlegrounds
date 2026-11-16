--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The gear each snail wears now (a copy of its utility's model), by snail, then by item id
local worn = {} --- @type { [Model]: { [string]: Model } }
-- The skin bone each piece of gear worn on the shell follows, by gear copy
local gearBones = {} --- @type { [Model]: Bone }
-- Whether the step is bound: after Flight moves the balls, before the camera aims at them
local stepping: boolean = false

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

--- @class Snails_Client_Gear
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(snailsFolder: Folder)
	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Looks again at a snail's gear whenever its state or an attribute that shows gear changes, and forgets it once it's
	gone.
]]
function Module._watchSnail(model: Instance)
	--[[ Checks ]]

	-- Check if it's a snail
	if not model:IsA("Model") then
		return
	end

	--[[ Connections ]]

	model.AttributeChanged:Connect(function(attribute: string)
		if attribute == "Alive" or attribute == "Ghost" or Module._isGearAttribute(attribute) then
			Module._refresh(model)
		end
	end)
	model.Destroying:Connect(function()
		for _itemId: string, gearModel: Model in pairs(worn[model] or {}) do
			gearBones[gearModel] = nil
		end
		worn[model] = nil
		Module._refreshLoop()
	end)

	--[[ Refreshing ]]

	Module._refresh(model)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Puts on a snail the gear whose attribute is set (an open parachute, a jetpack with fuel this turn) while it's in
	play, and takes off the rest.
]]
--- @param model Model
function Module._refresh(model)
	--[[ Local Variables ]]

	local wearing = worn[model] or {} --- @type { [string]: Model }
	local inPlay: boolean = model:GetAttribute("Alive") == true and not model:GetAttribute("Ghost")

	--[[ Applying ]]

	--- @param gear Snails_Gear
	for itemId: string, gear in pairs(_settings.GEAR) do
		local show: boolean = inPlay and model:GetAttribute(gear.Attribute) ~= nil
		if show and not wearing[itemId] then
			wearing[itemId] = I.G_Arsenal.GetModel(itemId):Clone()
			wearing[itemId].Parent = model
		elseif not show and wearing[itemId] then
			gearBones[wearing[itemId]] = nil
			wearing[itemId]:Destroy()
			wearing[itemId] = nil
		end
	end

	--[[ Saving ]]

	worn[model] = if next(wearing) then wearing else nil
	Module._refreshLoop()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Loop

--[[
	Follows the snails every frame while one wears gear, and stops when none does.
]]
function Module._refreshLoop()
	--[[ Connections ]]

	if next(worn) and not stepping then
		stepping = true
		I.S.RunService:BindToRenderStep("Snails_Gear", Enum.RenderPriority.Camera.Value - 1, Module._step)
	elseif not next(worn) and stepping then
		stepping = false
		I.S.RunService:UnbindFromRenderStep("Snails_Gear")
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves each worn piece of gear onto its snail: onto the skin's shell bone as the animation moves it, for gear worn on
	the shell, or onto the ball, turned the way the snail faces.
]]
function Module._step()
	--[[ Placing ]]

	--- @param wearing { [string]: Model }
	for model: Model, wearing in pairs(worn) do
		local root: BasePart? = model.PrimaryPart
		if not root then
			continue
		end
		for itemId: string, gearModel: Model in pairs(wearing) do
			local gear = _settings.GEAR[itemId] --- @type Snails_Gear
			local bone: Bone? = gear.Bone and Module._getBone(model, gearModel, gear.Bone)
			if bone and gear.BoneOffset then
				local skin: Model? = bone:FindFirstAncestorOfClass("Model")
				local scale: number = if skin then skin:GetScale() / _settings.GEAR_SKIN_SCALE else 1
				local offset: CFrame = gear.BoneOffset.Rotation + gear.BoneOffset.Position * scale
				gearModel:PivotTo(bone.TransformedWorldCFrame * offset)
			else
				gearModel:PivotTo(root.CFrame * CFrame.new(gear.Offset))
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Bone

--[[
	Returns the skin bone a piece of gear follows, found once on the snail (again when its skin was swapped), nil on a
	skin without it.
]]
--- @return Bone?
function Module._getBone(model: Model, gearModel: Model, boneName: string)
	--[[ Data ]]

	local bone: Bone? = gearBones[gearModel]

	--[[ Finding ]]

	if not bone or not bone:IsDescendantOf(model) then
		local found: Instance? = model:FindFirstChild(boneName, true)
		bone = if found and found:IsA("Bone") then found else nil
		gearBones[gearModel] = bone
	end

	--[[ Returning ]]

	return bone
end

--%%%%%%%%%%%%%%%%%%%% Is Gear Attribute

--[[
	Returns whether a snail attribute shows a piece of gear.
]]
--- @return boolean
function Module._isGearAttribute(attribute: string)
	--[[ Checking ]]

	--- @param gear Snails_Gear
	for _itemId: string, gear in pairs(_settings.GEAR) do
		if gear.Attribute == attribute then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

return Module
