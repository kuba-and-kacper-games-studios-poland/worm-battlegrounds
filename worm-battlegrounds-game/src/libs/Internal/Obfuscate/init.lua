--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local DEFAULT_LENGTH: number = 20

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type { [string]: string }
local charsets = {

	--[[ Default ]]

	Default = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
	Numbers = "1234567890",

	--[[ Letters ]]

	Letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
	Letters_Small = "abcdefghijklmnopqrstuvwxyz",
	Letters_Big = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",

	--[[ Custom ]]

	Noisy = "aA1!bB2@cC3#dD4$eE5%fF6^gG7&hH8*iI9(jJ0)kK-lL_mM=nN+oO[pP]qQ{rR}sS|tT:uU;vV<wW>xX,yY.zZ?",
	Base64ish = "0123456789abcdefABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/",
	Safe = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789",
	BinaryLike = "01lIO",
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local generator: Random = Random.new()

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

--- @class Ume_Library_Obfuscate : Ume_Library
local Obfuscate = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Obfuscate._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Obfuscate = Obfuscate --- @type Ume_Library_Obfuscate
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Random String

--[[
	Returns a random string of `length` characters picked from a named charset (`Default` when omitted).
]]
--- @return string
function Obfuscate.GetRandomString(length: number?, charset: string?)
	--[[ Local Variables ]]

	local characters: string = charset and charsets[charset] or charsets["Default"]
	local count: number = math.max(math.floor(tonumber(length) or DEFAULT_LENGTH), 0)

	--[[ Generating ]]

	local parts = table.create(count) --- @type { string }

	for index: number = 1, count do
		local characterIndex: number = generator:NextInteger(1, #characters)
		parts[index] = string.sub(characters, characterIndex, characterIndex)
	end

	--[[ Returning ]]

	return table.concat(parts)
end

--%%%%%%%%%%%%%%%%%%%% Shuffle

--[[
	Returns `input` with its characters in a random order.
]]
--- @return string
function Obfuscate.Shuffle(input: string)
	--[[ Characters ]]

	local characters = string.split(input, "") --- @type { string }

	--[[ Shuffling ]]

	for index: number = #characters, 2, -1 do
		local swapIndex: number = generator:NextInteger(1, index)
		characters[index], characters[swapIndex] = characters[swapIndex], characters[index]
	end

	--[[ Returning ]]

	return table.concat(characters)
end

return Obfuscate
