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

local Rotation = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Rotation")) --- @type MatchBoard_Rotation
local Custom = require(script.Parent:FindFirstChild("Custom")) --- @type MatchBoard_Client_Custom

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

-- The bots the player picked ("None" only in a party), and whether the panel sets up a party match
local picked: string = "Medium"
local party: boolean = false

-- The map the player picked ("Random" for any), and the maps the strip shows now (they follow the match's size)
local pickedMap: string = "Random"
local shownMaps: string = ""

-- Whether the panel sets up local play, and how many players share the screen then
local localPlay: boolean = false
local localPlayers: number = _settings.LOCAL_PLAYERS

-- Called whenever the panel opens or closes, so the board swaps its panels
local onChanged: () -> ()

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

--- @class MatchBoard_Client_Setup
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(changed: () -> ())
	--[[ Elements ]]

	onChanged = changed
	elems["Gui"] = I.UserInterface.UI[_settings.SETUP_GUI_NAME] --- @type ScreenGui
	elems["Setup"] = elems["Gui"]:FindFirstChild("U_Setup", true) --- @type Frame
	elems["Title"] = elems["Setup"]:FindFirstChild("S_Title", true) --- @type TextLabel
	elems["TitleIcon"] = elems["Setup"]:FindFirstChild("S_TitleIcon", true) --- @type ImageLabel
	elems["RewardText"] = elems["Setup"]:FindFirstChild("S_RewardText", true) --- @type TextLabel
	elems["RewardAmount"] = elems["Setup"]:FindFirstChild("S_RewardAmount", true) --- @type Frame
	elems["Reward"] = elems["Setup"]:FindFirstChild("S_Reward", true) --- @type TextLabel
	elems["Back"] = elems["Setup"]:FindFirstChild("S_Back", true) --- @type ImageButton
	elems["Start"] = elems["Setup"]:FindFirstChild("S_Start", true) --- @type ImageButton
	elems["MapList"] = elems["Setup"]:FindFirstChild("S_MapList", true) --- @type ScrollingFrame
	elems["MapPrefab"] = elems["Setup"]:FindFirstChild("PREFAB | SoloMap") --- @type ImageButton
	elems["PlayersRow"] = elems["Setup"]:FindFirstChild("S_PlayersRow", true) --- @type Frame

	--[[ Connections ]]

	for _index: number, difficulty: string in ipairs(Module._getChoices()) do
		elems[difficulty] = elems["Setup"]:FindFirstChild(`S_{difficulty}`, true) --- @type ImageButton
		I.Interact.OnPress(elems[difficulty], function()
			picked = difficulty
			Module._refresh()
		end)
	end
	for players: number = 2, _settings.LOCAL_MAX_PLAYERS do
		I.Interact.OnPress(elems["PlayersRow"]:FindFirstChild(`S_Players{players}`, true), function()
			localPlayers = players
			Module._refresh()
		end)
	end
	I.Interact.OnPress(elems["Back"], Module.Close)
	I.Interact.OnPress(elems["Start"], Module._start)
	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Topic.Subscribe("WidgetManager_Closed", Module._onClosed)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	Opens the setup widget for a solo match, for the player's party, or for local play (both may play without bots),
	through WidgetManager, which blurs and dims the world behind it as it does the custom lobby's window.
]]
function Module.Open(asParty: boolean, asLocal: boolean?)
	--[[ Saving ]]

	party = asParty
	localPlay = asLocal == true
	if localPlay then
		picked = "None"
	elseif not party and picked == "None" then
		picked = "Medium"
	end

	--[[ Opening ]]

	Module._refresh()
	I.WidgetManager.Open(_settings.SETUP_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	Closes the setup widget, back to the board.
]]
function Module.Close()
	I.WidgetManager.Close(_settings.SETUP_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	The setup opened: the board slides away, and on a pad the window holds the selection (Start first), B closing it.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the setup
	if widgetName ~= _settings.SETUP_GUI_NAME then
		return
	end

	--[[ Showing ]]

	onChanged()
	I.Console.Focus(elems["Setup"], Module.Close)
end

--%%%%%%%%%%%%%%%%%%%% On Closed

--[[
	The setup closed (Back, Start, or another widget opening over it): the board slides back and the pad lets go.
]]
function Module._onClosed(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the setup
	if widgetName ~= _settings.SETUP_GUI_NAME then
		return
	end

	--[[ Hiding ]]

	onChanged()
	I.Console.Unfocus(elems["Setup"])
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Writes the title and its mode icon (MODE_ICONS), shows how many share the screen only for local play and No bots only
	for a party or local play, marks the picked choices as the custom lobby does, says what a win pays (a solo match's
	coins, or how a party match pays), and lists the maps the match can be played on.
]]
function Module._refresh()
	--[[ Texts ]]

	elems["Title"].Text = if localPlay then "Local play" elseif party then "Play with party" else "Play solo"
	elems["TitleIcon"].Image = _settings.MODE_ICONS[if localPlay then "Local" elseif party then "Party" else "Bots"]
	elems["RewardText"].Text = _settings.REWARD_TEXT[if localPlay then "Local" elseif not party then "Solo" elseif picked == "None" then "PartyNoBots" else "Party"]
	elems["RewardAmount"].Visible = not party and not localPlay
	elems["Reward"].Text = tostring(_settings.SOLO_WIN_COINS[picked] or 0)

	--[[ Choices ]]

	elems["PlayersRow"].Visible = localPlay
	for players: number = 2, _settings.LOCAL_MAX_PLAYERS do
		Custom.SetPicked(elems["PlayersRow"]:FindFirstChild(`S_Players{players}`, true), players == localPlayers)
	end
	elems["None"].Visible = party or localPlay
	for _index: number, difficulty: string in ipairs(Module._getChoices()) do
		Custom.SetPicked(elems[difficulty], difficulty == picked)
	end

	--[[ Maps ]]

	Module._refreshMaps()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Maps

