--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Friends"

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

--- @class Friends_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function promptInvite(player: Player)
		-- Getting value
		local value: boolean = I.Friends.PromptGameInvite(player, nil, true)

		-- Returning
		if value then
			return true, `Prompted $|cr$|Friends Invite#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to prompt $|cr$|Friends Invite#| for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function getCount(player: Player)
		-- Getting value
		local value: number = I.Friends.GetActiveCount(player)

		-- Returning
		if value then
			return true, `$|cr$|{player.Name}#| has $|cr$|{value}#| active friends in the current session`
		else
			return false, `Failed to get active friends count for $|cr$|{player.Name}#|`
		end
	end

	local function getList(player: Player)
		-- Getting value
		local value: table = I.Friends.GetActiveList(player)

		-- Returning
		if value then
			return true, { `Getting $|cr$|{player.Name}#|'s active friends List...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s active friends List`
		end
	end

	local function isFriendsWith(player: Player, friend: Player)
		-- Getting value
		local value: boolean? = I.Friends.IsFriendsWith(player, friend)

		-- Returning
		if value ~= nil then
			if value then
				return true, `$|cr$|{player.Name}#| is friends with $|cr$|{friend.Name}#|`
			else
				return true, `$|cr$|{player.Name}#| is not friends with $|cr$|{friend.Name}#|`
			end
		else
			return false, `Failed to check if $|cr$|{player.Name}#| is friends with $|cr$|{friend.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		--[[ Control ]]

		{
			Aliases = { "prompt_invite" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = promptInvite,
		},

		--[[ Methods ]]

		{
			Aliases = { "get_count" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = getCount,
		},
		{
			Aliases = { "get_list" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = getList,
		},
		{
			Aliases = { "is_friends_with" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "friend", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = isFriendsWith,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Friends_Server", {
		Aliases = { "friends" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
