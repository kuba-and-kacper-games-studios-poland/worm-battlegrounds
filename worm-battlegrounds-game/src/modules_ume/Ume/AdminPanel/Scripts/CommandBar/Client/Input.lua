--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type AdminPanel_Permissions
local permissions = require(I.Dirs.GlobalData.AdminPanel.Permissions)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type AdminPanel_CommandBar_ClientShared
local state --- @type AdminPanel_CommandBar_ClientState

local c_utils --- @type AdminPanel_CommandBar_ClientUtils
local utils --- @type AdminPanel_CommandBar_Utils

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Debug Text Index

--[[
	Returns debug text index suffix if `DEBUG_TEXT_INDEX` is enabled.
]]
--- @return string
local function debugIdx(idx: string)
	return _settings.DEBUG_TEXT_INDEX and `:{idx}` or ""
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

--- @class AdminPanel_CommandBar_Client_Input
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_ClientShared
function Module.Init(_shared)
	shared = _shared
	state = _shared.state

	c_utils = _shared.c_utils
	utils = _shared.utils
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input Control

--%%%%%%%%%%%%%%%%%%%% Process Input

--[[
	Processes input from the `InputBox` to show player available suggestions for the currently command alias/variant/argument and mark if the inputs are valid.
]]
function Module.ProcessInput(ignoreSuggestions: boolean?)
	local elems = state.elems
	local aliases = state.aliases

	--[[ Data ]]

	local rawCommand: string = elems["InputBox"].Text

	--- @type AdminPanel_CommandBar_InputData
	local inputData = c_utils.GetInputData(rawCommand, aliases)

	--[[ Getting Cursor Position ]]

	local currentCursorPos: number = elems["InputBox"].CursorPosition
	local commandLength: number = #rawCommand + 1
	local isAtTheEnd: boolean = currentCursorPos == commandLength

	--[[ Clearing History Index ]]

	-- Command reset -> clear index
	if rawCommand == "" then
		state.commandHistoryIndex = nil
	end

	-- New/different command -> clear index
	if state.commandHistoryIndex and state.commandHistory[state.commandHistoryIndex] ~= rawCommand then
		state.commandHistoryIndex = nil
	end

	--[[ Not a Command ]]

	if not inputData.isCommand then
		elems["InputBox"].Text = inputData.command
		elems["DisplayBox"].Text = inputData.command

		if isAtTheEnd then
			elems["InputBox"].CursorPosition = #inputData.command + 1
		end

		state.activeArgIndex = nil

		if not ignoreSuggestions then
			shared.Suggestions.SetSuggestions(nil, nil)
		end

		return
	end

	--[[ Active Argument From Cursor ]]

	-- Determines which top-level arg the cursor is over so suggestions follow the cursor
	-- rather than always being anchored to the last argument.
	local cursorArgIdx: number = c_utils.GetActiveArgIndexAtCursor(inputData, currentCursorPos)
	local activeArgIndex: number
	if cursorArgIdx <= 0 then
		activeArgIndex = #inputData.args
	else
		activeArgIndex = math.min(cursorArgIdx, math.max(#inputData.args, 1))
	end

	state.activeArgIndex = activeArgIndex

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	--[[ Local Variables ]]

	local commandData --- @type AdminPanel_CommandBar_CommandData_Global
	local variantData --- @type AdminPanel_CommandBar_VariantData

	local availableAliases --- @type { string }
	local availableVariants --- @type { string }

	local finalString: string = ""
	local prefixString: string = ""

	local canSendGlobalCommands: boolean = false
	local variantDepth: number = 0

	--[[ Getting Command Data ]]

	do
		--[[ Permissions Check ]]

		if inputData.isGlobalCommand then
			canSendGlobalCommands = I.AdminPanel.GetPermissionLevel(I.Env.LocalPlayer) >= permissions.GlobalLevel
		end

		--[[ Setting Prefix ]]

		if inputData.isGlobalCommand then
			prefixString ..= canSendGlobalCommands and I.RichText.Format(_settings.GLOBAL_PREFIX, { Color = _settings.COLORS.GlobalPrefix }) or _settings.GLOBAL_PREFIX
		end
		prefixString ..= _settings.PREFIX

		--[[ Getting Command Data ]]

		-- Getting all valid commands for current alias
		availableAliases = c_utils.GetMatchingCommandsAliases(aliases, inputData, canSendGlobalCommands)

		-- If any alias is found -> get the selected command data
		if #availableAliases > 0 then
			-- If there's at least one argument -> then the command is chosen/set
			if #inputData.args > 0 then
				commandData = aliases[availableAliases[1]]
			end

			-- If the command is still being typed -> find the selected command
			if #inputData.args == 0 then
				-- If selected phrase exists -> select is as a command
				if state.autoCompletePhrase and aliases[state.autoCompletePhrase] and table.find(availableAliases, state.autoCompletePhrase) then
					commandData = aliases[state.autoCompletePhrase]
				else
					-- Otherwise select the first available alias
					commandData = aliases[availableAliases[1]]
				end
			end
		end

		--[[ Getting Variant Data ]]

		-- Setting default variant
		variantData = commandData and commandData.baseVariant

		if variantData and #inputData.args > 0 then
			--[[ Getting Deepest Variant ]]

			for argIndex: number, arg: string in ipairs(inputData.args) do
				-- Break repeat if current variant doesn't have child variants
				if not variantData.variants then
					break
				end

				-- Last argument should not be counted, as it's being currently edited
				if argIndex == #inputData.args then
					break
				end

				local foundVariant --- @type AdminPanel_CommandBar_VariantData

				--[[ Finding Child Variant ]]

				--- @param loopVariantData AdminPanel_CommandBar_VariantData
				for _, loopVariantData in ipairs(variantData.variants) do
					-- Checking if argument is matching any alias from the variant
					local isAliasMatching: boolean = table.find(loopVariantData.aliases, arg) ~= nil

					-- Matching alias -> Save and break the loop
					if isAliasMatching then
						foundVariant = loopVariantData
						break
					end
				end

				--[[ Validating ]]

				if foundVariant then
					-- Variant found -> Save as current and look for further one
					variantData = foundVariant
					variantDepth += 1
				else
					-- No child variant -> skip looking for further one
					break
				end
			end
		end

		--[[ Getting Available Variants ]]

		if variantData then
			-- Getting available variants, adding '1' to variant depth to compensate for the arg that is being edited
			availableVariants = c_utils.GetMatchingVariantsAliases(inputData, commandData, variantData, canSendGlobalCommands, variantDepth + 1)
		end
	end

	--[[ Command/Prefix Checks ]]

	do
		-- Global but no permission
		if inputData.isGlobalCommand and not canSendGlobalCommands then
			elems["InputBox"].Text = inputData.command
			elems["DisplayBox"].Text = inputData.command

			if not ignoreSuggestions then
				shared.Suggestions.SetSuggestions(nil, nil)
			end

			return
		end

		-- Invalid command
		if not commandData or not variantData then
			elems["InputBox"].Text = inputData.command
			elems["DisplayBox"].Text = `{prefixString}{I.RichText.Format(inputData.cleared, { Color = _settings.COLORS.Error })}`

			if isAtTheEnd then
				elems["InputBox"].CursorPosition = #inputData.command + 1
			end

			if not ignoreSuggestions then
				shared.Suggestions.SetSuggestions(nil, nil)
			end

			return
		end

		-- Only Prefix
		if #inputData.command == inputData.totalPrefixLength then
			elems["InputBox"].Text = inputData.command

			if (state.autoCompletePhrase or availableAliases[1]) and elems["InputBox"]:IsFocused() then
				elems["DisplayBox"].Text = `{prefixString}{I.RichText.Format(state.autoCompletePhrase or availableAliases[1], { Transparency = 0.5 })}`
			else
				elems["DisplayBox"].Text = prefixString
			end

			if not ignoreSuggestions then
				if elems["InputBox"]:IsFocused() then
					shared.Suggestions.SetSuggestions(inputData.command, { Alias = availableAliases })
				else
					shared.Suggestions.SetSuggestions(nil, nil)
				end
			end

			return
		end

		-- Global but not enabled for this variant
		if inputData.isGlobalCommand then
			if not variantData.globalEnabled and not variantData.variantsAreGlobal then
				elems["InputBox"].Text = inputData.command
				elems["DisplayBox"].Text = `{prefixString}{I.RichText.Format(inputData.cleared, { Color = _settings.COLORS.Error })}`

				if not ignoreSuggestions then
					shared.Suggestions.SetSuggestions(nil, nil)
				end

				return
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	-- Appending prefix
	finalString ..= prefixString

	--[[ Alias ]]

	do
		-- Incomplete alias
		if #inputData.args == 0 then
			--[[ Getting Goal Alias ]]

			local goalAlias: string
			if state.autoCompletePhrase and table.find(availableAliases, state.autoCompletePhrase) then
				goalAlias = state.autoCompletePhrase
			else
				goalAlias = availableAliases[1]
			end

			-- Getting text missing from completing the alias
			local isMissingTextApplicable: boolean = inputData.alias:lower() == goalAlias:lower():sub(1, #inputData.alias)
			local missingText: string = goalAlias:sub(#inputData.alias + 1)

			--[[ Updating ]]

			finalString ..= `{inputData.alias}`
			if elems["InputBox"]:IsFocused() and isMissingTextApplicable then
				finalString ..= `{I.RichText.Format(missingText, { Transparency = 0.5 })}`
			end

			if not ignoreSuggestions and elems["InputBox"]:IsFocused() then
				shared.Suggestions.SetSuggestions(inputData.command, { Alias = availableAliases })
			end
		else
			-- Alias is finished and the text cursor is on the next argument
			finalString ..= `{inputData.alias}`
		end
	end

	--[[ Arguments ]]

	do
		for i: number, currentArg: string | table in ipairs(inputData.args) do
			--[[ Local Variables ]]

			local argumentId: number = i - variantDepth
			local variantId: number = argumentId + variantDepth

			local isVariant: boolean = argumentId <= 0

			--[[ Displaying Argument ]]

			local parsedArg: string = Module.ParseArgument({
				--[[ General ]]

				i = i,
				arg = currentArg,

				argumentId = argumentId,
				variantId = variantId,
				isVariant = isVariant,

				variantDepth = variantDepth,
				ignoreSuggestions = ignoreSuggestions,

				activeArgIndex = activeArgIndex,

				--[[ Data ]]

				inputData = inputData,

				commandData = commandData,
				variantData = variantData,

				availableVariants = availableVariants or {},
			})

			--[[ Displaying ]]

			local firstBracketIndex: number? = parsedArg:find("<", nil, true)
			local colorPart: string = firstBracketIndex and parsedArg:sub(1, firstBracketIndex - 1)
			local typePart: string = firstBracketIndex and parsedArg:sub(firstBracketIndex, -1)

			local goalColor: string = _settings.ARGS_COLORS[i % _settings.ARGS_COLORS_AMOUNT + 1] or _settings.ARGS_COLORS[0]

			-- Adding parsed arg to the final string
			if colorPart and typePart then
				finalString ..= `{I.RichText.Format(colorPart, { Color = goalColor })}{typePart}`
			else
				finalString ..= `{I.RichText.Format(parsedArg, { Color = goalColor })}`
			end
		end
	end

	--[[ Incoming Arguments ]]

	local argsToDisplay --- @type AdminPanel_CommandBar_CommandDataArgTable
	local variantsToDisplay --- @type { string }

	-- Getting Arguments/Variants
	do
		--%%%%%%%%%%%%%%%%%%%% Find Matching Args And Variants

		--[[
			Finds and saves arguments and variants that are under given variantData.
		]]
		--- @param _variantData AdminPanel_CommandBar_VariantData
		local function findMatchingArgsAndVariants(_variantData)
			-- Setting arguments if they exists
			if _variantData.args then
				argsToDisplay = _variantData.args
			end

			-- Settings variants if arguments are missing
			if not _variantData.args and _variantData.variants and #_variantData.variants >= 1 then
				variantsToDisplay = {}

				--- @param loopVariantData AdminPanel_CommandBar_VariantData
				for _, loopVariantData in ipairs(_variantData.variants) do
					table.insert(variantsToDisplay, loopVariantData.aliases[1])
				end
			end
		end

		if elems["InputBox"]:IsFocused() then
			if variantData and (variantData.args or variantData.variants) then
				--[[ Alias ]]

				if state.autoCompleteType == "Alias" then
					findMatchingArgsAndVariants(variantData)
				end

				--[[ Variant ]]

				if state.autoCompleteType == "Variant" then
					for _, loopVariantData in ipairs(variantData.variants) do
						if table.find(loopVariantData.aliases, state.autoCompletePhrase) then
							findMatchingArgsAndVariants(loopVariantData)
							break
						end
					end
				end

				--[[ Argument ]]

				if state.autoCompleteType == "Argument" then
					findMatchingArgsAndVariants(variantData)
				end

				--[[ Not Selected ]]

				if not state.autoCompleteType then
					findMatchingArgsAndVariants(variantData)
				end
			end
		end
	end

	-- Displaying
	do
		--[[ Variants ]]

		if variantsToDisplay and #variantsToDisplay > 0 then
			-- Displaying single variant
			if #variantsToDisplay == 1 then
				finalString ..= ` {I.RichText.Format(variantsToDisplay[1], { Transparency = 0.5 })}`
			end

			-- Combining all variants
			if #variantsToDisplay > 1 then
				local combinedVariantsText: string = "&lt;"
				combinedVariantsText ..= table.concat(variantsToDisplay, " | ")

				if #combinedVariantsText <= 50 then
					-- Ending combined string
					combinedVariantsText ..= "&gt;"
				else
					-- Cropping
					combinedVariantsText = combinedVariantsText:sub(1, 50)
					combinedVariantsText ..= "..."
				end

				finalString ..= ` {I.RichText.Format(combinedVariantsText, { Transparency = 0.5 })}`
			end
		end

		--[[ Arguments ]]

		if argsToDisplay and #argsToDisplay > 0 then
			local inputtedArgs: number = #inputData.args - variantDepth

			if state.autoCompleteType == "Variant" then
				inputtedArgs -= 1
			end

			--- @param argData string | AdminPanel_CommandBar_CommandDataArgTable
			for i: number, argData in ipairs(argsToDisplay) do
				--[[ Displaying ]]

				if i > inputtedArgs then
					finalString ..= ` {c_utils.GetTypeString(argData)}`
				end
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	do
		--[[ Hiding Suggestions ]]

		if not elems["InputBox"]:IsFocused() then
			shared.Suggestions.SetSuggestions(nil, nil)
		end

		--[[ Updating Display ]]

		elems["InputBox"].Text = inputData.command
		elems["DisplayBox"].Text = finalString

		--[[ Updating Cursor Position ]]

		if isAtTheEnd then
			elems["InputBox"].CursorPosition = #inputData.command + 1
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Parse Argument

--[[
	Accepts table with argument data to parse, then returns that argument as a string with highlights, type hints etc.
]]
--- @param parseData AdminPanel_CommandBar_ArgParseData
--- @return string
function Module.ParseArgument(parseData: table)
	local elems = state.elems
	local dictionaries = state.dictionaries

	--%%%%%%%%%%%%%%%%%%%% Unpacking Data

	--[[ General ]]

	local i: number = parseData.i
	local arg: string | table = parseData.arg

	local variantDepth: number = parseData.variantDepth
	local ignoreSuggestions: boolean = parseData.ignoreSuggestions == true

	local activeArgIndex: number = parseData.activeArgIndex or #parseData.inputData.args

	local argumentId: number = parseData.argumentId
	local variantId: number = parseData.variantId
	local isVariant: boolean = parseData.isVariant

	--[[ Data ]]

	local inputData = parseData.inputData --- @type AdminPanel_CommandBar_InputData

	local commandData = parseData.commandData --- @type AdminPanel_CommandBar_CommandData_Global
	local variantData = parseData.variantData --- @type AdminPanel_CommandBar_VariantData

	local availableVariants = parseData.availableVariants --- @type { string }

	--[[ Table ]]

	local isInTable: boolean = parseData.isInTable == true
	local tableIndex: number | nil = parseData.tableIndex
	local tableArgs: number | nil = parseData.tableArgs
	local tableDepth: number = parseData.tableDepth or 1

	--%%%%%%%%%%%%%%%%%%%% Replace Regions

	--[[
		Replaces regions in text with matching text for the current argument.
	]]
	local function replaceRegions(input: string)
		return c_utils.ReplaceRegions(input, function(key: string, value: string)
			-- invoker
			if key == "invoker" then
				return `{I.Env.LocalPlayer.UserId}`
			end

			-- arg
			if key == "arg" and value ~= nil and tonumber(value) then
				local goalArg: number = i + tonumber(value)
				if not inputData.args[goalArg] then
					return ""
				end

				return inputData.args[goalArg]
			end

			return ""
		end)
	end

	--%%%%%%%%%%%%%%%%%%%% Local Variables

	local finalString: string = ""

	--[[ Arg Data ]]

	local argData = variantData.args and variantData.args[argumentId] --- @type AdminPanel_CommandBar_CommandDataArgTable | nil
	local argTypes = argData and argData.types --- @type { string } | nil
	local acceptTables: boolean = argTypes and table.find(argTypes, "table") ~= nil or false

	--[[ Dictionary ]]

	local dictId: string | nil = argData and argData.dict
	dictId = dictId and replaceRegions(dictId)

	-- Getting dictionary
	local dictData = dictId and dictionaries[dictId]
	local dictReq: boolean = argData and argData.requireDict == true

	-- Negating dictionary
	if argData and dictData and argData.dictNegate then
		--[[ Cloning Dict ]]

		dictData = I.Table.DeepCopy(dictData)

		--[[ Getting Negate Dictionary ]]

		local negateId: string = replaceRegions(argData.dictNegate)
		local dictData_Negate = dictionaries[negateId]

		--[[ Removing From Dictionary ]]

		if dictData_Negate then
			for _, dictElem: string in ipairs(dictData_Negate) do
				local existingPos: number | nil = table.find(dictData, dictElem)
				if existingPos then
					table.remove(dictData, existingPos)
				end
			end
		end
	end

	--[[ Active Checks ]]

	local isArgumentActive: boolean = i == activeArgIndex
	local isTableActive: boolean = true

	-- If argument is in table, check if it's last in that table
	if isInTable then
		isTableActive = tableIndex == tableArgs
	end

	--[[ Valid Checks ]]

	local isValidType: boolean = argData and utils.IsArgValidType(arg, argTypes, inputData.isGlobalCommand)
	local isValidDict: boolean = true
	local isExactDict: boolean = true

	-- Checking if argument is inside dictionary if the dictionary is required (partly for suggestions, exactly for validity)
	if dictReq then
		if dictData then
			isValidDict = c_utils.IsArgInTable(arg, dictData)
			isExactDict = c_utils.IsArgInTable(arg, dictData, true)
		else
			isValidDict = false
			isExactDict = false
		end
	end

	--[[ Other Checks ]]

	local isExcessiveArg: boolean = argumentId > (variantData.args and #variantData.args or (variantData.variants and 1 or 0))
	local canBeVariant: boolean = variantData.variants and #variantData.variants > 0 and variantDepth >= variantId

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	--[[ Excessive Argument ]]

	do
		if isExcessiveArg and not canBeVariant then
			-- Clearing suggestions only for the active arg, otherwise the active arg's suggestions could be wiped
			if not ignoreSuggestions and isArgumentActive then
				shared.Suggestions.SetSuggestions(nil, nil)
			end

			--[[ Table ]]

			if type(arg) == "table" then
				--[[ Data ]]

				-- Getting more detailed data on the current table argument
				local argTableData = inputData.argRanges[i]

				--[[ Table Start ]]

				finalString ..= "{"

				--[[ Table Arguments ]]

				for _i: number, argLoop: string | table in ipairs(arg) do
					finalString ..= Module.ParseArgument({
						--[[ General ]]

						i = i,
						arg = argLoop,

						argumentId = argumentId,
						variantId = variantId,
						isVariant = isVariant,

						variantDepth = variantDepth,
						ignoreSuggestions = ignoreSuggestions,

						activeArgIndex = activeArgIndex,

						--[[ Data ]]

						inputData = inputData,

						commandData = commandData,
						variantData = variantData,

						availableVariants = availableVariants,

						--[[ Table ]]

						isInTable = true,
						tableIndex = _i,
						tableArgs = #arg,
						tableDepth = tableDepth + 1,
					})
				end

				--[[ Table End ]]

				local invertedTableDepth: number = #argTableData - tableDepth + 1
				local isTableClosed: boolean = argTableData and argTableData[invertedTableDepth] and argTableData[invertedTableDepth].ending ~= nil

				-- Closing table
				if isTableClosed then
					-- Getting arg as a plain text
					local plainString: string = c_utils.StripRichTextTags(finalString)

					-- Adding space before closing the table
					if arg[1] == "" or plainString:sub(#plainString) ~= " " then
						finalString ..= " "
					end

					finalString ..= "}"
				end

				--[[ Returning ]]

				return ` {I.RichText.Format(finalString, { Transparency = 0.65 })}`
			end

			--[[ String ]]

			if arg == "" then
				return ""
			else
				return ` {I.RichText.Format(arg, { Transparency = 0.65 })}`
			end
		end
	end

	--[[ Table Argument ]]

	do
		if type(arg) == "table" then
			--[[ Data ]]

			-- Getting more detailed data on the current table argument
			local argTableData = inputData.argRanges[i]
			local typeString = not isInTable and argData and isArgumentActive and ` {c_utils.GetTypeString(argData)}` or ""

			--[[ Table Start ]]

			finalString ..= "{"

			--[[ Table Arguments ]]

			for _i: number, argLoop: string | table in ipairs(arg) do
				finalString ..= Module.ParseArgument({
					--[[ General ]]

					i = i,
					arg = argLoop,

					argumentId = argumentId,
					variantId = variantId,
					isVariant = isVariant,

					variantDepth = variantDepth,
					ignoreSuggestions = ignoreSuggestions,

					activeArgIndex = activeArgIndex,

					--[[ Data ]]

					inputData = inputData,

					commandData = commandData,
					variantData = variantData,

					availableVariants = availableVariants,

					--[[ Table ]]

					isInTable = true,
					tableIndex = _i,
					tableArgs = #arg,
					tableDepth = tableDepth + 1,
				})
			end

			--[[ Table End ]]

			local invertedTableDepth: number = #argTableData - tableDepth + 1
			local isTableClosed: boolean = argTableData and argTableData[invertedTableDepth] and argTableData[invertedTableDepth].ending ~= nil

			-- Closing table
			if isTableClosed then
				-- Getting arg as a plain text
				local plainString: string = c_utils.StripRichTextTags(finalString)

				-- Adding space before closing the table
				if arg[1] == "" or plainString:sub(#plainString) ~= " " then
					finalString ..= " "
				end

				finalString ..= "}"

				-- Clearing suggestions if the last table is closed
				if isArgumentActive and isTableActive then
					if not ignoreSuggestions then
						shared.Suggestions.SetSuggestions(nil, nil)
					end
				end
			else
				-- Closing unclosed table
				finalString ..= I.RichText.Format(" }", { Transparency = 0.5 })
			end

			--[[ Returning ]]

			if acceptTables then
				-- Success: Table is valid
				return ` {finalString}{typeString}`
			else
				if not ignoreSuggestions then
					shared.Suggestions.SetSuggestions(nil, nil)
				end

				-- Error: Table is not accepted as a argument
				return ` {I.RichText.Format(finalString, { Color = _settings.COLORS.Error })}{typeString}`
			end
		end
	end

	--[[ String Argument - Active ]]

	-- `nil` argument
	do
		if arg == "nil" and argData and argData.optional and not isInTable then
			--[[ Data ]]

			local typeString: string = not isInTable and argData and ` {c_utils.GetTypeString(argData)}` or ""
			local availableArguments = (isValidDict and dictData) and c_utils.GetMatchingArgs(arg, dictData) or {} --- @type { string }

			-- Clearing if Command Bar is not focused
			if not elems["InputBox"]:IsFocused() then
				typeString = ""
			end

			-- Displaying nil argument
			if availableArguments and not table.find(availableArguments, "nil") or not argData.requireDict then
				if isArgumentActive and isTableActive then
					-- Active arg has no suggestions; ensure stale ones are cleared
					if not ignoreSuggestions and elems["InputBox"]:IsFocused() then
						shared.Suggestions.SetSuggestions(nil, nil)
					end

					return ` {I.RichText.Format("nil", { Transparency = 0.5 })}{typeString}`
				else
					return ` {I.RichText.Format("nil", { Transparency = 0.5 })}`
				end
			end
		end
	end

	-- Existing argument
	do
		if isArgumentActive and isTableActive then
			--[[ Data ]]

			local typeString: string = not isInTable and argData and ` {c_utils.GetTypeString(argData)}` or ""
			local availableArguments = (isValidDict and dictData) and c_utils.GetMatchingArgs(arg, dictData) or {}
			local shouldDictUpdate: boolean = dictData ~= nil or #availableVariants > 0

			-- Clearing if Command Bar is not focused
			if not elems["InputBox"]:IsFocused() then
				typeString = ""
			end

			--%%%%%%%%%%%%%%%%%%%% Dictionary Update

			if shouldDictUpdate then
				--[[ Suggestions Exists ]]

				if availableArguments[1] or availableVariants[1] then
					-- Updating Suggestions
					if not ignoreSuggestions and elems["InputBox"]:IsFocused() then
						shared.Suggestions.SetSuggestions(inputData.command, { Variant = availableVariants, Argument = availableArguments })
					end

					-- Updating Display
					if #arg >= 1 then
						--[[ Getting Goal Alias ]]

						local doesPhraseExistsInCurrentTables: boolean = state.autoCompletePhrase
							and (table.find(availableArguments, state.autoCompletePhrase) ~= nil or table.find(availableVariants, state.autoCompletePhrase) ~= nil)

						local goalAlias: string
						if doesPhraseExistsInCurrentTables then
							goalAlias = state.autoCompletePhrase
						else
							goalAlias = availableVariants[1] or availableArguments[1]
						end

						-- Getting text missing from completing the argument
						local isMissingTextApplicable: boolean = arg:lower() == goalAlias:lower():sub(1, #arg)
						local missingText: string = goalAlias:sub(#arg + 1)

						--[[ Updating ]]

						-- Show suggestion text
						if state.autoCompleteType == "Variant" then
							finalString ..= ` {arg}{elems["InputBox"]:IsFocused() and isMissingTextApplicable and I.RichText.Format(missingText, { Transparency = 0.5 }) or ""}{debugIdx("1")}`
						else
							finalString ..= ` {arg}{elems["InputBox"]:IsFocused() and isMissingTextApplicable and I.RichText.Format(missingText, { Transparency = 0.5 }) or ""}{typeString}{debugIdx("2")}`
						end
					else
						if state.autoCompletePhrase then
							-- Argument is empty but suggestions were found
							if state.autoCompleteType == "Variant" then
								finalString ..= ` {elems["InputBox"]:IsFocused() and I.RichText.Format(state.autoCompletePhrase, { Transparency = 0.5 }) or ""}{debugIdx("3")}`
							else
								finalString ..= ` {elems["InputBox"]:IsFocused() and I.RichText.Format(state.autoCompletePhrase, { Transparency = 0.5 }) or ""}{typeString}{debugIdx("4")}`
							end
						end
					end
				end

				--[[ Suggestions Missing ]]

				if not availableArguments[1] and not availableVariants[1] then
					-- If argument is of valid type
					if isValidType then
						if dictReq then
							if inputData.isGlobalCommand and table.find(argTypes, "Player") then
								-- Valid type -> Suggestion is missing, but player can be on different server.
								finalString ..= ` {arg}{typeString}{debugIdx("5")}`
							else
								-- Invalid type -> Suggestion were not found while it's required
								finalString ..= ` {I.RichText.Format(arg, { Color = _settings.COLORS.Error })}{typeString}{debugIdx("6")}`
							end
						else
							-- Valid type / Dictionary not required -> Valid argument
							finalString ..= ` {arg}{typeString}{debugIdx("7")}`
						end
					else
						-- Invalid type
						finalString ..= ` {I.RichText.Format(arg, { Color = _settings.COLORS.Error })}{typeString}{debugIdx("8")}`
					end

					-- Clearing suggestions
					if not ignoreSuggestions and elems["InputBox"]:IsFocused() then
						shared.Suggestions.SetSuggestions(nil, nil)
					end
				end
			end

			--%%%%%%%%%%%%%%%%%%%% Non Dictionary Update

			if not shouldDictUpdate then
				-- Dictionary is required, but no valid ones were found
				if dictReq then
					-- Invalid dictionary
					if not isInTable then
						finalString ..= ` {I.RichText.Format(arg, { Color = _settings.COLORS.Error })}{typeString}{debugIdx("9")}`
					else
						-- Update invalid type in table only if the argument exists to not make the table too wide
						if arg ~= "" then
							finalString ..= ` {I.RichText.Format(arg, { Color = _settings.COLORS.Error })}{debugIdx("10")}`
						end
					end
				end

				-- Dictionary is not required so validate only argument type
				if not dictReq then
					if isValidType then
						-- Valid type
						finalString ..= ` {arg}{typeString}{debugIdx("11")}`
					else
						-- Invalid type
						finalString ..= ` {I.RichText.Format(arg, { Color = _settings.COLORS.Error })}{typeString}{debugIdx("12")}`
					end
				end

				-- Clearing suggestions
				if not ignoreSuggestions and elems["InputBox"]:IsFocused() then
					shared.Suggestions.SetSuggestions(nil, nil)
				end
			end
		end
	end

	--[[ String Argument - Non Active ]]

	do
		if not isArgumentActive or not isTableActive then
			--[[ Variant ]]

			if isVariant then
				--[[
					If `isVariant` is set to true, then we're certain that the variant is valid.
				]]
				finalString ..= ` {arg}{debugIdx("13")}`
			end

			--[[ Argument ]]

			if not isVariant then
				if isValidType and isExactDict then
					-- Success: Argument is valid
					finalString ..= ` {arg}{debugIdx("14")}`
				else
					if inputData.isGlobalCommand and argTypes and table.find(argTypes, "Player") then
						-- Argument is currently invalid, but the player we type can be on a different server
						finalString ..= ` {arg}{debugIdx("15")}`
					else
						-- Error: Argument is invalid
						finalString ..= ` {I.RichText.Format(arg, { Color = _settings.COLORS.Error })}{debugIdx("16")}`
					end
				end
			end

			-- Clearing suggestions only when the active arg sits in an inactive table position;
			-- otherwise this branch belongs to a non-active arg and must not touch suggestions.
			if not ignoreSuggestions and isArgumentActive and elems["InputBox"]:IsFocused() then
				shared.Suggestions.SetSuggestions(nil, nil)
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	--[[ Returning ]]

	local plainText = c_utils.StripRichTextTags(finalString)
	if plainText == "" or plainText == " " then
		return ""
	else
		return finalString
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