--[[
	Lists Random and the rotation's maps for the match's size (it changes with a party's bots), keeping the picked one
	when it's still there, and outlines the picked card as the custom lobby's are.
]]
function Module._refreshMaps()
	--[[ Local Variables ]]

	local players: number = if localPlay then localPlayers elseif party then Module._getPartyCount() else 1
	local pool = Rotation.GetPool(Rotation.GetPlaySize(players, picked)) --- @type { string }
	local key: string = table.concat(pool, ",")
	if pickedMap ~= "Random" and not table.find(pool, pickedMap) then
		pickedMap = "Random"
	end

	--[[ Building ]]

	if key ~= shownMaps then
		shownMaps = key
		for _index: number, child: Instance in ipairs(elems["MapList"]:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		Module._addMap("Random", 0)
		for index: number, mapId: string in ipairs(pool) do
			Module._addMap(mapId, index)
		end
	end

	--[[ Picked ]]

	for _index: number, card: Instance in ipairs(elems["MapList"]:GetChildren()) do
		if card:IsA("ImageButton") then
			Custom.SetPicked(card, card.Name == pickedMap)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Add Map

--[[
	Adds one map card to the strip: its picture, name and a press that picks it; Random shows the die and "Any map".
]]
function Module._addMap(mapId: string, order: number)
	--[[ Local Variables ]]

	local mapRow = _settings.MAPS[mapId] --- @type MatchBoard_MapRow?

	--[[ Cloning ]]

	local card: ImageButton = elems["MapPrefab"]:Clone()
	card.Name = mapId
	card.LayoutOrder = order
	card.Visible = true

	--[[ Texts ]]

	card:FindFirstChild("S_Icon", true).Image = if mapRow then mapRow.TileThumbnail else ""
	card:FindFirstChild("S_RandomIcon").Visible = mapRow == nil
	card:FindFirstChild("S_Name").Text = if mapRow then mapRow.Name else "Random"
	card:FindFirstChild("S_Info").Visible = mapRow == nil

	--[[ Saving ]]

	card.Parent = elems["MapList"]
	I.Interact.OnPress(card, function()
		pickedMap = mapId
		Module._refreshMaps()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Start

--[[
	Starts the solo, party or local match with the picked bots and map, and goes back to the board.
]]
function Module._start()
	--[[ Sending ]]

	if localPlay then
		I.Network.Fire("MatchBoard_PlayLocal", picked, pickedMap, localPlayers)
	elseif party then
		I.Network.Fire("MatchBoard_PlayParty", picked, pickedMap)
	else
		I.Network.Fire("MatchBoard_PlaySolo", picked, pickedMap)
	end

	--[[ Closing ]]

	Module.Close()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Open

--[[
	Returns whether the setup widget shows.
]]
--- @return boolean
function Module.IsOpen()
	return elems["Gui"].Enabled
end

--%%%%%%%%%%%%%%%%%%%% Get Party Count

--[[
	Returns how many players are in the local player's party in this server (1 alone).
]]
--- @return number
function Module._getPartyCount()
	--[[ Local Variables ]]

	local partyId: string? = I.S.Players.LocalPlayer:GetAttribute("PartyId")
	local count: number = 0

	--[[ Counting ]]

	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		if partyId and player:GetAttribute("PartyId") == partyId then
			count += 1
		end
	end

	--[[ Returning ]]

	return math.max(count, 1)
end

--%%%%%%%%%%%%%%%%%%%% Get Choices

--[[
	Returns every choice the panel has: No bots, then the difficulties.
]]
--- @return { string }
function Module._getChoices()
	--[[ Local Variables ]]

	local choices = { "None" } --- @type { string }
	table.move(_settings.SOLO_DIFFICULTIES, 1, #_settings.SOLO_DIFFICULTIES, 2, choices)

	--[[ Returning ]]

	return choices
end

return Module
