--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local UserInputService = I.S.UserInputService

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

--- @class AdminPanel_CommandBar_ClientUtils
local Client_Utils = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% General Functions

--%%%%%%%%%%%%%%%%%%%% Get Current Time With Milliseconds

--[[
	Returns the local time with milliseconds, as `HH:mm:ss.mmm`.
]]
--- @return string
function Client_Utils.GetCurrentTimeWithMilliseconds()
	--[[ Getting Time ]]

	local now: DateTime = DateTime.now()
	local milliseconds: number = now.UnixTimestampMillis % 1000

	--[[ Returning ]]

	return `{I.Date.UnixToDateLocal(now.UnixTimestamp, "HH:mm:ss")}.{string.format("%03d", milliseconds)}`
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Text Functions

--%%%%%%%%%%%%%%%%%%%% Replace Regions

--[[
	Regions replacer function for dictionary matching.
]]
--- @param replacer (key: string, value: string) -> ()
--- @return string
function Client_Utils.ReplaceRegions(str: string, replacer)
	return string.gsub(str, "%$|(.-)#|", function(region: string)
		local parts: { string } = string.split(region, ":")
		return replacer(parts[1], parts[2])
	end)
end

--%%%%%%%%%%%%%%%%%%%% Convert Table To String

--[[
    Accepts table and converts all strings/tables inside of it into a one string.
]]
--- @return string
function Client_Utils.ConvertTableToString(input: table)
	--[[ Local Variables ]]

	local toReturn = "{"
	local isFirst = true

	--[[ Converting Table ]]

	for entryName: string, entryValue: any in pairs(input) do
		local entryType: string = type(entryValue)

		--[[ Table Convert ]]

		if type(entryValue) == "table" then
			if isFirst then
				isFirst = false
				toReturn ..= ` {entryName}: {Client_Utils.ConvertTableToString(entryValue)}`
			else
				toReturn ..= `, {entryName}: {Client_Utils.ConvertTableToString(entryValue)}`
			end

			continue
		end

		--[[ String/Other Convert ]]

		if entryType ~= "table" then
			if entryType == "string" then
				entryValue = `"{entryValue}"`
			else
				entryValue = `{entryValue}`
			end
			entryValue = string.gsub(entryValue, "<", "&lt;")
			entryValue = string.gsub(entryValue, ">", "&gt;")

			if isFirst then
				isFirst = false
				toReturn ..= ` ["{entryName}"] = {entryValue}`
			else
				toReturn ..= `, ["{entryName}"] = {entryValue}`
			end
		end
	end

	--[[ Closing and Returnning ]]

	toReturn ..= " }"
	return toReturn
end

--%%%%%%%%%%%%%%%%%%%% Apply Custom Formatting

