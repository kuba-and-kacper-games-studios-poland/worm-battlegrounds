--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Worms"

--- @type Worms_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The gear each worm wears now (a copy of its utility's model), by worm, then by item id
local worn = {} --- @type { [Model]: { [string]: Model } }
local stepConnection: RBXScriptConnection?

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

--- @class Worms_Client_Gear
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(wormsFolder: Folder)
	--[[ Connections ]]

	wormsFolder.ChildAdded:Connect(Module._watchWorm)
	for _index: number, model: Instance in ipairs(wormsFolder:GetChildren()) do
		Module._watchWorm(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Worm

--[[
	Looks again at a worm's gear whenever its state or an attribute that shows gear changes, and forgets it once it's
	gone.
]]
function Module._watchWorm(model: Instance)
	--[[ Checks ]]

	-- Check if it's a worm
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
		worn[model] = nil
		Module._refreshLoop()
	end)

	--[[ Refreshing ]]

	Module._refresh(model)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Puts on a worm the gear whose attribute is set (an open parachute, a jetpack with fuel this turn) while it's in
	play, and takes off the rest.
]]
--- @param model Model
function Module._refresh(model)
	--[[ Local Variables ]]

	local wearing = worn[model] or {} --- @type { [string]: Model }
	local inPlay: boolean = model:GetAttribute("Alive") == true and not model:GetAttribute("Ghost")

	--[[ Applying ]]

	--- @param gear Worms_Gear
	for itemId: string, gear in pairs(_settings.GEAR) do
		local show: boolean = inPlay and model:GetAttribute(gear.Attribute) ~= nil
		if show and not wearing[itemId] then
			wearing[itemId] = I.G_Arsenal.GetModel(itemId):Clone()
			wearing[itemId].Parent = model
		elseif not show and wearing[itemId] then
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
	Follows the worms every frame while one wears gear, and stops when none does.
]]
function Module._refreshLoop()
	--[[ Connections ]]

	if next(worn) and not stepConnection then
		stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
	elseif not next(worn) and stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves each worn piece of gear onto its worm's ball, turned the way the worm faces.
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
			gearModel:PivotTo(root.CFrame * CFrame.new(_settings.GEAR[itemId].Offset))
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Gear Attribute

--[[
	Returns whether a worm attribute shows a piece of gear.
]]
--- @return boolean
function Module._isGearAttribute(attribute: string)
	--[[ Checking ]]

	--- @param gear Worms_Gear
	for _itemId: string, gear in pairs(_settings.GEAR) do
		if gear.Attribute == attribute then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

return Module
