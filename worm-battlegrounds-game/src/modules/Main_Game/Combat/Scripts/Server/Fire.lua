--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Uses = require(script.Parent:FindFirstChild("Uses")) --- @type Combat_Server_Uses
local Projectiles = require(script.Parent:FindFirstChild("Projectiles")) --- @type Combat_Server_Projectiles
local Rocket = require(script.Parent:FindFirstChild("Behaviors"):FindFirstChild("Rocket")) --- @type Combat_Rocket
local Bouncer = require(script.Parent:FindFirstChild("Behaviors"):FindFirstChild("Bouncer")) --- @type Combat_Bouncer
local Crawler = require(script.Parent:FindFirstChild("Behaviors"):FindFirstChild("Crawler")) --- @type Combat_Crawler
local Homing = require(script.Parent:FindFirstChild("Behaviors"):FindFirstChild("Homing")) --- @type Combat_Homing
local Roller = require(script.Parent:FindFirstChild("Behaviors"):FindFirstChild("Roller")) --- @type Combat_Roller
local Hitscan = require(script.Parent:FindFirstChild("Behaviors"):FindFirstChild("Hitscan")) --- @type Combat_Hitscan
local Melee = require(script.Parent:FindFirstChild("Behaviors"):FindFirstChild("Melee")) --- @type Combat_Melee

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Each weapon kind's behavior, by the Kind its row names
--- @type { [string]: Combat_Behavior }
local behaviors = { Rocket = Rocket, Bouncer = Bouncer, Crawler = Crawler, Homing = Homing, Roller = Roller, Hitscan = Hitscan, Melee = Melee }

-- Shots still running their behavior
local running: number = 0

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

--- @class Combat_Server_Fire
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% On Fire

