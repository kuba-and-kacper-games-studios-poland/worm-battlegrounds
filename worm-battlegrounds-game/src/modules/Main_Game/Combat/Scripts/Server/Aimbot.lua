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
	Every AIMBOT_REFRESH seconds, solves the guide again for each player whose `Aimbot` attribute the server set (the
	admin `aimbot` command), and clears it for those whose aimbot went off.
]]
function Module._mainLoop()
	--[[ Looping ]]

	I.DoEvery.Every(_serverSettings.AIMBOT_REFRESH, function()
		for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
			local success: boolean
			local result: any | string?
			success, result = pcall(Module._updatePlayer, player)
			if not success then
				warn(`[{_localName}::{script.Name}]: Failed to update the aim guide for ({player.Name})! - ({result})`)
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Update Player

--[[
	Sends a player with the aimbot on, on their turn, the shot that lands on each enemy snail from their snail with the
	weapon it holds, once something moved; sends an empty guide when there's nothing to show.
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

	-- Check if it's the player's turn to aim, and clear a guide that was showing
	if not snail or not itemId or not snail.PrimaryPart or not I.Match.IsActivePlayer(player) or I.Match.GetPhase() ~= "Turn" then
		if lastKeys[player] then
			lastKeys[player] = nil
			I.Network.Fire("Combat_AimbotGuide", player, {})
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

	-- Check if anything moved since the last guide
	if key == lastKeys[player] then
		return
	end

	--[[ Solving ]]

	lastKeys[player] = key
	arcParams.FilterDescendantsInstances = { snail, effectsFolder }
	local guides = {} --- @type { Combat_AimGuide }
	for _index: number, target: Model in ipairs(targets) do
		local guide = Module._getGuide(origin, target, itemId, wind) --- @type Combat_AimGuide?
		if guide then
			table.insert(guides, guide)
		end
	end

	--[[ Sending ]]

	I.Network.Fire("Combat_AimbotGuide", player, guides)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Shot

--[[
	Returns the aim guide's shot from a participant's snail at an enemy snail with a weapon: the first that hits, else
	the first found; nil when no enemy is in play or the weapon isn't aimed.
]]
--- @return Combat_AimGuide?
function Module.GetShot(participantId: string, itemId: string)
	--[[ Data ]]

	local snail: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is in play
	if not snail or not snail.PrimaryPart then
		return nil
	end

	--[[ Local Variables ]]

	local origin: Vector3 = snail.PrimaryPart.Position
	local wind: number = I.G_Combat.GetWindAcceleration(itemId, I.Match.GetWind())
	local first = nil --- @type Combat_AimGuide?

	--[[ Solving ]]

	arcParams.FilterDescendantsInstances = { snail, effectsFolder }
	for _index: number, target: Model in ipairs(Module._getTargets(snail)) do
		local guide = Module._getGuide(origin, target, itemId, wind) --- @type Combat_AimGuide?
		if guide and guide.Hit then
			return guide
		end
		first = first or guide
	end

	--[[ Returning ]]

	return first
end

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

--%%%%%%%%%%%%%%%%%%%% Get Guide

--[[
	Returns the best shot at a target with a weapon: an arc weapon's angle and power whose path lands nearest it (an
	exact hit when one is open), a gun's straight line, or a homing shot's launch up toward its side; nil for weapons
	that aren't aimed.
]]
--- @return Combat_AimGuide?
function Module._getGuide(origin: Vector3, target: Model, itemId: string, wind: number)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Local Variables ]]

	local aimAt: Vector3 = target.PrimaryPart.Position
	local toTarget: Vector3 = aimAt - origin

	--[[ Guns ]]

	if row.Aim == "Straight" then
		local hit: RaycastResult? = I.S.Workspace:Raycast(origin, toTarget, arcParams)
		local reached: boolean = toTarget.Magnitude <= (row.Range or 60) and (not hit or hit.Instance:IsDescendantOf(target))
		local stop: Vector3 = if hit then hit.Position else aimAt
		return { Angle = math.atan2(toTarget.Y, toTarget.X), Power = nil, Points = { origin, stop }, Target = aimAt, Hit = reached }
	end

	--[[ Homing ]]

	-- Fired up toward the target's side, it steers itself (as the bots fire it)
	if row.Aim == "Target" then
		local angle: number = math.rad(if toTarget.X < 0 then 110 else 70)
		local points = Module._getPath(origin, angle, 0.7, itemId, wind, target) --- @type { Vector3 }
		return { Angle = angle, Power = 0.7, Points = points, Target = aimAt, Hit = true }
	end

	--[[ Checks ]]

	-- Check if it's an arc weapon
	if row.Aim ~= "Arc" then
		return nil
	end

	--[[ Solving ]]

	local best = nil --- @type Combat_AimGuide?
	local bestMiss: number = math.huge
	for _index: number, arc: Vector2 in ipairs(Arcs.GetArcs(origin, aimAt, itemId, wind, _serverSettings.AIMBOT_POWERS)) do
		local points = Module._getPath(origin, arc.X, arc.Y, itemId, wind, target) --- @type { Vector3 }
		local miss: number = (points[#points] - aimAt).Magnitude
		if miss < bestMiss then
			bestMiss = miss
			best = { Angle = arc.X, Power = arc.Y, Points = points, Target = aimAt, Hit = false }
		end
	end

	--[[ Returning ]]

	if best then
		best.Hit = bestMiss <= _serverSettings.AIMBOT_HIT_MARGIN
	end
	return best
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
