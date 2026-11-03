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
local UserInputService = I.S.UserInputService
local RunService = I.S.RunService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _module = script:FindFirstAncestor(_localName)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type AdminPanel_CommandBar_ClientShared
local state --- @type AdminPanel_CommandBar_ClientState

local c_utils --- @type AdminPanel_CommandBar_ClientUtils

local FOCUS_CAPTURE_ATTEMPTS: number = 5

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

--- @class AdminPanel_CommandBar_Client_Connections
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_ClientShared
function Module.Init(_shared)
	shared = _shared
	state = _shared.state

	c_utils = _shared.c_utils
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Connections

--%%%%%%%%%%%%%%%%%%%% Connect Players Dict Update

--[[
	Creates connection that updates `players` dictionary whenever player joins or leaves.
]]
function Module.ConnectPlayersDictUpdate()
	--%%%%%%%%%%%%%%%%%%%% Update Players Dict

	--[[
		Updates the `players` dictionary to match the current active players, sorted by name.
		Skips `leavingPlayer`, who is still in `Players` while `PlayerRemoving` fires.
	]]
	local function updatePlayersDict(leavingPlayer: Player?)
		--[[ Getting players names ]]

		--- @type AdminPanel_CommandBar_DictionaryEntry
		local activePlayers = {
			Protected = true,
		}

		for _index: number, player: Player in ipairs(Players:GetPlayers()) do
			-- Skip the leaving player and names already added
			if player ~= leavingPlayer and not table.find(activePlayers, player.Name) then
				table.insert(activePlayers, player.Name)
			end
		end

		--[[ Sorting ]]

		table.sort(activePlayers, function(a: string, b: string)
			return a:lower() < b:lower()
		end)

		--[[ Updating ]]

		state.dictionaries["players"] = activePlayers
		shared.Input.ProcessInput()
	end

	--[[ Connecting ]]

	Players.PlayerAdded:Connect(function(_player: Player)
		updatePlayersDict()
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		updatePlayersDict(player)
	end)

	-- Initial Update
	updatePlayersDict()
end

--%%%%%%%%%%%%%%%%%%%% Connect Command Bar

