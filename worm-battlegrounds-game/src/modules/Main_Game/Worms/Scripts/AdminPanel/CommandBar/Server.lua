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

--- @class Worms_CommandBar_Server
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
	Registers the commands that hurt, heal, knock out and push worms by hand, for testing. Each one acts on the
	invoker's own worm unless it names a participant id.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Helper Functions

	local function getWorm(invoker: Player | number, participantId: string?)
		--[[ Local Variables ]]

		local userId: number = if typeof(invoker) == "Instance" then invoker.UserId else invoker
		local id: string = participantId or `P_{userId}`

		--[[ Returning ]]

		return id, I.Worms.Get(id)
	end

	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function damage(invoker: Player | number, amount: number, participantId: string?)
		--[[ Data ]]

		local id: string
		local model: Model?
		id, model = getWorm(invoker, participantId)

		--[[ Checks ]]

		-- Check if the worm is in play
		if not model or not model:GetAttribute("Alive") then
			return false, `No worm in play for $|cr$|{id}#|`
		end

		--[[ Executing ]]

		I.Worms.Damage(id, amount)

		--[[ Returning ]]

		return true, `$|cr$|{id}#| now has $|cr$|{model:GetAttribute("Health")}#| health`
	end

	local function heal(invoker: Player | number, amount: number, participantId: string?)
		--[[ Data ]]

		local id: string
		local model: Model?
		id, model = getWorm(invoker, participantId)

		--[[ Checks ]]

		-- Check if the worm is in play
		if not model or not model:GetAttribute("Alive") then
			return false, `No worm in play for $|cr$|{id}#|`
		end

		--[[ Executing ]]

		I.Worms.Heal(id, amount)

		--[[ Returning ]]

		return true, `$|cr$|{id}#| now has $|cr$|{model:GetAttribute("Health")}#| health`
	end

	local function kill(invoker: Player | number, participantId: string?)
		--[[ Data ]]

		local id: string
		local model: Model?
		id, model = getWorm(invoker, participantId)

		--[[ Checks ]]

		-- Check if the worm is in play
		if not model or not model:GetAttribute("Alive") then
			return false, `No worm in play for $|cr$|{id}#|`
		end

		--[[ Executing ]]

		I.Worms.Kill(id, "Command")

		--[[ Returning ]]

		return true, `Knocked out $|cr$|{id}#|`
	end

	local function push(invoker: Player | number, x: number, y: number, participantId: string?)
		--[[ Data ]]

		local id: string
		local model: Model?
		id, model = getWorm(invoker, participantId)

		--[[ Checks ]]

		-- Check if the worm is in play
		if not model or not model:GetAttribute("Alive") then
			return false, `No worm in play for $|cr$|{id}#|`
		end

		--[[ Executing ]]

		-- The push is a speed change, so it doesn't depend on the worm's mass
		I.Worms.Knockback(id, Vector3.new(x, y, 0) * model.PrimaryPart.AssemblyMass)

		--[[ Returning ]]

		return true, `Pushed $|cr$|{id}#| by $|cr$|{x}, {y}#| studs per second`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "damage" },
			Args = {
				{ name = "amount", types = { "number" } },
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = damage,
		},
		{
			Aliases = { "heal" },
			Args = {
				{ name = "amount", types = { "number" } },
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = heal,
		},
		{
			Aliases = { "kill" },
			Args = {
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = kill,
		},
		{
			Aliases = { "push" },
			Args = {
				{ name = "x", types = { "number" } },
				{ name = "y", types = { "number" } },
				{ name = "participantId", types = { "string" }, optional = true },
			},
			PassInvoker = true,
			Callback = push,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Worms_Server", {
		Aliases = { "worms" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
