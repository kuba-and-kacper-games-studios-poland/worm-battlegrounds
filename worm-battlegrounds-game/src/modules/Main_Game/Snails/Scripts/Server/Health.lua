--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Bodies = require(script.Parent:FindFirstChild("Bodies")) --- @type Snails_Server_Bodies
local Flight = require(script.Parent:FindFirstChild("Flight")) --- @type Snails_Server_Flight

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Who last hurt or pushed each snail, and with what, for kill credit
local lastAttackers = {} --- @type { [string]: string }
local lastItems = {} --- @type { [string]: string }

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

--- @class Snails_Server_Health
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Registry ]]

	I.Topic.Register("Snails_Died", {
		"string",
		"string",
		{ Type = "string", Optional = true },
		{ Type = "string", Optional = true },
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Damage

--[[
	**SERVER** |
	Takes health from a snail, rounded to a whole number and never below 0, and remembers who did it for kill credit.
	A snail at 0 stays in play until the match knocks it out once the shot settles.
]]
function Module.Damage(participantId: string, amount: number, sourceId: string?, itemId: string?)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)
	local damage: number = math.round(amount)

	--[[ Checks ]]

	-- Check if the snail is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	-- Check if the damage hurts
	if damage <= 0 then
		return
	end

	--[[ Saving ]]

	Module._setAttacker(participantId, sourceId, itemId)
	model:SetAttribute("Health", math.max(model:GetAttribute("Health") - damage, 0))
end

--%%%%%%%%%%%%%%%%%%%% Heal

--[[
	**SERVER** |
	Gives a snail health, rounded to a whole number and never above its MaxHealth.
]]
function Module.Heal(participantId: string, amount: number)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)
	local heal: number = math.round(amount)

	--[[ Checks ]]

	-- Check if the snail is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	-- Check if the heal adds health
	if heal <= 0 then
		return
	end

	--[[ Saving ]]

	model:SetAttribute("Health", math.min(model:GetAttribute("Health") + heal, model:GetAttribute("MaxHealth")))
end

--%%%%%%%%%%%%%%%%%%%% Knockback

--[[
	**SERVER** |
	Throws a snail with an impulse (its mass times the speed it adds), on the game's own physics (Flight), and remembers
	who did it for kill credit.
]]
function Module.Knockback(participantId: string, impulse: Vector3, sourceId: string?, itemId: string?)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	--[[ Applying ]]

	Module._setAttacker(participantId, sourceId, itemId)
	Flight.Throw(model, impulse / model.PrimaryPart.AssemblyMass)
end

--%%%%%%%%%%%%%%%%%%%% Kill

--[[
	**SERVER** |
	Knocks a snail out: it becomes a ghost that touches nothing (each screen draws it floating up and fading away), its
	player's screen streams the arena around their parked avatar again, and Snails_Died is published with the cause ("Water", "Lava", "Bounds", a weapon's cause), the killer and the item, falling back on whoever last
	hurt or pushed it.
]]
function Module.Kill(participantId: string, cause: string, sourceId: string?)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local killerId: string? = sourceId or lastAttackers[participantId]
	local itemId: string? = if sourceId then nil else lastItems[participantId]

	--[[ Saving ]]

	-- Out before its health drops, so a screen that hears the health change already sees a ghost
	model:SetAttribute("Alive", false)
	model:SetAttribute("Ghost", true)
	model:SetAttribute("Health", 0)

	--[[ Ghost ]]

	-- A ball flying a throw is anchored already, with no owner
	if not root.Anchored then
		root:SetNetworkOwner(nil)
	end
	root.Anchored = true
	root.CollisionGroup = "Ghost"
	root:FindFirstChild("Walk").Enabled = false

	--[[ Streaming ]]

	-- Its player watches on: the arena streams around their parked avatar again (by every map, at X 0), not the ghost's ball
	local player: Player? = I.S.Players:GetPlayerByUserId(model:GetAttribute("UserId") or 0)
	if player then
		player.ReplicationFocus = nil
	end

	--[[ Publishing ]]

	I.Topic.Publish("Snails_Died", participantId, cause, killerId, itemId)
end

--%%%%%%%%%%%%%%%%%%%% Set Attacker

--[[
	Remembers who last hurt or pushed a snail, and with what, unless it did so itself; bots read who in its LastAttacker
	attribute.
]]
function Module._setAttacker(participantId: string, sourceId: string?, itemId: string?)
	--[[ Checks ]]

	-- Skip hits with no source, and snails hurting themselves
	if not sourceId or sourceId == participantId then
		return
	end

	--[[ Saving ]]

	lastAttackers[participantId] = sourceId
	lastItems[participantId] = itemId
	Bodies.Get(participantId):SetAttribute("LastAttacker", sourceId)
end

return Module
