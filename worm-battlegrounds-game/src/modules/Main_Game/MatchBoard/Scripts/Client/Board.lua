--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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

--[[ Play ]]

-- Whether the play screen (the lobby rows and buttons) shows or is slid away, and where each of its parts rests
local playShown: boolean = true
local playHomes = {} --- @type { [GuiObject]: UDim2 }

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
	elems["Solo"] = elems["Play"]:FindFirstChild("S_Solo", true) --- @type ImageButton
	elems["Custom"] = elems["Play"]:FindFirstChild("S_Custom", true) --- @type ImageButton
	elems["Rows"] = elems["Play"]:FindFirstChild("U_Rows", true) --- @type ScrollingFrame
	prefabs["Row"] = elems["Rows"]:FindFirstChild("PREFAB | Row") --- @type Frame

	--[[ Saving ]]

	for _index: number, part: Instance in ipairs(elems["Play"]:GetChildren()) do
		if part:IsA("GuiObject") then
			playHomes[part] = part.Position
		end
	end

	--[[ Setup ]]

	Setup.Start(moduleGui, Module._refresh)

	--[[ Connections ]]

	boardFolder = I.Dirs.UmeReplicated:WaitForChild(_localName)
	boardFolder.ChildAdded:Connect(Module._watchRow)
	boardFolder.ChildRemoved:Connect(Module._onRowRemoved)
	for _index: number, config: Instance in ipairs(boardFolder:GetChildren()) do
		Module._watchRow(config)
	end
	I.Interact.OnPress(elems["Solo"], Module._onPlay)
	I.Interact.OnPress(elems["Custom"], function()
		if elems["Custom"]:GetAttribute("Interact_Function") == "" then
			I.WidgetManager.ShowMessage("Your party's leader picks the match.")
		end
	end)

	-- A card's map depends on how many travel with the player, so any player's party change redraws the board
	I.S.Players.PlayerAdded:Connect(Module._watchPlayer)
	I.S.Players.PlayerRemoving:Connect(Module._refresh)
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		Module._watchPlayer(player)
	end

	--[[ Selection ]]

	-- On a pad the selection rests on SOLO VS BOTS while nothing else wants it (the Console module's home)
	I.Console.SetHome(elems["Solo"])
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Row

--[[
	Adds a lobby card for a public row, in PUBLIC_ROWS order, and redraws the board whenever any row changes.
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
		I.Interact.OnPress(line:FindFirstChild("S_Join"), function()
			if Module._isPartyMember() then
				I.WidgetManager.ShowMessage("Your party's leader picks the match.")
				return
			end
			I.Network.Fire("MatchBoard_Join", config.Name)
		end)
	end

	--[[ Connections ]]

	config.AttributeChanged:Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Watch Player

--[[
	Redraws the board when a player's party changes.
]]
function Module._watchPlayer(player: Player)
	--[[ Connections ]]

	player.AttributeChanged:Connect(Module._refresh)
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
	Solo vs bots opens the setup for a solo match; in a party it sets up the party's match, which only the leader starts.
]]
function Module._onPlay()
	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer

	--[[ Checks ]]

	-- Check if the player may start their party's match
	if localPlayer:GetAttribute("PartyId") and not localPlayer:GetAttribute("PartyLeader") then
		I.WidgetManager.ShowMessage("Your party's leader picks the match.")
		return
	end

	--[[ Opening ]]

	Setup.Open(localPlayer:GetAttribute("PartyId") ~= nil)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws the board: Solo vs bots (Play with party in a party), and each public card's mode, the map a Join would land
	on for the player's group (the open match it'd join, or a new one on the card's map), its picture, and Join. The
	setup panel shows in the board's place, which slides away for it. A party member's Join, Play and Custom are greyed
	out (their leader picks), but Custom opens their leader's lobby once they're in it.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local member: boolean = Module._isPartyMember()
	local mine: Instance? = Module._getMyRow()
	local groupSize: number = Module._getGroupSize()

	--[[ Lines ]]

	for rowId: string, line: Frame in pairs(lines) do
		local config: Instance? = boardFolder:FindFirstChild(rowId)
		if not config then
			continue
		end
		local targets = I.S.HttpService:JSONDecode(config:GetAttribute("Targets") or "[]") --- @type { string }
		local target: string = targets[groupSize] or ""
		local mapRow = _settings.MAPS[if target ~= "" then target else config:GetAttribute("MapId")] --- @type MatchBoard_MapRow?
		line:FindFirstChild("S_Mode", true).Text = _settings.MODE_NAMES[config:GetAttribute("Mode")] or config:GetAttribute("Mode")
		line:FindFirstChild("S_Map", true).Text = if mapRow then mapRow.Name else ""
		line:FindFirstChild("S_Join"):FindFirstChild("Name1").Text = if member then "Host picks" else "Join"
		Module._setLocked(line:FindFirstChild("S_Join"), member)

		-- A map with no Thumbnail yet shows a plain card
		line:FindFirstChild("S_MapIcon", true).Image = if mapRow then mapRow.Thumbnail else ""
	end

	--[[ Play ]]

	elems["Solo"]:FindFirstChild("Name1").Text = if member then "Waiting for host" elseif I.S.Players.LocalPlayer:GetAttribute("PartyId") then "Play with party" else "Solo vs bots"
	Module._setLocked(elems["Solo"], member)

	--[[ Custom ]]

	-- A party member opens only their leader's lobby, which they're put in when it's made
	local inCustom: boolean = mine ~= nil and mine:GetAttribute("Kind") == "Custom"
	local customLocked: boolean = member and not inCustom
	elems["Custom"]:FindFirstChild("Name1").Text = if inCustom and member then "Party lobby" elseif member then "Host picks" else "Custom"
	elems["Custom"]:SetAttribute("Interact_Function", if customLocked then "" else "Toggle")
	Module._setLocked(elems["Custom"], customLocked)

	--[[ Panels ]]

	Module._slidePlay(not Setup.IsOpen())
end

--%%%%%%%%%%%%%%%%%%%% Slide Play

--[[
	Slides the play screen's parts (the lobby rows, SOLO VS BOTS and CUSTOM) down off the screen when the setup panel
	takes its place, and back up after; once they're gone it's hidden, so nothing in it takes a press.
]]
function Module._slidePlay(shown: boolean)
	--[[ Checks ]]

	-- Check if it changes
	if shown == playShown then
		return
	end

	--[[ Sliding ]]

	playShown = shown
	elems["Play"].Visible = true
	for part: GuiObject, home: UDim2 in pairs(playHomes) do
		local away: UDim2 = UDim2.new(home.X.Scale, home.X.Offset, 1 + part.AnchorPoint.Y * part.Size.Y.Scale + _settings.PLAY_SLIDE_MARGIN, 0)
		local Slide_TweenGoal = { Position = if shown then home else away }
		local Slide_Tween: Tween = I.S.TweenService:Create(part, if shown then _settings.PLAY_IN_TWEENINFO else _settings.PLAY_OUT_TWEENINFO, Slide_TweenGoal)
		Slide_Tween:Play()
	end

	--[[ Hiding ]]

	-- A show before the slide ends keeps it
	if not shown then
		task.delay(_settings.PLAY_OUT_TWEENINFO.Time, function()
			if not playShown then
				elems["Play"].Visible = false
			end
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Locked

--[[
	Greys a button out while the player's party leader picks the match, or gives it back the design's look, which it
	keeps on itself (its Look_* attributes) the first time.
]]
function Module._setLocked(button: ImageButton, locked: boolean)
	--[[ Elements ]]

	local main: ImageLabel = button:FindFirstChild("Background"):FindFirstChild("Main")
	local stroke: ImageLabel = button:FindFirstChild("Background"):FindFirstChild("Stroke")
	local text: TextLabel = button:FindFirstChild("Name1")

	--[[ Saving ]]

	if button:GetAttribute("Look_MainColor") == nil then
		button:SetAttribute("Look_MainColor", main.ImageColor3)
		button:SetAttribute("Look_StrokeColor", stroke.ImageColor3)
		button:SetAttribute("Look_TextColor", text.TextColor3)
		button:SetAttribute("Look_HoverScale", button:GetAttribute("Utils_HoverScale"))
		button:SetAttribute("Look_ClickScale", button:GetAttribute("Utils_ClickScale"))
	end

	--[[ Applying ]]

	main.ImageColor3 = if locked then _settings.LOCKED_MAIN_COLOR else button:GetAttribute("Look_MainColor")
	stroke.ImageColor3 = if locked then _settings.LOCKED_STROKE_COLOR else button:GetAttribute("Look_StrokeColor")
	text.TextColor3 = if locked then _settings.LOCKED_TEXT_COLOR else button:GetAttribute("Look_TextColor")

	-- A locked button doesn't bounce under the pointer
	button:SetAttribute("Utils_HoverScale", if locked then 1 else button:GetAttribute("Look_HoverScale"))
	button:SetAttribute("Utils_ClickScale", if locked then 1 else button:GetAttribute("Look_ClickScale"))
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

--%%%%%%%%%%%%%%%%%%%% Get Group Size

--[[
	Returns how many travel with the local player: their party's members in this server, or just them.
]]
--- @return number
function Module._getGroupSize()
	--[[ Local Variables ]]

	local partyId: string? = I.S.Players.LocalPlayer:GetAttribute("PartyId")
	local count: number = 0

	--[[ Counting ]]

	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		if player == I.S.Players.LocalPlayer or (partyId and player:GetAttribute("PartyId") == partyId) then
			count += 1
		end
	end

	--[[ Returning ]]

	return count
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

--%%%%%%%%%%%%%%%%%%%% Is Party Member

--[[
	Returns whether the local player is in a party they don't lead, so their leader picks the match.
]]
--- @return boolean
function Module._isPartyMember()
	return I.S.Players.LocalPlayer:GetAttribute("PartyId") ~= nil and not I.S.Players.LocalPlayer:GetAttribute("PartyLeader")
end

return Module
