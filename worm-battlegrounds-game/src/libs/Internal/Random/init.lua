--[[
    Created By:     Nari
]]

local _localName = "Random"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local generator: Random = Random.new()

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Resolve Range

--[[
	Resolves the optional range arguments. A lone argument is the upper bound.
]]
--- @return number?
--- @return number?
local function resolveRange(min: number?, max: number?, defaultMin: number, defaultMax: number)
	--[[ Resolving ]]

	-- Treat a lone argument as the upper bound
	if min ~= nil and max == nil then
		min, max = defaultMin, min
	end

	local resolvedMin: number = min or defaultMin
	local resolvedMax: number = max or defaultMax

	--[[ Checks ]]

	-- Check if the range is ordered
	if resolvedMin > resolvedMax then
		warn(`[{_localName}::{script.Name}]: (min) cannot be greater than (max)! (min: {resolvedMin}, max: {resolvedMax})`)
		return nil, nil
	end

	--[[ Returning ]]

	return resolvedMin, resolvedMax
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

--- @class Ume_Library_Random : Ume_Library
local RandomLib = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function RandomLib._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Random = RandomLib --- @type Ume_Library_Random
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Float

--[[
	Returns a random float in [min, max]. Defaults to [0, 1]; a lone argument is the upper bound.
]]
--- @return number?
function RandomLib.Float(min: number?, max: number?)
	--[[ Range ]]

	local resolvedMin: number?, resolvedMax: number? = resolveRange(min, max, 0, 1)

	--[[ Checks ]]

	-- Check if the range resolved
	if not resolvedMin or not resolvedMax then
		return nil
	end

	--[[ Returning ]]

	return generator:NextNumber(resolvedMin, resolvedMax)
end

--%%%%%%%%%%%%%%%%%%%% Int

--[[
	Returns a random integer in [min, max]. Defaults to 0 or 1; a lone argument is the upper bound.
]]
--- @return number?
function RandomLib.Int(min: number?, max: number?)
	--[[ Range ]]

	local resolvedMin: number?, resolvedMax: number? = resolveRange(min, max, 0, 1)

	--[[ Checks ]]

	-- Check if the range resolved
	if not resolvedMin or not resolvedMax then
		return nil
	end

	--[[ Returning ]]

	return generator:NextInteger(resolvedMin, resolvedMax)
end

return RandomLib
