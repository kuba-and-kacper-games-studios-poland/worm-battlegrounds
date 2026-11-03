--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type AdminPanel_CommandBar_ClientShared
local state --- @type AdminPanel_CommandBar_ClientState

local c_utils --- @type AdminPanel_CommandBar_ClientUtils

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

--- @class AdminPanel_CommandBar_Client_Suggestions
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_ClientShared
function Module.Init(_shared)
	shared = _shared
	state = _shared.state

	c_utils = _shared.c_utils
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Suggestions Control

--%%%%%%%%%%%%%%%%%%%% Set Suggestions

--[[
	Sets suggestions phrase from given tables and updates the suggestions display.
]]
function Module.SetSuggestions(command: string, newTables: table)
	--[[ Local Variables ]]

	local anyValidTableType: boolean = false

	-- Check if any valid types are passed
	if newTables then
		for _, typeName: string in ipairs(_settings.SUGGESTIONS_ORDER) do
			if newTables[typeName] then
				anyValidTableType = true
				break
			end
		end
	end

	--[[ Tables Checks / Data Updating ]]

	if command and anyValidTableType then
		--%%%%%%%%%%%%%%%%%%%% Updating Tables

		if not state.autoCompleteTable then
			state.autoCompleteTable = {}
		end

		-- Replacing old tables with new ones
		for _, typeName: string in ipairs(_settings.SUGGESTIONS_ORDER) do
			if newTables[typeName] and #newTables[typeName] > 0 then
				-- Update table if it's new or different
				if not state.autoCompleteTable[typeName] or not I.Table.Equal(state.autoCompleteTable[typeName], newTables[typeName]) then
					state.autoCompleteTable[typeName] = newTables[typeName]
				end
			else
				-- Clear table if it's missing
				state.autoCompleteTable[typeName] = nil
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Validating Passed Table

		local anyNewValidTableType: boolean = false

		-- Check if any valid types are passed
		for _, typeName: string in ipairs(_settings.SUGGESTIONS_ORDER) do
			if state.autoCompleteTable[typeName] then
				anyNewValidTableType = true
				break
			end
		end

		-- Clear suggestions if no valid tables were passed
		if not anyNewValidTableType then
			state.autoCompletePhrase = nil
			state.autoCompleteType = nil
			state.autoCompleteTable = nil

			-- Updating display
			Module.UpdateSuggestionsDisplay(command)
			return
		end

		--%%%%%%%%%%%%%%%%%%%% Validating Phrase

		-- Updating phrase to the first valid one if the currently selected one is missing
		if not state.autoCompleteTable[state.autoCompleteType] or not table.find(state.autoCompleteTable[state.autoCompleteType], state.autoCompletePhrase) then
			-- Clearing previously set suggestions
			state.autoCompletePhrase = nil
			state.autoCompleteType = nil

			-- Finding first existing phrase
			for _, typeName: string in ipairs(_settings.SUGGESTIONS_ORDER) do
				if state.autoCompleteTable[typeName] then
					state.autoCompletePhrase = state.autoCompleteTable[typeName][1]
					state.autoCompleteType = typeName
					break
				end
			end
		end

		-- Clear if suggestion is still not found
		if not state.autoCompletePhrase then
			state.autoCompletePhrase = nil
			state.autoCompleteType = nil
			state.autoCompleteTable = nil
		end
	else
		--%%%%%%%%%%%%%%%%%%%% Clearing Suggestions

		state.autoCompletePhrase = nil
		state.autoCompleteType = nil
		state.autoCompleteTable = nil
	end

	-- Updating display
	Module.UpdateSuggestionsDisplay(command)
end

--%%%%%%%%%%%%%%%%%%%% Update Suggestions Display