--[[
	Accepts string with custom formatting and applies colors to it.
]]
--- @return string
function Client_Utils.ApplyCustomFormatting(input: string)
	--[[ Cleaning ]]

	input = `{input}`
	input = string.gsub(input, "^[ \t]+", "") -- Remove leading spaces/tabs
	input = string.gsub(input, "%s+", " ") -- Normalize whitespace

	--[[ Local Variables ]]

	local results = {} --- @type { string } | { table }

	local inSection: boolean = false
	local textBuffer: string = ""
	local modifiers = {} --- @type { string }

	--%%%%%%%%%%%%%%%%%%%% Parsing

	local i = 1
	while i <= #input do
		local c: string = input:sub(i, i)

		--%%%%%%%%%%%%%%%%%%%% Section Start: $|

		if not inSection and c == "$" then
			local nextTwo: string = input:sub(i, i + 1)

			-- Entering Section
			if nextTwo == "$|" then
				-- Saving buffered text
				if textBuffer ~= "" then
					table.insert(results, textBuffer)
					textBuffer = ""
				end

				-- Entering section and skipping '$|'
				inSection = true
				i += 2

				continue
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Modifier: $|

		if inSection and c == "$" then
			local nextTwo: string = input:sub(i, i + 1)

			-- Saving modifier
			if nextTwo == "$|" then
				if textBuffer ~= "" then
					table.insert(modifiers, textBuffer)
					textBuffer = ""
				end

				i += 2

				continue
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Section End: #|

		if inSection and c == "#" then
			local nextTwo: string = input:sub(i, i + 1)

			-- Leaving Section
			if nextTwo == "#|" then
				local entry = { Text = textBuffer }

				-- Saving modifiers
				for _, mod: string in ipairs(modifiers) do
					-- Styles
					if mod == "b" then
						entry.Bold = true
						continue
					end
					if mod == "i" then
						entry.Italic = true
						continue
					end
					if mod == "u" then
						entry.Underline = true
						continue
					end
					if mod == "s" then
						entry.Strikethrough = true
						continue
					end

					-- Color logic
					if mod:match("^c") then
						entry.Color = mod:sub(2)
						continue
					end

					-- Transparency
					if mod:match("^t") then
						entry.Transparency = tonumber(mod:sub(2)) or 0
						continue
					end

					-- Mark color / transparency
					if mod:match("^mc") then
						entry.Mark_Color = mod:sub(3)
						continue
					end
					if mod:match("^mt") then
						entry.Mark_Transparency = tonumber(mod:sub(3)) or 0
						continue
					end
				end

				-- Saving entry and clearing buffer/mods
				table.insert(results, entry)
				textBuffer = ""
				table.clear(modifiers)

				-- Leaving section and skipping '#|'
				inSection = false
				i += 2

				continue
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Normal Character

		-- Saving and continuing
		textBuffer ..= c
		i += 1
	end

	-- Pushing last raw text or entirity of unclosed section
	if textBuffer ~= "" or inSection then
		if not inSection then
			table.insert(results, textBuffer)
		else
			table.insert(results, `$|{table.concat(modifiers, "$|")}$|{textBuffer}`)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Fixing Colors

	local previousColors = {
		Color = nil, --- @type number
		Mark_Color = nil, --- @type number
	}

	for _, loopElem: string | table in ipairs(results) do
		-- Skip if raw text
		if type(loopElem) == "string" then
			continue
		end

		--%%%%%%%%%%%%%%%%%%%% Updating Modifiers

		--[[ Font Color ]]

		if loopElem.Color then
			--[[ Random Color ]]

			if loopElem.Color == "r" then
				-- Setting color to index of the next available color
				local nextColorIndex: number = (previousColors.Color or 0) % #_settings.OUTPUT_DYNAMIC_COLORS + 1
				loopElem.Color = `{nextColorIndex}`
			end

			--[[ Indexed Color ]]

			if tonumber(loopElem.Color) then
				local colorIndex: number = tonumber(loopElem.Color)
				local isInRange: boolean = _settings.OUTPUT_DYNAMIC_COLORS[colorIndex] and colorIndex <= #_settings.OUTPUT_DYNAMIC_COLORS

				-- Saving index of the current color
				if isInRange then
					previousColors.Color = colorIndex
				end
			end
		end

		--[[ Mark Color ]]

		if loopElem.Mark_Color then
			--[[ Random Color ]]

			if loopElem.Mark_Color == "r" then
				-- Setting color to index of the next available color
				local nextColorIndex: number = (previousColors.Mark_Color or 0) % #_settings.OUTPUT_DYNAMIC_MARK_COLORS + 1
				loopElem.Mark_Color = `{nextColorIndex}`
			end

			--[[ Indexed Color ]]

			if tonumber(loopElem.Mark_Color) then
				local colorIndex: number = tonumber(loopElem.Mark_Color)
				local isInRange: boolean = _settings.OUTPUT_DYNAMIC_MARK_COLORS[colorIndex] and colorIndex <= #_settings.OUTPUT_DYNAMIC_MARK_COLORS

				-- Saving index of the current color
				if isInRange then
					previousColors.Mark_Color = colorIndex
				end
			end
		end
	end

	---%%%%%%%%%%%%%%%%%%%% Formatting String

	local finalString: string = ""

	for _, loopElem: string | table in ipairs(results) do
		-- Append raw string
		if type(loopElem) == "string" then
			finalString ..= loopElem
			continue
		end

		-- Converting Colors
		loopElem.Color = _settings.OUTPUT_DYNAMIC_COLORS[tonumber(loopElem.Color)] or _settings.OUTPUT_DYNAMIC_COLORS[loopElem.Color]
		loopElem.Mark_Color = _settings.OUTPUT_DYNAMIC_MARK_COLORS[tonumber(loopElem.Mark_Color)] or _settings.OUTPUT_DYNAMIC_MARK_COLORS[loopElem.Mark_Color]

		-- Appending formatted text
		finalString ..= I.RichText.Format(loopElem.Text, loopElem)
	end

	--%%%%%%%%%%%%%%%%%%%% Returning

	return finalString
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Text Cleanup Functions

--%%%%%%%%%%%%%%%%%%%% Strip RichText Tags

--[[
	Returns text without its RichText tags.
]]
--- @return string
function Client_Utils.StripRichTextTags(input: string)
	return input:gsub("<[^>]->", "")
end

--%%%%%%%%%%%%%%%%%%%% Trim Quotes

--[[
	Trims quotes from start and end of the string.
]]
--- @return string
function Client_Utils.TrimQuotes(input: string)
	if type(input) == "string" and input:sub(1, 1) == '"' and input:sub(-1) == '"' then
		return input:sub(2, -2)
	end
	return input
