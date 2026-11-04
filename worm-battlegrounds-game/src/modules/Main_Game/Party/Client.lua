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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._getElements()
	Module._createConnections()
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Finds the party panel's elements.
]]
function Module._getElements()
	--[[ General ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Members"] = moduleGui:FindFirstChild("U_Members", true) --- @type Frame
	elems["Invite"] = moduleGui:FindFirstChild("U_Invite", true):FindFirstChild("Button") --- @type ImageButton
	elems["InviteFriends"] = moduleGui:FindFirstChild("U_InviteFriends", true):FindFirstChild("Button") --- @type ImageButton
	elems["Leave"] = moduleGui:FindFirstChild("U_Leave", true) --- @type Frame

	--[[ Prefab ]]

	prefabs["Member"] = elems["Members"]:FindFirstChild("PREFAB | Member") --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Redraws the panel whenever anyone's party or level changes, and wires the buttons and invites.
]]
function Module._createConnections()
	--[[ Players ]]

	I.S.Players.PlayerAdded:Connect(Module._watchPlayer)
	I.S.Players.PlayerRemoving:Connect(Module._refresh)
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		Module._watchPlayer(player)
	end

	--[[ Buttons ]]

	I.Interact.OnPress(elems["Invite"], Module._inviteNext)
	I.Interact.OnPress(elems["InviteFriends"], function()
		I.Friends.PromptGameInvite()
	end)
	I.Interact.OnPress(elems["Leave"]:FindFirstChild("Button"), function()
		I.Network.Fire("Party_Leave")
	end)

	--[[ Invites ]]

	I.Network.Fired("Party_Invited", Module._onInvited)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Player

--[[
	Redraws the panel when a player's party or level changes.
]]
function Module._watchPlayer(player: Player)
	--[[ Connections ]]

	player.AttributeChanged:Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Lists the party's members (just the local player when they have none) with their level, the crown on the leader,
	and Kick buttons for the leader.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer
	local partyId: string? = localPlayer:GetAttribute("PartyId")
	local leader: boolean = localPlayer:GetAttribute("PartyLeader") == true
	local members = {} --- @type { Player }
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		if player == localPlayer or partyId and player:GetAttribute("PartyId") == partyId then
			table.insert(members, player)
		end
	end

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Members"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["Member"] then
			child:Destroy()
		end
	end

	--[[ Members ]]

	for _index: number, player: Player in ipairs(members) do
		local entry: Frame = prefabs["Member"]:Clone()
		local kick: Frame = entry:FindFirstChild("S_Kick", true)
		entry.Name = tostring(player.UserId)
		entry.LayoutOrder = if player:GetAttribute("PartyLeader") then 0 else 1
		entry.Visible = true
		entry:FindFirstChild("S_Name", true).Text = player.DisplayName
		entry:FindFirstChild("S_Level", true).Text = `Level {player:GetAttribute("Level") or 1}`
		entry:FindFirstChild("S_Avatar", true).Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
		entry:FindFirstChild("S_Crown", true).Visible = player:GetAttribute("PartyLeader") == true
		kick.Visible = leader and player ~= localPlayer
		entry.Parent = elems["Members"]
		I.Interact.OnPress(kick:FindFirstChild("Button"), function()
			I.Network.Fire("Party_Kick", player)
		end)
	end

	--[[ Buttons ]]

	elems["Leave"].Visible = partyId ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Invite Next

--[[
	Offers to invite each player in this server who isn't in a party, one at a time: yes sends the invite, no moves to
	the next. shortcut: no picker list in the Party gui yet, upgrade when it gets one.
]]
function Module._inviteNext()
	--[[ Local Variables ]]

	local candidates = {} --- @type { Player }
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		if player ~= I.S.Players.LocalPlayer and not player:GetAttribute("PartyId") then
			table.insert(candidates, player)
		end
	end

	--[[ Checks ]]

	-- Check if anyone can be invited
	if #candidates == 0 then
		I.WidgetManager.ShowMessage("Everyone here is already in a party. Invite friends instead!")
		return
	end

	--[[ Asking ]]

	for _index: number, player: Player in ipairs(candidates) do
		I.WidgetManager.ShowConfirmation(`Invite {player.DisplayName} to your party?`, function()
			I.Network.Fire("Party_Invite", player)
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Invited

--[[
	Asks whether to join the party of the player who invited the local player.
]]
function Module._onInvited(fromUserId: number)
	--[[ Local Variables ]]

	local from: Player? = I.S.Players:GetPlayerByUserId(fromUserId)

	--[[ Asking ]]

	I.WidgetManager.ShowConfirmation(`{if from then from.DisplayName else "Someone"} invited you to their party. Join?`, function()
		I.Network.Fire("Party_Answer", fromUserId, true)
	end, function()
		I.Network.Fire("Party_Answer", fromUserId, false)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
