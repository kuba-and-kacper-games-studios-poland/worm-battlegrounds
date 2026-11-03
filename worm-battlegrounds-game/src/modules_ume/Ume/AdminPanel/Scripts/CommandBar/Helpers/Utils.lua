--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Parse Values

--[[
	Returns the comma-separated numbers in a text when there are exactly `length` of them and each is finite, or nil.
]]
--- @return { number }?
local function parseValues(str: string, length: number)
	--[[ Splitting ]]

	-- Remove all whitespace
	str = str:gsub("%s+", "")

	--- @type { string }
	local parts = {}

	for part: string in str:gmatch("([^,]+)") do
		table.insert(parts, part)
	end

	--[[ Checks ]]

	-- Check if there are as many values as expected
	if #parts ~= length then
		return nil
	end

	--[[ Converting ]]

	--- @type { number }
	local values = {}

	for index: number, part: string in ipairs(parts) do
		local num: number? = tonumber(part)

		-- Check if the part is a finite number
		if not num or num ~= num or math.abs(num) == math.huge then
			return nil
		end

		values[index] = num
	end

	--[[ Returning ]]

	return values
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

--- @class AdminPanel_CommandBar_Utils
local Utils = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Arg Functions

--%%%%%%%%%%%%%%%%%%%% Get Variable Based On Type

--[[
	Returns argument converted to its expected type, or nil when it isn't one.
	A table converts only to `table`; every other type takes text.
]]
--- @param argData AdminPanel_CommandBar_CommandDataArgTable
--- @return string | number | { any }
function Utils.GetVariableBasedOnType(arg: string | table, argType: string, argData, isGlobal: boolean, shallowCheck: boolean?)
	--%%%%%%%%%%%%%%%%%%%% Table

	if argType == "table" then
		if type(arg) == "table" then
			--[[ Shallow Check ]]

			if shallowCheck then
				return arg
			end

			--[[ Deep Check ]]

			local convertedArgs = {}

			-- For each argument in the table
			for _, loopArg: string | table in ipairs(arg) do
				-- Convert to the first valid type
				for _, loopType: string in ipairs(argData.types) do
					local var: any = Utils.GetVariableBasedOnType(loopArg, loopType, argData)
					if var ~= nil then
						table.insert(convertedArgs, var)
						break
					end
				end
			end

			return convertedArgs
		end

		-- Invalid table
		return nil
	end

	--%%%%%%%%%%%%%%%%%%%% Other

	-- Check if a single argument is text, as the bar sends it
	if type(arg) ~= "string" then
		return nil
	end

	if argType == "BigNum" then
		return I.BN.ConvertFromAbbreviation(arg)
	end

	if argType == "Color" then
		return Utils.StringToColor(arg)
	end

	if argType == "Vector3" then
		return Utils.StringToVector3(arg)
	end

	if argType == "Vector2" then
		return Utils.StringToVector2(arg)
	end

	--%%%%%%%%%%%%%%%%%%%% Default

	-- string
	if argType == "string" then
		return arg
	end

	-- number
	if argType == "number" then
		return tonumber(arg)
	end

	-- boolean
	if argType == "boolean" then
		local isBool: boolean = arg == "true" or arg == "false"
		if isBool then
			return arg == "true"
		end

		return nil
	end

	-- Player
	if argType == "Player" then
		if isGlobal then
			return true
		else
			return Players:FindFirstChild(arg)
		end
	end

	-- Invalid type
	return nil
end

--%%%%%%%%%%%%%%%%%%%% Arg Type Check

--[[
	Checks if given argument matches any of the types in the table.
]]
--- @return boolean
function Utils.IsArgValidType(arg: string | table, types: { string }, isGlobal: boolean)
	for _, argType: string in ipairs(types) do
		if Utils.GetVariableBasedOnType(arg, argType, nil, isGlobal, true) ~= nil then
			return true
		end
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Convert Args Table

