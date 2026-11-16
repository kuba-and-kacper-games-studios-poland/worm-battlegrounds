--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Party"

--- @type Party_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Invites = require(_scripts:FindFirstChild("Client"):FindFirstChild("Invites")) --- @type Party_Client_Invites

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
	Invites.Start()
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Finds the party column's elements.
]]
function Module._getElements()
	--[[ General ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Leave"] = moduleGui:FindFirstChild("U_Party", true):FindFirstChild("S_Leave", true) --- @type ImageButton
	elems["Members"] = moduleGui:FindFirstChild("U_Members", true) --- @type Frame

	--[[ Prefab ]]

	prefabs["Member"] = elems["Members"]:FindFirstChild("PREFAB | Member") --- @type Frame
	prefabs["Invite"] = elems["Members"]:FindFirstChild("PREFAB | Invite") --- @type ImageButton

	--[[ Fitting ]]

	-- A custom lobby lists up to eight cards in a column made for MAX_PARTY: the column shrinks to fit them
	elems["FitScale"] = I.Create("UIScale")({ Name = "S_FitScale", Parent = elems["Members"] }) --- @type UIScale
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Redraws the column whenever anyone's party or level changes, and wires Leave.
]]
function Module._createConnections()
	--[[ Players ]]

	I.S.Players.PlayerAdded:Connect(Module._watchPlayer)
	I.S.Players.PlayerRemoving:Connect(Module._refresh)
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		Module._watchPlayer(player)
	end

	--[[ Buttons ]]

	I.Interact.OnPress(elems["Leave"], function()
		I.Network.Fire("Party_Leave")
	end)

	--[[ Custom Lobby ]]

	I.Topic.Subscribe("MatchBoard_RoomChanged", Module._refresh)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Player

--[[
	Redraws the column when a player's party or level changes.
]]
function Module._watchPlayer(player: Player)
	--[[ Connections ]]

	player.AttributeChanged:Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Lists the party's members (just the local player when they have none) with their avatar, name (their badges after
	it) and level, the crown on the leader and Kick for the leader, then a + card per free place for a player who may
	invite. In a custom lobby it lists the lobby instead: its members, the crown on its owner, and a + card per free
	place up to its size (opening the lobby's window to invite).
]]
function Module._refresh()
	--[[ Data ]]

	local room: Instance? = I.MatchBoard.GetCustomRoom()

	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer
	local partyId: string? = localPlayer:GetAttribute("PartyId")
	local leader: boolean = room == nil and localPlayer:GetAttribute("PartyLeader") == true
	local roomIds = if room then I.S.HttpService:JSONDecode(room:GetAttribute("Players") or "[]") else nil --- @type { number }?
	local places: number = if room then room:GetAttribute("Size") or _settings.MAX_PARTY else _settings.MAX_PARTY
	local members = {} --- @type { Player }
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		local inRoom: boolean = roomIds ~= nil and table.find(roomIds, player.UserId) ~= nil
		if player == localPlayer or inRoom or not room and partyId and player:GetAttribute("PartyId") == partyId then
			table.insert(members, player)
		end
	end

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Members"]:GetChildren()) do
		if child:IsA("GuiObject") and child ~= prefabs["Member"] and child ~= prefabs["Invite"] then
			child:Destroy()
		end
	end

	--[[ Members ]]

	for index: number, player: Player in ipairs(members) do
		local card: Frame = prefabs["Member"]:Clone()
		local kick: ImageButton = card:FindFirstChild("S_Kick", true)
		card.Name = tostring(player.UserId)
		local crowned: boolean = if room then room:GetAttribute("Owner") == player.UserId else player:GetAttribute("PartyLeader") == true
		card.LayoutOrder = if crowned then 0 else index
		card.Visible = true
		card:FindFirstChild("S_Name", true).Text = player.DisplayName
		card:FindFirstChild("S_Username", true).Text = `@{player.Name}`
		I.PlayerBadges.Show(card:FindFirstChild("S_Name", true), player.UserId)
		card:FindFirstChild("S_Level", true).Text = `Lv {player:GetAttribute("Level") or 1}`
		card:FindFirstChild("S_Avatar", true).Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
		card:FindFirstChild("S_Crown", true).Visible = crowned
		kick.Visible = leader and player ~= localPlayer
		card.Parent = elems["Members"]
		I.Interact.OnPress(kick, function()
			I.Network.Fire("Party_Kick", player)
		end)
	end

	--[[ Invites ]]

	-- Only the leader invites once there is a party; in a custom lobby, a free place opens the lobby's window
	if room or not partyId or leader then
		for place: number = #members + 1, places do
			local invite: ImageButton = prefabs["Invite"]:Clone()
			invite.Name = `Invite{place}`
			invite.LayoutOrder = places + place
			invite.Visible = true
			invite.Parent = elems["Members"]
			I.Interact.OnPress(invite, function()
				I.WidgetManager.Open(if room then _settings.CUSTOM_GUI_NAME else _settings.INVITE_GUI_NAME)
			end)
		end
	end

	--[[ Fitting ]]

	local cardHeight: number = prefabs["Member"].Size.Y.Scale
	local gap: number = elems["Members"]:FindFirstChildOfClass("UIListLayout").Padding.Scale
	local cards: number = math.max(places, #members)
	elems["FitScale"].Scale = math.min(1, (_settings.MAX_PARTY * cardHeight + (_settings.MAX_PARTY - 1) * gap) / (cards * cardHeight + (cards - 1) * gap))

	--[[ Buttons ]]

	elems["Leave"].Visible = room == nil and partyId ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
