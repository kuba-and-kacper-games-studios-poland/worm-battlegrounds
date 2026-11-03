--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Fall_Controller"

--- @type Fall_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace = I.S.Workspace
local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local destinationResolver: ((player: Player) -> CFrame?)?

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	--[[ Small Height Warning ]]

	if Workspace.FallenPartsDestroyHeight > -10000 then
		warn(`[{_localName}::{script.Name}]: Please change the (FallenPartsDestroyHeight) property of (workspace) to a number under (-10000)!`)
	end

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Fall_Controller_Fell", { "Player", "Model" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Fall_Controller = {

		--[[ Control ]]

		SetDestinationResolver = Module.SetDestinationResolver,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._mainLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Checks every character's height each `CHECK_INTERVAL` seconds.
]]
function Module._mainLoop()
	--[[ Connections ]]

	I.DoEvery.Get(_settings.CHECK_INTERVAL):Connect(function()
		for _, player: Player in ipairs(Players:GetPlayers()) do
			local success: boolean
			local result: any | string?
			success, result = pcall(Module._checkPlayer, player)
			if not success then
				warn(`[{_localName}::{script.Name}]: Failed to check fall for ({player.Name})! - ({result})`)
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Destination Resolver

--[[
	**SERVER** |
	Sets the function that picks where a fallen player is moved; when it returns nil
	(or no function is set) the player goes to the top of their `RespawnLocation`.
]]
function Module.SetDestinationResolver(callback: ((player: Player) -> CFrame?)?)
	--[[ Saving ]]

	destinationResolver = callback
end

--%%%%%%%%%%%%%%%%%%%% Check Player

--[[
	Moves the player's character back when it is below `MIN_POSITION`,
	then publishes `Fall_Controller_Fell`.
]]
function Module._checkPlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	local character: Model? = player.Character

	-- Skip players without a character
	if not character then
		return
	end

	-- Skip characters above the minimum height
	if character:GetPivot().Position.Y > _settings.MIN_POSITION then
		return
	end

	--[[ Finding Destination ]]

	local respawnLocation: SpawnLocation? = player.RespawnLocation
	local destination: CFrame? = if destinationResolver then destinationResolver(player) else nil

	-- Fall back to the top surface of the RespawnLocation, then the origin
	if not destination then
		destination = if respawnLocation then respawnLocation.CFrame * CFrame.new(0, respawnLocation.Size.Y / 2, 0) else CFrame.new(0, 0, 0)
	end

	--[[ Teleporting ]]

	I.World.MoveCharacterToPosition(character, destination)

	--[[ Publishing ]]

	I.Topic.Publish("Fall_Controller_Fell", player, character)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
