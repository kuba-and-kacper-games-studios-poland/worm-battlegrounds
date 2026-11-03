--[[
    Created By:     Frederico Macedo Pessoa, Marco Serpa Molinaro
    Edited By:      Nari
]]

local _localName = "BigNum"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local BigNum --- @type BigNum
local RADIX: number

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Is Zero

--[[
	Returns whether a BigNum is zero, whatever its sign.
]]
--- @param bigNum BigNum_Instance
--- @return boolean
local function isZero(bigNum)
	return bigNum.len == 1 and bigNum[0] == 0
end

--%%%%%%%%%%%%%%%%%%%% Assert Operands

--[[
	Errors when one of the operands is missing.
]]
local function assertOperands(functionName: string, ...: any)
	--[[ Checks ]]

	for index: number = 1, select("#", ...) do
		if select(index, ...) == nil then
			error(`[{_localName}::{script.Name}]: {functionName} is missing operand #{index}!`, 3)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Divide Magnitudes

--[[
	Long division of two positive BigNums into `quotient` and `remainder`.
]]
--- @param dividend BigNum_Instance
--- @param divisor BigNum_Instance
--- @param quotient BigNum_Instance
--- @param remainder BigNum_Instance
local function divideMagnitudes(dividend, divisor, quotient, remainder)
	--[[ Local Variables ]]

	local estimate = BigNum.new()
	estimate.len = dividend.len - divisor.len - 1

	BigNum.Change(quotient, "0")
	BigNum.Copy(dividend, remainder)

	--[[ Dividing ]]

	while BigNum.CompareAbs(remainder, divisor) ~= 2 do
		local remainderTop: number = remainder[remainder.len - 1]
		local divisorTop: number = divisor[divisor.len - 1]

		-- Estimate the next quotient block from the top blocks, using two blocks when the top one is too small
		if remainderTop >= divisorTop then
			BigNum.Put(estimate, math.floor(remainderTop / divisorTop), remainder.len - divisor.len)
			estimate.len = remainder.len - divisor.len + 1
		else
			BigNum.Put(estimate, math.floor((remainderTop * RADIX + remainder[remainder.len - 2]) / divisorTop), remainder.len - divisor.len - 1)
			estimate.len = remainder.len - divisor.len
		end

		estimate.signal = if remainder.signal ~= divisor.signal then "-" else "+"

		BigNum.Add(estimate, quotient, quotient)
		estimate = estimate * divisor
		BigNum.Sub(remainder, estimate, remainder)
	end

	--[[ Correcting ]]

	-- Undo an overshoot so the remainder ends up non-negative
	if remainder.signal == "-" and not isZero(remainder) then
		BigNum.Sub(quotient, BigNum.new(1), quotient)
		BigNum.Add(divisor, remainder, remainder)
	end
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

--- @class BigNum_Arithmetic
local Arithmetic = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param bigNum BigNum
function Arithmetic.Init(bigNum)
	BigNum = bigNum
	RADIX = bigNum._constants.RADIX
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	Stores `bnum1 + bnum2` in `bnum3`. The output may be one of the inputs.
]]
--- @param bnum1 BigNum_Instance
--- @param bnum2 BigNum_Instance
--- @param bnum3 BigNum_Instance
function Arithmetic.Add(bnum1, bnum2, bnum3)
	--[[ Checks ]]

	assertOperands("Add", bnum1, bnum2, bnum3)

	--[[ Mixed Signs ]]

	-- Turn -a + b into b - a
	if bnum1.signal == "-" and bnum2.signal == "+" then
		bnum1.signal = "+"
		Arithmetic.Sub(bnum2, bnum1, bnum3)

		if not rawequal(bnum1, bnum3) then
			bnum1.signal = "-"
		end
		return
	end

	-- Turn a + -b into a - b
	if bnum1.signal == "+" and bnum2.signal == "-" then
		bnum2.signal = "+"
		Arithmetic.Sub(bnum1, bnum2, bnum3)

		if not rawequal(bnum2, bnum3) then
			bnum2.signal = "-"
		end
		return
	end

	--[[ Local Variables ]]

	local signal: string = bnum1.signal
	local oldLength: number = bnum3.len or 0
	local longer, shorter = bnum1, bnum2

	if bnum2.len > bnum1.len then
		longer, shorter = bnum2, bnum1
	end

	--[[ Adding ]]

	local carry: number = 0

	for index: number = 0, longer.len - 1 do
		local sum: number = longer[index] + (shorter[index] or 0) + carry

		if sum >= RADIX then
			bnum3[index] = sum - RADIX
			carry = 1
		else
			bnum3[index] = sum
			carry = 0
		end
	end

	--[[ Saving ]]

	local length: number = longer.len

	if carry == 1 then
		bnum3[length] = 1
		length += 1
	end

	for index: number = length, oldLength - 1 do
		bnum3[index] = nil
	end

	bnum3.len = length
	bnum3.signal = signal
