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
	Registers the commands that start and end a snail's turn by hand, for testing. Each one acts on the invoker's own
	snail unless it names a participant id.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Helper Functions

	local function getId(invoker: Player | number, participantId: string?)
		return participantId or `P_{if typeof(invoker) == "Instance" then invoker.UserId else invoker}`
	end

	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function turn(invoker: Player | number, participantId: string?)
		--[[ Local Variables ]]

		local id: string = getId(invoker, participantId)

		--[[ Executing ]]

		-- Check if the turn started
		if not I.SnailControl.StartTurn(id) then
			return false, `$|cr$|{id}#| has no snail in play that a player here moves`
		end

		--[[ Returning ]]

		return true, `Started a turn for $|cr$|{id}#|`
	end

	local function stop(invoker: Player | number, participantId: string?)
		--[[ Local Variables ]]

		local id: string = getId(invoker, participantId)

		--[[ Executing ]]

		I.SnailControl.EndTurn(id)

		--[[ Returning ]]

		return true, `Ended the turn of $|cr$|{id}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "turn" },
			Args = {
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = turn,
		},
		{
			Aliases = { "end" },
			Args = {
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = stop,
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
