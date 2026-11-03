--[[
    Created By:     Nari
]]

local _localName = "Network"

--- @type Network_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper Functions

--%%%%%%%%%%%%%%%%%%%% Is Unsafe Number

--[[
	Checks if `number` is unsafe.
]]
--- @return boolean
local function isUnsafeNumber(n: number)
	-- `nan` number
	if n ~= n then
		return true
	end

	-- `inf` number
	if n == math.huge or n == -math.huge then
		return true
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Is Unsafe String

--[[
	Checks if `string` is unsafe.
]]
--- @return boolean
local function isUnsafeString(s: string)
	-- Long string check
	if #s > _settings.MAX_STRING_LENGTH then
		return true
	end

	-- Checking if the string as a number is unsafe
	local normalized: string = s:gsub("%s+", ""):lower()
	if normalized == "nan" or normalized == "inf" or normalized == "+inf" or normalized == "-inf" or normalized == "infinity" or normalized == "+infinity" or normalized == "-infinity" then
		return true
	end

	-- Checking if converted string is still a valid number
	local n: number? = tonumber(s)
	if n then
		return isUnsafeNumber(n)
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scan Functions

--%%%%%%%%%%%%%%%%%%%% Scan

--[[
	Checks if passed value is unsafe.
	Uses a recursion stack so shared table references (DAG) are allowed; only true cycles fail.
]]
--- @return boolean
local function scan(value: any, visiting: { [table]: boolean }, depth: number)
	-- Table depth reached
	if depth > _settings.MAX_TABLE_DEPTH then
		return true
	end

	--[[ Scanning ]]

	local vType: string = type(value)

	if vType == "number" then
		if isUnsafeNumber(value) then
			return true
		end
	elseif vType == "string" then
		if isUnsafeString(value) then
			return true
		end
	elseif vType == "table" then
		--[[ Cycle check (table already on current scan path) ]]

		if visiting[value] then
			return true
		end
		visiting[value] = true

		--[[ Entries Check ]]

		local count: number = 0

		for k: any, v: any in pairs(value) do
			count += 1

			-- Table limit reached
			if count > _settings.MAX_TABLE_SIZE then
				visiting[value] = nil
				return true
			end

			-- Scanning key and value
			if scan(k, visiting, depth + 1) or scan(v, visiting, depth + 1) then
				visiting[value] = nil
				return true
			end
		end

		visiting[value] = nil
	end

	return false
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

--- @class Network_Helpers
local Helpers = {}

--%%%%%%%%%%%%%%%%%%%% Validate Remote Args

--[[
	Validates arguments sent by the client.
]]
--- @return boolean
function Helpers.ValidateRemoteArgs(...: any)
	-- Packing arguments into a table
	local args: { any } = table.pack(...)
	args.n = nil

	--[[ Scanning ]]

	local visiting = {}
	if scan(args, visiting, 0) then
		return false
	end

	return true
end

--%%%%%%%%%%%%%%%%%%%% Estimate Size

--[[
	Returns a rough byte size of a value, for the Studio network stats.
]]
--- @return number
function Helpers.EstimateSize(value: any)
	--[[ Local Variables ]]

	local vType: string = typeof(value)

	--[[ Measuring ]]

	if vType == "string" then
		return #value
	elseif vType == "number" then
		return 8
	elseif vType == "boolean" or vType == "nil" then
		return 1
	elseif vType == "Vector3" then
		return 12
	elseif vType == "CFrame" then
		return 48
	elseif vType == "table" then
		local size: number = 0

		for k: any, v: any in pairs(value) do
			size += Helpers.EstimateSize(k) + Helpers.EstimateSize(v)
		end

		return size
	end

	--[[ Returning ]]

	return 4
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Helpers
