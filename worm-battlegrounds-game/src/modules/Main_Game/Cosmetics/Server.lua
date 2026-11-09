--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--- @type Cosmetics_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- When each player last played an emote (os.clock)
local lastEmote = {} --- @type { [Player]: number }

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

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	----------- DATA -----------
	----------------------------

	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Cosmetics"] = {
		EquippedSkin = _settings.DEFAULT_SKIN,
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	-- Where clients show emotes over snails
	I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})
	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)
	I.G_Player.OnPlayerRemoving(I.Priority.Default, function(player: Player)
		lastEmote[player] = nil
	end)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Cosmetics_Equip", { "Player", "string" }, { RateLimit = 2 })
	I.Network.Fired("Cosmetics_Equip", Module.Equip)
	I.Network.GetFunction("Cosmetics_BuyEmote", { "Player", "string" }, { RateLimit = 2 })
	I.Network.OnInvoke("Cosmetics_BuyEmote", Module.BuyEmote)
	I.Network.GetEvent("Cosmetics_PlayEmote", { "Player", "string" }, { RateLimit = 1 })
	I.Network.Fired("Cosmetics_PlayEmote", Module.PlayEmote)
	I.Network.GetEvent("Cosmetics_EmotePlayed")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Cosmetics = {

		--[[ Control ]]

		Equip = Module.Equip,
		BuyEmote = Module.BuyEmote,
		PlayEmote = Module.PlayEmote,

		--[[ Methods ]]

		GetSkin = Module.GetSkin,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Gives a joining player the starter skin and emote they don't have yet, and writes the skin they wear into their
	Cosmetics folder.
]]
function Module._createReplicator(player: Player)
	--[[ Granting ]]

	for _index: number, itemId: string in ipairs(_settings.STARTER_ITEMS) do
		if not I.Inventory.HasItem(player, itemId) then
			I.Inventory.AddItem(player, itemId)
		end
	end

	--[[ Publishing ]]

	I.Replicator.CreateFolder(player, _localName)
	Module._publish(player)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Equip

--[[
	**SERVER** |
	Wears an owned skin in the next match.
]]
--- @return boolean
function Module.Equip(player: Player, skinId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]

	--[[ Checks ]]

	-- Check if it's an owned skin
	if not I.G_Cosmetics.GetSkins()[skinId] or not I.Inventory.HasItem(player, skinId) then
		return false
	end

	--[[ Saving ]]

	moduleData["EquippedSkin"] = skinId

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Buy Emote

--[[
	**SERVER** |
	Buys an emote with coins when the player's level is high enough.
]]
--- @return boolean
function Module.BuyEmote(player: Player, emoteId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local row = I.G_Cosmetics.GetEmotes()[emoteId] --- @type Cosmetics_EmoteData?

	--[[ Checks ]]

	-- Check if it's an emote the player doesn't own yet
	if not row or I.Inventory.HasItem(player, emoteId) then
		return false
	end

	-- Check if the player's level is high enough
	if I.Progression.GetLevel(player) < row.Level then
		return false
	end

	-- Check if the player can pay
	if row.Coins ~= "0" and not I.Currency.Subtract(player, "Coins", row.Coins) then
		return false
	end

	--[[ Returning ]]

	return I.Inventory.AddItem(player, emoteId, "1", true)
end

--%%%%%%%%%%%%%%%%%%%% Play Emote

--[[
	**SERVER** |
	Plays an owned emote for everyone in the server, at most once every EMOTE_COOLDOWN seconds.
]]
--- @return boolean
function Module.PlayEmote(player: Player, emoteId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if it's an owned emote
	if not I.G_Cosmetics.GetEmotes()[emoteId] or not I.Inventory.HasItem(player, emoteId) then
		return false
	end

	-- Check if the cooldown is over
	if lastEmote[player] and os.clock() - lastEmote[player] < _settings.EMOTE_COOLDOWN then
		return false
	end

	--[[ Playing ]]

	lastEmote[player] = os.clock()
	I.Network.FireAll("Cosmetics_EmotePlayed", player.UserId, emoteId)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes the skin a player wears into their Cosmetics folder and onto the Player (EquippedSkin), where the lobby's
	party stage reads every member's.
]]
function Module._publish(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]

	--[[ Saving ]]

	I.Replicator.Set(player, _localName, "EquippedSkin", moduleData["EquippedSkin"])
	player:SetAttribute("EquippedSkin", moduleData["EquippedSkin"])
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Skin

--[[
	**SERVER** |
	Returns the skin a player takes into a match: its model's name in Assets.Skins, and whether it's shiny
	(SHINY_COPIES or more copies). A skin they no longer own falls back to the default.
]]
--- @return string, boolean
function Module.GetSkin(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]

	--[[ Local Variables ]]

	local skinId: string = moduleData["EquippedSkin"]
	if not I.G_Cosmetics.GetSkins()[skinId] or not I.Inventory.HasItem(player, skinId) then
		skinId = _settings.DEFAULT_SKIN
	end

	--[[ Returning ]]

	return I.G_Cosmetics.GetSkin(skinId).Model, (tonumber(I.Inventory.GetItem(player, skinId)) or 0) >= _settings.SHINY_COPIES
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
