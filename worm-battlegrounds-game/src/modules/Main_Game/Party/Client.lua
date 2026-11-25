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

	--[[ Frame ]]

	-- The card's rim takes the player's prestige frame: white, so the gradient on it shows the tier's colours
	local rim: ImageLabel = prefabs["Member"]:FindFirstChild("Background"):FindFirstChild("Stroke")
	rim.ImageColor3 = Color3.new(1, 1, 1)
	I.Create("UIGradient")({ Name = "S_Prestige", Rotation = 45, Parent = rim })

	--[[ Second Column ]]

	-- A custom lobby of more than COLUMN_CARDS lists the rest in a second column beside the first, its cards compact
	elems["MembersRight"] = elems["Members"]:Clone() --- @type Frame
	for _index: number, child: Instance in ipairs(elems["MembersRight"]:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	elems["MembersRight"].Name = "S_MembersRight"
	elems["MembersRight"].Position = UDim2.fromScale(_settings.SECOND_COLUMN_X, elems["Members"].Position.Y.Scale)
	elems["MembersRight"].Parent = elems["Members"].Parent
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
	Lists the party's members (just the local player when they have none) with their avatar in their prestige frame
	(their names and levels stand over their snails on the stage), the crown on the leader and Kick for the leader, then a + card per free
	place for a player who may invite. In a custom lobby it lists the lobby instead: its members, the crown on its
	owner, and a + card per free place up to its size (opening the lobby's window to invite); while the player picks a
	size on the lobby's create step, it shows that many places already. More than COLUMN_CARDS cards fill a second
	column.
]]
function Module._refresh()
	--[[ Data ]]

	local room: Instance? = I.MatchBoard.GetCustomRoom()
	local pickedSize: number? = I.MatchBoard.GetPickedSize()

	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer
	local partyId: string? = localPlayer:GetAttribute("PartyId")
	local leader: boolean = room == nil and localPlayer:GetAttribute("PartyLeader") == true
	local roomIds = if room then I.S.HttpService:JSONDecode(room:GetAttribute("Players") or "[]") else nil --- @type { number }?
	local places: number = if room then room:GetAttribute("Size") or _settings.MAX_PARTY else pickedSize or _settings.MAX_PARTY
	local members = {} --- @type { Player }
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		local inRoom: boolean = roomIds ~= nil and table.find(roomIds, player.UserId) ~= nil
		if player == localPlayer or inRoom or not room and partyId and player:GetAttribute("PartyId") == partyId then
			table.insert(members, player)
		end
	end

	--[[ Clearing ]]

	for _index: number, column: Instance in ipairs({ elems["Members"], elems["MembersRight"] }) do
		for _index2: number, child: Instance in ipairs(column:GetChildren()) do
			if child:IsA("GuiObject") and child ~= prefabs["Member"] and child ~= prefabs["Invite"] then
				child:Destroy()
			end
		end
	end

	--[[ Members ]]

	-- The crowned player first, then the rest as they joined
	for index: number, player: Player in ipairs(members) do
		if Module._isCrowned(player, room) then
			table.insert(members, 1, table.remove(members, index))
			break
		end
	end
	local cards = {} --- @type { GuiObject }
	for _index: number, player: Player in ipairs(members) do
		local card: Frame = prefabs["Member"]:Clone()
		local kick: ImageButton = card:FindFirstChild("S_Kick", true)
		card.Name = tostring(player.UserId)
		card.Visible = true
		card:FindFirstChild("S_Avatar", true).Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
		card:FindFirstChild("S_Crown", true).Visible = Module._isCrowned(player, room)
		I.G_Progression.ApplyFrame(card:FindFirstChild("S_Prestige", true), player:GetAttribute("Level") or 1)
		kick.Visible = leader and player ~= localPlayer
		I.Interact.OnPress(kick, function()
			I.Network.Fire("Party_Kick", player)
		end)
		table.insert(cards, card)
	end

	--[[ Invites ]]

	-- Only the leader invites once there is a party; in a custom lobby (or its create step), a free place opens its window
	local custom: boolean = room ~= nil or pickedSize ~= nil
	if custom or not partyId or leader then
		for place: number = #members + 1, places do
			local invite: ImageButton = prefabs["Invite"]:Clone()
			invite.Name = `Invite{place}`
			invite.Visible = true
			I.Interact.OnPress(invite, function()
				I.WidgetManager.Open(if custom then _settings.CUSTOM_GUI_NAME else _settings.INVITE_GUI_NAME)
			end)
			table.insert(cards, invite)
		end
	end

	--[[ Placing ]]

	for index: number, card: GuiObject in ipairs(cards) do
		card.LayoutOrder = index
		card.Parent = if index <= _settings.COLUMN_CARDS then elems["Members"] else elems["MembersRight"]
	end

	--[[ Buttons ]]

	elems["Leave"].Visible = room == nil and partyId ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Crowned

--[[
	Returns whether a player wears the crown: the custom lobby's owner, or the party's leader.
]]
--- @return boolean
function Module._isCrowned(player: Player, room: Instance?)
	return if room then room:GetAttribute("Owner") == player.UserId else player:GetAttribute("PartyLeader") == true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
