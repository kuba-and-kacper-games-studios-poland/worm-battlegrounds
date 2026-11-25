--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--- @type Cosmetics_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- When each player last played an emote (os.clock)
local lastEmote = {} --- @type { [Player]: number }

-- When each bot's snail last played one (PlaySnailEmote), by its snail's id
local lastSnailEmote = {} --- @type { [string]: number }

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
		Outfit = table.clone(_settings.DEFAULT_OUTFIT),
		PiecesGiven = false,
		SeenPieces = {},
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	-- Where clients show emotes over snails
	I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})
	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._setUpPlayer)
	I.G_Player.OnPlayerRemoving(I.Priority.Default, function(player: Player)
		lastEmote[player] = nil
	end)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Cosmetics_Equip", { "Player", "string", "string" }, { RateLimit = 4 })
	I.Network.Fired("Cosmetics_Equip", Module.Equip)
	I.Network.GetEvent("Cosmetics_See", { "Player", "string" }, { RateLimit = 4 })
	I.Network.Fired("Cosmetics_See", Module.See)
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
		See = Module.See,
		BuyEmote = Module.BuyEmote,
		PlayEmote = Module.PlayEmote,
		PlaySnailEmote = Module.PlaySnailEmote,

		--[[ Methods ]]

		GetOutfit = Module.GetOutfit,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Set Up Player

--[[
	Gives a joining player the starter pieces and emote they don't have yet (seen already, so never NEW), swaps the
	whole skins they owned for their sets' pieces once, and writes the outfit they wear onto the Player and the pieces
	they've seen into their Cosmetics folder.
]]
function Module._setUpPlayer(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]

	--[[ Granting ]]

	for _index: number, itemId: string in ipairs(_settings.STARTER_ITEMS) do
		if not I.Inventory.HasItem(player, itemId) then
			I.Inventory.AddItem(player, itemId)
		end
		if I.G_Cosmetics.GetPieces()[itemId] then
			moduleData["SeenPieces"][itemId] = true
		end
	end
	Module._givePieces(player)

	--[[ Publishing ]]

	I.Replicator.CreateFolder(player, _localName)
	Module._publish(player)
	Module._publishSeen(player)
end

--%%%%%%%%%%%%%%%%%%%% Give Pieces