--[[
	Converts all arguments in the given table into their expected types.\
	Returns boolean indicating if the conversion succeeded and table with args or error message string.
]]
--- @param variantData AdminPanel_CommandBar_VariantData
--- @return boolean
--- @return { any } | string
function Utils.ConvertArgsTable(variantData, args: { string | table }, isGlobal: boolean, shallowCheck: boolean)
	--[[ Checks ]]

	-- Skip variants without arguments
	if not args or not variantData.args then
		return true, {}
	end

	--[[ Local Variables ]]

	local convertedArgs = {} --- @type { any }

	--[[ Converting Arguments ]]

	--- @param argData AdminPanel_CommandBar_CommandDataArgTable
	for argId: number, argData in ipairs(variantData.args) do
		--[[ Getting Argument ]]

		local currentArg: string = args[argId]

		--[[ Checks ]]

		-- Check if a required argument is missing
		if currentArg == nil and not argData.optional then
			return false, _settings.DEBUG_MESSAGES.MissingArgument:format(argData.name)
		end

		-- Skip if an optional argument is missing
		if currentArg == nil then
			continue
		end

		-- Skip if argument is set nil or is empty
		if argData.optional and (currentArg == "nil" or currentArg == "") then
			continue
		end

		--[[ Converting ]]

		local argFound: boolean = false

		-- Looping through every type allowed for this arg to get the right one
		for _, argType: string in ipairs(argData.types) do
			local var: any = Utils.GetVariableBasedOnType(currentArg, argType, argData, isGlobal, shallowCheck)
			if var ~= nil then
				convertedArgs[argId] = var
				argFound = true
				break
			end
		end

		--[[ Not Found: Error ]]

		-- Check if any allowed type accepted the argument
		if not argFound then
			return false, _settings.DEBUG_MESSAGES.InvalidArgument:format(argData.name)
		end
	end

	--[[ Returning ]]

	return true, convertedArgs
end

--%%%%%%%%%%%%%%%%%%%% Get Variant Data From Args

