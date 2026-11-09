--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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
	--------- REGISTRY ---------
	----------------------------

	--- @Topics
	I.Topic.Register("Crates_Opened")

	--- @Network
	I.Network.GetFunction("Crates_Open", { "Player", "string", "number", "string" }, { RateLimit = 2 })
	I.Network.OnInvoke("Crates_Open", Module.Open)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Crates = {

		--[[ Control ]]

		Open = Module.Open,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	**SERVER** |
	Opens one crate, a 3-pack or a 10-pack, paid in a currency the crate takes or with VIP's free daily crate ("VipDaily"):
	takes the price, rolls each item by the crate's odds and gives it. Returns what each crate gave, or nil when the
	player can't open it.
]]
--- @return { Crates_Result }?
function Module.Open(player: Player, crateId: string, count: number, payWith: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	local row = I.G_Crates.GetAll()[crateId] --- @type Crates_CrateData?
	if not row then
		return nil
	end

	--[[ Checks ]]

	-- Check if it's a pack size the game sells
	if not table.find(_settings.COUNTS, count) then
		return nil
	end

	-- Check if a hidden crate is the tutorial's, still unopened
	if row.Hidden and (crateId ~= _settings.TUTORIAL_CRATE or count ~= 1 or not I.Tutorial.CanOpenCrate(player)) then
		return nil
	end

	-- Check if paid random items are allowed for the player
	if #row.Fixed == 0 and table.find(_settings.PAID_CURRENCIES, payWith) and I.Policy.GetArePaidRandomItemsRestricted(player) then
		I.Notify.ShowNotification(player, "Crates aren't available in your region.")
		return nil
	end

	-- Check if the free daily crate is this one, and ready
	if payWith == "VipDaily" and (crateId ~= _settings.VIP_CRATE or count ~= 1 or not I.Shop.CanClaimVipCrate(player)) then
		return nil
	end

	-- Check if the crate takes this currency
	if payWith ~= "VipDaily" and not row.Prices[payWith] then
		return nil
	end

	--[[ Paying ]]

	local paid: boolean
	if payWith == "VipDaily" then
		paid = I.Shop.ClaimVipCrate(player)
	else
		paid = I.Currency.Subtract(player, payWith, I.G_Crates.GetPrice(crateId, payWith, count))
	end
	if not paid then
		return nil
	end

	--[[ Rolling ]]

	local items = {} --- @type { string }
	if #row.Fixed > 0 then
		items = table.clone(row.Fixed)
	else
		local odds = row.OddsByCurrency[if payWith == "VipDaily" then _settings.VIP_ODDS else payWith] --- @type { [string]: number }
		for _index: number = 1, count do
			table.insert(items, Module._roll(odds))
		end
	end

	--[[ Giving ]]

	local results = {} --- @type { Crates_Result }
	for _index: number, itemId: string in ipairs(items) do
		local before: number = tonumber(I.Inventory.GetItem(player, itemId)) or 0
		I.Inventory.AddItem(player, itemId, "1", true)
		table.insert(results, {
			ItemId = itemId,
			Copies = before + 1,
			JustShiny = before + 1 == _settings.SHINY_COPIES,
		})
	end

	--[[ Publishing ]]

	I.Topic.Publish("Crates_Opened", player, crateId, results)

	--[[ Returning ]]

	return results
end

--%%%%%%%%%%%%%%%%%%%% Roll

--[[
	Picks one item by its chance in percent.
]]
--- @param odds { [string]: number }
--- @return string
function Module._roll(odds)
	--[[ Local Variables ]]

	local pick: number = I.Random.Float(0, 100)
	local lastId: string = ""

	--[[ Rolling ]]

	for itemId: string, chance: number in pairs(odds) do
		lastId = itemId
		pick -= chance
		if pick <= 0 then
			return itemId
		end
	end

	--[[ Returning ]]

	-- Rounding can leave a sliver past the last item
	return lastId
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
