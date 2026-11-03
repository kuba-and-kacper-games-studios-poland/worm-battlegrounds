--[[
    Created By:     Nari 
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Leaderstats"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ IntValue Range ]]

local INT_VALUE_MIN: number = -2 ^ 63
local INT_VALUE_MAX: number = 2 ^ 63 - 1024

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Coerce Stat Value

--[[
	Coerces a string or number for Value instances (Command BigNum resolves to digit strings).
	IntValue numbers are capped to the 64-bit range an IntValue can hold.
]]
--- @return string | number | nil
local function coerceStatValue(value: string | number, valueClass: "StringValue" | "NumberValue" | "IntValue")
	--[[ StringValue ]]

	if valueClass == "StringValue" then
		return tostring(value)
	end

	--[[ Getting Number ]]

	local n: number = tonumber(value)

	-- Check if the value is a number
	if n == nil then
		return nil
	end

	--[[ IntValue ]]

	if valueClass == "IntValue" then
		-- Check if the number is NaN
		if n ~= n then
			return nil
		end

		-- Cap at the IntValue range so it doesn't overflow
		return math.clamp(math.floor(n), INT_VALUE_MIN, INT_VALUE_MAX)
	end

	--[[ NumberValue ]]

	return n
end

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Setup, Module._create)
	I.G_Player.OnPlayerRemoving(I.Priority.Late, Module._updateCommandDictionaries)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Leaderstats = {

		--[[ Control ]]

		AddValue = Module.AddValue,
		RemoveValue = Module.RemoveValue,
		SetValue = Module.SetValue,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._updateCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	Creates leaderstats folder for player.
]]
function Module._create(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	-- Skip if already exists
	if player:FindFirstChild("leaderstats") then
		return
	end

	-- Creating leaderstats
	local leaderstats: Folder = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Update Command Dictionaries

--[[
	Updates dictionaries used by module commands.
]]
function Module._updateCommandDictionaries()
	--[[ Getting Values ]]

	local allValuesNames = {} --- @type { string }

	for _, player: Player in ipairs(Players:GetPlayers()) do
		--[[ Getting Leaderstats ]]

		local leaderstats: Folder = player:FindFirstChild("leaderstats")
		if not leaderstats then
			continue
		end

		--[[ Saving Values ]]

		for _, elem: Instance in ipairs(leaderstats:GetChildren()) do
			if elem:IsA("StringValue") or elem:IsA("NumberValue") or elem:IsA("IntValue") then
				if not table.find(allValuesNames, elem.Name) then
					table.insert(allValuesNames, elem.Name)
				end
			end
		end
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Leaderstats_ValueNames`, allValuesNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Value

--[[
	**SERVER** |
	Creates new leaderstats value for player.
	Optional priority places higher values earlier on the player list.
]]
--- @return boolean
function Module.AddValue(player: Player, valueName: string, baseValue: string | number, valueClass: "StringValue" | "NumberValue" | "IntValue", priority: number?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Invalid class
	if valueClass ~= "StringValue" and valueClass ~= "NumberValue" and valueClass ~= "IntValue" then
		warn(`[{_localName}::{script.Name}]: ({valueClass}) is not a valid (valueClass)!`)
		return false
	end

	--[[ Getting Leaderstats ]]

	-- Getting leaderstats
	local leaderstats: Folder = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false
	end

	-- Return if value already exists
	if leaderstats:FindFirstChild(valueName) then
		warn(`[{_localName}::{script.Name}]: Value ({valueName}) already exists!`)
		return false
	end

	--[[ Creating Value ]]

	local coerced: string | number | nil = coerceStatValue(baseValue, valueClass)

	-- Check if the base value fits the class
	if coerced == nil then
		warn(`[{_localName}::{script.Name}]: Could not coerce baseValue for ({valueName}) ({valueClass})`)
		return false
	end

	local newValue: StringValue | NumberValue | IntValue = Instance.new(valueClass)
	newValue.Name = valueName
	newValue.Value = coerced

	--[[ Priority ]]

	if priority ~= nil then
		local priorityValue: NumberValue = Instance.new("NumberValue")
		priorityValue.Name = "Priority"
		priorityValue.Value = priority
		priorityValue.Parent = newValue
	end

	--[[ Parenting ]]

	-- Parent last so the stat replicates with its Priority
	newValue.Parent = leaderstats

	--[[ Updating Dictionaries ]]

	I.AdminPanel_CommandBar.UpdateDictionary(`Leaderstats_ValueNames-{player.Name}`, { valueName }, nil, 255, { BoundTo = player.UserId })
	Module._updateCommandDictionaries()

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Remove Value

--[[
	**SERVER** |
	Removes leaderstats value for player.
]]
--- @return boolean
function Module.RemoveValue(player: Player, valueName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Getting Leaderstats ]]

	-- Getting leaderstats
	local leaderstats: Folder = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false
	end

	--[[ Getting Value ]]

	local existingValue: StringValue | NumberValue | IntValue = leaderstats:FindFirstChild(valueName)
	if not existingValue then
		return false
	end

	--[[ Destroying ]]

	existingValue:Destroy()

	--[[ Updating Dictionaries ]]

	I.AdminPanel_CommandBar.UpdateDictionary(`Leaderstats_ValueNames-{player.Name}`, nil, { valueName }, 255, { BoundTo = player.UserId })
	Module._updateCommandDictionaries()

	return true
end

--%%%%%%%%%%%%%%%%%%%% Set Value

--[[
	**SERVER** |
	Updates existing leaderstats value.
]]
--- @return boolean
function Module.SetValue(player: Player, valueName: string, value: string | number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Missing leaderstats
	local leaderstats: Folder = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false
	end

	-- Missing value
	local existingValue: StringValue | NumberValue | IntValue = leaderstats:FindFirstChild(valueName)
	if not existingValue then
		return false
	end

	--[[ Updating ]]

	local coerced: string | number | nil
	if existingValue:IsA("StringValue") then
		coerced = coerceStatValue(value, "StringValue")
	elseif existingValue:IsA("NumberValue") then
		coerced = coerceStatValue(value, "NumberValue")
	elseif existingValue:IsA("IntValue") then
		coerced = coerceStatValue(value, "IntValue")
	else
		return false
	end

	if coerced == nil then
		warn(`[{_localName}::{script.Name}]: Could not coerce value for ({valueName})`)
		return false
	end

	existingValue.Value = coerced

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
