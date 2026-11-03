--[[
    Created By:     Nari
]]

local _localName = "Date"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--[[ Tokens ]]

local TOKENS = {
	"YYYY",
	"YY",
	"MMMM",
	"MMM",
	"MM",
	"M",
	"DDDD",
	"DDD",
	"DD",
	"D",
	"HH",
	"H",
	"hh",
	"h",
	"mm",
	"m",
	"ss",
	"s",
	"A",
	"a",
} --- @type { string }

table.sort(TOKENS, function(a: string, b: string)
	if #a ~= #b then
		return #a > #b
	end
	return a < b
end)

--[[ Fields ]]

local REQUIRED_FIELDS = { "year", "month", "day", "hour", "min", "sec", "wday" } --- @type { string }

--[[ Names ]]

local MONTH_NAMES = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" } --- @type { string }
local MONTH_SHORT = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" } --- @type { string }
local DAY_NAMES = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" } --- @type { string }
local DAY_SHORT = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" } --- @type { string }

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

--- @class Ume_Library_Date : Ume_Library
local Date = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Date._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Date = Date --- @type Ume_Library_Date
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Unix To Date Local

--[[
	Formats a Unix timestamp in local time using template tokens (see `UnixToDate`).
]]
--- @return string
function Date.UnixToDateLocal(unixTime: number, format: string)
	return Date.UnixToDate(os.date("*t", unixTime), format)
end

--%%%%%%%%%%%%%%%%%%%% Unix To Date UTC

--[[
	Formats a Unix timestamp in UTC using template tokens (see `UnixToDate`).
]]
--- @return string
function Date.UnixToDateUTC(unixTime: number, format: string)
	return Date.UnixToDate(os.date("!*t", unixTime), format)
end

--%%%%%%%%%%%%%%%%%%%% Unix To Date

--[[
	Formats a date table with template tokens. Tokens are matched longest first in one pass.
	Year: YYYY, YY. Month: MMMM (January), MMM (Jan), MM (01), M (1). Day: DDDD (Monday), DDD (Mon), DD (01), D (1).
	Hour: HH / H (24h), hh / h (12h). Minute: mm, m. Second: ss, s. Period: A (AM), a (am).
]]
--- @param dateData Date_DateTable
--- @return string
function Date.UnixToDate(dateData, format: string)
	--[[ Checks ]]

	-- Check if the format is a string
	if type(format) ~= "string" then
		error(`[{_localName}::{script.Name}]: (format) must be a string!`, 2)
	end

	-- Check if the date data is a table
	if type(dateData) ~= "table" then
		error(`[{_localName}::{script.Name}]: (dateData) must be a table!`, 2)
	end

	-- Check if the date data has every required field
	for _index: number, field: string in ipairs(REQUIRED_FIELDS) do
		if dateData[field] == nil then
			error(`[{_localName}::{script.Name}]: (dateData) is missing ({field}), expected the os.date("*t") shape!`, 2)
		end
	end

	--[[ Local Variables ]]

	local hour12: number = dateData.hour % 12
	if hour12 == 0 then
		hour12 = 12
	end

	local period: string = if dateData.hour >= 12 then "PM" else "AM"

	--- @type { [string]: string }
	local values = {
		YYYY = string.format("%04d", dateData.year),
		YY = string.format("%02d", dateData.year % 100),

		MMMM = MONTH_NAMES[dateData.month],
		MMM = MONTH_SHORT[dateData.month],
		MM = string.format("%02d", dateData.month),
		M = tostring(dateData.month),

		DDDD = DAY_NAMES[dateData.wday],
		DDD = DAY_SHORT[dateData.wday],
		DD = string.format("%02d", dateData.day),
		D = tostring(dateData.day),

		HH = string.format("%02d", dateData.hour),
		H = tostring(dateData.hour),
		hh = string.format("%02d", hour12),
		h = tostring(hour12),

		mm = string.format("%02d", dateData.min),
		m = tostring(dateData.min),

		ss = string.format("%02d", dateData.sec),
		s = tostring(dateData.sec),

		A = period,
		a = string.lower(period),
	}

	--[[ Replacing ]]

	local parts = {} --- @type { string }
	local index: number = 1

	while index <= #format do
		local matchedToken: string? = nil

		for _tokenIndex: number, token: string in ipairs(TOKENS) do
			if string.sub(format, index, index + #token - 1) == token then
				matchedToken = token
				break
			end
		end

		-- Keep characters that are not tokens
		if not matchedToken then
			table.insert(parts, string.sub(format, index, index))
			index += 1
			continue
		end

		table.insert(parts, values[matchedToken])
		index += #matchedToken
	end

	--[[ Returning ]]

	return table.concat(parts)
end

return Date