--[[
	Once per player (the owner's pick, 2026-11-14): every skin they own gives each piece of its set as many copies as
	the skin had, so a shiny skin makes shiny pieces, and the skin they wore becomes the pieces they wear. The skins stay
	in their inventory.
]]
function Module._givePieces(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]

	--[[ Checks ]]

	-- Check if the pieces were given already
	if moduleData["PiecesGiven"] then
		return
	end

	--[[ Giving ]]

	--- @param set Cosmetics_SetData
	for setId: string, set in pairs(I.G_Cosmetics.GetSets()) do
		local copies: number = tonumber(I.Inventory.GetItem(player, set.Skin)) or 0
		if copies == 0 then
			continue
		end
		for _slot: string, pieceId: string in pairs(I.G_Cosmetics.GetSetPieces(setId)) do
			local have: number = tonumber(I.Inventory.GetItem(player, pieceId)) or 0
			if copies > have then
				I.Inventory.AddItem(player, pieceId, tostring(copies - have), true)
			end
		end

		-- The skin they wore, piece for piece; a set with no body of its own keeps the starter body it showed
		if moduleData["EquippedSkin"] == set.Skin then
			local wearing = table.clone(_settings.DEFAULT_OUTFIT) --- @type Cosmetics_Outfit
			for slot: string, pieceId: string in pairs(I.G_Cosmetics.GetSetPieces(setId)) do
				wearing[slot] = pieceId
			end
			moduleData["Outfit"] = wearing
		end
	end

	--[[ Saving ]]

	moduleData["EquippedSkin"] = nil
	moduleData["PiecesGiven"] = true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Equip

--[[
	**SERVER** |
	Wears an owned piece in its slot, or takes the hat or neck piece off ("").
]]
--- @return boolean
function Module.Equip(player: Player, slot: string, pieceId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]
	local piece = I.G_Cosmetics.GetPieces()[pieceId] --- @type Cosmetics_PieceData?

	--[[ Checks ]]

	-- Check if it's a slot that can be left empty, when taking a piece off
	if pieceId == "" and slot ~= "Hat" and slot ~= "Neck" then
		return false
	end

	-- Check if it's an owned piece of this slot
	if pieceId ~= "" and (not piece or piece.Slot ~= slot or not I.Inventory.HasItem(player, pieceId)) then
		return false
	end

	--[[ Saving ]]

	moduleData["Outfit"][slot] = pieceId

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% See

--[[
	**SERVER** |
	Marks every piece of a slot the player owns as seen, so the Style screen stops calling them NEW.
]]
--- @return boolean
function Module.See(player: Player, slot: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]

	--[[ Checks ]]

	-- Check if it's a slot
	if not table.find(_settings.SLOTS, slot) then
		return false
	end

	--[[ Saving ]]

	--- @param piece Cosmetics_PieceData
	for pieceId: string, piece in pairs(I.G_Cosmetics.GetPieces()) do
		if piece.Slot == slot and I.Inventory.HasItem(player, pieceId) then
			moduleData["SeenPieces"][pieceId] = true
		end
	end

	--[[ Publishing ]]

	Module._publishSeen(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Buy Emote

--[[
	**SERVER** |
	Buys an emote with diamonds when the player's level is high enough.
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
	if row.Diamonds ~= "0" and not I.Currency.Subtract(player, "Diamonds", row.Diamonds) then
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

--%%%%%%%%%%%%%%%%%%%% Play Snail Emote

--[[
	**SERVER** |
	Plays an emote on a match snail that has no player behind it (a bot's, by its snail's id) for everyone, at most once
	every EMOTE_COOLDOWN seconds per snail: bots taunt with it.
]]
--- @return boolean
function Module.PlaySnailEmote(snailId: string, emoteId: string)
	--[[ Checks ]]

	-- Check if it's an emote
	if not I.G_Cosmetics.GetEmotes()[emoteId] then
		warn(`[{_localName}::{script.Name}]: Emote ({emoteId}) doesn't exist!`)
		return false
	end

	-- Check if the cooldown is over
	if lastSnailEmote[snailId] and os.clock() - lastSnailEmote[snailId] < _settings.EMOTE_COOLDOWN then
		return false
	end

	--[[ Playing ]]

	lastSnailEmote[snailId] = os.clock()
	I.Network.FireAll("Cosmetics_EmotePlayed", snailId, emoteId)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes the outfit a player wears onto the Player (Outfit), where their Style screen and every lobby's party stage
	read it.
]]
function Module._publish(player: Player)
	player:SetAttribute("Outfit", I.G_Cosmetics.GetOutfitText(Module.GetOutfit(player)))
end

--%%%%%%%%%%%%%%%%%%%% Publish Seen

--[[
	Writes the pieces a player has seen into their Cosmetics folder (Seen: piece ids, comma-separated), where their Style
	screen tells the new ones.
]]
function Module._publishSeen(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]

	--[[ Local Variables ]]

	local seen = {} --- @type { string }
	for pieceId: string, _seen: boolean in pairs(moduleData["SeenPieces"]) do
		table.insert(seen, pieceId)
	end

	--[[ Publishing ]]

	I.Replicator.Set(player, _localName, "Seen", table.concat(seen, ","))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Outfit

--[[
	**SERVER** |
	Returns the outfit a player wears, and whether it's shiny (a piece with SHINY_COPIES or more copies). A piece they no
	longer own falls back to DEFAULT_OUTFIT's.
]]
--- @return Cosmetics_Outfit, boolean
function Module.GetOutfit(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Cosmetics"]

	--[[ Local Variables ]]

	local outfit = I.G_Cosmetics.GetOutfit(I.G_Cosmetics.GetOutfitText(moduleData["Outfit"])) --- @type Cosmetics_Outfit
	local shiny: boolean = false

	--[[ Checking ]]

	for slot: string, pieceId: string in pairs(outfit) do
		if pieceId == "" then
			continue
		end
		local copies: number = tonumber(I.Inventory.GetItem(player, pieceId)) or 0
		if copies == 0 then
			outfit[slot] = _settings.DEFAULT_OUTFIT[slot]
		elseif copies >= _settings.SHINY_COPIES then
			shiny = true
		end
	end

	--[[ Returning ]]

	return outfit, shiny
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
