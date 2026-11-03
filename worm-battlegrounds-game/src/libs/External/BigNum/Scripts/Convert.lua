--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local DEFAULT_SEPARATOR: string = ","
local FORMATTED_DECIMALS: number = 2

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local BigNum --- @type BigNum
local abbreviations --- @type { string }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Split Sign

--[[
	Splits a leading `-` from a digit string.
]]
--- @return string
--- @return string
local function splitSign(text: string)
	--[[ Returning ]]

	if string.sub(text, 1, 1) == "-" then
		return "-", string.sub(text, 2)
	end

	return "", text
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

--- @class BigNum_Convert
local Convert = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param bigNum BigNum
function Convert.Init(bigNum)
	BigNum = bigNum
	abbreviations = bigNum._constants.ABBREVIATIONS
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Abbreviation Convert

--[[
	Abbreviates a whole number (`1234567` -> `1.23m` with 2 decimals). Decimals are truncated and keep trailing zeros.
	With `returnSeparated`, returns the number part and the suffix separately.
]]
--- @param num BigNum_Value
--- @return string
--- @return string?
function Convert.AbbreviationConvert(num, decimalCount: number?, returnSeparated: boolean?)
	--[[ Local Variables ]]

	local decimals: number = math.max(math.floor(tonumber(decimalCount) or 0), 0)
	local sign: string, digits: string = splitSign(tostring(BigNum.ToBigNum(num or 0)))
	local suffixIndex: number = math.min((#digits - 1) // 3, #abbreviations)

	--[[ Splitting ]]

	local integerLength: number = #digits - suffixIndex * 3
	local value: string = sign .. string.sub(digits, 1, integerLength)

	if suffixIndex > 0 and decimals > 0 then
		value ..= "." .. string.sub(digits, integerLength + 1, integerLength + decimals)
	end

	local suffix: string = if suffixIndex > 0 then abbreviations[suffixIndex] else ""

	--[[ Returning ]]

	if returnSeparated then
		return value, suffix
	end

	return value .. suffix
end

--%%%%%%%%%%%%%%%%%%%% Abbreviation Convert Formatted

--[[
	Abbreviates a whole number and trims trailing decimal zeros (`1.20k` -> `1.2k`, `1.00k` -> `1k`).
]]
--- @param num BigNum_Value
--- @return string
function Convert.AbbreviationConvertFormatted(num, decimalCount: number?)
	--[[ Converting ]]

	local value: string, suffix: string? = Convert.AbbreviationConvert(num, decimalCount, true)

	--[[ Trimming ]]

	if string.find(value, "%.") then
		value = (string.gsub(value, "0+$", ""))
		value = (string.gsub(value, "%.$", ""))
	end

	--[[ Returning ]]

	return value .. (suffix or "")
end

--%%%%%%%%%%%%%%%%%%%% Convert From Abbreviation

--[[
	Expands an abbreviated number (`1.5k` -> `1500`) into a whole number string, truncating extra decimals.
	Plain integers are returned canonically. Returns nil for anything else.
]]
--- @return string?
function Convert.ConvertFromAbbreviation(num: string)
	--[[ Checks ]]

	-- Check if the value is a string
	if type(num) ~= "string" then
		return nil
	end

	--[[ Plain Integer ]]

	local text: string = (string.gsub(num, "%s+", ""))

	if string.match(text, "^%-?%d+$") then
		return tostring(BigNum.new(text))
	end

	--[[ Parsing ]]

	local sign: string, integerDigits: string, fractionDigits: string, abbreviation: string = string.match(text, "^(%-?)(%d*)%.?(%d*)(%a+)$")

	--[[ Checks ]]

	-- Check if the text is a number followed by letters
	if not abbreviation or (integerDigits == "" and fractionDigits == "") then
		return nil
	end

	local abbreviationIndex: number? = table.find(abbreviations, abbreviation)

	-- Check if the abbreviation is known
	if not abbreviationIndex then
		return nil
	end

	--[[ Returning ]]

	local zeros: number = abbreviationIndex * 3
	local digits: string = integerDigits .. string.sub(fractionDigits .. string.rep("0", zeros), 1, zeros)

	return tostring(BigNum.new(sign .. digits))
end

--%%%%%%%%%%%%%%%%%%%% Format With Separator

--[[
	Inserts `separator` (`,` by default) between every three integer digits, keeping the sign and any decimals.
]]
--- @return string
function Convert.FormatWithSeparator(num: number | string, separator: string?)
	--[[ Parsing ]]

	local text: string = tostring(num or "")
	local sign: string, integerDigits: string, rest: string = string.match(text, "^([%+%-]?)(%d+)(.*)$")

	--[[ Checks ]]

	-- Leave values without leading digits untouched
	if not integerDigits then
		return text
	end

	--[[ Grouping ]]

	local groups = {} --- @type { string }
	local firstGroupLength: number = #integerDigits % 3

	if firstGroupLength > 0 then
		table.insert(groups, string.sub(integerDigits, 1, firstGroupLength))
	end

	for index: number = firstGroupLength + 1, #integerDigits, 3 do
		table.insert(groups, string.sub(integerDigits, index, index + 2))
	end

	--[[ Returning ]]

	return sign .. table.concat(groups, separator or DEFAULT_SEPARATOR) .. rest
end

--%%%%%%%%%%%%%%%%%%%% Dynamic Format

--[[
	Formats a number with separators, or abbreviates it (2 decimals, trimmed) once it has `length` or more integer digits.
	Values that are not numbers are returned through `tostring`.
]]
--- @return string
function Convert.DynamicFormat(num: number | string, length: number?, separator: string?)
	--[[ Checks ]]

	-- Return an empty string for missing values
	if num == nil then
		return ""
	end

	--[[ Parsing ]]

	local text: string = tostring(num)
	local sign: string, integerDigits: string, decimals: string = string.match(text, "^(%-?)(%d+)(%.?%d*)$")

	-- Expand scientific notation into whole digits
	if not integerDigits and tonumber(text) and string.find(text, "[eE]") then
		text = tostring(BigNum.new(text))
		sign, integerDigits, decimals = string.match(text, "^(%-?)(%d+)(%.?%d*)$")
	end

	--[[ Checks ]]

	-- Leave values that are not numbers untouched
	if not integerDigits then
		return text
	end

	--[[ Returning ]]

	if #integerDigits >= (tonumber(length) or math.huge) then
		return Convert.AbbreviationConvertFormatted(sign .. integerDigits, FORMATTED_DECIMALS)
	end

	return Convert.FormatWithSeparator(sign .. integerDigits, separator) .. decimals
end

return Convert
