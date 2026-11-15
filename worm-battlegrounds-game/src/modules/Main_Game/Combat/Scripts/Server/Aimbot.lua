--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--- @type Combat_ServerSettings
local _serverSettings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Arcs = require(script.Parent:FindFirstChild("Arcs")) --- @type Combat_Server_Arcs

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local effectsFolder: Instance

-- What each player's guide was last solved for, so it's sent again only when something moved
local lastKeys = {} --- @type { [Player]: string }

-- Casts that see what shots hit: terrain and snails in play
local arcParams: RaycastParams = RaycastParams.new()

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

--- @class Combat_Server_Aimbot
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Local Variables ]]

	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)
	arcParams.CollisionGroup = "Projectile"
	arcParams.FilterType = Enum.RaycastFilterType.Exclude

	--[[ Connections ]]

	I.S.Players.PlayerRemoving:Connect(function(player: Player)
		lastKeys[player] = nil
	end)

	--[[ Starting ]]

	Module._mainLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Every AIMBOT_REFRESH seconds, finds again the snails each player whose `Aimbot` attribute the server set (the admin
	`aimbot` command) can hit, and clears them for those whose aimbot went off.
]]
function Module._mainLoop()
	--[[ Looping ]]

	I.DoEvery.Every(_serverSettings.AIMBOT_REFRESH, function()
		for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
			local success: boolean
			local result: any | string?
			success, result = pcall(Module._updatePlayer, player)
			if not success then
				warn(`[{_localName}::{script.Name}]: Failed to update the aimbot for ({player.Name})! - ({result})`)
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Update Player

--[[
	Sends a player with the aimbot on, on their turn, the enemy snails a shot with the weapon their snail holds would
	hurt, once something moved; sends an empty list when there's nothing to show.
]]
function Module._updatePlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local snail: Model? = if player:GetAttribute("Aimbot") then I.Snails.Get(`P_{player.UserId}`) else nil
	local itemId: string? = snail and snail:GetAttribute("HeldItem")

	--[[ Checks ]]

	-- Check if it's the player's turn to aim with a weapon, and clear the marks that were showing
	if not snail or not itemId or I.G_Arsenal.IsUtility(itemId) or not snail.PrimaryPart or not I.Match.IsActivePlayer(player) or I.Match.GetPhase() ~= "Turn" then
		if lastKeys[player] then
			lastKeys[player] = nil
			I.Network.Fire("Combat_AimbotTargets", player, {})
		end
		return
	end

	--[[ Local Variables ]]

	local origin: Vector3 = snail.PrimaryPart.Position
	local wind: number = I.G_Combat.GetWindAcceleration(itemId, I.Match.GetWind())
	local targets = Module._getTargets(snail) --- @type { Model }
	local key: string = `{itemId} {wind} {Module._getKey(origin)}`
	for _index: number, target: Model in ipairs(targets) do
		key ..= ` {Module._getKey(target.PrimaryPart.Position)}`
	end

	--[[ Checks ]]

	-- Check if anything moved since the last list
	if key == lastKeys[player] then
		return
	end

	--[[ Solving ]]

	lastKeys[player] = key
	arcParams.FilterDescendantsInstances = { snail, effectsFolder }
	local hittable = {} --- @type { Model }
	for _index: number, target: Model in ipairs(targets) do
		if Module._canHit(snail, target, itemId, wind) then
			table.insert(hittable, target)
		end
	end

	--[[ Sending ]]

	I.Network.Fire("Combat_AimbotTargets", player, hittable)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Targets

--[[
	Returns the snails in play on another team than the player's.
]]
--- @return { Model }
function Module._getTargets(snail: Model)
	--[[ Local Variables ]]

	local targets = {} --- @type { Model }
	local team: number? = snail:GetAttribute("Team")

	--[[ Searching ]]

	for _index: number, model: Instance in ipairs(snail.Parent:GetChildren()) do
		if model:IsA("Model") and model ~= snail and model.PrimaryPart and model:GetAttribute("Alive") and not model:GetAttribute("Ghost") and model:GetAttribute("Team") ~= team then
			table.insert(targets, model)
		end
	end

	--[[ Returning ]]

	return targets
end

--%%%%%%%%%%%%%%%%%%%% Can Hit

--[[
	Returns whether some aim with a weapon hurts a target, as the bots foresee a shot (I.Bots.GetShotHits: bounces,
	fuses, bomblets, crawls and blasts included). An arc weapon tries the arcs from GetArcs at AIMBOT_POWERS whose
	paths first touch nearest the target, AIMBOT_SIMULATED of them; a gun or a swing aims straight at it, and a homing
	shot is fired up toward its side (as the bots fire it). A weapon placed at the feet hits nothing here.
]]
--- @return boolean
function Module._canHit(snail: Model, target: Model, itemId: string, wind: number)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Local Variables ]]

	local origin: Vector3 = snail.PrimaryPart.Position
	local aimAt: Vector3 = target.PrimaryPart.Position
	local toTarget: Vector3 = aimAt - origin

	-- Each aim's angle (X), power (Y) and, for arcs, how far from the target its path first touches (Z)
	local aims = {} --- @type { Vector3 }

	--[[ Aiming ]]

	if row.Aim == "Arc" then
		for _index: number, arc: Vector2 in ipairs(Arcs.GetArcs(origin, aimAt, itemId, wind, _serverSettings.AIMBOT_POWERS)) do
			local points = Module._getPath(origin, arc.X, arc.Y, itemId, wind, target) --- @type { Vector3 }
			table.insert(aims, Vector3.new(arc.X, arc.Y, (points[#points] - aimAt).Magnitude))
		end
		table.sort(aims, function(a: Vector3, b: Vector3): boolean
			return a.Z < b.Z
		end)
	elseif row.Aim == "Target" then
		table.insert(aims, Vector3.new(math.rad(if toTarget.X < 0 then 110 else 70), 0.7, 0))
	elseif row.Aim == "Straight" or row.Aim == "Melee" then
		table.insert(aims, Vector3.new(math.atan2(toTarget.Y, toTarget.X), 1, 0))
	end

	--[[ Predicting ]]

	for index: number = 1, math.min(#aims, _serverSettings.AIMBOT_SIMULATED) do
		local hits = I.Bots.GetShotHits(snail, itemId, aims[index].X, aims[index].Y, aimAt) --- @type { [string]: number }?
		if hits and hits[target.Name] then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Get Path

--[[
	Returns the points an arc shot passes through from the snail's muzzle until it first touches terrain or a snail
	(the target's middle when that's what it touches), or the end of AIMBOT_ARC_SECONDS.
]]
--- @return { Vector3 }
function Module._getPath(origin: Vector3, angle: number, power: number, itemId: string, wind: number, target: Model)
	--[[ Local Variables ]]

	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
	local muzzle: number = I.Settings["Snails"].ROOT_SIZE / 2 + _settings.MUZZLE_GAP
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(itemId, angle, power)
	local points = Arcs.PredictArc(origin + direction * muzzle, velocity, wind, _serverSettings.AIMBOT_ARC_SECONDS, _serverSettings.AIMBOT_ARC_STEP) --- @type { Vector3 }

	--[[ Searching ]]

	for index: number = 2, #points do
		local hit: RaycastResult? = I.S.Workspace:Raycast(points[index - 1], points[index] - points[index - 1], arcParams)
		if hit then
			local path = table.move(points, 1, index - 1, 1, {}) --- @type { Vector3 }
			table.insert(path, if hit.Instance:IsDescendantOf(target) then target.PrimaryPart.Position else hit.Position)
			return path
		end
	end

	--[[ Returning ]]

	return points
end

--%%%%%%%%%%%%%%%%%%%% Get Key

--[[
	Returns a position rounded to a quarter stud as text, so the guide is solved again only after a real move.
]]
--- @return string
function Module._getKey(position: Vector3)
	return `{math.round(position.X * 4)},{math.round(position.Y * 4)}`
end

return Module
