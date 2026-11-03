--[[
    Created By:     Frederico Macedo Pessoa, Marco Serpa Molinaro
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local BigNum --- @type UmeGui_BigNum
local RADIX_LEN: number

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

--- @class UmeGui_BigNum_Metatable
local Metatable = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param bigNum UmeGui_BigNum
function Metatable.Init(bigNum)
	BigNum = bigNum
	RADIX_LEN = bigNum._constants.RADIX_LEN
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	`+` metamethod. Operands may be BigNums, numbers, or number strings.
]]
--- @return UmeGui_BigNum_Instance
function Metatable.Add(num1: any, num2: any)
	--[[ Calculating ]]

	local result = BigNum.new()
	BigNum.Add(BigNum.ToBigNum(num1), BigNum.ToBigNum(num2), result)

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Sub

--[[
	`-` metamethod. Operands may be BigNums, numbers, or number strings.
]]
--- @return UmeGui_BigNum_Instance
function Metatable.Sub(num1: any, num2: any)
	--[[ Calculating ]]

	local result = BigNum.new()
	BigNum.Sub(BigNum.ToBigNum(num1), BigNum.ToBigNum(num2), result)

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Mul

--[[
	`*` metamethod. Operands may be BigNums, numbers, or number strings.
]]
--- @return UmeGui_BigNum_Instance
function Metatable.Mul(num1: any, num2: any)
	--[[ Calculating ]]

	local result = BigNum.new()
	BigNum.Mul(BigNum.ToBigNum(num1), BigNum.ToBigNum(num2), result)

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Div

--[[
	`/` metamethod. Returns the quotient truncated toward zero.
]]
--- @return UmeGui_BigNum_Instance
function Metatable.Div(num1: any, num2: any)
	--[[ Calculating ]]

	local quotient = BigNum.new()
	local remainder = BigNum.new()
	BigNum.Div(BigNum.ToBigNum(num1), BigNum.ToBigNum(num2), quotient, remainder)

	--[[ Returning ]]

	return quotient
end

--%%%%%%%%%%%%%%%%%%%% Pow

--[[
	`^` metamethod. The exponent must be a non-negative integer.
]]
--- @return UmeGui_BigNum_Instance
function Metatable.Pow(num1: any, num2: any)
	return BigNum.Pow(BigNum.ToBigNum(num1), BigNum.ToBigNum(num2))
end

--%%%%%%%%%%%%%%%%%%%% Unm

--[[
	Unary `-` metamethod. Zero stays positive.
]]
--- @return UmeGui_BigNum_Instance
function Metatable.Unm(num: any)
	--[[ Calculating ]]

	local result = BigNum.new(num)

	if not (result.len == 1 and result[0] == 0) then
		result.signal = if result.signal == "-" then "+" else "-"
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Eq

--[[
	`==` metamethod. Only runs when both operands are BigNums.
]]
--- @return boolean
function Metatable.Eq(num1: any, num2: any)
	return BigNum.Eq(BigNum.ToBigNum(num1), BigNum.ToBigNum(num2))
end

--%%%%%%%%%%%%%%%%%%%% Lt

--[[
	`<` metamethod.
]]
--- @return boolean
function Metatable.Lt(num1: any, num2: any)
	return BigNum.Lt(BigNum.ToBigNum(num1), BigNum.ToBigNum(num2))
end

--%%%%%%%%%%%%%%%%%%%% Le

--[[
	`<=` metamethod.
]]
--- @return boolean
function Metatable.Le(num1: any, num2: any)
	return BigNum.Le(BigNum.ToBigNum(num1), BigNum.ToBigNum(num2))
end

--%%%%%%%%%%%%%%%%%%%% To String

--[[
	`tostring` metamethod. Returns the base-10 digits with a leading `-` for negative values.
]]
--- @param bigNum UmeGui_BigNum_Instance
--- @return string
function Metatable.ToString(bigNum)
	--[[ Checks ]]

	-- Return zero for malformed values
	if type(bigNum.len) ~= "number" or bigNum.len <= 0 then
		return "0"
	end

	--[[ Digits ]]

	local parts = table.create(bigNum.len) --- @type { string }
	local highest: number = bigNum[bigNum.len - 1] or 0

	parts[1] = tostring(highest)

	for index: number = bigNum.len - 2, 0, -1 do
		parts[bigNum.len - index] = string.format(`%0{RADIX_LEN}d`, bigNum[index] or 0)
	end

	--[[ Returning ]]

	local text: string = table.concat(parts)

	if bigNum.signal == "-" and not (bigNum.len == 1 and highest == 0) then
		return "-" .. text
	end

	return text
end

return Metatable