--[[
	A player's fire request: fires their snail's weapon when it's their turn.
]]
function Module._onFire(player: Player, itemId: string, angle: number, power: number, target: Vector3?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if it's their turn, not a bot's in their place
	if not I.Match.IsActivePlayer(player) then
		return
	end

	--[[ Firing ]]

	Module.Fire(`P_{player.UserId}`, itemId, angle, power, target)
end

--%%%%%%%%%%%%%%%%%%%% On Use Utility

--[[
	A player's utility request: uses it on their snail when it's their turn.
]]
function Module._onUseUtility(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if it's their turn, not a bot's in their place
	if not I.Match.IsActivePlayer(player) then
		return
	end

	--[[ Using ]]

	Module.UseUtility(`P_{player.UserId}`, itemId)
end

--%%%%%%%%%%%%%%%%%%%% On Detonate

--[[
	A player's request to blow up their rolling black hole grenade.
]]
function Module._onDetonate(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if it's their turn, not a bot's in their place
	if not I.Match.IsActivePlayer(player) then
		return
	end

	--[[ Detonating ]]

	Roller.Detonate(`P_{player.UserId}`)
end

--%%%%%%%%%%%%%%%%%%%% On Select

--[[
	A player picked an item in their loadout bar: their snail holds it, for everyone to see.
]]
function Module._onSelect(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local model: Model? = I.Snails.Get(`P_{player.UserId}`)

	--[[ Checks ]]

	-- Check if the item is in their loadout
	if not model or Uses.GetUses(model.Name, itemId) == nil then
		return
	end

	-- Check if a bot isn't playing their snail's turn
	if I.Match.GetActive() == model.Name and I.Match.IsAutopilot() then
		return
	end

	--[[ Saving ]]

	model:SetAttribute("HeldItem", itemId)
end

--%%%%%%%%%%%%%%%%%%%% On Aim

--[[
	The active player's aim, sent ten times a second while they aim: shown on their snail for everyone.
]]
function Module._onAim(player: Player, angle: number, power: number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if it's their turn
	if not I.Match.IsActivePlayer(player) then
		return
	end

	--[[ Showing ]]

	Module.ShowAim(`P_{player.UserId}`, nil, angle, power)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Fire

--[[
	**SERVER** |
	Fires a participant's weapon (players through their remote, bots directly): checks it's their turn and they may
	use it, takes a use, takes their snail back (or, for a weapon with a Retreat, lets it run first), ends their turn,
	runs the weapon, and publishes Combat_ShotResolved with the damage it dealt once everything it spawned is done. `angle` is in radians (0 is right, counterclockwise);
	`target` is for the homing missile. Returns whether it fired.
]]
--- @return boolean
function Module.Fire(participantId: string, itemId: string, angle: number, power: number, target: Vector3?)
	--[[ Data ]]

	local participant = I.Match.GetParticipant(participantId) --- @type Match_Participant?
	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if it's this snail's turn
	if not participant or not model or I.Match.GetActive() ~= participantId or I.Match.GetPhase() ~= "Turn" then
		return false
	end

	-- Check if it's a weapon they may fire now
	if not I.G_Arsenal.IsWeapon(itemId) or not Uses.CanUse(participantId, itemId) then
		return false
	end

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	-- Check if a homing missile has a target
	if row.Aim == "Target" and not target then
		return false
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
	local facing: number = if direction.X < 0 then -1 else 1

	--[[ Taking ]]

	-- A weapon with a Retreat leaves the snail its turn a while longer, to run from it; any other ends it now
	Uses.Take(participantId, itemId)
	if row.Retreat then
		I.SnailControl.Retreat(participantId, row.Retreat)
	else
		I.SnailControl.EndTurn(participantId)
	end
	root:FindFirstChild("Upright").CFrame = CFrame.lookAlong(Vector3.zero, Vector3.xAxis * facing)
	model:SetAttribute("Facing", facing)

	-- The shot is away: everyone's aim line for it goes
	model:SetAttribute("AimTime", 0)

	--- @type Combat_Shot
	local shot = {
		ParticipantId = participantId,
		ItemId = itemId,
		Row = row,
		Shiny = Module._isShiny(participant, itemId),
		-- A weapon placed at the feet starts inside the snail's ball, so a wall in front can't swallow it
		Origin = if row.Aim == "Feet" then root.Position else Projectiles.GetStart(root.Position, direction, model),
		Direction = direction,
		Angle = angle,
		Power = math.clamp(power, 0, 1),
		Facing = facing,
		Target = if target then Vector3.new(target.X, target.Y, 0) else nil,
		Damage = 0,
		Shooter = model,
	}

	--[[ Publishing ]]

	I.Topic.Publish("Combat_ShotFired", participantId, itemId)
	Module._playSound(`Fire_{itemId}`, shot.Origin)

	--[[ Running ]]

	running += 1
	task.spawn(function()
		local success: boolean
		local result: any | string?
		success, result = pcall(behaviors[row.Kind].Run, shot)
		if not success then
			warn(`[{_localName}::{script.Name}]: Shot ({itemId}) by ({participantId}) failed! - ({result})`)
		end
		running -= 1
		I.Topic.Publish("Combat_ShotResolved", participantId, shot.Damage)
	end)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Use Utility

--[[
	**SERVER** |
	Uses a utility from a participant's loadout on their snail during their turn, which goes on: a heal, or a movement
	effect. Returns whether it was used.
]]
--- @return boolean
function Module.UseUtility(participantId: string, itemId: string)
	--[[ Data ]]

	--- @type Match_Participant?
	local participant = I.Match.GetParticipant(participantId)

	--[[ Checks ]]

	-- Check if it's this snail's turn
	if not participant or I.Match.GetActive() ~= participantId or I.Match.GetPhase() ~= "Turn" then
		return false
	end

	-- Check if it's a utility they may use now
	if not I.G_Arsenal.IsUtility(itemId) or not Uses.CanUse(participantId, itemId) then
		return false
	end

	--[[ Local Variables ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_UtilityData
	local shiny: boolean = Module._isShiny(participant, itemId)

	--[[ Applying ]]

	if row.Effect == "Heal" then
		I.Snails.Heal(participantId, if shiny then row.ShinyAmount or row.Amount or 0 else row.Amount or 0)
	elseif not I.SnailControl.ApplyEffect(participantId, row.Effect, shiny) then
		return false
	end
	Uses.Take(participantId, itemId)
	Module._playSound(`Use_{itemId}`, I.Snails.Get(participantId).PrimaryPart.Position)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Show Aim

--[[
	**SERVER** |
	Shows a snail's aim to every player: its angle and power, stamped with the server time (AimTime) so clients draw
	its aim line while the stamps keep coming. `itemId`, when given, is the weapon it holds.
]]
function Module.ShowAim(participantId: string, itemId: string?, angle: number, power: number)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is still in play
	if not model then
		return
	end

	--[[ Saving ]]

	if itemId then
		model:SetAttribute("HeldItem", itemId)
	end

	-- A bot's snail turns to face its aim (a player's own screen turns theirs), so its weapon never points back through it
	local side: number = math.sign(math.cos(angle))
	if (model:GetAttribute("IsBot") or I.Match.IsAutopilot()) and side ~= 0 then
		model.PrimaryPart:FindFirstChild("Upright").CFrame = CFrame.lookAlong(Vector3.zero, Vector3.xAxis * side)
		model:SetAttribute("Facing", side)
	end
	model:SetAttribute("AimAngle", angle)
	model:SetAttribute("AimPower", math.clamp(power, 0, 1))
	model:SetAttribute("AimTime", I.S.Workspace:GetServerTimeNow())
end

--%%%%%%%%%%%%%%%%%%%% Play Sound

--[[
	Has every player hear a weapon's or utility's sound where it was used (SoundsList's Fire_<itemId> and
	Use_<itemId>), within Combat's sound range.
]]
function Module._playSound(name: string, position: Vector3)
	I.Sound.PlayForAll({
		Name = name,
		Location = position,
		SoundGroup = "SFX",
		RollOffMin = _settings.SOUND_ROLLOFF_MIN,
		RollOffMax = _settings.SOUND_ROLLOFF_MAX,
		PitchMin = 0.95,
		PitchMax = 1.05,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Idle

--[[
	**SERVER** |
	Returns whether no shot is running and no projectile is in flight.
]]
--- @return boolean
function Module.IsIdle()
	return running == 0 and Projectiles.GetActive() == 0
end

--%%%%%%%%%%%%%%%%%%%% Is Shiny

--[[
	Returns whether a participant's copy of an item is shiny (10 copies owned).
]]
--- @param participant Match_Participant
--- @return boolean
function Module._isShiny(participant, itemId: string)
	return participant.ShinyItems ~= nil and participant.ShinyItems[itemId] == true
end

return Module
