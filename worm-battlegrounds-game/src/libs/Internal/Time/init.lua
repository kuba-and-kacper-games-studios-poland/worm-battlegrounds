--[[
    Created By:     Nari
]]

local _localName = "Time"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--[[ Seconds ]]

local SECONDS_IN_MINUTE: number = 60
local SECONDS_IN_HOUR: number = 3600
local SECONDS_IN_DAY: number = 86400

--[[ Templates ]]

local DEFAULT_TEMPLATES = { "Dt:HHl:MMl:SSl", "HHt:MMl:SSl", "MMt:SSl", "MMt:SSt" } --- @type { string }

--[[ Tokens ]]

local TOKENS = {
	"DDt",
	"Dt",
	"HHt",
	"Ht",
	"HHl",
	"Hl",
	"MMt",
	"Mt",
	"MMl",
	"Ml",
	"SSt",
	"St",
	"SSl",
	"Sl",
} --- @type { string }

table.sort(TOKENS, function(a: string, b: string)
	if #a ~= #b then
		return #a > #b
	end
	return a < b
end)

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

--- @class Ume_Library_Time : Ume_Library
local Time = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Time._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Time = Time --- @type Ume_Library_Time
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Format Clean

--[[
	Formats seconds with the template matching the largest unit present.
	`formatTemplates` overrides [1] days, [2] hours, [3] minutes, [4] seconds
	(defaults: "Dt:HHl:MMl:SSl", "HHt:MMl:SSl", "MMt:SSl", "MMt:SSt").
]]
--- @param formatTemplates { string }?
--- @return string
function Time.FormatClean(s: number | string, formatTemplates)
	--[[ Checks ]]

	local seconds: number? = tonumber(s)

	-- Check if the value is a number
	if not seconds then
		warn(`[{_localName}::{script.Name}]: Invalid (s) value. Expected (number), got ({s}: {typeof(s)})!`)
		return "0"
	end

	--[[ Local Variables ]]

	local templateIndex: number = 4

	if seconds >= SECONDS_IN_DAY then
		templateIndex = 1
	elseif seconds >= SECONDS_IN_HOUR then
		templateIndex = 2
	elseif seconds >= SECONDS_IN_MINUTE then
		templateIndex = 3
	end

	--[[ Returning ]]

	return Time.Format(seconds, formatTemplates and formatTemplates[templateIndex] or DEFAULT_TEMPLATES[templateIndex])
end

--%%%%%%%%%%%%%%%%%%%% Format

--[[
	Formats whole seconds (negative values count as 0) with template tokens.
	`t` tokens are the total amount of that unit, `l` tokens are the remainder after larger units.
	Days: DDt, Dt. Hours: HHt, Ht, HHl, Hl. Minutes: MMt, Mt, MMl, Ml. Seconds: SSt, St, SSl, Sl.
	Doubled letters are zero-padded to two digits.
]]
--- @return string
function Time.Format(s: number | string, format: string)
	--[[ Checks ]]

	local seconds: number? = tonumber(s)

	-- Check if the value is a number
	if not seconds then
		return format
	end

	--[[ Local Variables ]]

	local totalSeconds: number = math.max(math.floor(seconds), 0)
	local totalMinutes: number = totalSeconds // SECONDS_IN_MINUTE
	local totalHours: number = totalSeconds // SECONDS_IN_HOUR
	local totalDays: number = totalSeconds // SECONDS_IN_DAY

	--- @type { [string]: string }
	local values = {
		DDt = string.format("%02d", totalDays),
		Dt = tostring(totalDays),

		HHt = string.format("%02d", totalHours),
		Ht = tostring(totalHours),
		HHl = string.format("%02d", totalHours % 24),
		Hl = tostring(totalHours % 24),

		MMt = string.format("%02d", totalMinutes),
		Mt = tostring(totalMinutes),
		MMl = string.format("%02d", totalMinutes % 60),
		Ml = tostring(totalMinutes % 60),

		SSt = string.format("%02d", totalSeconds),
		St = tostring(totalSeconds),
		SSl = string.format("%02d", totalSeconds % 60),
		Sl = tostring(totalSeconds % 60),
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

return Time
