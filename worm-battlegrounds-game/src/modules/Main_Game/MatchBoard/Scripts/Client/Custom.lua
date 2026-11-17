--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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

--[[ Choices ]]

local pickedMap: string = _settings.CUSTOM_MAP_POOL[1]
local pickedMode: string = "Deathmatch"
local pickedSize: number = 4
local pickedDifficulty: string = "None"

--[[ Room ]]

-- The lobby the player is in, and whether they asked to leave it (so its closing only shows the create step then)
local myRoomId: string? = nil
local leaving: boolean = false

-- Whether the window shows (the create step while the player is in no lobby)
local windowOpen: boolean = false

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

--- @class MatchBoard_Client_Custom
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Topics ]]

	-- The player's custom lobby changed: joined, left, someone came or went, or it closed (the lobby's stage and Party follow it)
	I.Topic.Register("MatchBoard_RoomChanged")
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.CUSTOM_GUI_NAME]
	elems["Create"] = moduleGui:FindFirstChild("U_Create", true) --- @type Frame
	elems["Maps"] = moduleGui:FindFirstChild("U_Maps", true) --- @type ScrollingFrame
	elems["Room"] = moduleGui:FindFirstChild("U_Room", true) --- @type Frame
	elems["Info"] = elems["Room"]:FindFirstChild("S_Info", true) --- @type TextLabel
	elems["Members"] = moduleGui:FindFirstChild("U_Members", true) --- @type ScrollingFrame
	elems["Invitable"] = moduleGui:FindFirstChild("U_Invitable", true) --- @type ScrollingFrame
	prefabs["MapChoice"] = elems["Maps"]:FindFirstChild("PREFAB | MapChoice") --- @type ImageButton
	prefabs["Member"] = elems["Members"]:FindFirstChild("PREFAB | Member") --- @type Frame
	prefabs["Invitable"] = elems["Invitable"]:FindFirstChild("PREFAB | Invitable") --- @type Frame

	--[[ Maps ]]

	for index: number, mapId: string in ipairs(_settings.CUSTOM_MAP_POOL) do
		local choice: ImageButton = prefabs["MapChoice"]:Clone()
		local mapRow = _settings.MAPS[mapId] --- @type MatchBoard_MapRow
		choice.Name = mapId
		choice.LayoutOrder = index
		choice.Visible = true
		choice:FindFirstChild("S_Icon", true).Image = mapRow.TileThumbnail
		choice:FindFirstChild("S_Name", true).Text = mapRow.Name
		choice:FindFirstChild("S_Info", true).Text = `{table.concat(mapRow.Sizes, " / ")} players`
		choice.Parent = elems["Maps"]
		I.Interact.OnPress(choice, function()
			pickedMap = mapId
			Module._fitSize()
			Module._refreshChoices()
			I.Topic.Publish("MatchBoard_RoomChanged")
		end)
	end

	--[[ Connections ]]

	for _index: number, mode: string in ipairs({ "Deathmatch", "Teams" }) do
		I.Interact.OnPress(Module._getButton(`S_{mode}`), function()
			pickedMode = mode
			Module._refreshChoices()
		end)
	end
	for _index: number, size: number in ipairs({ 2, 4, 6, 8 }) do
		I.Interact.OnPress(Module._getButton(`S_Players{size}`), function()
			-- Check if the picked map is made for this size
			if not table.find(_settings.MAPS[pickedMap].Sizes, size) then
				return
			end
			pickedSize = size
			Module._refreshChoices()
			I.Topic.Publish("MatchBoard_RoomChanged")
		end)
	end
	for _index: number, difficulty: string in ipairs(_settings.CUSTOM_DIFFICULTIES) do
		I.Interact.OnPress(Module._getButton(`S_Bots{difficulty}`), function()
			pickedDifficulty = difficulty
			Module._refreshChoices()
		end)
	end
	I.Interact.OnPress(Module._getButton("S_Create"), function()
		I.Network.Fire("MatchBoard_CreateCustom", pickedMap, pickedMode, pickedSize, pickedDifficulty)
	end)
	I.Interact.OnPress(Module._getButton("S_Start"), Module._onStart)
	I.Interact.OnPress(Module._getButton("S_Leave"), function()
		leaving = true
		I.Network.Fire("MatchBoard_LeaveCustom")
	end)
	I.Interact.OnPress(Module._getButton("S_InviteFriends"), function()
		I.Friends.PromptGameInvite()
	end)

	boardFolder = I.Dirs.UmeReplicated:WaitForChild(_localName)
	boardFolder.ChildAdded:Connect(function(config: Instance)
		config.AttributeChanged:Connect(Module._refreshRoom)
		Module._refreshRoom()
	end)
	for _index: number, config: Instance in ipairs(boardFolder:GetChildren()) do
		config.AttributeChanged:Connect(Module._refreshRoom)
	end
	boardFolder.ChildRemoved:Connect(Module._onRoomRemoved)
	I.S.Players.PlayerAdded:Connect(Module._refreshRoom)
	I.S.Players.PlayerRemoving:Connect(Module._refreshRoom)
	I.Network.Fired("MatchBoard_Invited", Module._onInvited)
	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Topic.Subscribe("WidgetManager_Closed", Module._onClosed)
	Module._refreshChoices()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Picked

