--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui
local boardFolder: Folder

-- Each public row's line on the board, by row id
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
	elems["Quick"] = elems["Play"]:FindFirstChild("S_Quick", true):FindFirstChild("Button") --- @type ImageButton
	elems["Rows"] = I.UserInterface.UI[_settings.MODES_GUI_NAME]:FindFirstChild("U_Rows", true) --- @type Frame
	elems["WaitingRoom"] = moduleGui:FindFirstChild("U_WaitingRoom") --- @type Frame
	elems["Match"] = elems["WaitingRoom"]:FindFirstChild("S_Match", true) --- @type TextLabel
	elems["Countdown"] = elems["WaitingRoom"]:FindFirstChild("S_Countdown", true) --- @type TextLabel
	elems["Count"] = elems["WaitingRoom"]:FindFirstChild("S_Count", true) --- @type TextLabel
	elems["Players"] = elems["WaitingRoom"]:FindFirstChild("U_Players", true) --- @type Frame
	elems["Vote"] = elems["WaitingRoom"]:FindFirstChild("S_Vote", true):FindFirstChild("Button") --- @type ImageButton
	elems["Leave"] = elems["WaitingRoom"]:FindFirstChild("S_Leave", true):FindFirstChild("Button") --- @type ImageButton
	prefabs["Row"] = elems["Rows"]:FindFirstChild("PREFAB | Row") --- @type Frame
	prefabs["PlayerName"] = elems["Players"]:FindFirstChild("PREFAB | PlayerName") --- @type Frame

	--[[ Connections ]]

	boardFolder = I.Dirs.UmeReplicated:WaitForChild(_localName)
	boardFolder.ChildAdded:Connect(Module._watchRow)
	boardFolder.ChildRemoved:Connect(Module._onRowRemoved)
	for _index: number, config: Instance in ipairs(boardFolder:GetChildren()) do
		Module._watchRow(config)
	end
	I.Interact.OnPress(elems["Quick"], Module._quickJoin)
	I.Interact.OnPress(elems["Vote"], function()
		I.Network.Fire("MatchBoard_Vote")
	end)
	I.Interact.OnPress(elems["Leave"], function()
		I.Network.Fire("MatchBoard_Leave")
	end)
	I.DoEvery.Every(0.25, Module._tick)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Row

--[[
	Adds a line for a public row and redraws the board whenever any row changes.
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
		line.Visible = true
		line.Parent = elems["Rows"]
		lines[config.Name] = line
		I.Interact.OnPress(line:FindFirstChild("S_Join", true):FindFirstChild("Button"), function()
			I.Network.Fire("MatchBoard_Join", config.Name)
			I.WidgetManager.Close(_settings.MODES_GUI_NAME)
		end)
	end

	--[[ Connections ]]

	config.AttributeChanged:Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% On Row Removed

--[[
	Takes a started or closed row's line off the board.
]]
function Module._onRowRemoved(config: Instance)
	--[[ Removing ]]

	if lines[config.Name] then
		lines[config.Name]:Destroy()
		lines[config.Name] = nil
	end
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Quick Join

--[[
	Joins the open public match closest to starting: the one with the most players that still has room, a deathmatch
	first on a tie, since any party fits it. The server checks the party fits.
]]
function Module._quickJoin()
	--[[ Local Variables ]]

	local best: Instance? = nil
	local bestCount: number = -1

	--[[ Searching ]]

	for rowId: string, _line: Frame in pairs(lines) do
		local config: Instance? = boardFolder:FindFirstChild(rowId)
		if not config then
			continue
		end
		local count: number = #Module._getPlayers(config)
		local deathmatch: boolean = config:GetAttribute("Mode") == "Deathmatch"
		if count < config:GetAttribute("Size") and (count > bestCount or count == bestCount and deathmatch) then
			best = config
			bestCount = count
		end
	end

	--[[ Checks ]]

	-- Check if a match has room
	if not best then
		return
	end

	--[[ Joining ]]

	I.Network.Fire("MatchBoard_Join", best.Name)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws the board: each public row's mode, map, players and join button, or the waiting room of the row the player
	is in, with everyone in it and the votes.
]]
function Module._refresh()
	--[[ Lines ]]

	for rowId: string, line: Frame in pairs(lines) do
		local config: Instance? = boardFolder:FindFirstChild(rowId)
		if not config then
			continue
		end
		local mapRow = _settings.MAPS[config:GetAttribute("MapId")] --- @type MatchBoard_MapRow?
		local players = Module._getPlayers(config) --- @type { number }
		line:FindFirstChild("S_Mode", true).Text = _settings.MODE_NAMES[config:GetAttribute("Mode")] or config:GetAttribute("Mode")
		line:FindFirstChild("S_Map", true).Text = if mapRow then mapRow.Name else config:GetAttribute("MapId")
		line:FindFirstChild("S_Players", true).Text = `{#players} / {config:GetAttribute("Size")}`
		line:FindFirstChild("S_Thumbnail", true).Image = if mapRow then mapRow.Thumbnail else ""
		line:FindFirstChild("S_Join", true):FindFirstChild("ButtonText", true).Text = if config:GetAttribute("Mode") == "Deathmatch" then "Join" else "Join teams"
	end

	--[[ Waiting Room ]]

	local mine: Instance? = Module._getMyRow()
	local waiting: boolean = mine ~= nil and mine:GetAttribute("Kind") == "Public"
	elems["Play"].Visible = not waiting
	elems["WaitingRoom"].Visible = waiting
	if not mine or not waiting then
		return
	end

	local mapRow = _settings.MAPS[mine:GetAttribute("MapId")] --- @type MatchBoard_MapRow?
	local players = Module._getPlayers(mine) --- @type { number }
	elems["Match"].Text = `{_settings.MODE_NAMES[mine:GetAttribute("Mode")] or mine:GetAttribute("Mode")} • {if mapRow then mapRow.Name else ""}`
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