end

--%%%%%%%%%%%%%%%%%%%% Trim Quotes In Table

--[[
	Trims strings from quotes in the given table.
]]
--- @return AdminPanel_CommandBar_TrimmedTable
function Client_Utils.TrimQuotesInTable(input: table)
	-- Return if string is inputted
	if type(input) ~= "table" then
		return Client_Utils.TrimQuotes(`{input}`)
	end

	--[[ Trimming Table Items ]]

	--- @type AdminPanel_CommandBar_TrimmedTable
	local stripped = {}

	--- @param value string | AdminPanel_CommandBar_TrimmedTable
	for key: string, value in pairs(input) do
		local newKey: string = type(key) == "string" and Client_Utils.TrimQuotes(key) or key
		stripped[newKey] = type(value) == "table" and Client_Utils.TrimQuotesInTable(value) or Client_Utils.TrimQuotes(value)
	end

	--[[ Returning ]]

	return stripped
end

--%%%%%%%%%%%%%%%%%%%% Trim From Toggle Keys

--[[
	Removes characters from keys used to open the command bar from given string.
]]
--- @return string
function Client_Utils.TrimFromToggleKeys(input: string)
	-- Return if string is empty
	if #input == 0 then
		return input
	end

	--[[ Local Variables ]]

	local done = false

	--[[ Trimmming Command ]]

	repeat
		done = true
		for _, keyCode: Enum.KeyCode in ipairs(_settings.COMMAND_BAR_KEYS) do
			local keyString: string = UserInputService:GetStringForKeyCode(keyCode)

			-- Skip empty key strings to prevent infinite loop
			if keyString == "" then
				continue
			end

			-- Skip if key is a part of any alias
			if string.find(_settings.PREFIX, keyString, 1, true) or string.find(_settings.GLOBAL_PREFIX, keyString, 1, true) then
				continue
			end

			-- Removing character
			if input:sub(1, #keyString) == keyString then
				input = input:sub(#keyString + 1)
				done = false -- Input changed -> reset loop
				break
			end
		end
	until done

	--[[ Returning ]]

	return input
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Command Cleanup Functions

--%%%%%%%%%%%%%%%%%%%% Cleanup Command

--[[
	Cleanups the given command string by removing all unwanted characters, long whitespaces and makes the command tokens ready to be parsed.
]]
--- @return string
function Client_Utils.CleanupCommand(input: string)
	--[[ Cleaning ]]

	input = string.gsub(input, "^[ \t]+", "") -- Removing spaces and tabs from start
	input = string.gsub(input, "%s+", " ") -- Removing whitespaces

	input = input:gsub("[<>]", "")

	input = Client_Utils.TrimFromToggleKeys(input)

	--[[ Local Variables ]]

	local finalString: string = ""
	local cPrev: string = ""
	local stringMode: boolean = false

	local tablesOpened: number = 0
	local tablesClosed: number = 0

	--[[ Cleaning ]]

	for i = 1, #input do
		local c: string = input:sub(i, i)
		local cNext: string = input:sub(i + 1, i + 1)
		local addspaceAfter = false

		--[[ Checks ]]

		-- Toggling string mode
		if c == '"' then
			stringMode = not stringMode
		end

		-- Skip to avoid stacking spaces
		if not stringMode and cPrev == " " and c == " " then
			continue
		end

		--[[ Opened Tables ]]

		if not stringMode and c == "{" then
			tablesOpened += 1
		end

		if not stringMode and c == "}" then
			if tablesOpened >= tablesClosed + 1 then
				tablesClosed += 1
			else
				continue
			end
		end

		--[[ Table Checks ]]

		-- Adding space after table start
		if not stringMode and c == "{" and cNext and cNext ~= " " and cNext ~= "" then
			addspaceAfter = true
		end

		-- Adding space after table end
		if not stringMode and c == "}" and cPrev ~= " " then
			finalString ..= " "
		end

		-- Adding space before table
		if not stringMode and c == "{" and cPrev and cPrev ~= " " then
			finalString ..= " "
		end

		-- Adding space after table
		if not stringMode and cPrev == "}" and c ~= " " then
			finalString ..= " "
		end

		--[[ Updating ]]

		cPrev = c
		finalString ..= c

		if addspaceAfter then
			cPrev = " "
			finalString ..= " "
		end
	end

	return finalString
end

--%%%%%%%%%%%%%%%%%%%% Sanitize Table Spaces

--[[
	Removes whitespaces at the start and at the end of a table.
]]
--- @return string
function Client_Utils.SanitizeTableSpaces(input: string)
	--[[ Local Variables ]]

	local finalString: string = ""
	local cPrev: string = ""
	local stringMode: boolean = false

	--[[ Cleaning ]]

	for i = 1, #input do
		local c: string = input:sub(i, i)
		local cNext = input:sub(i + 1, i + 1)

		--[[ Checks ]]

		-- Toggling string mode
		if c == '"' then
			stringMode = not stringMode
		end

		--[[ Table Checks ]]

		-- Skip if in table
		if not stringMode and cPrev == "{" and c == " " then
			continue
		end
		if not stringMode and cNext == "}" and c == " " then
			continue
		end

		--[[ Updating ]]

		cPrev = c
		finalString ..= c
	end

	return finalString
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Command Functions

--%%%%%%%%%%%%%%%%%%%% Get Command Tokens

--[[
	Accepts string and returns all tokens/tables inside of it, with their start and end position in the string.
]]
--- @return { string } | { AdminPanel_CommandBar_TokenGroup }
function Client_Utils.GetCommandTokens(input: string)
	--[[ Local Variables ]]

	local stack = {} --- @type { AdminPanel_CommandBar_TokenStack }
	local result = {} --- @type { string } | { AdminPanel_CommandBar_TokenGroup }

	local currentTextStart: number? = nil
	local currentGroup = nil --- @type AdminPanel_CommandBar_TokenGroup?

	local skippingAlias: boolean = true
	local stringMode: boolean = false

	--[[ Local Functions ]]

	--[[
		Saves selected text range as a token.
	]]
	local function saveToken(upTo: number)
		if not currentTextStart then
			return
		end

		-- Getting token
		local token: string = input:sub(currentTextStart, upTo)

		--[[ Saving ]]

		-- If token is not empty
		if token:match("%S") then
			if skippingAlias then
				skippingAlias = false -- skip alias
			else
				table.insert(result, token)
			end
		end

		currentTextStart = nil
	end

	--[[ Counting Tokens ]]

	for i = 1, #input do
		local c: string = input:sub(i, i)

		--[[ Checks ]]

		-- Toggling string mode
		if c == '"' then
			stringMode = not stringMode
		end

		-- Skip for strings
		if stringMode then
			continue
		end

		--[[ Table Checks ]]

		-- Table start
		if c == "{" then
			-- Starting new group of nested tables
			if #stack == 0 then
				saveToken(i - 1) -- Saving previous token
				currentGroup = {}
			end

			-- Saving table depth and starting position
			table.insert(stack, {
				start = i,
				depth = #stack + 1,
			})

			continue
		end

		-- Table end
		if c == "}" then
			-- Getting last brace position
			local top: table = table.remove(stack)

			if top then
				-- Creating and saving table info
				local tableInfo = {
					start = top.start,
					ending = i,
					depth = top.depth,
				}
				table.insert(currentGroup, tableInfo)

				-- Saving if it was top-level group
				if #stack == 0 then
					table.insert(result, currentGroup)
					currentGroup = nil
				end
			end

			continue
		end

		-- Plain text
		if #stack == 0 then
			if c:match("%S") and not currentTextStart then
				-- Start new text token
				currentTextStart = i
			elseif c:match("%s") and currentTextStart then
				-- End of text token
				saveToken(i - 1)
			end
		end
	end

	-- Save any unclosed token
	saveToken(#input)

	-- Handle unclosed table
	if #stack > 0 and currentGroup then
		for _, unclosed in ipairs(stack) do
			table.insert(currentGroup, {
				start = unclosed.start,
				ending = nil,
				depth = unclosed.depth,
			})
		end
		table.insert(result, currentGroup)
	end

	return result
end

--%%%%%%%%%%%%%%%%%%%% Clear Args Table

--[[
	Recurvise clearing all empty arguments from tables.
]]
function Client_Utils.ClearArgsTable(t: table)
	if #t == 1 and t[1] == "" then
		-- Clearing Table
		t[1] = nil
	else
		for i: number = #t, 1, -1 do -- Reverse loop to avoid index shifting
			if type(t[i]) == "table" then
				Client_Utils.ClearArgsTable(t[i])
			elseif t[i] == "" then
				table.remove(t, i)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Parse Tokens

--[[
	Parses input into a nested table of tokens/arguments.
]]
--- @return { AdminPanel_CommandBar_ParsedArg }
--- @return number
function Client_Utils.ParseTokens(input: string, index: number)
	-- Sanitizing input
	input = Client_Utils.SanitizeTableSpaces(input)

	--%%%%%%%%%%%%%%%%%%%% Local Variables

	local result = {}
	local token: string = ""

	local stringMode: boolean = false

	--%%%%%%%%%%%%%%%%%%%% Parsing

	while index <= #input do
		local c: string = input:sub(index, index)

		--[[ String Mode ]]

		-- Toggling string mode
		if c == '"' then
			stringMode = not stringMode
		end

		-- Adding characters if in string
		if stringMode then
			token ..= c

			index += 1
			continue
		end

		--[[ Checks ]]

		-- Table start
		if c == "{" then
			-- Getting all tokens inside the table
			local subTable
			subTable, index = Client_Utils.ParseTokens(input, index + 1)

			-- Saving table result
			table.insert(result, subTable)

			index += 1
			continue
		end

		-- Table end
		if c == "}" then
			-- Saving last token
			table.insert(result, token)
			return result, index
		end

		-- Token separator
		if c == " " then
			-- Saving if current token is not empty
			if token ~= "" then
				table.insert(result, token)
				token = ""
			end

			index += 1
			continue
		end

		-- Regular character
		if c ~= " " then
			token ..= c

			index += 1
			continue
		end
	end

	-- Saving last unclosed token
	if token ~= "" then
		table.insert(result, token)
	end

	--%%%%%%%%%%%%%%%%%%%% Last Token

	local lastToken: string | table = result[#result]
	local isLastTokenTable: boolean = type(lastToken) == "table"
	local isLastCharSpace: boolean = input:sub(-1) == " "

	-- Last character is a whitespace - proceeding to the next argument
	if isLastCharSpace and not isLastTokenTable then
		table.insert(result, "")
	end

	--%%%%%%%%%%%%%%%%%%%% Table Control

	-- Last token is a table - removing empty last argument from it
	if isLastTokenTable then
		local isTableClosed = input:gsub("%s+", ""):sub(-1) == "}"

		if isTableClosed then
			-- Clearing table if the only argument is empty
			if lastToken[1] and lastToken[1] == "" then
				lastToken[1] = nil
			end

			-- Adding empty argument after table to display next suggestions
			table.insert(result, "")
		end
	end

	-- Recursive clearing all empty tables
	for i = 1, #result do
		if type(result[i]) == "table" then
			Client_Utils.ClearArgsTable(result[i])
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Unclosed Table

	stringMode = false
	local tablesOpened: number = 0
	local tablesClosed: number = 0

	-- Counting tables
	for i = 1, #input do
		local c: string = input:sub(i, i)

		-- Toggling string mode
		if c == '"' then
			stringMode = not stringMode
			continue
		end

		-- Saving tables count
		if not stringMode then
			if c == "{" then
				tablesOpened += 1
			end
			if c == "}" then
				tablesClosed += 1
			end
		end
	end

	-- If there are more tables opened than closed
	if tablesOpened > tablesClosed then
		-- Clear last argument if it's empty bcs it cannot exists if the tables are opened
		if result[#result] == "" then
			table.remove(result, #result)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Populating Last Unlosed Table

	if isLastTokenTable then
		local currentDepth: number = 1
		local maxDepth: number = tablesOpened - tablesClosed
		local lastTable: string | table = result[#result]

		local stop: boolean = false
		repeat
			-- Stop if exceeded depth
			if currentDepth > maxDepth then
				stop = true
			end

			-- Stop if active argument isn't a table
			if type(lastTable) ~= "table" then
				stop = true
				break
			end

			-- Reached max depth
			if currentDepth == maxDepth then
				stop = true

				-- Adding empty argument to display suggestions
				local lastElem: table? = lastTable[#lastTable]
				if not lastElem or type(lastElem) == "table" or isLastCharSpace then
					table.insert(lastTable, "")
				end

				break
			end

			-- Getting last elem from current table
			local newLastTable: table? = lastTable[#lastTable]

			-- Saving table and continuing the loop
			if type(newLastTable) == "table" then
				lastTable = newLastTable
				currentDepth += 1
			else
				stop = true
				break
			end

		until stop
	end

	--%%%%%%%%%%%%%%%%%%%% Returning

	return result, index
end

--%%%%%%%%%%%%%%%%%%%% Get Input Data

--[[
	Turns command into a InputData table.
]]
--- @param aliases { [string]: AdminPanel_CommandBar_CommandData_Global }
--- @return AdminPanel_CommandBar_InputData
function Client_Utils.GetInputData(command: string, aliases)
	-- Sanitizing
	command = Client_Utils.CleanupCommand(command)

	--%%%%%%%%%%%%%%%%%%%% Prefix Checks

	local cleared: string = command

	-- Global Command
	local isGlobalCommand: boolean = cleared:sub(1, #_settings.GLOBAL_PREFIX) == `{_settings.GLOBAL_PREFIX}`
	if isGlobalCommand then
		cleared = cleared:sub(#_settings.GLOBAL_PREFIX + 1)
	end

	-- Standard Command
	local isCommand: boolean = cleared:sub(1, #_settings.PREFIX) == `{_settings.PREFIX}`
	cleared = isCommand and cleared:sub(#_settings.PREFIX + 1)

	--%%%%%%%%%%%%%%%%%%%% Getting Arguments

	local args: { string }, argsToSend: { string }, _i: number
	if isCommand then
		args, _i = Client_Utils.ParseTokens(cleared, 1)
		argsToSend = Client_Utils.TrimQuotesInTable(I.Table.DeepCopy(args))
	end

	-- Getting arg ranges used to determine their length and depth
	local argRanges: {} = isCommand and Client_Utils.GetCommandTokens(cleared)

	-- Making sure first argument always exists
	if isCommand and not args[1] then
		args[1] = ""
		argsToSend[1] = ""
	end

	--%%%%%%%%%%%%%%%%%%%% Getting Alias

	local alias: string = isCommand and args[1]
	if isCommand then
		table.remove(args, 1) -- Removing alias form arguments
		table.remove(argsToSend, 1) -- Removing alias form arguments
	end

	--%%%%%%%%%%%%%%%%%%%% Prefix Length

	local prefixLength: number = #_settings.PREFIX
	local globalPrefixLength: number = isGlobalCommand and #_settings.GLOBAL_PREFIX or 0
	local totalPrefixLength: number = prefixLength + globalPrefixLength

	--%%%%%%%%%%%%%%%%%%%% Getting Command Data

	local commandData = aliases[alias] --- @type AdminPanel_CommandBar_CommandData_Global
	local variantData = commandData and commandData.baseVariant --- @type AdminPanel_CommandBar_VariantData

	local previousVariantData = variantData --- @type AdminPanel_CommandBar_VariantData

	--[[ Getting Variant ]]

	local variantDepth: number = 1
	if commandData and variantData and #args >= 1 then
		while true do
			-- Stop searching if command has no variants
			if not variantData.variants then
				break
			end

			-- Stop if end is reached
			if args[variantDepth] == nil then
				break
			end

			-- Saving matching variant and searching for the next one
			local variantChanged: boolean = false

			--- @param loopVariantData AdminPanel_CommandBar_VariantData
			for _, loopVariantData in ipairs(variantData.variants) do
				if table.find(loopVariantData.aliases, args[variantDepth]) then
					previousVariantData = variantData
					variantData = loopVariantData
					variantDepth += 1
					variantChanged = true
					break
				end
			end

			if not variantChanged then
				break
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Returning

	return {
		command = command,
		cleared = cleared,
		alias = alias,

		isCommand = isCommand,
		isGlobalCommand = isGlobalCommand,

		commandData = commandData,
		variantData = variantData,
		previousVariantData = previousVariantData,
		variantDepth = variantDepth,

		args = args,
		argsToSend = argsToSend,
		argRanges = argRanges,

		prefixLength = prefixLength,
		globalPrefixLength = globalPrefixLength,
		totalPrefixLength = totalPrefixLength,
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Active Arg Index At Cursor

--[[
	Returns the top-level argument index in `inputData.args` that the cursor is currently positioned over.
	Returns `0` when the cursor is over the prefix or the alias.
	Top-level brace groups and quoted strings are treated as a single argument.
]]
--- @param inputData AdminPanel_CommandBar_InputData
--- @return number
function Client_Utils.GetActiveArgIndexAtCursor(inputData, cursorPos: number)
	--[[ Local Variables ]]

	local cleared: string = inputData.cleared or ""
	local prefixLen: number = inputData.totalPrefixLength or 0

	-- Cursor offset within `cleared` (0-based: 0 = start of cleared)
	local offset: number = cursorPos - 1 - prefixLen

	-- Cursor is in or before prefix
	if offset <= 0 then
		return 0
	end

	--[[ Walking Tokens ]]

	local tokens: { { start: number, ending: number } } = {}

	local currentTokenStart: number? = nil
	local braceDepth: number = 0
	local stringMode: boolean = false

	for i = 1, #cleared do
		local c: string = cleared:sub(i, i)

		-- String mode toggle
		if c == '"' then
			stringMode = not stringMode

			if not currentTokenStart then
				currentTokenStart = i
			end

		-- Top-level space is a separator
		elseif not stringMode and c == " " and braceDepth == 0 then
			if currentTokenStart then
				table.insert(tokens, { start = currentTokenStart, ending = i - 1 })
				currentTokenStart = nil
			end

		-- Regular character (including braces)
		else
			if not currentTokenStart then
				currentTokenStart = i
			end

			if not stringMode and c == "{" then
				braceDepth += 1
			elseif not stringMode and c == "}" then
				braceDepth = math.max(0, braceDepth - 1)
			end
		end
	end

	-- Trailing token
	if currentTokenStart then
		table.insert(tokens, { start = currentTokenStart, ending = #cleared })
	end

	--[[ Locating Cursor In Tokens ]]

	-- `offset` is the index of the character the cursor is positioned right after.
	-- Cursor at `start - 1` sits right before the token, cursor at `ending` sits right after its last char;
	-- both should count as belonging to that token.
	for tokenIdx: number, tokenRange in ipairs(tokens) do
		if offset >= tokenRange.start - 1 and offset <= tokenRange.ending then
			-- tokenIdx 1 = alias, 2+ = command args (after alias removal)
			return tokenIdx - 1
		end
	end

	--[[ Past End / Between Tokens ]]

	-- Cursor is past the last token (e.g., trailing whitespace) -> point to next slot
	return #tokens
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Utils Functions

--%%%%%%%%%%%%%%%%%%%% Suggestion Text Matches

--[[
	Plain substring match for client suggestions; case-insensitive.
]]
--- @return boolean
local function suggestionTextMatches(haystack: string, needle: string)
	--[[ Empty Needle ]]

	if needle == "" then
		return true
	end

	--[[ Compare Lowered ]]

	return haystack:lower():find(needle:lower(), 1, true) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Get Matching Commands Aliases

--[[
	Gets and returns all matching aliases for the given `inputData`.
]]
--- @param aliases { [string]: AdminPanel_CommandBar_CommandData_Global }
--- @param inputData AdminPanel_CommandBar_InputData
--- @return { string }
function Client_Utils.GetMatchingCommandsAliases(aliases, inputData, canSendGlobalCommands: boolean)
	--[[ Checks ]]

	if type(inputData.alias) ~= "string" then
		return {}
	end

	--[[ Local Variables ]]

	local isAliasCompleted: boolean = #inputData.args >= 1

	--[[ Completed Alias ]]

	if isAliasCompleted then
		-- Invalid command -> Returning empty table
		if not aliases[inputData.alias] then
			return {}
		end

		-- Save if variant is local
		if not inputData.isGlobalCommand then
			return { inputData.alias }
		end

		--- @type AdminPanel_CommandBar_CommandData_Global
		local commandData = aliases[inputData.alias]

		--[[ Global Checks ]]

		-- Skip if command is registered on client
		if not commandData._isServerData then
			return {}
		end

		-- Skip if player cannot send global commands
		if not canSendGlobalCommands then
			return {}
		end

		-- Save if variant or its child variants are global
		if commandData.baseVariant.globalEnabled or commandData.baseVariant.variantsAreGlobal then
			return { inputData.alias }
		end

		-- Fallback return
		return {}
	end

	--[[ Finding All Matching Aliases ]]

	--- @type { string }
	local toReturn = {}

	if not isAliasCompleted then
		--- @param commandData AdminPanel_CommandBar_CommandData_Global
		for alias: string, commandData in pairs(aliases) do
			--[[ Alias Checks ]]

			-- Alias is not matching inputted alias -> Skip
			if not suggestionTextMatches(alias, inputData.alias) then
				continue
			end

			-- Save if variant is local
			if not inputData.isGlobalCommand then
				table.insert(toReturn, alias)
				continue
			end

			--[[ Global Checks ]]

			-- Skip if command is registered on client
			if not commandData._isServerData then
				continue
			end

			-- Skip if player cannot send global commands
			if not canSendGlobalCommands then
				continue
			end

			-- Save if variant or its child variants are global
			if commandData.baseVariant.globalEnabled or commandData.baseVariant.variantsAreGlobal then
				table.insert(toReturn, alias)
				continue
			end
		end
	end

	--[[ Sorting ]]

	table.sort(toReturn, function(a: string, b: string)
		return (`{a}`):lower() < (`{b}`):lower()
	end)

	--[[ Returning ]]

	return toReturn
end

--%%%%%%%%%%%%%%%%%%%% Get Matching Variants Aliases

--[[
	Returns all matching aliases in the given `variantData` for argument at given `searchDepth`.
]]
--- @param inputData AdminPanel_CommandBar_InputData
--- @param variantData AdminPanel_CommandBar_VariantData
--- @return { string }?
function Client_Utils.GetMatchingVariantsAliases(inputData, commandData, variantData, canSendGlobalCommands: boolean, searchDepth: number)
	if not variantData.variants then
		return nil
	end

	--[[ Local Variables ]]

	local arg: string = inputData.args[searchDepth] or ""
	local toReturn = {} --- @type { string }

	if type(arg) ~= "string" then
		return nil
	end

	--[[ Finding All Matching Aliases ]]

	--- @param loopVariantData AdminPanel_CommandBar_VariantData
	for _, loopVariantData in ipairs(variantData.variants) do
		for _, alias: string in ipairs(loopVariantData.aliases) do
			--[[ Alias Checks ]]

			-- Alias is not matching inputted alias -> Skip
			if not suggestionTextMatches(alias, arg) then
				continue
			end

			-- Save if variant is local
			if not inputData.isGlobalCommand then
				table.insert(toReturn, alias)
				continue
			end

			--[[ Global Checks ]]

			-- Skip if command is registered on client
			if not commandData._isServerData then
				continue
			end

			-- Skip if player cannot send global commands
			if not canSendGlobalCommands then
				continue
			end

			-- Save if variant or its child variants are global
			if loopVariantData.globalEnabled or loopVariantData.variantsAreGlobal then
				table.insert(toReturn, alias)
				continue
			end
		end
	end

	--[[ Sorting ]]

	table.sort(toReturn, function(a: string, b: string)
		return (`{a}`):lower() < (`{b}`):lower()
	end)

	--[[ Returning ]]

	return toReturn
end

--%%%%%%%%%%%%%%%%%%%% Get Matching Args

--[[
	Gets and returns the matching args of the given `dict`, in the dictionary's own order.
	Stops collecting after `SUGGESTIONS_MATCH_WINDOWS` windows of `SUGGESTIONS_LIMIT` matches.
]]
--- @param dict AdminPanel_CommandBar_DictionaryEntry
--- @return { string }
function Client_Utils.GetMatchingArgs(arg: string, dict)
	--[[ Local Variables ]]

	local toReturn = {} --- @type { string }
	local needle: string = arg:lower()
	local matchLimit: number = _settings.SUGGESTIONS_LIMIT * _settings.SUGGESTIONS_MATCH_WINDOWS

	-- Using the stored lowercase copy only while it still lines up with the entries
	local lowered = if dict._lowered and #dict._lowered == #dict then dict._lowered else nil --- @type { string }?

	--[[ Getting Matching ]]

	for index: number, loopArg: string in ipairs(dict) do
		local haystack: string = if lowered then lowered[index] else loopArg:lower()

		-- Skip entries that don't contain the typed text
		if needle ~= "" and not haystack:find(needle, 1, true) then
			continue
		end

		table.insert(toReturn, loopArg)

		-- Stop after a few windows of matches
		if #toReturn >= matchLimit then
			break
		end
	end

	--[[ Returning ]]

	return toReturn
end

--%%%%%%%%%%%%%%%%%%%% Get Type String

--[[
	Converts all argument types into a single string and returns it.\
	Returns formatted string and raw if needed.
]]
--- @param argData AdminPanel_CommandBar_CommandDataArgTable
--- @return string
--- @return string
function Client_Utils.GetTypeString(argData, returnRaw: boolean)
	--[[ Local Variables ]]

	local optionalString: string = if argData.optional then "?" else ""
	local typeString: string

	--[[ Getting Types ]]

	for _, argType: string in ipairs(argData.types) do
		if not typeString then
			typeString = `{argType}`
		else
			typeString = `{typeString} | {argType}`
		end
	end

	--[[ Returning ]]

	local formattedString: string = I.RichText.Format(`&lt;{argData.name}{optionalString}: {typeString}&gt;`, { Transparency = 0.5 })
	local rawString: string = `{argData.name}{optionalString}: {typeString}`

	if returnRaw then
		return formattedString, rawString
	else
		return formattedString
	end
end

--%%%%%%%%%%%%%%%%%%%% Is Arg In Table

--[[
	Checks if given argument or its part matches any item in the given table.
	With `exactMatch`, the argument without its quotes must equal an item, as the server requires.
]]
--- @param dict AdminPanel_CommandBar_DictionaryEntry
--- @return boolean
function Client_Utils.IsArgInTable(arg: string | table, dict, exactMatch: boolean?)
	--[[ Local Variables ]]

	local argToCheck: string = arg

	-- Getting last argument / active argument from table
	if type(arg) == "table" then
		local stop: boolean = false
		repeat
			if type(argToCheck) == "table" then
				argToCheck = argToCheck[#argToCheck] or ""
			else
				stop = true
			end
		until stop
	end

	--[[ Matching ]]

	-- Exact match for marking the argument valid
	if exactMatch then
		return table.find(dict, Client_Utils.TrimQuotes(argToCheck)) ~= nil
	end

	-- Checking if found
	for _index: number, loopArg: string in ipairs(dict) do
		-- Stop at the first item containing the argument
		if suggestionTextMatches(loopArg, argToCheck) then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Client_Utils
