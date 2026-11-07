--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Setup = require(script.Parent:FindFirstChild("Setup")) --- @type MatchBoard_Client_Setup

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui
local boardFolder: Folder

-- Each public row's card on the board, by row id
local lines = {} --- @type { [string]: Frame }

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

--- @class MatchBoard_Client_Board
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.BOARD_GUI_NAME]
	elems["Play"] = moduleGui:FindFirstChild("U_Play") --- @type Frame
	elems["Welcome"] = elems["Play"]:FindFirstChild("S_Welcome", true) --- @type TextLabel
	elems["Solo"] = elems["Play"]:FindFirstChild("S_Solo", true) --- @type Frame
	elems["Rows"] = elems["Play"]:FindFirstChild("U_Rows", true) --- @type ScrollingFrame
	elems["WaitingRoom"] = moduleGui:FindFirstChild("U_WaitingRoom") --- @type Frame
	elems["Match"] = elems["WaitingRoom"]:FindFirstChild("S_Match", true) --- @type TextLabel
	elems["Countdown"] = elems["WaitingRoom"]:FindFirstChild("S_Countdown", true) --- @type TextLabel
	elems["Count"] = elems["WaitingRoom"]:FindFirstChild("S_Count", true) --- @type TextLabel
	elems["Players"] = elems["WaitingRoom"]:FindFirstChild("U_Players", true) --- @type Frame
	elems["Vote"] = elems["WaitingRoom"]:FindFirstChild("S_Vote", true):FindFirstChild("Button") --- @type ImageButton
	elems["Leave"] = elems["WaitingRoom"]:FindFirstChild("S_Leave", true):FindFirstChild("Button") --- @type ImageButton
	prefabs["Row"] = elems["Rows"]:FindFirstChild("PREFAB | Row") --- @type Frame
	prefabs["PlayerName"] = elems["Players"]:FindFirstChild("PREFAB | PlayerName") --- @type Frame

	--[[ Setup ]]

	Setup.Start(moduleGui, Module._refresh)
	elems["Welcome"].Text = `Welcome, {I.S.Players.LocalPlayer.DisplayName}`

	--[[ Connections ]]

	boardFolder = I.Dirs.UmeReplicated:WaitForChild(_localName)
	boardFolder.ChildAdded:Connect(Module._watchRow)
	boardFolder.ChildRemoved:Connect(Module._onRowRemoved)
	for _index: number, config: Instance in ipairs(boardFolder:GetChildren()) do
		Module._watchRow(config)
	end
	I.Interact.OnPress(elems["Solo"]:FindFirstChild("Button"), Module._onPlay)
	I.Interact.OnPress(elems["Vote"], function()
		I.Network.Fire("MatchBoard_Vote")
	end)
	I.Interact.OnPress(elems["Leave"], function()
		I.Network.Fire("MatchBoard_Leave")
	end)
	I.S.Players.LocalPlayer.AttributeChanged:Connect(Module._refresh)
	I.DoEvery.Every(0.25, Module._tick)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Row

--[[
	Adds a card for a public row, in PUBLIC_ROWS order, and redraws the board whenever any row changes.
]]
function Module._watchRow(config: Instance)
	--[[ Data ]]

	if not config:GetAttribute("Kind") then
		config:GetAttributeChangedSignal("Kind"):Wait()
	end
	local kind: string = config:GetAttribute("Kind")

	--[[ Line ]]

	if kind == "Public" then
		local line: Frame = prefabs["Row"]:Clone()
		line.Name = config.Name
		line.LayoutOrder = Module._getRowOrder(config:GetAttribute("Mode"))
		line.Visible = true
		line.Parent = elems["Rows"]
		lines[config.Name] = line
		I.Interact.OnPress(line:FindFirstChild("S_Join", true):FindFirstChild("Button"), function()
			I.Network.Fire("MatchBoard_Join", config.Name)
		end)
	end

	--[[ Connections ]]

	config.AttributeChanged:Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% On Row Removed

--[[
	Takes a started or closed row's card off the board.
]]
function Module._onRowRemoved(config: Instance)
	--[[ Removing ]]

	if lines[config.Name] then
		lines[config.Name]:Destroy()
		lines[config.Name] = nil
	end
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% On Play

