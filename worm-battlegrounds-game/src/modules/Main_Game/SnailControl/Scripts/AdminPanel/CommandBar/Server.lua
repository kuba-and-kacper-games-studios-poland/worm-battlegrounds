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

--- @class SnailControl_CommandBar_Server
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
	Registers the commands that start and end a snail's turn and fill its stamina by hand, for testing. Each one acts on the invoker's own
	snail unless it names another by its name, its player's username or its id.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Get Snail Id

	--[[
		Returns the participant id and the name of the snail a command acts on: the one it names (by its name, its
		player's username or its id), or the invoker's own. Text that names no snail comes back as both.
	]]
	--- @return string, string
	local function getSnailId(invoker: Player | number, snail: string?)
		--[[ Data ]]

		local query: string = snail or `P_{if typeof(invoker) == "Instance" then invoker.UserId else invoker}`
		local participant = I.Match.FindParticipant(query) --- @type Match_Participant?

		--[[ Returning ]]

		if participant then
			return participant.Id, participant.DisplayName
		end
		return query, query
	end

	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function turn(invoker: Player | number, snail: string?)
		--[[ Local Variables ]]

		local id: string
		local name: string
		id, name = getSnailId(invoker, snail)

		--[[ Executing ]]

		-- Check if the turn started
		if not I.SnailControl.StartTurn(id) then
			return false, `No snail $|cr$|{name}#| in play that a player here moves`
		end

		--[[ Returning ]]

		return true, `Started a turn for $|cr$|{name}#|`
	end

	local function stop(invoker: Player | number, snail: string?)
		--[[ Local Variables ]]

		local id: string
		local name: string
		id, name = getSnailId(invoker, snail)

		--[[ Executing ]]

		I.SnailControl.EndTurn(id)

		--[[ Returning ]]

		return true, `Ended the turn of $|cr$|{name}#|`
	end

	local function refill(invoker: Player | number, snail: string?)
		--[[ Local Variables ]]

		local id: string
		local name: string
		id, name = getSnailId(invoker, snail)

		--[[ Executing ]]

		-- Check if the stamina was filled
		if not I.SnailControl.Refill(id) then
			return false, `No snail $|cr$|{name}#| in play`
		end

		--[[ Returning ]]

		return true, `Filled the stamina of $|cr$|{name}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "turn" },
			Args = {
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = turn,
		},
		{
			Aliases = { "end" },
			Args = {
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = stop,
		},
		{
			Aliases = { "refill" },
			Args = {
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = refill,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("SnailControl_Server", {
		Aliases = { "snailcontrol" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
