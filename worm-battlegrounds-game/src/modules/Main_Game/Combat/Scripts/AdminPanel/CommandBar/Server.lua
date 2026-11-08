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

--- @class Combat_CommandBar_Server
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
	Registers the commands that give weapons and utilities mid-match and fill their uses, for testing. Each one acts on
	the invoker's own snail unless it names a participant id.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Helper Functions

	local function getId(invoker: Player | number, participantId: string?)
		return participantId or `P_{if typeof(invoker) == "Instance" then invoker.UserId else invoker}`
	end

	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function give(invoker: Player | number, itemId: string, participantId: string?)
		--[[ Local Variables ]]

		local id: string = getId(invoker, participantId)

		--[[ Executing ]]

		-- Check if the item was given
		if not I.Combat.Give(id, itemId) then
			return false, `$|cr$|{id}#| isn't in a match, or $|cr$|{itemId}#| isn't an item`
		end

		--[[ Returning ]]

		return true, `Gave $|cr$|{itemId}#| to $|cr$|{id}#|`
	end

	local function refill(invoker: Player | number, participantId: string?)
		--[[ Local Variables ]]

		local id: string = getId(invoker, participantId)

		--[[ Executing ]]

		-- Check if the uses were filled
		if not I.Combat.Refill(id) then
			return false, `$|cr$|{id}#| isn't in a match`
		end

		--[[ Returning ]]

		return true, `Filled every use of $|cr$|{id}#| and cleared its cooldowns`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Dictionaries ]]

	local itemIds = {} --- @type { string }
	--- @param _row Arsenal_WeaponData
	for itemId: string, _row in pairs(I.G_Arsenal.GetAll()) do
		table.insert(itemIds, itemId)
	end
	table.sort(itemIds)
	I.AdminPanel_CommandBar.SetDictionary("Combat_ItemIds", itemIds, 255)

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "give" },
			Args = {
				{ name = "itemId", types = { "string" }, dict = "Combat_ItemIds", requireDict = true },
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = give,
		},
		{
			Aliases = { "refill" },
			Args = {
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = refill,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Combat_Server", {
		Aliases = { "combat" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