--[[
	Finds the deepest variant within the command using provided args.\
	Returns boolean indicating if the "get" succeeded, variant data and cropped args.
]]
--- @param commandData AdminPanel_CommandBar_CommandData_Global
--- @return boolean
--- @return AdminPanel_CommandBar_VariantData
--- @return { AdminPanel_CommandBar_ParsedArg }
function Utils.GetVariantDataFromArgs(commandData, args: { string | table })
	--[[ Local Variables ]]

	--- @type AdminPanel_CommandBar_VariantData
	local chosenVariant = commandData.baseVariant
	local depth: number = 1

	--[[ Finding Deepest Variant ]]

	while true do
		-- Variants table is missing in the current variant
		if not chosenVariant.variants then
			break
		end

		-- Depth is out of bounds -> sticking to the currently choosen variant
		if not args[depth] then
			break
		end

		--[[ Getting Variant ]]

		local variantChanged: boolean = false

		--- @param variantData AdminPanel_CommandBar_VariantData
		for _, variantData in ipairs(chosenVariant.variants) do
			-- If argument is found in the aliases -> save it as current variant
			if table.find(variantData.aliases, args[depth]) then
				chosenVariant = variantData
				depth += 1
				variantChanged = true
				break
			end
		end

		-- Skip if variant stayed the same
		if not variantChanged then
			break
		end
	end

	--[[ Cropping Arguments ]]

	local croppedArgs = {}
	table.move(args, depth, #args, 1, croppedArgs)

	--[[ Returning ]]

	return true, chosenVariant, croppedArgs
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Color Functions

--%%%%%%%%%%%%%%%%%%%% String To Color

--[[
	Formats string into a Color3. 
]]
--- @return Color3?
function Utils.StringToColor(input: string)
	if not input or type(input) ~= "string" then
		return nil
	end

	-- Trim whitespace from input
	input = input:match("^%s*(.-)%s*$")

	--[[ Hex Color ]]

	if input:sub(1, 1) == "#" then
		local success: boolean, color: Color3 = pcall(function()
			return Color3.fromHex(input)
		end)

		if success then
			return color
		else
			return nil
		end
	end

	--[[ Normal Color ]]

	if input:sub(1, 6) == "color(" and input:sub(-1) == ")" then
		local content: string = input:sub(7, -2)
		local values: table = parseValues(content, 3)

		if not values then
			return nil
		end

		for i: number, value: number in ipairs(values) do
			values[i] = math.clamp(value, 0, 1)
		end

		if values then
			return Color3.new(values[1], values[2], values[3])
		end
	end

	--[[ RGB Color ]]

	if input:lower():sub(1, 4) == "rgb(" and input:sub(-1) == ")" then
		local content: string = input:sub(5, -2)
		local values: table = parseValues(content, 3)

		if not values then
			return nil
		end

		for i: number, value: number in ipairs(values) do
			values[i] = math.clamp(value, 0, 255)
		end

		if values then
			return Color3.fromRGB(values[1], values[2], values[3])
		end
	end

	--[[ HSV Color ]]

	if input:lower():sub(1, 4) == "hsv(" and input:sub(-1) == ")" then
		local content: string = input:sub(5, -2)
		local values: table = parseValues(content, 3)

		if not values then
			return nil
		end

		for i: number, value: number in ipairs(values) do
			values[i] = math.clamp(value, 0, 1)
		end

		if values then
			return Color3.fromHSV(values[1], values[2], values[3])
		end
	end

	-- Invalid color
	return nil
end

--%%%%%%%%%%%%%%%%%%%% String To Vector3

--[[
	Formats string into a Vector3.
]]
--- @return Vector3?
function Utils.StringToVector3(input: string)
	if not input or type(input) ~= "string" then
		return nil
	end

	-- Trim whitespace from input
	input = input:match("^%s*(.-)%s*$")

	--[[ Converting ]]

	if input:sub(1, 3) == "v3(" and input:sub(-1) == ")" then
		local content: string = input:sub(4, -2)
		local values: table = parseValues(content, 3)

		if not values then
			return nil
		end

		if values then
			return Vector3.new(values[1], values[2], values[3])
		end
	end

	-- Invalid vector
	return nil
end

--%%%%%%%%%%%%%%%%%%%% String To Vector2

--[[
	Formats string into a Vector2.
]]
--- @return Vector2?
function Utils.StringToVector2(input: string)
	if not input or type(input) ~= "string" then
		return nil
	end

	-- Trim whitespace from input
	input = input:match("^%s*(.-)%s*$")

	--[[ Converting ]]

	if input:lower():sub(1, 3) == "v2(" and input:sub(-1) == ")" then
		local content: string = input:sub(4, -2)
		local values: table = parseValues(content, 2)

		if not values then
			return nil
		end

		if values then
			return Vector2.new(values[1], values[2])
		end
	end

	-- Invalid vector
	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Variant Cleaning

--%%%%%%%%%%%%%%%%%%%% Remove Variants By Permission Level

--[[
	Performs a deep search and removes all variants with greater permission level than is given.
]]
--- @param variantData AdminPanel_CommandBar_VariantData
function Utils.RemoveVariantsByPermissionLevel(variantData, permissionLevel: number)
	-- No variants found -> skip
	if not variantData.variants then
		return
	end

	--[[ Reverse Loop Check ]]

	for i: number = #variantData.variants, 1, -1 do
		--- @param loopVariantData AdminPanel_CommandBar_VariantData
		local loopVariantData = variantData.variants[i]

		-- Removing if permission level is lower
		if loopVariantData.permissionLevel > permissionLevel then
			table.remove(variantData.variants, i)
			continue
		end

		-- Searching further
		Utils.RemoveVariantsByPermissionLevel(loopVariantData, permissionLevel)
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Variant Permission Level

--[[
	Updates `permissionLevel` of all command variants to not be less than its parent variant.
]]
--- @param variantData AdminPanel_CommandBar_VariantData
function Utils.UpdateVariantPermissionLevel(variantData, debugPrefix: string)
	-- Skip if not variants were found
	if not variantData.variants then
		return
	end

	--[[ Variants Check ]]

	--- @param loopVariantData AdminPanel_CommandBar_VariantData
	for _, loopVariantData in ipairs(variantData.variants) do
		-- Getting variant debug prefix
		local variantDebugPrefix: string = `{debugPrefix}||{loopVariantData.aliases[1]}`

		--[[ Updating Permission Level ]]

		-- Setting default value if it's missing
		if not loopVariantData.permissionLevel then
			loopVariantData.permissionLevel = variantData.permissionLevel
		end

		-- Clamping so the child variant won't have lower permission level than their parent
		if variantData.permissionLevel > loopVariantData.permissionLevel then
			loopVariantData.permissionLevel = variantData.permissionLevel
			warn(`[{_localName}::{script.Name}]: Command [{variantDebugPrefix}] - Permission level for this variant is higher than permission level for its parent!`)
		end

		--[[ Updating Child Variants ]]

		Utils.UpdateVariantPermissionLevel(loopVariantData, variantDebugPrefix)
	end
end

--%%%%%%%%%%%%%%%%%%%% Cleanup Variants

--[[
	Cleanups variants so they're ready to be sent to client.
]]
--- @param variantData AdminPanel_CommandBar_VariantData
function Utils.CleanupVariants(variantData)
	variantData.callbackUUID = nil
	variantData.callbackUUID_globalReturn = nil

	-- Cleaning child variants
	if variantData.variants then
		--- @param loopVariantData AdminPanel_CommandBar_VariantData
		for _, loopVariantData in ipairs(variantData.variants) do
			Utils.CleanupVariants(loopVariantData)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Utils
