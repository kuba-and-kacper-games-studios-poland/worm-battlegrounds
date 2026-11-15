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

--- @class Snails_CommandBar_Server
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
	Registers the commands that hurt, heal, knock out and push snails by hand, for testing. Each one acts on the
	invoker's own snail unless it names another by its name, its player's username or its id.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Get Snail

	--[[
		Returns the participant id, the name and the model of the snail a command acts on: the one it names (by its
		name, its player's username or its id), or the invoker's own; no model when it isn't in play.
	]]
	--- @return string, string, Model?
	local function getSnail(invoker: Player | number, snail: string?)
		--[[ Data ]]

		local query: string = snail or `P_{if typeof(invoker) == "Instance" then invoker.UserId else invoker}`
		local participant = I.Match.FindParticipant(query) --- @type Match_Participant?

		--[[ Returning ]]

		if participant then
			return participant.Id, participant.DisplayName, I.Snails.Get(participant.Id)
		end
		return query, query, nil
	end

	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function damage(invoker: Player | number, amount: number, snail: string?)
		--[[ Data ]]

		local id: string
		local name: string
		local model: Model?
		id, name, model = getSnail(invoker, snail)

		--[[ Checks ]]

		-- Check if the snail is in play
		if not model or not model:GetAttribute("Alive") then
			return false, `No snail $|cr$|{name}#| in play`
		end

		--[[ Executing ]]

		I.Snails.Damage(id, amount)

		--[[ Returning ]]

		return true, `$|cr$|{name}#| now has $|cr$|{model:GetAttribute("Health")}#| health`
	end

	local function heal(invoker: Player | number, amount: number, snail: string?)
		--[[ Data ]]

		local id: string
		local name: string
		local model: Model?
		id, name, model = getSnail(invoker, snail)

		--[[ Checks ]]

		-- Check if the snail is in play
		if not model or not model:GetAttribute("Alive") then
			return false, `No snail $|cr$|{name}#| in play`
		end

		--[[ Executing ]]

		I.Snails.Heal(id, amount)

		--[[ Returning ]]

		return true, `$|cr$|{name}#| now has $|cr$|{model:GetAttribute("Health")}#| health`
	end

	local function kill(invoker: Player | number, snail: string?)
		--[[ Data ]]

		local id: string
		local name: string
		local model: Model?
		id, name, model = getSnail(invoker, snail)

		--[[ Checks ]]

		-- Check if the snail is in play
		if not model or not model:GetAttribute("Alive") then
			return false, `No snail $|cr$|{name}#| in play`
		end

		--[[ Executing ]]

		I.Snails.Kill(id, "Command")

		--[[ Returning ]]

		return true, `Knocked out $|cr$|{name}#|`
	end

	local function push(invoker: Player | number, x: number, y: number, snail: string?)
		--[[ Data ]]

		local id: string
		local name: string
		local model: Model?
		id, name, model = getSnail(invoker, snail)

		--[[ Checks ]]

		-- Check if the snail is in play
		if not model or not model:GetAttribute("Alive") then
			return false, `No snail $|cr$|{name}#| in play`
		end

		--[[ Executing ]]

		-- The push is a speed change, so it doesn't depend on the snail's mass
		I.Snails.Knockback(id, Vector3.new(x, y, 0) * model.PrimaryPart:GetMass())

		--[[ Returning ]]

		return true, `Pushed $|cr$|{name}#| by $|cr$|{x}, {y}#| studs per second`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "damage" },
			Args = {
				{ name = "amount", types = { "number" } },
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = damage,
		},
		{
			Aliases = { "heal" },
			Args = {
				{ name = "amount", types = { "number" } },
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = heal,
		},
		{
			Aliases = { "kill" },
			Args = {
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = kill,
		},
		{
			Aliases = { "push" },
			Args = {
				{ name = "x", types = { "number" } },
				{ name = "y", types = { "number" } },
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = push,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Snails_Server", {
		Aliases = { "snails" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
