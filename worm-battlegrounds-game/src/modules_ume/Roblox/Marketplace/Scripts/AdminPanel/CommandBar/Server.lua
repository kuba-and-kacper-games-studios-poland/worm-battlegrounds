--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Marketplace"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local assets = require(I.Dirs.GlobalData.Marketplace.Assets) --- @type Marketplace_Assets
local bundles = require(I.Dirs.GlobalData.Marketplace.Bundles) --- @type Marketplace_Bundles
local gamepasses = require(I.Dirs.GlobalData.Marketplace.GamePasses) --- @type Marketplace_GamePasses
local products = require(I.Dirs.GlobalData.Marketplace.Products) --- @type Marketplace_Products

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { string }
local rewardTypes = {
	"Single",
	"Session",
	"Character",
}

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

--- @class Marketplace_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Prompt Purchase Functions

	local function promptPurchase_regular(player: Player, productName: string, productType: Enum.InfoType)
		--[[ Checks ]]

		if productType == Enum.InfoType.Asset then
			if not assets[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Bundle then
			if not bundles[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.GamePass then
			if not gamepasses[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Product then
			if not products[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		else
			return false, `Invalid Product type: $|cr$|{productType.Name}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean
		if productType == Enum.InfoType.Asset then
			value = I.Marketplace.Asset_PromptPurchase(player, productName)
		elseif productType == Enum.InfoType.Bundle then
			value = I.Marketplace.Bundle_PromptPurchase(player, productName)
		elseif productType == Enum.InfoType.GamePass then
			value = I.Marketplace.GamePass_PromptPurchase(player, productName)
		elseif productType == Enum.InfoType.Product then
			value = I.Marketplace.Product_PromptPurchase(player, productName)
		end

		-- Returning
		if value then
			return true, `Prompted {productType.Name} $|cr$|{productName}#| purchase for $|cr$|{player.Name}#|`
		else
			return false, `Failed to prompt {productType.Name} $|cr$|{productName}#| purchase for $|cr$|{player.Name}#|`
		end
	end

	local function promptPurchase_robloxPlus(player: Player)
		-- Getting value
		local value: boolean = I.Marketplace.RobloxPlus_PromptPurchase(player)

		-- Returning
		if value then
			return true, `Prompted $|cr$|Roblox Plus#| subscription for $|cr$|{player.Name}#|`
		else
			return false, `Failed to prompt $|cr$|Roblox Plus#| subscription for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Reward Functions

	local function rewardFor(player: Player, productName: string, productType: Enum.InfoType, rewardType: string?, forceReward: boolean?)
		--[[ Checks ]]

		if productType == Enum.InfoType.Asset then
			if not assets[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Bundle then
			if not bundles[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.GamePass then
			if not gamepasses[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Product then
			if not products[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		else
			return false, `Invalid Product type: $|cr$|{productType.Name}#|`
		end

		if rewardType then
			if not table.find(rewardTypes, rewardType) then
				return false, `Invalid Reward type: $|cr$|{rewardType}#|`
			end
		end

		--[[ Executing ]]

		-- Getting value
		local success: boolean, value: { string } = I.Marketplace._awardReward(player, productName, productType, rewardType, forceReward)

		-- Returning
		if success then
			if rewardType then
				return true,
					{
						`Granting $|cr$|{productType.Name}#| $|cr$|{productName}#| $|cr$|{rewardType}#| reward to $|cr$|{player.Name}#|...`,
						`Granted $|cr$|{#value}#| rewards:`,
						value,
						"_multilineOutput",
					}
			else
				return true, {
					`Granting $|cr$|{productType.Name}#| $|cr$|{productName}#| reward to $|cr$|{player.Name}#|...`,
					`Granted $|cr$|{#value}#| rewards:`,
					value,
					"_multilineOutput",
				}
			end
		else
			-- Getting second message
			local owns: boolean = I.G_Marketplace.PlayerOwns(player, productName, productType)
			local returnTable = { "_multilineOutput" }
			if not owns then
				table.insert(returnTable, 1, `$|cr$|{player.Name}#| does not own the $|cr$|{productType.Name}#| $|cr$|{productName}#|`)
			end

			-- Returning
			if rewardType then
				table.insert(returnTable, 1, `Failed to grant $|cr$|{productType.Name}#| $|cr$|{productName}#| $|cr$|{rewardType}#| reward to $|cr$|{player.Name}#|`)
				return false, returnTable
			else
				table.insert(returnTable, 1, `Failed to grant $|cr$|{productType.Name}#| $|cr$|{productName}#| rewards to $|cr$|{player.Name}#|`)
				return false, returnTable
			end
		end
	end

	local function rewardForAll(player: Player, productType: Enum.InfoType, rewardType: string?, forceReward: boolean?)
		--[[ Checks ]]

		if rewardType then
			if not table.find(rewardTypes, rewardType) then
				return false, `Invalid Reward type: $|cr$|{rewardType}#|`
			end
		end

		--[[ Executing ]]

		-- Getting value
		local value: table = I.Marketplace._awardRewardForAll(player, productType, rewardType, forceReward)

		-- Returning
		if value then
			if next(value) then
				if rewardType then
					return true,
						{
							`Granting all $|cr$|{productType.Name}#| $|cr$|{rewardType}#| rewards to $|cr$|{player.Name}#|...`,
							`Granted $|cr$|{I.Table.PackedLength(value)}#| rewards:`,
							value,
							"_multilineOutput",
						}
				else
					return true,
						{
							`Granting all $|cr$|{productType.Name}#| rewards to $|cr$|{player.Name}#|...`,
							`Granted $|cr$|{I.Table.PackedLength(value)}#| rewards:`,
							value,
							"_multilineOutput",
						}
				end
			else
				if rewardType then
					return true, `Granting all $|cr$|{productType.Name}#| $|cr$|{rewardType}#| rewards to $|cr$|{player.Name}#| succeeded, but no rewards were granted`
				else
					return true, `Granting all $|cr$|{productType.Name}#| rewards to $|cr$|{player.Name}#| succeeded, but no rewards were granted`
				end
			end
		else
			if rewardType then
				return false, `Failed to grant all $|cr$|{productType.Name}#| $|cr$|{rewardType}#| rewards to $|cr$|{player.Name}#|`
			else
				return false, `Failed to grant all $|cr$|{productType.Name}#| rewards to $|cr$|{player.Name}#|`
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Get Functions

	local function getInfo(productName: string, productType: Enum.InfoType)
		--[[ Checks ]]

		if productType == Enum.InfoType.Asset then
			if not assets[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Bundle then
			if not bundles[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.GamePass then
			if not gamepasses[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Product then
			if not products[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		else
			return false, `Invalid Product type: $|cr$|{productType.Name}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: table = I.G_Marketplace.GetProductInfo(productName, productType)

		-- Returning
		if value then
			return true, { `Retrieving {productType.Name} $|cr$|{productName}#| info...`, value, "_multilineOutput" }
		else
			return false, `Failed to retrieve {productType.Name} $|cr$|{productName}#| info`
		end
	end

	local function getPrice(productName: string, productType: Enum.InfoType)
		--[[ Checks ]]

		if productType == Enum.InfoType.Asset then
			if not assets[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Bundle then
			if not bundles[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.GamePass then
			if not gamepasses[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Product then
			if not products[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		else
			return false, `Invalid Product type: $|cr$|{productType.Name}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string = I.G_Marketplace.GetProductPrice(productName, productType, true)

		-- Returning
		if value then
			return true, { `Retrieving {productType.Name} $|cr$|{productName}#| price...`, value, "_multilineOutput" }
		else
			return false, `Failed to retrieve {productType.Name} $|cr$|{productName}#| price`
		end
	end

	local function getRobuxSpent(player: Player, productType: Enum.InfoType?)
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return false, `Failed to get $|cr$|{player.Name}#|'s RobuxSpent`
		end

		--[[ Data ]]

		--- @type Player_ProfileData
		local profileData = I.Player.GetProfile(player).Data
		local moduleData = profileData["Marketplace"]

		--[[ Executing ]]

		-- Getting value
		local value: number
		if productType == Enum.InfoType.Asset then
			value = moduleData.AssetRobuxSpent
		elseif productType == Enum.InfoType.Bundle then
			value = moduleData.BundleRobuxSpent
		elseif productType == Enum.InfoType.GamePass then
			value = moduleData.GamePassRobuxSpent
		elseif productType == Enum.InfoType.Product then
			value = moduleData.ProductRobuxSpent
		elseif productType == nil then
			value = moduleData.AssetRobuxSpent + moduleData.BundleRobuxSpent + moduleData.GamePassRobuxSpent + moduleData.ProductRobuxSpent
		end

		-- Returning
		if value then
			if productType then
				return true, `$|cr$|{player.Name}#| spent $|cr$|\u{E002}{value}#| Robux on $|cr$|{productType.Name}#|`
			else
				return true, `$|cr$|{player.Name}#| spent $|cr$|\u{E002}{value}#| Robux total`
			end
		else
			if productType then
				return false, `Failed to get $|cr$|{player.Name}#|'s $|cr$|{productType.Name}#| RobuxSpent`
			else
				return false, `Failed to get $|cr$|{player.Name}#|'s RobuxSpent`
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Gift Functions

	--[[ Gift ]]

	local function giftGamePass(player: Player, gamepassName: string)
		--[[ Checks ]]

		if not gamepasses[gamepassName] then
			return false, `Invalid GamePass name: $|cr$|{gamepassName}#|`
		end

		if I.Marketplace.GamePass_IsGifted(player, gamepassName) then
			return false, `GamePass $|cr$|{gamepassName}#| is already gifted to $|cr$|{player.Name}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Marketplace.GamePass_Gift(player, gamepassName)

		-- Returning
		if value then
			return true, `Gifted GamePass $|cr$|{gamepassName}#| to $|cr$|{player.Name}#|`
		else
			return false, `Failed to gift GamePass $|cr$|{gamepassName}#| to $|cr$|{player.Name}#|`
		end
	end

	local function giftAllGamePasses(player: Player)
		-- Getting value
		local success: boolean, gifted: { string }? = I.Marketplace.GamePass_GiftAll(player)

		-- Returning
		if success then
			return true, { `Gifting all GamePasses to $|cr$|{player.Name}#|...`, `Successfully gifted $|cr$|{#gifted}#| GamePasses:`, gifted, "_multilineOutput" }
		else
			return false, `Failed to gift all GamePasses to $|cr$|{player.Name}#|`
		end
	end

	local function giftProduct(player: Player, productName: string)
		--[[ Checks ]]

		if not products[productName] then
			return false, `Invalid Product name: $|cr$|{productName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Marketplace.Product_Gift(player, productName)

		-- Returning
		if value then
			return true, `Gifted Product $|cr$|{productName}#| to $|cr$|{player.Name}#|`
		else
			return false, `Failed to gift Product $|cr$|{productName}#| to $|cr$|{player.Name}#|`
		end
	end

	--[[ Clear ]]

	local function clearGamePassGift(player: Player, gamepassName: string)
		--[[ Checks ]]

		if not gamepasses[gamepassName] then
			return false, `Invalid GamePass name: $|cr$|{gamepassName}#|`
		end

		if not I.Marketplace.GamePass_IsGifted(player, gamepassName) then
			return false, `GamePass $|cr$|{gamepassName}#| is not gifted for $|cr$|{player.Name}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Marketplace.GamePass_ClearGift(player, gamepassName)

		if value then
			return true, `Cleared $|cr$|{player.Name}#|'s $|cr$|{gamepassName}#| GamePass gift`
		else
			return false, `Failed to clear $|cr$|{player.Name}#|'s $|cr$|{gamepassName}#| GamePass gift`
		end
	end

	local function clearAllGamePassGifts(player: Player)
		-- Getting value
		local success: boolean, cleared: { string }? = I.Marketplace.GamePass_ClearAllGifts(player)

		-- Returning
		if success then
			return true, { `Clearing all $|cr$|{player.Name}#|'s GamePass gifts...`, `Successfully cleared $|cr$|{#cleared}#| GamePasses:`, cleared, "_multilineOutput" }
		else
			return false, `Failed to clear $|cr$|{player.Name}#|'s GamePass gifts`
		end
	end

	--[[ Get ]]

	local function isGifted(player: Player, gamepassName: string)
		--[[ Checks ]]

		if not gamepasses[gamepassName] then
			return false, `Invalid GamePass name: $|cr$|{gamepassName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Marketplace.GamePass_IsGifted(player, gamepassName)

		-- Returning
		if value then
			return true, `GamePass $|cr$|{gamepassName}#| is gifted to $|cr$|{player.Name}#|`
		else
			return true, `GamePass $|cr$|{gamepassName}#| is $|cr$|not#| gifted to $|cr$|{player.Name}#|`
		end
	end

	local function getGifted(player: Player)
		-- Getting value
		local success: boolean, gifted: { string }? = I.Marketplace.GamePass_GetGifted(player)

		-- Returning
		if success then
			return true, {
				`Getting all $|cr$|{player.Name}#|'s gifted GamePasses...`,
				`$|cr$|{player.Name}#| has $|cr$|{#gifted}#| gifted GamePasses:`,
				gifted,
				"_multilineOutput",
			}
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s gifted GamePasses`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Owns Functions

	local function owns_byPlayer(player: Player, productName: string, productType: Enum.InfoType)
		--[[ Checks ]]

		if productType == Enum.InfoType.Asset then
			if not assets[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Bundle then
			if not bundles[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.GamePass then
			if not gamepasses[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		elseif productType == Enum.InfoType.Product then
			if not products[productName] then
				return false, `Invalid Product name: $|cr$|{productName}#| for type $|cr$|{productType.Name}#|`
			end
		else
			return false, `Invalid Product type: $|cr$|{productType.Name}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.G_Marketplace.PlayerOwns(player, productName, productType)

		-- Returning
		if value then
			return true, `$|cr$|{player.Name}#| owns the $|cr$|{productName}#| {productType.Name}`
		else
			return true, `$|cr$|{player.Name}#| does not own the $|cr$|{productName}#| {productType.Name}`
		end
	end

	local function isRobloxPlus(player: Player)
		local hasPlus: boolean = I.Marketplace.RobloxPlus_IsRobloxPlus(player)

		if hasPlus then
			return true, `$|cr$|{player.Name}#| has $|cr$|Roblox Plus#|`
		end

		return true, `$|cr$|{player.Name}#| does $|cr$|not#| have $|cr$|Roblox Plus#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Prompt Purchase ]]

		{
			Aliases = { "prompt_purchase" },

			Variants = {
				{
					Aliases = { "asset" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "assetName", types = { "string" }, dict = "Marketplace_AssetNames", requireDict = true },
					},
					Callback = function(player: Player, assetName: string)
						return promptPurchase_regular(player, assetName, Enum.InfoType.Asset)
					end,
				},
				{
					Aliases = { "bundle" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "bundleName", types = { "string" }, dict = "Marketplace_BundleNames", requireDict = true },
					},
					Callback = function(player: Player, bundleName: string)
						return promptPurchase_regular(player, bundleName, Enum.InfoType.Bundle)
					end,
				},
				{
					Aliases = { "gamepass" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "gamepassName", types = { "string" }, dict = "Marketplace_GamePassNames", requireDict = true },
					},
					Callback = function(player: Player, gamepassName: string)
						return promptPurchase_regular(player, gamepassName, Enum.InfoType.GamePass)
					end,
				},
				{
					Aliases = { "product" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "productName", types = { "string" }, dict = "Marketplace_ProductNames", requireDict = true },
					},
					Callback = function(player: Player, productName: string)
						return promptPurchase_regular(player, productName, Enum.InfoType.Product)
					end,
				},
				{
					Aliases = { "premium" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = promptPurchase_robloxPlus,
				},
			},
		},

		--[[ Reward ]]

		{
			Aliases = { "reward_for" },

			Variants = {
				{
					Aliases = { "asset" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "assetName", types = { "string" }, dict = "Marketplace_AssetNames", requireDict = true },
						{ name = "rewardType", types = { "string" }, dict = "Marketplace_ProductRewardType", requireDict = true, optional = true },
						{ name = "forceReward", types = { "boolean" }, optional = true },
					},
					Callback = function(player: Player, productName: string, rewardType: string?, forceReward: boolean?)
						return rewardFor(player, productName, Enum.InfoType.Asset, rewardType, forceReward)
					end,
				},
				{
					Aliases = { "bundle" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "bundleName", types = { "string" }, dict = "Marketplace_BundleNames", requireDict = true },
						{ name = "rewardType", types = { "string" }, dict = "Marketplace_ProductRewardType", requireDict = true, optional = true },
						{ name = "forceReward", types = { "boolean" }, optional = true },
					},
					Callback = function(player: Player, productName: string, rewardType: string?, forceReward: boolean?)
						return rewardFor(player, productName, Enum.InfoType.Bundle, rewardType, forceReward)
					end,
				},
				{
					Aliases = { "gamepass" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "gamepassName", types = { "string" }, dict = "Marketplace_GamePassNames", requireDict = true },
						{ name = "rewardType", types = { "string" }, dict = "Marketplace_ProductRewardType", requireDict = true, optional = true },
						{ name = "forceReward", types = { "boolean" }, optional = true },
					},
					Callback = function(player: Player, productName: string, rewardType: string?, forceReward: boolean?)
						return rewardFor(player, productName, Enum.InfoType.GamePass, rewardType, forceReward)
					end,
				},
			},
		},
		{
			Aliases = { "reward_for_all" },

			Variants = {
				{
					Aliases = { "asset" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "rewardType", types = { "string" }, dict = "Marketplace_ProductRewardType", requireDict = true, optional = true },
						{ name = "forceReward", types = { "boolean" }, optional = true },
					},
					Callback = function(player: Player, rewardType: string?, forceReward: boolean?)
						return rewardForAll(player, Enum.InfoType.Asset, rewardType, forceReward)
					end,
				},
				{
					Aliases = { "bundle" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "rewardType", types = { "string" }, dict = "Marketplace_ProductRewardType", requireDict = true, optional = true },
						{ name = "forceReward", types = { "boolean" }, optional = true },
					},
					Callback = function(player: Player, rewardType: string?, forceReward: boolean?)
						return rewardForAll(player, Enum.InfoType.Bundle, rewardType, forceReward)
					end,
				},
				{
					Aliases = { "gamepass" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "rewardType", types = { "string" }, dict = "Marketplace_ProductRewardType", requireDict = true, optional = true },
						{ name = "forceReward", types = { "boolean" }, optional = true },
					},
					Callback = function(player: Player, rewardType: string?, forceReward: boolean?)
						return rewardForAll(player, Enum.InfoType.GamePass, rewardType, forceReward)
					end,
				},
			},
		},

		--[[ Get ]]

		{
			Aliases = { "get_info" },

			Variants = {
				{
					Aliases = { "asset" },
					Args = {
						{ name = "assetName", types = { "string" }, dict = "Marketplace_AssetNames", requireDict = true },
					},
					Callback = function(assetName: string)
						return getInfo(assetName, Enum.InfoType.Asset)
					end,
				},
				{
					Aliases = { "bundle" },
					Args = {
						{ name = "bundleName", types = { "string" }, dict = "Marketplace_BundleNames", requireDict = true },
					},
					Callback = function(bundleName: string)
						return getInfo(bundleName, Enum.InfoType.Bundle)
					end,
				},
				{
					Aliases = { "gamepass" },
					Args = {
						{ name = "gamepassName", types = { "string" }, dict = "Marketplace_GamePassNames", requireDict = true },
					},
					Callback = function(gamepassName: string)
						return getInfo(gamepassName, Enum.InfoType.GamePass)
					end,
				},
				{
					Aliases = { "product" },
					Args = {
						{ name = "productName", types = { "string" }, dict = "Marketplace_ProductNames", requireDict = true },
					},
					Callback = function(productName: string)
						return getInfo(productName, Enum.InfoType.Product)
					end,
				},
			},
		},
		{
			Aliases = { "get_price" },

			Variants = {
				{
					Aliases = { "asset" },
					Args = {
						{ name = "assetName", types = { "string" }, dict = "Marketplace_AssetNames", requireDict = true },
					},
					Callback = function(assetName: string)
						return getPrice(assetName, Enum.InfoType.Asset)
					end,
				},
				{
					Aliases = { "bundle" },
					Args = {
						{ name = "bundleName", types = { "string" }, dict = "Marketplace_BundleNames", requireDict = true },
					},
					Callback = function(bundleName: string)
						return getPrice(bundleName, Enum.InfoType.Bundle)
					end,
				},
				{
					Aliases = { "gamepass" },
					Args = {
						{ name = "gamepassName", types = { "string" }, dict = "Marketplace_GamePassNames", requireDict = true },
					},
					Callback = function(gamepassName: string)
						return getPrice(gamepassName, Enum.InfoType.GamePass)
					end,
				},
				{
					Aliases = { "product" },
					Args = {
						{ name = "productName", types = { "string" }, dict = "Marketplace_ProductNames", requireDict = true },
					},
					Callback = function(productName: string)
						return getPrice(productName, Enum.InfoType.Product)
					end,
				},
			},
		},
		{
			Aliases = { "get_robux_spent" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = function(player: Player)
				return getRobuxSpent(player)
			end,

			Variants = {
				{
					Aliases = { "asset" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = function(player: Player)
						return getRobuxSpent(player, Enum.InfoType.Asset)
					end,
				},
				{
					Aliases = { "bundle" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = function(player: Player)
						return getRobuxSpent(player, Enum.InfoType.Bundle)
					end,
				},
				{
					Aliases = { "gamepass" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = function(player: Player)
						return getRobuxSpent(player, Enum.InfoType.GamePass)
					end,
				},
				{
					Aliases = { "product" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = function(player: Player)
						return getRobuxSpent(player, Enum.InfoType.Product)
					end,
				},
			},
		},

		--[[ Gift ]]

		{
			Aliases = { "gift" },

			Variants = {
				{
					Aliases = { "gamepass" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "gamepassName", types = { "string" }, dict = "Marketplace_GamePassNames", requireDict = true },
					},
					Callback = giftGamePass,
				},
				{
					Aliases = { "all_gamepasses" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = giftAllGamePasses,
				},
				{
					Aliases = { "product" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "productName", types = { "string" }, dict = "Marketplace_ProductNames", requireDict = true },
					},
					Callback = giftProduct,
				},
			},
		},

		--[[ Gift - Clear ]]

		{
			Aliases = { "clear_gamepass_gift" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "gamepassName", types = { "string" }, dict = "Marketplace_GamePassNames", requireDict = true },
			},
			Callback = clearGamePassGift,
		},
		{
			Aliases = { "clear_all_gamepasses_gift" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = clearAllGamePassGifts,
		},

		--[[ Gift - Get ]]

		{
			Aliases = { "is_gifted" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "gamepassName", types = { "string" }, dict = "Marketplace_GamePassNames", requireDict = true },
			},
			Callback = isGifted,
		},
		{
			Aliases = { "get_gifted" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = getGifted,
		},

		--[[ Owns ]]

		{
			Aliases = { "owns" },

			Variants = {
				{
					Aliases = { "asset" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "assetName", types = { "string" }, dict = "Marketplace_AssetNames", requireDict = true },
					},
					Callback = function(player: Player, assetName: string)
						return owns_byPlayer(player, assetName, Enum.InfoType.Asset)
					end,
				},
				{
					Aliases = { "bundle" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "bundleName", types = { "string" }, dict = "Marketplace_BundleNames", requireDict = true },
					},
					Callback = function(player: Player, bundleName: string)
						return owns_byPlayer(player, bundleName, Enum.InfoType.Bundle)
					end,
				},
				{
					Aliases = { "gamepass" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "gamepassName", types = { "string" }, dict = "Marketplace_GamePassNames", requireDict = true },
					},
					Callback = function(player: Player, gamepassName: string)
						return owns_byPlayer(player, gamepassName, Enum.InfoType.GamePass)
					end,
				},
				{
					Aliases = { "premium" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = isRobloxPlus,
				},
			},
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Marketplace_Server", {
		Aliases = { "marketplace" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--[[ Getting Values ]]

	local allAssetNames = {} --- @type string
	for name: string, _assetData: table in pairs(assets) do
		table.insert(allAssetNames, name)
	end
	local allBundleNames = {} --- @type string
	for name: string, _bundleData: table in pairs(bundles) do
		table.insert(allBundleNames, name)
	end
	local allGamepassNames = {} --- @type string
	for name: string, _gamepassData: table in pairs(gamepasses) do
		table.insert(allGamepassNames, name)
	end
	local allProductNames = {} --- @type string
	for name: string, _productData: table in pairs(products) do
		table.insert(allProductNames, name)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Marketplace_AssetNames`, allAssetNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Marketplace_BundleNames`, allBundleNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Marketplace_GamePassNames`, allGamepassNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Marketplace_ProductNames`, allProductNames, 255)

	I.AdminPanel_CommandBar.SetDictionary(`Marketplace_ProductRewardType`, rewardTypes, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
