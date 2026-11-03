--[[
    Created By:     Nari
]]

--- @type Ume
local I

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

--- @class Validate_BigNum
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param umeInstance Ume
function Module.Init(umeInstance)
	--[[ Storing ]]

	I = umeInstance
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Comparand

--[[
	Returns the value as a BigNum for Min / Max comparison, or nil when it is not a BigNum value.
]]
--- @return BigNum_Instance?
function Module.GetComparand(value: any)
	--[[ Returning ]]

	if Module.IsBigNum(value) then
		return value
	end

	if Module.IsBigNumString(value) then
		return I.BN.new(value)
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Is Big Num

--[[
	Returns whether the value is a BigNum instance.
]]
--- @return boolean
function Module.IsBigNum(value: any)
	return I.BN.IsBigNum(value)
end

--%%%%%%%%%%%%%%%%%%%% Is Big Num String

--[[
	Returns whether the value is an integer string with an optional leading minus (no decimals).
]]
--- @return boolean
function Module.IsBigNumString(value: any)
	return type(value) == "string" and string.match(value, "^%-?%d+$") ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Is Big Num Value

--[[
	Returns whether the value is a BigNum instance or a BigNum integer string.
]]
--- @return boolean
function Module.IsBigNumValue(value: any)
	return Module.IsBigNum(value) or Module.IsBigNumString(value)
end

return Module
