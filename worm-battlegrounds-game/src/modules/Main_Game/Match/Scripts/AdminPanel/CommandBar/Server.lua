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

--- @class Match_CommandBar_Server
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
	Registers the commands that steer a match by hand, for testing: skip a turn, change how long turns last, set the
	wind and the round, and win at once.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function skip()
		--[[ Checks ]]

		-- Check if a turn is playing
		if I.Match.GetPhase() ~= "Turn" then
			return false, `No turn is playing (phase $|cr$|{I.Match.GetPhase()}#|)`
		end

		--[[ Executing ]]

		I.Match.SkipTurn()

		--[[ Returning ]]

		return true, `Skipped the turn of $|cr$|{I.Match.GetActive()}#|`
	end

	local function time(seconds: number)
		--[[ Checks ]]

		-- Check if seconds is a positive number (0 goes back to the default)
		if seconds < 0 then
			return false, `Invalid seconds: $|cr$|{seconds}#| must be $|cr$|0#| or more`
		end

		--[[ Executing ]]

		I.Match.SetTurnSeconds(if seconds > 0 then seconds else nil)

		--[[ Returning ]]

		if seconds > 0 then
			return true, `Turns now last $|cr$|{seconds}#| seconds`
		end
		return true, `Turns last their usual time again`
	end

	local function wind(value: number)
		--[[ Executing ]]

		I.Match.SetWind(value)

		--[[ Returning ]]

		return true, `The wind is $|cr$|{I.Match.GetWind()}#| until the next turn`
	end

	local function round(value: number)
		--[[ Executing ]]

		I.Match.SetRound(value)

		--[[ Returning ]]

		return true, `The match is on round $|cr$|{math.max(math.round(value), 1)}#|`
	end

	local function win(invoker: Player | number, participantId: string?)
		--[[ Data ]]

		local id: string = participantId or `P_{if typeof(invoker) == "Instance" then invoker.UserId else invoker}`
		local winner = I.Match.GetParticipant(id) --- @type Match_Participant?

		--[[ Checks ]]

		-- Check if they play this match
		if not winner then
			return false, `$|cr$|{id}#| isn't in the match`
		end

		-- Check if snails are in play
		if not table.find({ "Turn", "Flight", "Settle" }, I.Match.GetPhase()) then
			return false, `Snails aren't in play yet (phase $|cr$|{I.Match.GetPhase()}#|)`
		end

		--[[ Knocking Out ]]

		local count: number = 0
		--- @param participant Match_Participant
		for _index: number, participant in ipairs(I.Match.GetParticipants()) do
			local model: Model? = I.Snails.Get(participant.Id)
			if participant.Team ~= winner.Team and model and model:GetAttribute("Alive") then
				I.Snails.Kill(participant.Id, "Command")
				count += 1
			end
		end
		I.Match.SkipTurn()

		--[[ Returning ]]

		return true, `Knocked out $|cr$|{count}#| snails, so $|cr$|{id}#|'s team wins after this turn`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Turns ]]

		{
			Aliases = { "skip" },
			Callback = skip,
		},
		{
			Aliases = { "time" },
			Args = {
				{ name = "seconds", types = { "number" } },
			},
			Callback = time,
		},

		--[[ Match ]]

		{
			Aliases = { "wind" },
			Args = {
				{ name = "wind", types = { "number" } },
			},
			Callback = wind,
		},
		{
			Aliases = { "round" },
			Args = {
				{ name = "round", types = { "number" } },
			},
			Callback = round,
		},
		{
			Aliases = { "win" },
			Args = {
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = win,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Match_Server", {
		Aliases = { "match" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