--[[
	Updates display of the suggested auto completion phrases.
]]
function Module.UpdateSuggestionsDisplay(command: string)
	local elems = state.elems
	local prefabs = state.prefabs

	local createdSuggestions = state.createdSuggestions
	local createdSuggestionsSeparators = state.createdSuggestionsSeparators

	--%%%%%%%%%%%%%%%%%%%% Clearing

	-- Hide if suggestions are disabled
	if not command or not state.autoCompletePhrase or not state.autoCompleteType or not state.autoCompleteTable then
		-- Hiding suggestions GUI
		elems["SuggestionsContainer"].Visible = false
		elems["SuggestionsContainerBg"].Visible = false

		-- Clearing all suggestions
		for elemName: string, elem: TextLabel | GuiObject in pairs(createdSuggestions) do
			elem:Destroy()
			createdSuggestions[elemName] = nil
		end

		return
	end

	--%%%%%%%%%%%%%%%%%%%% Getting Command

	--[[ Input Data ]]

	--- @type AdminPanel_CommandBar_InputData
	local inputData = c_utils.GetInputData(command, state.aliases)
	local finalString: string = ""

	--[[ Getting Trimmed Command ]]

	-- Prefix
	if inputData.isGlobalCommand then
		finalString ..= _settings.GLOBAL_PREFIX
	end
	finalString ..= _settings.PREFIX

	-- Arguments
	local separated: { string } = inputData.cleared:split(" ") -- Splitting input into arguments

	-- Move suggestion by one space, to display correctly in table
	if separated[#separated] == "{" or separated[#separated] == "}" then
		table.insert(separated, "")
	end

	-- Changing last argument to nothing, so the suggestion box will not move and display at the start of the argument
	separated[#separated] = ""

	-- Concatenating all arguments to the final string
	finalString ..= `{table.concat(separated, " ")} `

	--%%%%%%%%%%%%%%%%%%%% Building Flat List

	-- Flat ordered list across all types, used for windowing
	local flatList = {}
	for _: number, typeName: string in ipairs(_settings.SUGGESTIONS_ORDER) do
		local typeTable: { string } = state.autoCompleteTable[typeName]
		if typeTable then
			for _: number, phrase: string in ipairs(typeTable) do
				table.insert(flatList, { type = typeName, phrase = phrase })
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Window Calculation

	--[[ Selected Index ]]

	local selectedIdx: number = 0
	for idx: number, entry in ipairs(flatList) do
		if entry.type == state.autoCompleteType and entry.phrase == state.autoCompletePhrase then
			selectedIdx = idx
			break
		end
	end

	--[[ Window Bounds ]]

	local windowSize: number = math.min(_settings.SUGGESTIONS_LIMIT, #flatList)
	local windowStart: number = state.suggestionsWindowStart or 1

	-- Sliding the window so the selected entry stays visible
	if selectedIdx > 0 and windowSize > 0 then
		if selectedIdx < windowStart then
			windowStart = selectedIdx
		elseif selectedIdx >= windowStart + windowSize then
			windowStart = selectedIdx - windowSize + 1
		end
	end

	-- Clamping to valid range
	if windowSize <= 0 or #flatList <= windowSize then
		windowStart = 1
	else
		windowStart = math.clamp(windowStart, 1, #flatList - windowSize + 1)
	end

	state.suggestionsWindowStart = windowStart
	local windowEnd: number = windowStart + windowSize - 1

	--%%%%%%%%%%%%%%%%%%%% Creating/Updating Suggestions

	--[[ Removing Missing Suggestions ]]

	for elemName: string, elem: TextLabel | GuiObject in pairs(createdSuggestions) do
		local splittedName: { string } = elemName:split("_")
		local elemType: string = splittedName[1]
		table.remove(splittedName, 1)
		local fullElemName: string = table.concat(splittedName, "_")

		-- Destroying if suggestion is no longer in the data
		if not state.autoCompleteTable[elemType] or not table.find(state.autoCompleteTable[elemType], fullElemName) then
			elem:Destroy()
			createdSuggestions[elemName] = nil
		end
	end

	--[[ Window Lookup ]]

	-- key -> flatIdx for entries within the visible window
	local windowKeys = {} --- @type { [string]: number }
	for i: number = windowStart, windowEnd do
		local entry = flatList[i]
		if entry then
			windowKeys[`{entry.type}_{entry.phrase}`] = i
		end
	end

	--[[ Creating / Updating / Hiding ]]

	local selectedKey: string = `{state.autoCompleteType}_{state.autoCompletePhrase}`

	for _: number, entry in ipairs(flatList) do
		local key: string = `{entry.type}_{entry.phrase}`
		local existing: TextLabel = createdSuggestions[key]
		local windowIdx: number? = windowKeys[key]

		if windowIdx then
			-- In window: ensure created and visible
			if not existing then
				local cloned: TextLabel = prefabs["SuggestionText"]:Clone()
				cloned.Parent = elems["SuggestionsContainer"]
				createdSuggestions[key] = cloned
				existing = cloned
			end

			existing.LayoutOrder = (windowIdx * 2) * _settings.SUGGESTIONS_DIRECTION
			existing.Visible = true

			-- Highlighting selected, plain text otherwise
			if key == selectedKey then
				existing.Text = I.RichText.Format(entry.phrase, { Color = _settings.COLORS.AutoComplete })
			else
				existing.Text = entry.phrase
			end
		else
			-- Out of window: keep alive but hidden so the window can slide back later
			if existing then
				existing.Visible = false
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Separators Update

	-- Hiding all separators upfront; re-shown below when a type boundary lands inside the window
	for _separatorName: string, separator: Frame in pairs(createdSuggestionsSeparators) do
		separator.Visible = false
	end

	for i: number = windowStart, windowEnd - 1 do
		local current = flatList[i]
		local next_ = flatList[i + 1]

		if current and next_ and current.type ~= next_.type then
			local separatorKey: string = `sep_{i}`

			if not createdSuggestionsSeparators[separatorKey] then
				local cloned: Frame = prefabs["SuggestionSeparator"]:Clone()
				cloned.Parent = elems["SuggestionsContainer"]
				createdSuggestionsSeparators[separatorKey] = cloned
			end

			createdSuggestionsSeparators[separatorKey].LayoutOrder = (i * 2 + 1) * _settings.SUGGESTIONS_DIRECTION
			createdSuggestionsSeparators[separatorKey].Visible = true
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Container Position Update

	--[[ Updating Container ]]

	elems["SuggestionPosBox"].Text = finalString

	-- Setting position with offset set by default
	elems["SuggestionsContainer"].Position = UDim2.new(0, elems["SuggestionPosBox"].TextBounds.X, state.defContainerPos.Y.Scale, state.defContainerPos.Y.Offset)
	elems["SuggestionsContainerBg"].Position = elems["SuggestionsContainer"].Position

	task.wait() -- Wait for `UIListLayout` properties to update to match current childrens

	-- Size
	local currentPos = elems["SuggestionsContainer"].UIListLayout.AbsoluteContentSize
	elems["SuggestionsContainerBg"].Size = UDim2.fromOffset(currentPos.X, currentPos.Y)

	-- Visibility
	elems["SuggestionsContainer"].Visible = #command >= 1
	elems["SuggestionsContainerBg"].Visible = #command >= 1
end

--%%%%%%%%%%%%%%%%%%%% Move Suggestion

--[[
	Moves suggestion selection in the given direction.
]]
function Module.MoveSuggestion(direction: number)
	-- Auto complete not active
	if not state.autoCompletePhrase or not state.autoCompleteType or not state.autoCompleteTable then
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Local Functions

	--[[
		Returns name of a suggestion type from its index.
	]]
	--- @return string
	local function getTypeFromIndex(index: number)
		local loopTypeName: string = _settings.SUGGESTIONS_ORDER[index]
		if state.autoCompleteTable[loopTypeName] then
			return loopTypeName
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Moving

	--[[ Local Variables ]]

	local currentIndex: number
	local currentType: string

	--[[ Finding Moved Type ]]

	local currentPos: number = state.autoCompleteTable[state.autoCompleteType] and table.find(state.autoCompleteTable[state.autoCompleteType], state.autoCompletePhrase)

	-- Finding position of the next phrase
	if currentPos then
		-- Calculating desired position
		local goalPos: number = currentPos + direction

		--[[ Previous Table ]]

		-- Previous type table last phrase
		if goalPos <= 0 then
			local currentTypePos: number = table.find(_settings.SUGGESTIONS_ORDER, state.autoCompleteType)
			local previousType: string

			-- First loop: reverse from current position to '1'
			for i: number = currentTypePos - 1, 1, -1 do
				local loopPreviousType: string = getTypeFromIndex(i)
				if loopPreviousType and loopPreviousType ~= state.autoCompleteType then
					previousType = loopPreviousType
					break
				end
			end

			-- Second loop: reverse from last position to current
			if not previousType then
				for i: number = #_settings.SUGGESTIONS_ORDER, currentTypePos, -1 do
					local loopPreviousType: string = getTypeFromIndex(i)
					if loopPreviousType and loopPreviousType ~= state.autoCompleteType then
						previousType = loopPreviousType
						break
					end
				end
			end

			-- Filling with the selected one if no other types are present
			if not previousType then
				previousType = state.autoCompleteType
			end

			-- Updating
			currentIndex = #state.autoCompleteTable[previousType]
			currentType = previousType
		end

		--[[ Next Table ]]

		-- Next type table first phrase
		if goalPos > #state.autoCompleteTable[state.autoCompleteType] then
			local currentTypePos: number = table.find(_settings.SUGGESTIONS_ORDER, state.autoCompleteType)
			local nextType: string

			-- First loop: continue from current position to last position
			for i: number = currentTypePos + 1, #_settings.SUGGESTIONS_ORDER do
				local loopNextType: string = getTypeFromIndex(i)
				if loopNextType and loopNextType ~= state.autoCompleteType then
					nextType = loopNextType
					break
				end
			end

			-- Second loop: continue from '1' to current position
			if not nextType then
				for i = 1, currentTypePos, 1 do
					local loopNextType: string = getTypeFromIndex(i)
					if loopNextType and loopNextType ~= state.autoCompleteType then
						nextType = loopNextType
						break
					end
				end
			end

			-- Filling with the selected one if no other types are present
			if not nextType then
				nextType = state.autoCompleteType
			end

			-- Updating
			currentIndex = 1
			currentType = nextType
		end

		--[[ Current Table ]]

		if goalPos > 0 and goalPos <= #state.autoCompleteTable[state.autoCompleteType] then
			currentIndex = goalPos
			currentType = state.autoCompleteType
		end
	end

	-- Current phrase position is missing, so find the first existing one
	if not currentPos then
		local firstExistingType: string

		-- Finding first valid type table
		for _, tableType: string in ipairs(_settings.SUGGESTIONS_ORDER) do
			if state.autoCompleteTable[tableType] and state.autoCompleteTable[tableType][1] then
				firstExistingType = tableType
				break
			end
		end

		-- Updating position and type
		if firstExistingType then
			currentIndex = 1
			currentType = firstExistingType
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Updating

	-- Updating current phrase
	state.autoCompletePhrase = state.autoCompleteTable[currentType][currentIndex]
	state.autoCompleteType = currentType

	-- Re-rendering suggestions display so the window slides to keep selection visible
	Module.UpdateSuggestionsDisplay(state.elems["InputBox"].Text)

	-- Updating input display
	shared.Input.ProcessInput(true)
end

--%%%%%%%%%%%%%%%%%%%% Auto Complete

--[[
	Auto completes currently chosen argument.
]]
function Module.AutoComplete()
	-- Auto Complete not active
	if not state.autoCompletePhrase then
		return
	end

	local elems = state.elems

	--[[ Data ]]

	--- @type AdminPanel_CommandBar_InputData
	local inputData = c_utils.GetInputData(elems["InputBox"].Text, state.aliases)
	local finalString = ""

	--[[ Getting Prefix ]]

	if inputData.isGlobalCommand then
		finalString ..= _settings.GLOBAL_PREFIX
	end
	finalString ..= _settings.PREFIX

	--[[ Getting Arguments ]]

	local separated: { string } = inputData.cleared:split(" ")

	-- Add space after table or before
	if separated[#separated] == "{" or separated[#separated] == "}" then
		table.insert(separated, "")
	end

	separated[#separated] = state.autoCompletePhrase
	finalString ..= `{table.concat(separated, " ")} `

	--[[ Updating ]]

	elems["InputBox"].Text = finalString
	elems["InputBox"].CursorPosition = #finalString + 1
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
