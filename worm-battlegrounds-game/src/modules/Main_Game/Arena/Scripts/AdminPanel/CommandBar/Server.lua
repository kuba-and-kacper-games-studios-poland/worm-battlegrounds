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

--- @class Arena_CommandBar_Server
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
	Registers the commands that load a map and carve the arena by hand, for testing.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function load(mapId: string)
		--[[ Executing ]]

		local value: boolean = I.Arena.Load(mapId)

		--[[ Returning ]]

		if value then
			return true, `Loaded map $|cr$|{mapId}#|`
		end
		return false, `Failed to load map $|cr$|{mapId}#|`
	end

	local function carve(x: number, y: number, radius: number)
		--[[ Checks ]]

		if radius <= 0 then
			return false, `Invalid radius: $|cr$|{radius}#| must be above $|cr$|0#|`
		end

		--[[ Executing ]]

		I.Arena.Carve(Vector3.new(x, y, 0), radius)

		--[[ Returning ]]

		return true, `Carved a $|cr$|{radius}#| stud hole at $|cr$|{x}, {y}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "load" },
			Args = {
				{ name = "mapId", types = { "string" } },
			},
			Callback = load,
		},
		{
			Aliases = { "carve" },
			Args = {
				{ name = "x", types = { "number" } },
				{ name = "y", types = { "number" } },
				{ name = "radius", types = { "number" } },
			},
			Callback = carve,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Arena_Server", {
		Aliases = { "arena" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
