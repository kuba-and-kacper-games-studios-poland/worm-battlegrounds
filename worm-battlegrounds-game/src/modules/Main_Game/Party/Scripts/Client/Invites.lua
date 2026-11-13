--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Party"

--- @type Party_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local inviteGui: ScreenGui

-- The players invited since the list opened, so their button says Sent
local sent = {} --- @type { [number]: boolean }

-- Who the open invite is from, and when it runs out (os.clock)
local fromUserId: number? = nil
local inviteEndsAt: number = 0

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

--- @class Party_Client_Invites
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	inviteGui = I.UserInterface.UI[_settings.INVITE_GUI_NAME]
	elems["Players"] = inviteGui:FindFirstChild("U_Players", true) --- @type ScrollingFrame
	elems["Empty"] = inviteGui:FindFirstChild("S_Empty", true) --- @type TextLabel
	elems["InviteFriends"] = inviteGui:FindFirstChild("S_InviteFriends", true) --- @type ImageButton
	prefabs["Invitable"] = elems["Players"]:FindFirstChild("PREFAB | Invitable") --- @type Frame

	local invitedGui: ScreenGui = I.UserInterface.UI[_settings.INVITED_GUI_NAME]
	elems["From"] = invitedGui:FindFirstChild("S_Text", true) --- @type TextLabel
	elems["FromAvatar"] = invitedGui:FindFirstChild("S_Avatar", true) --- @type ImageLabel
	elems["Accept"] = invitedGui:FindFirstChild("S_Accept", true):FindFirstChild("Button") --- @type ImageButton
	elems["Decline"] = invitedGui:FindFirstChild("S_Decline", true):FindFirstChild("Button") --- @type ImageButton

	--[[ Connections ]]

	I.Topic.Subscribe("WidgetManager_Opened", function(name: string)
		if name == _settings.INVITE_GUI_NAME then
			sent = {}
			Module._refreshList()
		end
	end)
	I.Topic.Subscribe("WidgetManager_Closed", function(name: string)
		if name == _settings.INVITED_GUI_NAME then
			task.defer(Module._onInvitedClosed)
		end
	end)
	I.S.Players.PlayerAdded:Connect(Module._watchPlayer)
	I.S.Players.PlayerRemoving:Connect(Module._refreshList)
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		Module._watchPlayer(player)
	end
	I.Interact.OnPress(elems["InviteFriends"], function()
		I.Friends.PromptGameInvite()
	end)
	I.Interact.OnPress(elems["Accept"], function()
		Module._answer(true)
	end)
	I.Interact.OnPress(elems["Decline"], function()
		Module._answer(false)
	end)
	I.Network.Fired("Party_Invited", Module._onInvited)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Player

--[[
	Redraws the invite list when a player joins, or joins or leaves a party.
]]
function Module._watchPlayer(player: Player)
	--[[ Connections ]]

	player:GetAttributeChangedSignal("PartyId"):Connect(Module._refreshList)
	Module._refreshList()
end

--%%%%%%%%%%%%%%%%%%%% Refresh List

--[[
	While the invite box shows, lists everyone else in this server who isn't in a party, each with Invite (Sent, greyed
	from its Look_Sent* attributes, once pressed); with nobody to invite it says so.
]]
function Module._refreshList()
	--[[ Checks ]]

	-- Check if the invite box shows
	if not inviteGui.Enabled then
		return
	end

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Players"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["Invitable"] then
			child:Destroy()
		end
	end

	--[[ Players ]]

	local count: number = 0
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		if player == I.S.Players.LocalPlayer or player:GetAttribute("PartyId") then
			continue
		end
		count += 1

		local entry: Frame = prefabs["Invitable"]:Clone()
		local invite: ImageButton = entry:FindFirstChild("S_Invite", true)
		local inviteText: TextLabel = invite:FindFirstChild("S_Text")
		local look: string = if sent[player.UserId] then "Sent" else ""
		entry.Name = tostring(player.UserId)
		entry.LayoutOrder = count
		entry.Visible = true
		entry:FindFirstChild("S_Name", true).Text = player.DisplayName
		entry:FindFirstChild("S_Username", true).Text = `@{player.Name}`
		entry:FindFirstChild("S_Avatar", true).Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
		inviteText.Text = if sent[player.UserId] then "Sent" else "Invite"
		inviteText.TextColor3 = invite:GetAttribute(`Look_{look}TextColor`)
		invite:FindFirstChild("Background"):FindFirstChild("Stroke").ImageColor3 = invite:GetAttribute(`Look_{look}StrokeColor`)
		entry.Parent = elems["Players"]
		I.Interact.OnPress(invite, function()
			if sent[player.UserId] then
				return
			end
			sent[player.UserId] = true
			I.Network.Fire("Party_Invite", player)
			Module._refreshList()
		end)
	end

	--[[ Empty ]]

	elems["Empty"].Visible = count == 0
end

--%%%%%%%%%%%%%%%%%%%% On Invited

--[[
	Shows the invite box: who asked the local player to join their party, with Join party and No thanks.
]]
function Module._onInvited(userId: number)
	--[[ Local Variables ]]

	local from: Player? = I.S.Players:GetPlayerByUserId(userId)

	--[[ Showing ]]

	fromUserId = userId
	inviteEndsAt = os.clock() + _settings.INVITE_SECONDS
	elems["From"].Text = `{if from then from.DisplayName else "Someone"} invited you to their party!`
	elems["FromAvatar"].Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
	I.WidgetManager.Open(_settings.INVITED_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% On Invited Closed

--[[
	When another window replaced the invite box (the Party panel's + opens the invite list), brings the box back once
	that window closes, while the invite lasts. Closed by the player, it's dropped.
]]
function Module._onInvitedClosed()
	--[[ Checks ]]

	-- Check if the invite is still unanswered
	if not fromUserId then
		return
	end

	-- Check if the player closed it, or it ran out
	if not I.WidgetManager.GetCurrent() or os.clock() >= inviteEndsAt then
		fromUserId = nil
		return
	end

	--[[ Queueing ]]

	I.WidgetManager.OpenQueue(_settings.INVITED_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% Answer

--[[
	Answers the open invite and closes its box.
]]
function Module._answer(accept: boolean)
	--[[ Checks ]]

	-- Check if an invite is open
	if not fromUserId then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("Party_Answer", fromUserId, accept)
	fromUserId = nil

	--[[ Closing ]]

	I.WidgetManager.Close(_settings.INVITED_GUI_NAME)
end

return Module
