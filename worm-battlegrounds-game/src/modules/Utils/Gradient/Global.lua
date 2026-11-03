--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Gradient"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Gradients ]]

--- @type { [string]: Gradient_GradientTable }
local storedGradients = {
	["_default"] = {
		Color = ColorSequence.new(Color3.new(1, 1, 1)),
		Offset = Vector2.zero,
		Rotation = 0,
		Transparency = NumberSequence.new(0),
	},
}

--[[ Warnings ]]

--- @type { [string]: boolean }
local warnedGradients = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Warn Missing Gradient

--[[
	Warns once per unknown gradient name.
	Stays silent for a nil name and for a caller that asked for nil instead of the default.
]]
local function warnMissingGradient(gradientName: string?, returnDefault: boolean?)
	--[[ Checks ]]

	-- Skip a nil name, a caller that handles the miss, and names already reported
	if gradientName == nil or returnDefault == false or warnedGradients[gradientName] then
		return
	end

	--[[ Warning ]]

	warnedGradients[gradientName] = true
	warn(`[{_localName}::{script.Name}]: Gradient ({gradientName}) is missing - using _default.`)
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

	Module._storeGradients()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Gradient = {

		--[[ Control ]]

		Set = Module.Set,

		--[[ Methods ]]

		Get = Module.Get,
		GetColor = Module.GetColor,
		GetOffset = Module.GetOffset,
		GetRotation = Module.GetRotation,
		GetTransparency = Module.GetTransparency,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Store Gradients

--[[
	Stores gradient data from all UIGradients under 'ReplicatedStorage/Ume'.
]]
function Module._storeGradients()
	--[[ Getting Storage ]]

	local storageFolder: Folder = I.Dirs.UmeReplicated:FindFirstChild(_localName)
	if not storageFolder then
		warn(`[{_localName}::{script.Name}]: ({_localName}) Folder is missing from the (ReplicatedStorage/Ume)!`)
		return
	end

	--[[ Saving ]]

	for _, elem: UIGradient in ipairs(storageFolder:GetDescendants()) do
		if elem:IsA("UIGradient") then
			Module.Set(elem.Name, elem)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	Saves gradient data under the `gradientName` name.
]]
--- @param gradientData Gradient_GradientTable | UIGradient
function Module.Set(gradientName: string, gradientData)
	--[[ Checks ]]

	if gradientName == `_default` then
		warn(`[{_localName}::{script.Name}]: ({gradientName}) Gradient cannot be replaced!`)
		return
	end

	--[[ UIGradient: Saving ]]

	if type(gradientData) == "userdata" and gradientData:IsA("UIGradient") then
		gradientData = {
			Color = gradientData.Color,
			Offset = gradientData.Offset,
			Rotation = gradientData.Rotation,
			Transparency = gradientData.Transparency,
		}
	end

	--[[ Gradient Table: Checks ]]

	if type(gradientData) ~= "table" then
		warn(`[{_localName}::{script.Name}]: ({gradientData}) is not a valid (gradientData)!`)
		return
	end

	--[[ Gradient Table: Saving ]]

	-- Creating new entry
	if not storedGradients[gradientName] then
		storedGradients[gradientName] = {}
	end

	-- Saving
	storedGradients[gradientName].Color = gradientData.Color or storedGradients[gradientName].Color
	storedGradients[gradientName].Offset = gradientData.Offset or storedGradients[gradientName].Offset
	storedGradients[gradientName].Rotation = gradientData.Rotation or storedGradients[gradientName].Rotation
	storedGradients[gradientName].Transparency = gradientData.Transparency or storedGradients[gradientName].Transparency
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns gradient table associated with the `gradientName`.
]]
--- @return Gradient_GradientTable?
function Module.Get(gradientName: string, returnDefault: boolean?)
	--[[ Checks ]]

	-- Check if the gradient exists
	if not storedGradients[gradientName] then
		warnMissingGradient(gradientName, returnDefault)
		return if returnDefault ~= false then storedGradients["_default"] else nil
	end

	--[[ Returning ]]

	return storedGradients[gradientName]
end

--%%%%%%%%%%%%%%%%%%%% Get Color

--[[
	Returns color of the `gradientName` gradient.
]]
--- @return ColorSequence?
function Module.GetColor(gradientName: string, returnDefault: boolean?)
	--[[ Checks ]]

	-- Check if the gradient exists
	if not storedGradients[gradientName] then
		warnMissingGradient(gradientName, returnDefault)
		return if returnDefault ~= false then storedGradients["_default"].Color else nil
	end

	--[[ Returning ]]

	return storedGradients[gradientName].Color
end

--%%%%%%%%%%%%%%%%%%%% Get Offset

--[[
	Returns offset of the `gradientName` gradient.
]]
--- @return Vector2?
function Module.GetOffset(gradientName: string, returnDefault: boolean?)
	--[[ Checks ]]

	-- Check if the gradient exists
	if not storedGradients[gradientName] then
		warnMissingGradient(gradientName, returnDefault)
		return if returnDefault ~= false then storedGradients["_default"].Offset else nil
	end

	--[[ Returning ]]

	return storedGradients[gradientName].Offset
end

--%%%%%%%%%%%%%%%%%%%% Get Rotation

--[[
	Returns rotation of the `gradientName` gradient.
]]
--- @return number?
function Module.GetRotation(gradientName: string, returnDefault: boolean?)
	--[[ Checks ]]

	-- Check if the gradient exists
	if not storedGradients[gradientName] then
		warnMissingGradient(gradientName, returnDefault)
		return if returnDefault ~= false then storedGradients["_default"].Rotation else nil
	end

	--[[ Returning ]]

	return storedGradients[gradientName].Rotation
end

--%%%%%%%%%%%%%%%%%%%% Get Transparency

--[[
	Returns transparency of the `gradientName` gradient.
]]
--- @return NumberSequence?
function Module.GetTransparency(gradientName: string, returnDefault: boolean?)
	--[[ Checks ]]

	-- Check if the gradient exists
	if not storedGradients[gradientName] then
		warnMissingGradient(gradientName, returnDefault)
		return if returnDefault ~= false then storedGradients["_default"].Transparency else nil
	end

	--[[ Returning ]]

	return storedGradients[gradientName].Transparency
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
