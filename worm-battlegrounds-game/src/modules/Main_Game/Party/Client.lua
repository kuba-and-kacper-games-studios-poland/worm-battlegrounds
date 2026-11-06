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

--[[ General ]]

-- Whether the panel is open under its tab: open on PC, folded on phones and tablets until tapped
local open: boolean

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
	Module._onPlatformChanged()
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
	local party: Frame = moduleGui:FindFirstChild("U_Party", true)
	elems["Tab"] = party:FindFirstChild("S_Tab", true) --- @type Frame
	elems["TabText"] = elems["Tab"]:FindFirstChild("ButtonText", true) --- @type TextLabel
	elems["TabFace"] = elems["Tab"]:FindFirstChild("Face", true) --- @type ImageLabel
	elems["TabIcon"] = elems["Tab"]:FindFirstChild("Icon", true) --- @type ImageLabel
	elems["Panel"] = party:FindFirstChild("S_Panel", true) --- @type Frame
	elems["Members"] = moduleGui:FindFirstChild("U_Members", true) --- @type Frame
	elems["Invite"] = moduleGui:FindFirstChild("U_Invite", true):FindFirstChild("Button") --- @type ImageButton
	elems["InviteFriends"] = moduleGui:FindFirstChild("U_InviteFriends", true):FindFirstChild("Button") --- @type ImageButton
	elems["Leave"] = moduleGui:FindFirstChild("U_Leave", true) --- @type Frame

	--[[ Prefab ]]

	prefabs["Member"] = elems["Members"]:FindFirstChild("PREFAB | Member") --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Redraws the panel whenever anyone's party or level changes, and wires the tab, the buttons and invites.
]]
function Module._createConnections()
	--[[ Tab ]]

	I.Interact.OnPress(elems["Tab"]:FindFirstChild("Button"), function()
		open = not open
		Module._refreshTab()
	end)
	I.Topic.Subscribe("Platform_Changed", Module._onPlatformChanged)

	--[[ Players ]]

	I.S.Players.PlayerAdded:Connect(Module._watchPlayer)
	I.S.Players.PlayerRemoving:Connect(Module._refresh)
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		Module._watchPlayer(player)
	end

	--[[ Buttons ]]

	I.Interact.OnPress(elems["Invite"], function()
		I.WidgetManager.Open(_settings.INVITE_GUI_NAME)
	end)
	I.Interact.OnPress(elems["InviteFriends"], function()
		I.Friends.PromptGameInvite()
	end)
	I.Interact.OnPress(elems["Leave"]:FindFirstChild("Button"), function()
		I.Network.Fire("Party_Leave")
	end)
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
	elems["TabText"].Text = `Party {#members}/{_settings.MAX_PARTY}`
end

--%%%%%%%%%%%%%%%%%%%% On Platform Changed

--[[
	Opens the panel on PC and console and folds it on phones and tablets, where it would cover the Loadout card.
]]
function Module._onPlatformChanged()
	--[[ Applying ]]

	open = I.Platform.Current ~= "Mobile"
	Module._refreshTab()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Tab

--[[
	Shows the panel while open, with the tab in the kit's selected skin and its arrow turned up; folded, only the tab.
]]
function Module._refreshTab()
	--[[ Applying ]]

	elems["Panel"].Visible = open
	elems["TabFace"].Image = elems["TabFace"]:GetAttribute(if open then "Kit_SelectedImage" else "Kit_Image")
	elems["TabIcon"].Rotation = if open then 180 else 0
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