--[[
	Play solo opens the setup for a solo match; in a party it sets up the party's match, which only the leader starts.
]]
function Module._onPlay()
	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer

	--[[ Checks ]]

	-- Check if the player may start their party's match
	if localPlayer:GetAttribute("PartyId") and not localPlayer:GetAttribute("PartyLeader") then
		I.WidgetManager.ShowMessage("Only your party's leader can start a match.")
		return
	end

	--[[ Opening ]]

	Setup.Open(localPlayer:GetAttribute("PartyId") ~= nil)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws the board: Play solo (Play with party in a party), each public row's mode, map, players and Join (Join teams
	for team modes), or the waiting room of the row the player is in, with everyone in it and the votes. The setup
	panel shows in the board's place.
]]
function Module._refresh()
	--[[ Lines ]]

	for rowId: string, line: Frame in pairs(lines) do
		local config: Instance? = boardFolder:FindFirstChild(rowId)
		if not config then
			continue
		end
		local players = Module._getPlayers(config) --- @type { number }
		local mapRow = _settings.MAPS[config:GetAttribute("MapId")] --- @type MatchBoard_MapRow?
		line:FindFirstChild("S_Mode", true).Text = _settings.MODE_NAMES[config:GetAttribute("Mode")] or config:GetAttribute("Mode")
		line:FindFirstChild("S_Map", true).Text = if mapRow then mapRow.Name else ""
		line:FindFirstChild("S_Players", true).Text = `{#players} / {config:GetAttribute("Size")}`
		line:FindFirstChild("S_Join", true):FindFirstChild("ButtonText", true).Text = if config:GetAttribute("Mode") == "Deathmatch" then "Join" else "Join teams"
	end

	--[[ Play ]]

	elems["Solo"]:FindFirstChild("ButtonText", true).Text = if I.S.Players.LocalPlayer:GetAttribute("PartyId") then "Play with party" else "Play solo"

	--[[ Panels ]]

	-- Joining a public match closes the setup, which redraws the board again
	local mine: Instance? = Module._getMyRow()
	local waiting: boolean = mine ~= nil and mine:GetAttribute("Kind") == "Public"
	if waiting and Setup.IsOpen() then
		Setup.Close()
		return
	end
	elems["Play"].Visible = not waiting and not Setup.IsOpen()
	elems["WaitingRoom"].Visible = waiting

	--[[ Waiting Room ]]

	if not mine or not waiting then
		return
	end
	local mapRow = _settings.MAPS[mine:GetAttribute("MapId")] --- @type MatchBoard_MapRow?
	local players = Module._getPlayers(mine) --- @type { number }
	elems["Match"].Text = `{_settings.MATCH_NAMES[mine:GetAttribute("Mode")] or mine:GetAttribute("Mode")} • {if mapRow then mapRow.Name else ""}`
	elems["Count"].Text = `{#players} / {mine:GetAttribute("Size")} players`
	elems["Vote"]:FindFirstChild("ButtonText", true).Text = `Vote to start  {mine:GetAttribute("Votes")} / {mine:GetAttribute("VotesNeeded")}`
	for _index: number, child: Instance in ipairs(elems["Players"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["PlayerName"] then
			child:Destroy()
		end
	end
	for index: number, userId: number in ipairs(players) do
		local entry: Frame = prefabs["PlayerName"]:Clone()
		local player: Player? = I.S.Players:GetPlayerByUserId(userId)
		entry.Name = tostring(userId)
		entry.LayoutOrder = index
		entry.Visible = true
		entry:FindFirstChild("S_Name", true).Text = if player then player.DisplayName else "?"
		entry:FindFirstChild("S_Avatar", true).Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
		entry.Parent = elems["Players"]
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Counts the rows' timers down, on the board and in the waiting room.
]]
function Module._tick()
	--[[ Local Variables ]]

	local now: number = I.S.Workspace:GetServerTimeNow()

	--[[ Lines ]]

	for rowId: string, line: Frame in pairs(lines) do
		local config: Instance? = boardFolder:FindFirstChild(rowId)
		if config then
			line:FindFirstChild("S_Timer", true).Text = Module._getTime(config, now)
		end
	end

	--[[ Waiting Room ]]

	local mine: Instance? = Module._getMyRow()
	if mine and elems["WaitingRoom"].Visible then
		elems["Countdown"].Text = `Match starts in {Module._getTime(mine, now)}`
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get My Row

--[[
	Returns the row or lobby the local player is in.
]]
--- @return Instance?
function Module._getMyRow()
	--[[ Searching ]]

	for _index: number, config: Instance in ipairs(boardFolder:GetChildren()) do
		if table.find(Module._getPlayers(config), I.S.Players.LocalPlayer.UserId) then
			return config
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Players

--[[
	Returns the user ids in a row.
]]
--- @return { number }
function Module._getPlayers(config: Instance)
	return I.S.HttpService:JSONDecode(config:GetAttribute("Players") or "[]")
end

--%%%%%%%%%%%%%%%%%%%% Get Row Order

--[[
	Returns where a public row of a mode sits on the board: its place in PUBLIC_ROWS.
]]
--- @return number
function Module._getRowOrder(mode: string)
	--[[ Searching ]]

	--- @param option MatchBoard_RowOption
	for index: number, option in ipairs(_settings.PUBLIC_ROWS) do
		if option.Mode == mode then
			return index
		end
	end

	--[[ Returning ]]

	return #_settings.PUBLIC_ROWS + 1
end

--%%%%%%%%%%%%%%%%%%%% Get Time

--[[
	Returns the time left on a row as "0:29", or its full time while nobody has joined.
]]
--- @return string
function Module._getTime(config: Instance, now: number)
	--[[ Local Variables ]]

	local endsAt: number = config:GetAttribute("EndsAt") or 0
	local left: number = if endsAt > 0 then math.max(math.ceil(endsAt - now), 0) else _settings.ROW_SECONDS

	--[[ Returning ]]

	return string.format("%d:%02d", left // 60, left % 60)
end

return Module
