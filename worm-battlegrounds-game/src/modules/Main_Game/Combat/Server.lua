--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Uses = require(_scripts:FindFirstChild("Server"):FindFirstChild("Uses")) --- @type Combat_Server_Uses
local Projectiles = require(_scripts:FindFirstChild("Server"):FindFirstChild("Projectiles")) --- @type Combat_Server_Projectiles
local Blast = require(_scripts:FindFirstChild("Server"):FindFirstChild("Blast")) --- @type Combat_Server_Blast
local Fire = require(_scripts:FindFirstChild("Server"):FindFirstChild("Fire")) --- @type Combat_Server_Fire
local Roller = require(_scripts:FindFirstChild("Server"):FindFirstChild("Behaviors"):FindFirstChild("Roller")) --- @type Combat_Roller
local Arcs = require(_scripts:FindFirstChild("Server"):FindFirstChild("Arcs")) --- @type Combat_Server_Arcs
local Aimbot = require(_scripts:FindFirstChild("Server"):FindFirstChild("Aimbot")) --- @type Combat_Server_Aimbot

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

	Projectiles.Init()
	Uses.Init()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Combat_ShotFired", { "string", "string" })
	I.Topic.Register("Combat_ShotResolved", { "string", "number" })

	--- @Network
	I.Network.GetEvent("Combat_Select", { "Player", "string" }, { RateLimit = 10 })
	I.Network.Fired("Combat_Select", Fire._onSelect)
	I.Network.GetEvent("Combat_Fire", { "Player", "string", "number", { Type = "number", Min = 0, Max = 1 }, { Type = "Vector3", Optional = true } }, { RateLimit = 2 })
	I.Network.Fired("Combat_Fire", Fire._onFire)
	I.Network.GetEvent("Combat_UseUtility", { "Player", "string" }, { RateLimit = 2 })
	I.Network.Fired("Combat_UseUtility", Fire._onUseUtility)
	I.Network.GetEvent("Combat_Detonate", { "Player" }, { RateLimit = 2 })
	I.Network.Fired("Combat_Detonate", Fire._onDetonate)
	I.Network.GetUEvent("Combat_Aim", { "Player", "number", "number" }, { RateLimit = 15 })
	I.Network.UFired("Combat_Aim", Fire._onAim)

	I.Network.GetEvent("Combat_Explosion")
	I.Network.GetEvent("Combat_Hit")
	I.Network.GetEvent("Combat_Tracer")
	I.Network.GetEvent("Combat_AimbotGuide")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Combat = {

		--[[ Control ]]

		Fire = Fire.Fire,
		UseUtility = Fire.UseUtility,
		ShowAim = Fire.ShowAim,
		Detonate = Roller.Detonate,
		Explode = Blast.Explode,
		Hit = Blast.Hit,
		Give = Uses.Give,
		Refill = Uses.Refill,

		--[[ Methods ]]

		CanUse = Uses.CanUse,
		GetUses = Uses.GetUses,
		IsIdle = Fire.IsIdle,
		GetArcs = Arcs.GetArcs,
		PredictArc = Arcs.PredictArc,
		GetShotStart = Projectiles.GetStart,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Uses.Start()
	Aimbot.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
