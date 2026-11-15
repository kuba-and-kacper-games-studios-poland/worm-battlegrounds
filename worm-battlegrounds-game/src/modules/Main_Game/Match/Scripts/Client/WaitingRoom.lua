--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--- @type Match_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui
local matchFolder: Folder

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

--- @class Match_Client_WaitingRoom
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Folder)
	--[[ Saving ]]

	matchFolder = folder

	--[[ Starting ]]

	Module._getElements()
	Module._createConnections()
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Finds the waiting room's parts in the MatchWaiting gui.
]]
function Module._getElements()
	--[[ General ]]

	moduleGui = I.UserInterface.UI[_settings.WAITING_GUI_NAME]
	elems["Room"] = moduleGui:FindFirstChild("U_WaitingRoom") --- @type Frame
	elems["Countdown"] = elems["Room"]:FindFirstChild("S_Countdown", true) --- @type TextLabel
	elems["Info"] = elems["Room"]:FindFirstChild("S_Info", true) --- @type TextLabel
	elems["Players"] = elems["Room"]:FindFirstChild("U_Players", true) --- @type ScrollingFrame
	elems["Ready"] = elems["Room"]:FindFirstChild("S_Ready", true) --- @type ImageButton
	elems["Leave"] = elems["Room"]:FindFirstChild("S_Leave", true) --- @type ImageButton

	--[[ Prefab ]]

	prefabs["PlayerName"] = elems["Players"]:FindFirstChild("PREFAB | PlayerName") --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Redraws the room when it opens, closes or changes, or when the player joins or leaves the match (the Studio map),
	wires Ready and Leave, and counts down.
]]
function Module._createConnections()
	--[[ Connections ]]

	matchFolder:GetAttributeChangedSignal("RoomEndsAt"):Connect(Module._refresh)
	matchFolder:GetAttributeChangedSignal("Room"):Connect(Module._refresh)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refresh)
	I.DoEvery.Every(0.25, Module._tick)

	--[[ Buttons ]]

	I.Interact.OnPress(elems["Ready"], function()
		I.Network.Fire("Match_Ready")
	end)
	I.Interact.OnPress(elems["Leave"], function()
		I.Network.Fire("Match_Leave")
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the room while the player's public match is open to joins: the mode and players, everyone seated (who's
	still on the way, who's ready), and Ready, which reads how many are.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local open: boolean = matchFolder:GetAttribute("RoomEndsAt") ~= nil and I.S.Players.LocalPlayer:GetAttribute("InMatch") == true
	local seats = I.S.HttpService:JSONDecode(matchFolder:GetAttribute("Room") or "[]") --- @type { Match_RoomSeat }

	--[[ Visibility ]]

	moduleGui.Enabled = open

	-- On a pad the room holds the selection while it shows
	if open then
		I.Console.Focus(elems["Room"])
	else
		I.Console.Unfocus(elems["Room"])
	end

	--[[ Checks ]]

	-- Check if the room shows
	if not open then
		return
	end

	--[[ Texts ]]

	local readyCount: number = 0
	local hereCount: number = 0
	local mineReady: boolean = false
	--- @param seat Match_RoomSeat
	for _index: number, seat in ipairs(seats) do
		readyCount += if seat.Ready then 1 else 0
		hereCount += if seat.Here then 1 else 0
		mineReady = mineReady or (seat.UserId == I.S.Players.LocalPlayer.UserId and seat.Ready)
	end
	elems["Info"].Text = `{matchFolder:GetAttribute("Mode")}  |  {#seats} / {matchFolder:GetAttribute("Size")} players`
	elems["Ready"]:FindFirstChild("S_Text").Text = if mineReady then `Waiting {readyCount}/{hereCount}` else `Ready {readyCount}/{hereCount}`

	--[[ Players ]]

	for _index: number, child: Instance in ipairs(elems["Players"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["PlayerName"] then
			child:Destroy()
		end
	end
	--- @param seat Match_RoomSeat
	for index: number, seat in ipairs(seats) do
		Module._addPlayer(seat, index)
	end
end

--%%%%%%%%%%%%%%%%%%%% Add Player

--[[
	Adds one seat to the room's list: their avatar and name, "Joining…" while they're on the way, and READY once they
	pressed it.
]]
--- @param seat Match_RoomSeat
function Module._addPlayer(seat, index: number)
	--[[ Local Variables ]]

	local player: Player? = I.S.Players:GetPlayerByUserId(seat.UserId)

	--[[ Cloning ]]

	local entry: Frame = prefabs["PlayerName"]:Clone()

	--[[ Elements ]]

	local name: TextLabel = entry:FindFirstChild("S_Name", true)
	local username: TextLabel = entry:FindFirstChild("S_Username", true)
	local avatar: ImageLabel = entry:FindFirstChild("S_Avatar", true)
	local ready: TextLabel = entry:FindFirstChild("S_ReadyTag", true)

	--[[ Texts ]]

	name.Text = seat.Name
	username.Text = if not seat.Here then "Joining…" elseif player then `@{player.Name}` else ""
	avatar.Image = `rbxthumb://type=AvatarHeadShot&id={seat.UserId}&w=150&h=150`

	--[[ Visibility ]]

	ready.Visible = seat.Ready

	--[[ Saving ]]

	entry.Name = tostring(seat.UserId)
	entry.LayoutOrder = index
	entry.Visible = true
	entry.Parent = elems["Players"]
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Counts the room's time down.
]]
function Module._tick()
	--[[ Checks ]]

	-- Check if the room shows
	if not moduleGui.Enabled then
		return
	end

	--[[ Applying ]]

	-- Clamped before rounding up: math.ceil of the last fraction of a second is -0
	local left: number = math.ceil(math.max((matchFolder:GetAttribute("RoomEndsAt") or 0) - I.S.Workspace:GetServerTimeNow(), 0))
	elems["Countdown"].Text = `Match starts in {string.format("%d:%02d", left // 60, left % 60)}`
end

return Module