--[[
	Marks a button or map choice as picked, or not (the setup panel's too), in the design's looks it keeps (its Look_*
	attributes): a white outline and text when picked, grey when not.
]]
function Module.SetPicked(button: ImageButton, picked: boolean)
	--[[ Elements ]]

	local background: Frame = button:FindFirstChild("Background")
	local stroke: ImageLabel = background:FindFirstChild("Stroke")
	local label: TextLabel = button:FindFirstChild("Name1") or button:FindFirstChild("S_Name")

	--[[ Applying ]]

	stroke.ImageColor3 = button:GetAttribute(if picked then "Look_SelectedStrokeColor" else "Look_StrokeColor")
	label.TextColor3 = button:GetAttribute(if picked then "Look_SelectedTextColor" else "Look_TextColor")

	-- Buttons of one size share the picked and unpicked outline pictures; the bots' row keeps each button's own
	if button:GetAttribute("Look_Stroke") then
		stroke.Image = button:GetAttribute(if picked then "Look_SelectedStroke" else "Look_Stroke")
		background:FindFirstChild("Stroke2").Image = button:GetAttribute(if picked then "Look_SelectedStroke2" else "Look_Stroke2")
	end
end

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Shows the create step or the player's lobby when the window opens.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's this window
	if widgetName ~= _settings.CUSTOM_GUI_NAME then
		return
	end

	--[[ Refreshing ]]

	windowOpen = true
	Module._refreshChoices()
	Module._refreshRoom()
end

--%%%%%%%%%%%%%%%%%%%% On Closed

--[[
	Tells Party the create step's size no longer stands in for a lobby when the window closes.
]]
function Module._onClosed(widgetName: string)
	--[[ Checks ]]

	-- Check if it's this window
	if widgetName ~= _settings.CUSTOM_GUI_NAME then
		return
	end

	--[[ Publishing ]]

	windowOpen = false
	I.Topic.Publish("MatchBoard_RoomChanged")
end

--%%%%%%%%%%%%%%%%%%%% Refresh Choices

--[[
	Marks the picked map, mode, player count and bots, and greys out the player counts the picked map isn't made for.
]]
function Module._refreshChoices()
	--[[ Applying ]]

	for _index: number, mapId: string in ipairs(_settings.CUSTOM_MAP_POOL) do
		Module.SetPicked(elems["Maps"]:FindFirstChild(mapId), mapId == pickedMap)
	end
	for _index: number, mode: string in ipairs({ "Deathmatch", "Teams" }) do
		Module.SetPicked(elems["Create"]:FindFirstChild(`S_{mode}`, true), mode == pickedMode)
	end
	for _index: number, size: number in ipairs({ 2, 4, 6, 8 }) do
		local button: ImageButton = elems["Create"]:FindFirstChild(`S_Players{size}`, true)
		Module.SetPicked(button, size == pickedSize)
		Module._setFaded(button, not table.find(_settings.MAPS[pickedMap].Sizes, size))
	end
	for _index: number, difficulty: string in ipairs(_settings.CUSTOM_DIFFICULTIES) do
		Module.SetPicked(elems["Create"]:FindFirstChild(`S_Bots{difficulty}`, true), difficulty == pickedDifficulty)
	end
end

--%%%%%%%%%%%%%%%%%%%% Fit Size

--[[
	Moves the picked player count to the nearest one the picked map is made for, when it isn't one.
]]
function Module._fitSize()
	--[[ Local Variables ]]

	local sizes = _settings.MAPS[pickedMap].Sizes --- @type { number }

	--[[ Checks ]]

	-- Check if the map already holds the picked count
	if table.find(sizes, pickedSize) then
		return
	end

	--[[ Fitting ]]

	local best: number = sizes[1]
	for _index: number, size: number in ipairs(sizes) do
		if math.abs(size - pickedSize) < math.abs(best - pickedSize) then
			best = size
		end
	end
	pickedSize = best
end

--%%%%%%%%%%%%%%%%%%%% Set Faded

--[[
	Fades a choice the picked map can't take (its pictures and text see-through), or brings back the design's own
	transparency, which each part keeps on itself (Look_Transparency) the first time.
]]
function Module._setFaded(button: ImageButton, faded: boolean)
	--[[ Applying ]]

	for _index: number, part: Instance in ipairs(button:GetDescendants()) do
		local property: string? = if part:IsA("ImageLabel") then "ImageTransparency" elseif part:IsA("TextLabel") then "TextTransparency" else nil
		if property then
			if part:GetAttribute("Look_Transparency") == nil then
				part:SetAttribute("Look_Transparency", part[property])
			end
			local own: number = part:GetAttribute("Look_Transparency")
			part[property] = if faded then 1 - (1 - own) * 0.35 else own
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% On Room Removed

--[[
	A lobby closed: when it was the player's and they didn't leave it (it started, or its owner closed it), the window
	closes instead of going back to the create step.
]]
function Module._onRoomRemoved(config: Instance)
	--[[ Closing ]]

	if config.Name == myRoomId and not leaving then
		I.WidgetManager.Close(_settings.CUSTOM_GUI_NAME)
	end

	--[[ Refreshing ]]

	Module._refreshRoom()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Room

--[[
	Shows the player's lobby when they're in one: its settings, its members then an open slot per free place up to its
	size, and everyone in this server they can invite (the owner only). Tells the lobby's stage and Party
	(MatchBoard_RoomChanged).
]]
function Module._refreshRoom()
	--[[ Data ]]

	local room: Instance? = Module.GetMyRoom()
	myRoomId = if room then room.Name else nil
	leaving = leaving and room ~= nil

	--[[ Publishing ]]

	I.Topic.Publish("MatchBoard_RoomChanged")

	--[[ Visibility ]]

	elems["Create"].Visible = room == nil
	elems["Room"].Visible = room ~= nil
	if not room then
		return
	end

	--[[ Clearing ]]

	for _index: number, list: string in ipairs({ "Members", "Invitable" }) do
		for _index2: number, child: Instance in ipairs(elems[list]:GetChildren()) do
			if child:IsA("Frame") and child ~= prefabs["Member"] and child ~= prefabs["Invitable"] then
				child:Destroy()
			end
		end
	end

	--[[ Info ]]

	local members = I.S.HttpService:JSONDecode(room:GetAttribute("Players") or "[]") --- @type { number }
	local mapRow = _settings.MAPS[room:GetAttribute("MapId")] --- @type MatchBoard_MapRow?
	local owner: boolean = room:GetAttribute("Owner") == I.S.Players.LocalPlayer.UserId
	local difficulty: string = room:GetAttribute("Difficulty")
	local bots: string = if difficulty == "None" then "No bots" else `{difficulty} bots`
	elems["Info"].Text = `{room:GetAttribute("Mode")}  |  {room:GetAttribute("Size")} players  |  {if mapRow then mapRow.Name else ""}  |  {bots}`
	Module._getButton("S_Start").Visible = owner

	--[[ Members ]]

	for index: number, userId: number in ipairs(members) do
		local entry: Frame = prefabs["Member"]:Clone()
		local player: Player? = I.S.Players:GetPlayerByUserId(userId)
		entry.Name = tostring(userId)
		entry.LayoutOrder = index
		entry.Visible = true
		entry:FindFirstChild("S_Name", true).Text = if player then player.DisplayName else "?"
		entry:FindFirstChild("S_Username", true).Text = if player then `@{player.Name}` else ""
		entry:FindFirstChild("S_Avatar", true).Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
		entry.Parent = elems["Members"]
	end

	--[[ Open Slots ]]

	for place: number = #members + 1, room:GetAttribute("Size") or #members do
		local entry: Frame = prefabs["Member"]:Clone()
		local nameLabel: TextLabel = entry:FindFirstChild("S_Name", true)
		entry.Name = `Open{place}`
		entry.LayoutOrder = place
		entry.Visible = true
		nameLabel.Text = _settings.CUSTOM_OPEN_SLOT_TEXT
		nameLabel.TextTransparency = _settings.CUSTOM_OPEN_SLOT_TRANSPARENCY
		entry:FindFirstChild("S_Username", true).Text = ""
		entry:FindFirstChild("S_Avatar", true).Image = ""
		entry.Parent = elems["Members"]
	end

	--[[ Invitable ]]

	if not owner then
		return
	end
	for index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		if table.find(members, player.UserId) then
			continue
		end
		local entry: Frame = prefabs["Invitable"]:Clone()
		entry.Name = tostring(player.UserId)
		entry.LayoutOrder = index
		entry.Visible = true
		entry:FindFirstChild("S_Name", true).Text = player.DisplayName
		entry:FindFirstChild("S_Username", true).Text = `@{player.Name}`
		entry:FindFirstChild("S_Avatar", true).Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
		entry.Parent = elems["Invitable"]
		I.Interact.OnPress(entry:FindFirstChild("S_Invite", true), function()
			I.Network.Fire("MatchBoard_InviteCustom", player)
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Start

--[[
	The owner presses Start: the lobby starts once someone else or bots will play, else a message says they can't start
	alone.
]]
function Module._onStart()
	--[[ Data ]]

	local room: Instance? = Module.GetMyRoom()
	local members = I.S.HttpService:JSONDecode(if room then room:GetAttribute("Players") or "[]" else "[]") --- @type { number }

	--[[ Checks ]]

	-- Check if anyone else, or bots, will play
	if #members < 2 and (not room or room:GetAttribute("Difficulty") == "None") then
		I.WidgetManager.ShowMessage(_settings.CUSTOM_ALONE_MESSAGE)
		return
	end

	--[[ Sending ]]

	I.Network.Fire("MatchBoard_StartCustom")
end

--%%%%%%%%%%%%%%%%%%%% On Invited

--[[
	Asks whether to join a lobby another player invited the local player to.
]]
function Module._onInvited(fromUserId: number, roomId: string)
	--[[ Local Variables ]]

	local from: Player? = I.S.Players:GetPlayerByUserId(fromUserId)

	--[[ Asking ]]

	I.WidgetManager.ShowConfirmation(`{if from then from.DisplayName else "Someone"} invited you to a custom lobby. Join?`, function()
		I.Network.Fire("MatchBoard_InviteAnswer", roomId, true)
		I.WidgetManager.Open(_settings.CUSTOM_GUI_NAME)
	end, function()
		I.Network.Fire("MatchBoard_InviteAnswer", roomId, false)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get My Room

--[[
	**CLIENT** |
	Returns the custom lobby the local player is in (its Configuration: `Players`, `Size`, `Owner`…), nil when in none
	or before the board has arrived.
]]
--- @return Instance?
function Module.GetMyRoom()
	--[[ Checks ]]

	-- Check if the board has arrived
	if not boardFolder then
		return nil
	end

	--[[ Searching ]]

	for _index: number, config: Instance in ipairs(boardFolder:GetChildren()) do
		local members = I.S.HttpService:JSONDecode(config:GetAttribute("Players") or "[]") --- @type { number }
		if config:GetAttribute("Kind") == "Custom" and table.find(members, I.S.Players.LocalPlayer.UserId) then
			return config
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Picked Size

--[[
	**CLIENT** |
	Returns the player count picked on the create step while the window shows it (the player is in no lobby yet), so
	Party can show that many places before the lobby exists; nil otherwise.
]]
--- @return number?
function Module.GetPickedSize()
	return if windowOpen and Module.GetMyRoom() == nil then pickedSize else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Button

--[[
	Returns a named button in the window.
]]
--- @return ImageButton
function Module._getButton(buttonName: string)
	return moduleGui:FindFirstChild(buttonName, true)
end

return Module