end

--%%%%%%%%%%%%%%%%%%%% Sub

--[[
	Stores `bnum1 - bnum2` in `bnum3`. The output may be one of the inputs.
]]
--- @param bnum1 BigNum_Instance
--- @param bnum2 BigNum_Instance
--- @param bnum3 BigNum_Instance
function Arithmetic.Sub(bnum1, bnum2, bnum3)
	--[[ Checks ]]

	assertOperands("Sub", bnum1, bnum2, bnum3)

	--[[ Mixed Signs ]]

	-- Turn -a - b into -(a + b)
	if bnum1.signal == "-" and bnum2.signal == "+" then
		bnum1.signal = "+"
		Arithmetic.Add(bnum1, bnum2, bnum3)
		bnum3.signal = if isZero(bnum3) then "+" else "-"

		if not rawequal(bnum1, bnum3) then
			bnum1.signal = "-"
		end
		return
	end

	-- Turn -a - -b into b - a
	if bnum1.signal == "-" and bnum2.signal == "-" then
		bnum1.signal = "+"
		bnum2.signal = "+"
		Arithmetic.Sub(bnum2, bnum1, bnum3)

		if not rawequal(bnum1, bnum3) then
			bnum1.signal = "-"
		end
		if not rawequal(bnum2, bnum3) then
			bnum2.signal = "-"
		end
		return
	end

	-- Turn a - -b into a + b
	if bnum1.signal == "+" and bnum2.signal == "-" then
		bnum2.signal = "+"
		Arithmetic.Add(bnum1, bnum2, bnum3)

		if not rawequal(bnum2, bnum3) then
			bnum2.signal = "-"
		end
		return
	end

	-- Turn a - b with |b| > |a| into -(b - a)
	if BigNum.CompareAbs(bnum1, bnum2) == 2 then
		Arithmetic.Sub(bnum2, bnum1, bnum3)
		bnum3.signal = "-"
		return
	end

	--[[ Subtracting ]]

	local oldLength: number = bnum3.len or 0
	local maxLength: number = bnum1.len
	local borrow: number = 0
	local length: number = 0

	for index: number = 0, maxLength - 1 do
		local difference: number = bnum1[index] - (bnum2[index] or 0) - borrow

		if difference < 0 then
			difference += RADIX
			borrow = 1
		else
			borrow = 0
		end

		bnum3[index] = difference

		if difference ~= 0 then
			length = index + 1
		end
	end

	--[[ Saving ]]

	if length == 0 then
		bnum3[0] = 0
		length = 1
	end

	for index: number = length, math.max(oldLength, maxLength) - 1 do
		bnum3[index] = nil
	end

	bnum3.len = length
	bnum3.signal = "+"
end

--%%%%%%%%%%%%%%%%%%%% Mul

