--[[
	Created By: 	Nari
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
	Lists the party's members (just the local player when they have none) with their avatar, name and level, the
	crown on the leader and Kick for the leader, then a + card per free place for a player who may invite.
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
		if child:IsA("GuiObject") and child ~= prefabs["Member"] and child ~= prefabs["Invite"] then
			child:Destroy()
		end
	end

	--[[ Members ]]

	for index: number, player: Player in ipairs(members) do
		local card: Frame = prefabs["Member"]:Clone()
		local kick: ImageButton = card:FindFirstChild("S_Kick", true)
		card.Name = tostring(player.UserId)
		card.LayoutOrder = if player:GetAttribute("PartyLeader") then 0 else index
		card.Visible = true
		card:FindFirstChild("S_Name", true).Text = player.DisplayName
		card:FindFirstChild("S_Level", true).Text = `Lv {player:GetAttribute("Level") or 1}`
		card:FindFirstChild("S_Avatar", true).Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
		card:FindFirstChild("S_Crown", true).Visible = player:GetAttribute("PartyLeader") == true
		kick.Visible = leader and player ~= localPlayer
		card.Parent = elems["Members"]
		I.Interact.OnPress(kick, function()
			I.Network.Fire("Party_Kick", player)
		end)
	end

	--[[ Invites ]]

	-- Only the leader invites once there is a party
	if not partyId or leader then
		for place: number = #members + 1, _settings.MAX_PARTY do
			local invite: ImageButton = prefabs["Invite"]:Clone()
			invite.Name = `Invite{place}`
			invite.LayoutOrder = _settings.MAX_PARTY + place
			invite.Visible = true
			invite.Parent = elems["Members"]
			I.Interact.OnPress(invite, function()
				I.WidgetManager.Open(_settings.INVITE_GUI_NAME)
			end)
		end
	end

	--[[ Buttons ]]

	elems["Leave"].Visible = partyId ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
