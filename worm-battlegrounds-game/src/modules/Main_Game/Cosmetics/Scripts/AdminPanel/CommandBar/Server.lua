--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

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

--- @class Cosmetics_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the commands that give a player a skin's set of pieces, or every piece or emote they don't own yet.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Add Missing

	--[[
		Gives a player one copy of each item they don't own yet, and returns how many they got.
	]]
	--- @param itemIds { string }
	--- @return number
	local function addMissing(player: Player, itemIds)
		--[[ Local Variables ]]

		local added: number = 0

		--[[ Adding ]]

		for _index: number, itemId: string in ipairs(itemIds) do
			if not I.Inventory.HasItem(player, itemId) and I.Inventory.AddItem(player, itemId, "1", true) then
				added += 1
			end
		end

		--[[ Returning ]]

		return added
	end

	--%%%%%%%%%%%%%%%%%%%% Give Skin

	--[[
		Gives a player one more copy of each piece of a set (a whole skin).
	]]
	local function giveSkin(player: Player, setId: string)
		--[[ Data ]]

		local set = I.G_Cosmetics.GetSet(setId) --- @type Cosmetics_SetData?

		--[[ Checks ]]

		-- Check if the set exists
		if not set then
			return false, `Invalid SetId: $|cr$|{setId}#|`
		end

		--[[ Local Variables ]]

		local given = {} --- @type { string }

		--[[ Adding ]]

		for _slot: string, pieceId: string in pairs(I.G_Cosmetics.GetSetPieces(setId)) do
			if I.Inventory.AddItem(player, pieceId, "1", true) then
				table.insert(given, pieceId)
			end
		end

		--[[ Returning ]]

		if #given == 0 then
			return false, `Failed to give the $|cr$|{set.Name}#| set to $|cr$|{player.Name}#|`
		end
		return true, `Gave $|cr$|{player.Name}#| the $|cr$|{set.Name}#| set: $|cr$|{table.concat(given, ", ")}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Unlock Skins

	--[[
		Gives a player every snail piece they don't own yet.
	]]
	local function unlockSkins(player: Player)
		--[[ Local Variables ]]

		local pieceIds = {} --- @type { string }
		--- @param _row Cosmetics_PieceData
		for pieceId: string, _row in pairs(I.G_Cosmetics.GetPieces()) do
			table.insert(pieceIds, pieceId)
		end

		--[[ Returning ]]

		return true, `Gave $|cr$|{player.Name}#| $|cr$|{addMissing(player, pieceIds)}#| pieces they didn't own`
	end

	--%%%%%%%%%%%%%%%%%%%% Unlock Emotes

	--[[
		Gives a player every emote they don't own yet.
	]]
	local function unlockEmotes(player: Player)
		--[[ Local Variables ]]

		local emoteIds = {} --- @type { string }
		--- @param _row Cosmetics_EmoteData
		for emoteId: string, _row in pairs(I.G_Cosmetics.GetEmotes()) do
			table.insert(emoteIds, emoteId)
		end

		--[[ Returning ]]

		return true, `Gave $|cr$|{player.Name}#| $|cr$|{addMissing(player, emoteIds)}#| emotes they didn't own`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Dictionaries ]]

	local setIds = {} --- @type { string }
	--- @param _row Cosmetics_SetData
	for setId: string, _row in pairs(I.G_Cosmetics.GetSets()) do
		table.insert(setIds, setId)
	end
	table.sort(setIds)
	I.AdminPanel_CommandBar.SetDictionary("Cosmetics_SetIds", setIds, 255)

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "give_skin" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "setId", types = { "string" }, dict = "Cosmetics_SetIds", requireDict = true },
			},
			Callback = giveSkin,
		},
		{
			Aliases = { "unlock_skins" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = unlockSkins,
		},
		{
			Aliases = { "unlock_emotes" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = unlockEmotes,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Cosmetics_Server", {
		Aliases = { "cosmetics" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
