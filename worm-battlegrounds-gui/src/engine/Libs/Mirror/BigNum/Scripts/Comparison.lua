--[[
    Created By:     Frederico Macedo Pessoa, Marco Serpa Molinaro
    Edited By:      Nari
]]

local _localName = "BigNum"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Is Zero

--[[
	Returns whether a BigNum is zero, whatever its sign.
]]
--- @param bigNum UmeGui_BigNum_Instance
--- @return boolean
local function isZero(bigNum)
	return bigNum.len == 1 and bigNum[0] == 0
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

--- @class UmeGui_BigNum_Comparison
local Comparison = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Compare

--[[
	Compares two BigNums: 1 when `bnum1` is greater, 2 when it is smaller, 0 when equal.
]]
--- @param bnum1 UmeGui_BigNum_Instance
--- @param bnum2 UmeGui_BigNum_Instance
--- @return number
function Comparison.Compare(bnum1, bnum2)
	--[[ Checks ]]

	-- Check if both values were passed
	if bnum1 == nil or bnum2 == nil then
		error(`[{_localName}::{script.Name}]: Compare expects two BigNums!`, 2)
	end

	-- Treat both zeros as equal whatever their sign
	if isZero(bnum1) and isZero(bnum2) then
		return 0
	end

	--[[ Signs ]]

	if bnum1.signal == "+" and bnum2.signal == "-" then
		return 1
	end

	if bnum1.signal == "-" and bnum2.signal == "+" then
		return 2
	end

	--[[ Returning ]]

	local magnitude: number = Comparison.CompareAbs(bnum1, bnum2)

	-- Flip the magnitude result when both are negative
	if bnum1.signal == "-" and magnitude ~= 0 then
		return 3 - magnitude
	end

	return magnitude
end

--%%%%%%%%%%%%%%%%%%%% Compare Abs

--[[
	Compares the absolute values of two BigNums: 1 when |bnum1| is greater, 2 when smaller, 0 when equal.
]]
--- @param bnum1 UmeGui_BigNum_Instance
--- @param bnum2 UmeGui_BigNum_Instance
--- @return number
function Comparison.CompareAbs(bnum1, bnum2)
	--[[ Checks ]]

	-- Check if both values were passed
	if bnum1 == nil or bnum2 == nil then
		error(`[{_localName}::{script.Name}]: CompareAbs expects two BigNums!`, 2)
	end

	--[[ Length ]]

	if bnum1.len > bnum2.len then
		return 1
	end

	if bnum1.len < bnum2.len then
		return 2
	end

	--[[ Digits ]]

	for index: number = bnum1.len - 1, 0, -1 do
		if bnum1[index] > bnum2[index] then
			return 1
		end

		if bnum1[index] < bnum2[index] then
			return 2
		end
	end

	--[[ Returning ]]

	return 0
end

--%%%%%%%%%%%%%%%%%%%% Eq

--[[
	Returns whether two BigNums are equal.
]]
--- @param bnum1 UmeGui_BigNum_Instance
--- @param bnum2 UmeGui_BigNum_Instance
--- @return boolean
function Comparison.Eq(bnum1, bnum2)
	return Comparison.Compare(bnum1, bnum2) == 0
end

--%%%%%%%%%%%%%%%%%%%% Lt

--[[
	Returns whether `bnum1` is smaller than `bnum2`.
]]
--- @param bnum1 UmeGui_BigNum_Instance
--- @param bnum2 UmeGui_BigNum_Instance
--- @return boolean
function Comparison.Lt(bnum1, bnum2)
	return Comparison.Compare(bnum1, bnum2) == 2
end

--%%%%%%%%%%%%%%%%%%%% Le

--[[
	Returns whether `bnum1` is smaller than or equal to `bnum2`.
]]
--- @param bnum1 UmeGui_BigNum_Instance
--- @param bnum2 UmeGui_BigNum_Instance
--- @return boolean
function Comparison.Le(bnum1, bnum2)
	return Comparison.Compare(bnum1, bnum2) ~= 1
end

return Comparison