--[[
	Stores `bnum1 * bnum2` in `bnum3`. The output may be one of the inputs.
]]
--- @param bnum1 BigNum_Instance
--- @param bnum2 BigNum_Instance
--- @param bnum3 BigNum_Instance
function Arithmetic.Mul(bnum1, bnum2, bnum3)
	--[[ Checks ]]

	assertOperands("Mul", bnum1, bnum2, bnum3)

	-- Multiply into a scratch value when the output aliases an input
	if rawequal(bnum3, bnum1) or rawequal(bnum3, bnum2) then
		local scratch = BigNum.new()
		Arithmetic.Mul(bnum1, bnum2, scratch)
		BigNum.Copy(scratch, bnum3)
		return
	end

	--[[ Local Variables ]]

	local oldLength: number = bnum3.len or 0
	local length: number = bnum1.len + bnum2.len

	for index: number = 0, length - 1 do
		bnum3[index] = 0
	end

	for index: number = length, oldLength - 1 do
		bnum3[index] = nil
	end

	--[[ Multiplying ]]

	for index1: number = 0, bnum1.len - 1 do
		local carry: number = 0

		for index2: number = 0, bnum2.len - 1 do
			local value: number = bnum1[index1] * bnum2[index2] + carry + bnum3[index1 + index2]
			bnum3[index1 + index2] = value % RADIX
			carry = value // RADIX
		end

		if carry ~= 0 then
			bnum3[index1 + bnum2.len] = carry
		end
	end

	--[[ Trimming ]]

	while length > 1 and bnum3[length - 1] == 0 do
		bnum3[length - 1] = nil
		length -= 1
	end

	--[[ Saving ]]

	bnum3.len = length
	bnum3.signal = if bnum1.signal ~= bnum2.signal and not isZero(bnum3) then "-" else "+"
end

--%%%%%%%%%%%%%%%%%%%% Div

--[[
	Stores `bnum1 / bnum2` truncated toward zero in `bnum3`, and the remainder (with the sign of `bnum1`) in `bnum4`.
	The outputs must be new BigNums, not the inputs.
]]
--- @param bnum1 BigNum_Instance
--- @param bnum2 BigNum_Instance
--- @param bnum3 BigNum_Instance
--- @param bnum4 BigNum_Instance
function Arithmetic.Div(bnum1, bnum2, bnum3, bnum4)
	--[[ Checks ]]

	assertOperands("Div", bnum1, bnum2, bnum3, bnum4)

	-- Check if the divisor is zero
	if isZero(bnum2) then
		error(`[{_localName}::{script.Name}]: Division by zero!`, 2)
	end

	--[[ Dividing ]]

	local signal1: string = bnum1.signal
	local signal2: string = bnum2.signal

	bnum1.signal = "+"
	bnum2.signal = "+"
	divideMagnitudes(bnum1, bnum2, bnum3, bnum4)
	bnum1.signal = signal1
	bnum2.signal = signal2

	--[[ Signs ]]

	bnum3.signal = if signal1 ~= signal2 and not isZero(bnum3) then "-" else "+"
	bnum4.signal = if signal1 == "-" and not isZero(bnum4) then "-" else "+"
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Pow

--[[
	Returns `base ^ exponent` for a non-negative integer exponent, using exponentiation by squaring.
]]
--- @param base BigNum_Instance
--- @param exponent BigNum_Instance
--- @return BigNum_Instance
function Arithmetic.Pow(base, exponent)
	--[[ Local Variables ]]

	local remaining = BigNum.new(exponent)
	local result = BigNum.new(1)
	local square = BigNum.new(base)

	--[[ Checks ]]

	-- Check if the exponent is non-negative
	if remaining.signal == "-" and not isZero(remaining) then
		error(`[{_localName}::{script.Name}]: Pow exponent must be non-negative!`, 2)
	end

	--[[ Calculating ]]

	while not isZero(remaining) do
		if remaining[0] % 2 == 1 then
			result = result * square
		end

		remaining = remaining / 2

		if not isZero(remaining) then
			square = square * square
		end
	end

	--[[ Returning ]]

	return result
end

return Arithmetic
