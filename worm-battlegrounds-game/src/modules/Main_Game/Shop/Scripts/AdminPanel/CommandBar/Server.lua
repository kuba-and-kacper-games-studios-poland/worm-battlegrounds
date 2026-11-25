--[[
	Created By: 	HungryN00B
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

--- @class Shop_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the command that buys a diamond pack for a player without Robux, for testing: the pack's reward is granted
	and their screen hears the purchase as after a real one, so the shop's payout plays once it closes.
]]
function Module._registerCommands()
	--[[ Local Variables ]]

	local settings = I.Settings["Shop"] --- @type Shop_Settings
	local packNames = {} --- @type { string }

	--- @param pack Shop_Pack
	for _index: number, pack in ipairs(settings.PACKS) do
		table.insert(packNames, pack.Product)
	end

	--%%%%%%%%%%%%%%%%%%%% Buy Pack

	--[[
		Grants a diamond pack as its receipt would, and tells the player's screen it was bought.
	]]
	local function buyPack(player: Player, productName: string)
		--[[ Checks ]]

		-- Check if the pack's reward was granted
		if not I.Marketplace.Product_Gift(player, productName) then
			return false, `Failed to grant $|cr$|{productName}#| to $|cr$|{player.Name}#|`
		end

		--[[ Publishing ]]

		I.Network.Fire("Marketplace_ProductPurchaseSucceeded", player, productName)

		--[[ Returning ]]

		return true, `$|cr$|{player.Name}#| bought $|cr$|{productName}#|; it plays once the shop closes`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		--[[ Control ]]
		{
			Aliases = { "buy_pack" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "product", types = { "string" }, dict = "Shop_Packs", requireDict = true },
			},
			Callback = buyPack,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.SetDictionary("Shop_Packs", packNames, 255)
	I.AdminPanel_CommandBar.Register("Shop_Server", {
		Aliases = { "shop" },
		PermissionLevel = 255,
		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
}
