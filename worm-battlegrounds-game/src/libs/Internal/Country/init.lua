--[[
    Created By:     Nari
]]

local _localName = "Country"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local countries = require(_data:FindFirstChild("Countries")) --- @type { Country_CountryData }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local byName = {} --- @type { [string]: Country_CountryData }
local byAlpha2 = {} --- @type { [string]: Country_CountryData }
local byAlpha3 = {} --- @type { [string]: Country_CountryData }
local byCode = {} --- @type { [string]: Country_CountryData }
local byEmoji = {} --- @type { [string]: Country_CountryData }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% To Key

--[[
	Normalizes a lookup value into a lowercase key.
]]
--- @return string
local function toKey(value: any)
	return string.lower(tostring(value))
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

--- @class Ume_Library_Country : Ume_Library
local Country = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Country._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Country = Country --- @type Ume_Library_Country
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get By Name

--[[
	Returns the country with this name (case-insensitive).
]]
--- @return Country_CountryData?
function Country.GetByName(countryName: string)
	return byName[toKey(countryName)]
end

--%%%%%%%%%%%%%%%%%%%% Get By Alpha2

--[[
	Returns the country with this ISO 3166-1 alpha-2 code (case-insensitive).
]]
--- @return Country_CountryData?
function Country.GetByAlpha2(alpha2: string)
	return byAlpha2[toKey(alpha2)]
end

--%%%%%%%%%%%%%%%%%%%% Get By Alpha3

--[[
	Returns the country with this ISO 3166-1 alpha-3 code (case-insensitive).
]]
--- @return Country_CountryData?
function Country.GetByAlpha3(alpha3: string)
	return byAlpha3[toKey(alpha3)]
end

--%%%%%%%%%%%%%%%%%%%% Get By Country Code

--[[
	Returns the country with this ISO 3166-1 numeric code. Numbers and short strings are zero-padded (4 -> "004").
]]
--- @return Country_CountryData?
function Country.GetByCountryCode(countryCode: string | number)
	--[[ Local Variables ]]

	local numericCode: number? = tonumber(countryCode)

	--[[ Checks ]]

	-- Check if the code is a whole number
	if not numericCode or numericCode % 1 ~= 0 then
		return nil
	end

	--[[ Returning ]]

	return byCode[string.format("%03d", numericCode)]
end

--%%%%%%%%%%%%%%%%%%%% Get By Emoji

--[[
	Returns the country with this flag emoji.
]]
--- @return Country_CountryData?
function Country.GetByEmoji(flagEmoji: string)
	return byEmoji[tostring(flagEmoji)]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Setup

--- @param countryData Country_CountryData
for _index: number, countryData in ipairs(countries) do
	byName[toKey(countryData.Name)] = countryData
	byAlpha2[toKey(countryData.Alpha2)] = countryData
	byAlpha3[toKey(countryData.Alpha3)] = countryData
	byCode[toKey(countryData.Code)] = countryData
	byEmoji[countryData.Emoji] = countryData
end

return Country