--[[
	Connects command bar elements.
]]
function Module.ConnectCommandBar()
	local elems = state.elems

	--%%%%%%%%%%%%%%%%%%%% Input

	-- Focus lost after pressing enter
	elems["InputBox"].FocusLost:Connect(function(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
		if enterPressed and inputThatCausedFocusLoss then
			shared.Control.ExecuteCommand()
			task.wait() -- Re-capturing focus in the next frame, otherwise it'll not work
			elems["InputBox"]:CaptureFocus()
		end
	end)

	-- Text changed -> process command
	elems["InputBox"]:GetPropertyChangedSignal("Text"):Connect(function()
		shared.Input.ProcessInput()
	end)

	--%%%%%%%%%%%%%%%%%%%% Input Update

	-- Focus changed -> process command
	elems["InputBox"].Focused:Connect(function()
		shared.Input.ProcessInput()
	end)
	elems["InputBox"].FocusLost:Connect(function()
		shared.Input.ProcessInput()
	end)

	--%%%%%%%%%%%%%%%%%%%% Control Buttons

	-- Execute command
	elems["ExecuteButton"].MouseButton1Click:Connect(function()
		shared.Control.ExecuteCommand()
	end)

	-- Close command bar
	elems["CloseButton"].MouseButton1Click:Connect(function()
		shared.Control.ToggleCommandBar()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Connect Input

--[[
	Connects input to control the command bar behaviour.
]]
function Module.ConnectInput()
	local elems = state.elems
	local connections = state.connections

	--[[ Input ]]

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		--[[ Checks ]]

		-- Skip input typed into another text box, such as the chat
		if gameProcessedEvent and UserInputService:GetFocusedTextBox() ~= elems["InputBox"] then
			return
		end

		--%%%%%%%%%%%%%%%%%%%% Auto Completion

		if state.commandBar.Enabled and elems["InputBox"]:IsFocused() then
			-- Auto Complete current phrase
			if input.KeyCode == Enum.KeyCode.Tab then
				shared.Suggestions.AutoComplete()

				return
			end

			-- Move selection to another phrase
			if (input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down) and state.autoCompletePhrase then
				--[[ Command History Check ]]

				local currentInput: string = elems["InputBox"].Text

				-- Resolving the arg currently under the cursor so middle-cursor moves stay on suggestions
				--- @type AdminPanel_CommandBar_InputData
				local inputData = c_utils.GetInputData(currentInput, state.aliases)
				local activeArg: string | table = state.activeArgIndex and inputData.args[state.activeArgIndex]

				local isArgCompleted: boolean = state.autoCompleteTable
					and state.autoCompleteType
					and state.autoCompleteTable[state.autoCompleteType]
					and type(activeArg) == "string"
					and table.find(state.autoCompleteTable[state.autoCompleteType], activeArg) ~= nil
				local isLastCommandHistory: boolean = currentInput == state.commandHistory[state.commandHistoryIndex]

				local canMoveAutoCompletion: boolean = not isArgCompleted and not isLastCommandHistory

				--[[ Moving ]]

				if canMoveAutoCompletion then
					-- Getting move direction based on the pressed key
					local moveDirection: number = input.KeyCode == Enum.KeyCode.Up and 1 or -1

					-- Inverting direction
					if _settings.SUGGESTIONS_DIRECTION == 1 then
						moveDirection *= -1
					end

					-- Initial move
					shared.Suggestions.MoveSuggestion(moveDirection)

					-- Creating move connection
					if not connections["MoveAutoComplete"] then
						local timePassed = 0
						connections["MoveAutoComplete"] = RunService.Heartbeat:Connect(function(deltaTime: number)
							--[[ Watching for Disconnect ]]

							if not UserInputService:IsKeyDown(input.KeyCode) then
								connections["MoveAutoComplete"]:Disconnect()
								connections["MoveAutoComplete"] = nil
								return
							end

							--[[ Updating Move ]]

							timePassed += deltaTime
							if timePassed >= _settings.SUGGESTION_MOVE_THRESHOLD then
								timePassed -= _settings.SUGGESTION_MOVE_STEP
								shared.Suggestions.MoveSuggestion(moveDirection)
							end
						end)
					end

					return
				end
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Focus

		if state.commandBar.Enabled and input.KeyCode == Enum.KeyCode.Slash then
			if not elems["InputBox"]:IsFocused() then
				-- Adding prefix
				if #elems["InputBox"].Text == 0 then
					elems["InputBox"].Text = `{_settings.PREFIX}`
				end

				-- Capturing focus, a few attempts while the bar stays open
				for _attempt: number = 1, FOCUS_CAPTURE_ATTEMPTS do
					task.wait()

					-- Stop when the bar was closed meanwhile
					if not state.commandBar.Enabled then
						break
					end

					elems["InputBox"]:CaptureFocus()
					task.wait()

					-- Stop once focused
					if elems["InputBox"]:IsFocused() then
						break
					end
				end
			end

			return
		end

		--%%%%%%%%%%%%%%%%%%%% Move Command History

		local historyMovePressed: boolean = input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down

		if state.commandBar.Enabled and elems["InputBox"]:IsFocused() and historyMovePressed then
			--[[ Moving Index ]]

			if input.KeyCode == Enum.KeyCode.Up then
				-- Creating index
				if not state.commandHistoryIndex and #state.commandHistory >= 1 then
					state.commandHistoryIndex = 0
				end

				-- Moving up
				if state.commandHistoryIndex then
					state.commandHistoryIndex += 1
				end
			elseif input.KeyCode == Enum.KeyCode.Down then
				if state.commandHistoryIndex then
					-- Moving down if exists
					state.commandHistoryIndex -= 1

					-- Clearing if out of bounds
					if state.commandHistoryIndex <= 0 then
						state.commandHistoryIndex = nil
					end
				end
			end

			--[[ Clamping Index / Updating Text ]]

			if state.commandHistoryIndex and #state.commandHistory >= 1 then
				-- Clamping index to history limit
				state.commandHistoryIndex = math.min(state.commandHistoryIndex, #state.commandHistory)

				-- Updating text
				if state.commandHistoryIndex and state.commandHistory[state.commandHistoryIndex] then
					elems["InputBox"].Text = state.commandHistory[state.commandHistoryIndex]
					elems["InputBox"].CursorPosition = #state.commandHistory[state.commandHistoryIndex] + 1
				end
			else
				state.commandHistoryIndex = nil
				elems["InputBox"].Text = ""
			end

			return
		end
	end)

	elems["InputBox"].FocusLost:Connect(function()
		if connections["MoveAutoComplete"] then
			connections["MoveAutoComplete"]:Disconnect()
			connections["MoveAutoComplete"] = nil
		end
	end)

	--[[ Cursor Position ]]

	elems["InputBox"]:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		shared.Selection.UpdateSelectionDisplay()

		-- Re-evaluate suggestions for the arg currently under the cursor
		if elems["InputBox"]:IsFocused() then
			shared.Input.ProcessInput()
		end
	end)

	--[[ Selection ]]

	elems["InputBox"]:GetPropertyChangedSignal("SelectionStart"):Connect(function()
		shared.Selection.UpdateSelectionDisplay()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Connect Cursor Update

--[[
	Connects cursor update animation.
]]
function Module.ConnectCursorUpdate()
	local elems = state.elems
	local connections = state.connections

	--%%%%%%%%%%%%%%%%%%%% Position Update

	elems["InputBox"]:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		shared.Cursor.UpdateCursorPosition()
	end)
	elems["InputBox"]:GetPropertyChangedSignal("Text"):Connect(function()
		shared.Cursor.UpdateCursorPosition()
	end)

	-- Initial position update
	shared.Cursor.UpdateCursorPosition()

	--%%%%%%%%%%%%%%%%%%%% Visibility Update

	-- Connecting
	elems["InputBox"].Focused:Connect(function()
		if connections["CursorVisibility"] then
			return
		end

		local timePassed: number = 0
		connections["CursorVisibility"] = RunService.Heartbeat:Connect(function(deltaTime: number)
			timePassed += deltaTime
			if timePassed >= _settings.CURSOR_FLICKER_SPEED then
				timePassed -= _settings.CURSOR_FLICKER_SPEED
				elems["Cursor"].Visible = not elems["Cursor"].Visible
			end
		end)

		-- Showing by default
		elems["Cursor"].Visible = true
	end)

	-- Disconnecting
	elems["InputBox"].FocusLost:Connect(function()
		if connections["CursorVisibility"] then
			connections["CursorVisibility"]:Disconnect()
			connections["CursorVisibility"] = nil
		end

		-- Hiding
		elems["Cursor"].Visible = false
	end)
end

--%%%%%%%%%%%%%%%%%%%% Connect Data Updates

--[[
	Creates connections that updates `commands` and `dictionaries`.
]]
function Module.ConnectDataUpdates()
	--%%%%%%%%%%%%%%%%%%%% Commands Update

	_module:GetAttributeChangedSignal("AdminPanel_CommandsVersion_Client"):Connect(function()
		if state.commandBar.Enabled then
			shared.Data.UpdateCommandsData("Client")
		end
	end)
	_module:GetAttributeChangedSignal("AdminPanel_CommandsVersion_Server"):Connect(function()
		if state.commandBar.Enabled then
			shared.Data.UpdateCommandsData("Server")
		end
	end)

	--%%%%%%%%%%%%%%%%%%%% Dictionaries Update

	_module:GetAttributeChangedSignal("AdminPanel_DictionariesVersion_Client"):Connect(function()
		if state.commandBar.Enabled then
			shared.Data.UpdateDictionariesData("Client")
		end
	end)
	_module:GetAttributeChangedSignal("AdminPanel_DictionariesVersion_Server"):Connect(function()
		if state.commandBar.Enabled then
			shared.Data.UpdateDictionariesData("Server")
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
