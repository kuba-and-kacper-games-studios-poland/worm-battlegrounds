--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Worms"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Bodies = require(_scripts:FindFirstChild("Server"):FindFirstChild("Bodies")) --- @type Worms_Server_Bodies
local Health = require(_scripts:FindFirstChild("Server"):FindFirstChild("Health")) --- @type Worms_Server_Health
local Hazards = require(_scripts:FindFirstChild("Server"):FindFirstChild("Hazards")) --- @type Worms_Server_Hazards

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

	Bodies.Init()
	Health.Init()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Worms = {

		--[[ Control ]]

		Spawn = Bodies.Spawn,
		Damage = Health.Damage,
		Heal = Health.Heal,
		Knockback = Health.Knockback,
		Kill = Health.Kill,
		SetOwner = Bodies.SetOwner,
		Clear = Bodies.Clear,

		--[[ Methods ]]

		Get = Bodies.Get,
		GetAll = Bodies.GetAll,
		GetAlive = Bodies.GetAlive,
		IsGrounded = Module.IsGrounded,
		IsSettled = Bodies.IsSettled,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Hazards.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Grounded

--[[
	**SERVER** |
	Returns whether a participant's worm stands on something.
]]
--- @return boolean
function Module.IsGrounded(participantId: string)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)
	if not model then
		return false
	end

	--[[ Returning ]]

	return Hazards.IsGrounded(model.PrimaryPart.Position)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
